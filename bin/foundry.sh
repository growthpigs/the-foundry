#!/usr/bin/env bash
# The Foundry — Autonomous Pipeline Orchestrator
# Canonical repo: growthpigs/the-foundry
# PAI System-Level — applies to ALL projects
#
# Usage:
#   ./foundry.sh #123                         # Auto-detect mode from labels
#   ./foundry.sh --mode GREENFIELD #123       # Force GREENFIELD mode
#   ./foundry.sh --mode FIX #123              # Force FIX mode
#   ./foundry.sh --defcon #123                # Emergency HOTFIX mode
#   ./foundry.sh --gated #123                 # Add human checkpoints
#   ./foundry.sh --dry-run #123               # Show plan without executing
#
# Can run from bare terminal OR inside Claude Code (CLAUDECODE guard auto-unsets).

set -euo pipefail

# ─────────────────────────────────────────────────
# CONSTANTS
# ─────────────────────────────────────────────────

VERSION="2.5.3"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$SCRIPT_DIR"
GLOBAL_COMMANDS="$HOME/.claude/commands"
SE_SKILLS="$HOME/.claude/skills/software-engineer/skills"
DARK_FOUNDRY_DIR=".foundry"
MAX_RETRIES_PER_STAGE=3
MAX_RETRIES_TOTAL=50
TOTAL_RETRIES=0

# Default budgets per stage (USD)
# Using functions instead of declare -A for Bash 3.2 compatibility (macOS ships 3.2)
# Budget philosophy (v2.5): MAX subscription = flat rate, not pay-per-token.
# These are GUARDRAILS against runaway loops, NOT cost controls.
# A stage that needs $3 shouldn't be killed at $3 — it should have $10 headroom.
# If a stage actually burns $15+, something is genuinely wrong (infinite loop, etc).
get_stage_budget() {
  case "$1" in
    issue)               echo 5 ;;
    user-stories)        echo 5 ;;
    explore)             echo 10 ;;
    issue-review)        echo 10 ;;
    red-team)            echo 10 ;;
    red-team-quick)      echo 10 ;;
    red-team-spec)       echo 10 ;;
    red-team-compliance) echo 10 ;;
    anti-regression)     echo 5 ;;
    code)                echo 15 ;;
    validate)            echo 10 ;;
    e2e)                 echo 15 ;;
    pr)                  echo 10 ;;
    pr-review)           echo 10 ;;
    compliance)          echo 10 ;;
    follow-up)           echo 10 ;;
    fsd)                 echo 15 ;;
    autoresearch)        echo 15 ;;
    *)                   echo 10 ;;  # default fallback
  esac
}

# Constitution files — core (12KB) loaded every stage, full (86KB) only for ASSAY/CRUCIBLE
CONSTITUTION_CORE="$SCRIPT_DIR/CONSTITUTION-CORE.md"
CONSTITUTION_FULL="$SCRIPT_DIR/CONSTITUTION.md"
CONSTITUTION_FILE="$CONSTITUTION_CORE"  # default to core; overridden per stage below

# Progressive-disclosure tiering (#73): CLIENT-tier articles are stripped for
# internal projects per the Loading Map in CONSTITUTION.md.
# DEFENSIVE SOURCE: a missing lib must NOT brick the orchestrator (it runs under
# 'set -euo pipefail', where a bare failed source aborts at startup — strictly
# worse than the pre-#73 warn-and-continue behavior). If the lib is absent or
# fails to load, fall back to full-constitution loading (old behavior) with a
# warning; the pipeline still runs, just without tier stripping.
if [ -f "$SCRIPT_DIR/bin/lib/constitution-loader.sh" ] \
   && . "$SCRIPT_DIR/bin/lib/constitution-loader.sh"; then
  :
else
  echo "[WARN] constitution-loader.sh missing/failed — CLIENT-tier stripping disabled; loading full constitution (safe: more rules, never fewer)." >&2
  foundry_project_type() { printf 'client'; }
  load_constitution() { cat "$1"; }
fi

# Permission tiers — CC3 F1 fix (Via Negativa: remove permissions you don't need)
# Read-only stages run WITHOUT --dangerously-skip-permissions (safe default).
# Write stages (code, validate, e2e, pr, fsd) get full permissions.
stage_needs_write() {
  case "$1" in
    code|pr|fsd|follow-up|autoresearch) return 0 ;;  # true — needs write permissions
    *)                                  return 1 ;;  # false — read-only
  esac
}

has_npm_script() {
  node -e "const p=require('./package.json'); process.exit(p.scripts && p.scripts[process.argv[1]] ? 0 : 1)" "$1" 2>/dev/null
}

run_npm_script_if_present() {
  local script_name="$1"
  local label="$2"
  local output_file="$3"
  local tail_lines="${4:-8}"

  if has_npm_script "$script_name"; then
    echo "Command: npm run ${script_name}" >> "$output_file"
    if npm run --silent "$script_name" 2>&1 | tail -"$tail_lines" >> "$output_file"; then
      echo "${label}: PASS" >> "$output_file"
      return 0
    else
      echo "${label}: FAIL" >> "$output_file"
      return 1
    fi
  fi

  echo "${label}: SKIP (no ${script_name} script)" >> "$output_file"
  return 2
}

# Entry limit per stage — architectural stages get more context budget (Crucible March 2026)
# Entry limits per stage — increased after Self-Audit March 2026.
# Context amnesia was the #1 architectural flaw: 5 entries per stage
# destroyed 80% of architectural context at every boundary.
get_entry_limit() {
  case "$1" in
    explore|fsd) echo 15 ;;
    code)        echo 15 ;;
    *)           echo 10 ;;
  esac
}

# ─────────────────────────────────────────────────
# NESTING GUARD (Critical — Issue #22)
# ─────────────────────────────────────────────────

# If running inside Claude Code, unset CLAUDECODE so child `claude -p` processes work.
# Each stage gets fresh context regardless — the isolation comes from `claude -p`, not from
# being in a separate terminal. The original guard was overly restrictive.
if [ -n "${CLAUDECODE:-}" ]; then
  echo "[INFO] Running inside Claude Code — unsetting CLAUDECODE for child processes"
  unset CLAUDECODE
fi

# ─────────────────────────────────────────────────
# ARGUMENT PARSING
# ─────────────────────────────────────────────────

MODE=""
GATED=false
DRY_RUN=false
DEFCON=false
ISSUE_NUM=""
PROJECT_DIR=""
ENGINE="claude"
REQUIRE_NOTEBOOK_CRUCIBLE=false
VERIFY_NOTEBOOK_CRUCIBLE_ONLY=false

usage() {
  echo "Dark Foundry v${VERSION} — Autonomous Pipeline Orchestrator"
  echo ""
  echo "Usage: $0 [OPTIONS] #<issue-number>"
  echo ""
  echo "Options:"
  echo "  --mode MODE     Force pipeline mode (GREENFIELD|FEATURE|FIX|HOTFIX|REFACTOR|SECURE|SPEC)"
  echo "  --defcon        Emergency mode (forces HOTFIX)"
  echo "  --gated         Add human checkpoints after explore and code"
  echo "  --dry-run       Show pipeline plan without executing"
  echo "  --project DIR   Project directory (default: current directory)"
  echo "  --engine NAME   Execution engine (claude|codex; default: claude)"
  echo "  --require-notebook-crucible  Require verified NotebookLM audio artifact gate"
  echo "  --verify-notebook-crucible-only  Verify NotebookLM gate and exit"
  echo "  --help          Show this help"
  echo ""
  echo "Examples:"
  echo "  $0 #123                     Auto-detect mode from issue labels"
  echo "  $0 --mode REFACTOR #456     Force REFACTOR mode"
  echo "  $0 --defcon #789            Production emergency"
  echo "  $0 --gated --mode FULL #123 Full pipeline with human gates"
  echo "  $0 --engine codex --mode FEATURE #123 Run stages with Codex exec"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE=$(echo "$2" | tr '[:lower:]' '[:upper:]')  # POSIX-compatible uppercase (Bash 3.2 safe)
      shift 2
      ;;
    --defcon)
      DEFCON=true
      shift
      ;;
    --gated)
      GATED=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --require-notebook-crucible)
      REQUIRE_NOTEBOOK_CRUCIBLE=true
      shift
      ;;
    --verify-notebook-crucible-only)
      VERIFY_NOTEBOOK_CRUCIBLE_ONLY=true
      REQUIRE_NOTEBOOK_CRUCIBLE=true
      shift
      ;;
    --project)
      PROJECT_DIR="$2"
      shift 2
      ;;
    --engine)
      ENGINE=$(echo "$2" | tr '[:upper:]' '[:lower:]')
      case "$ENGINE" in
        claude|codex) ;;
        *) echo "ERROR: Unknown engine: $ENGINE (expected claude|codex)"; exit 1 ;;
      esac
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    \#[0-9]*)
      ISSUE_NUM="${1#\#}"
      shift
      ;;
    [0-9]*)
      ISSUE_NUM="$1"
      shift
      ;;
    *)
      echo "ERROR: Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [ -z "$ISSUE_NUM" ]; then
  echo "ERROR: Issue number required."
  usage
  exit 1
fi

# Default to current directory and normalize once.
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
if [ ! -d "$PROJECT_DIR" ]; then
  echo "ERROR: Project directory not found: $PROJECT_DIR"
  exit 1
fi
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
PROJECT_COMMANDS="$PROJECT_DIR/.claude/commands"

# ─────────────────────────────────────────────────
# RESOLVE COMMAND FILE
# ─────────────────────────────────────────────────
# Resolution order:
#   1. Project .claude/commands/<name>.md
#   2. Global ~/.claude/commands/<name>.md
#   3. Software Engineer skill ~/.claude/skills/software-engineer/skills/<name>/SKILL.md

resolve_command() {
  local name="$1"

  # 1. Project-local command
  if [ -f "$PROJECT_COMMANDS/${name}.md" ]; then
    echo "$PROJECT_COMMANDS/${name}.md"
    return
  fi

  # 2. Global command
  if [ -f "$GLOBAL_COMMANDS/${name}.md" ]; then
    echo "$GLOBAL_COMMANDS/${name}.md"
    return
  fi

  # 3. Software Engineer skill
  if [ -f "$SE_SKILLS/${name}/SKILL.md" ]; then
    echo "$SE_SKILLS/${name}/SKILL.md"
    return
  fi

  echo ""
}

# ─────────────────────────────────────────────────
# CLASSIFIER (Stage 0)
# ─────────────────────────────────────────────────

classify_issue() {
  local issue_num="$1"

  # If mode forced via --mode or --defcon, skip classification
  if [ "$DEFCON" = true ]; then
    echo "HOTFIX"
    return
  fi
  if [ -n "$MODE" ]; then
    echo "$MODE"
    return
  fi

  # Read labels from GitHub
  local labels
  labels=$(gh issue view "$issue_num" --json labels -q '.labels[].name' 2>/dev/null || echo "")

  if echo "$labels" | grep -qi "hotfix\|production-down\|P0\|emergency"; then
    echo "HOTFIX"
  elif echo "$labels" | grep -qi "security\|vulnerability\|cve\|idor\|xss"; then
    echo "SECURE"
  elif echo "$labels" | grep -qi "spec\|fsd\|architecture\|defcon-0\|specification"; then
    echo "SPEC"
  elif echo "$labels" | grep -qi "refactor\|tech-debt\|cleanup\|performance"; then
    echo "REFACTOR"
  elif echo "$labels" | grep -qi "bug\|fix\|regression\|patch"; then
    echo "FIX"
  elif echo "$labels" | grep -qi "new\|greenfield"; then
    echo "GREENFIELD"
  else
    echo "FEATURE"
  fi
}

# ─────────────────────────────────────────────────
# MODE → STAGE LIST
# ─────────────────────────────────────────────────

get_stages() {
  local mode="$1"

  case "$mode" in
    GREENFIELD|FULL)
      echo "issue user-stories explore issue-review red-team anti-regression code validate e2e pr pr-review compliance autoresearch follow-up"
      ;;
    FEATURE)
      echo "issue user-stories red-team-quick anti-regression code validate e2e pr autoresearch follow-up"
      ;;
    FIX)
      echo "issue user-stories explore red-team-quick anti-regression code validate e2e pr follow-up"
      ;;
    HOTFIX)
      echo "issue code validate-fast pr follow-up"
      ;;
    REFACTOR)
      echo "issue user-stories explore red-team anti-regression-critical code validate e2e pr compliance autoresearch follow-up"
      ;;
    SECURE)
      echo "issue user-stories explore red-team anti-regression code validate e2e pr-restricted pr-review compliance autoresearch follow-up"
      ;;
    SPEC)
      echo "issue user-stories explore issue-review fsd red-team-spec follow-up"
      ;;
    *)
      echo "ERROR: Unknown mode: $mode" >&2
      exit 1
      ;;
  esac
}


add_notebook_crucible_stage() {
  local stages="$1"
  local output=""
  local inserted=false

  for stage in $stages; do
    output="${output}${stage} "
    case "$stage" in
      red-team|red-team-quick|red-team-spec)
        if [ "$inserted" = false ]; then
          output="${output}notebook-crucible "
          inserted=true
        fi
        ;;
    esac
  done

  if [ "$inserted" = false ]; then
    output="${output}notebook-crucible "
  fi

  echo "$output" | sed 's/[[:space:]]*$//'
}

# ─────────────────────────────────────────────────
# STAGE EXECUTION
# ─────────────────────────────────────────────────

PROGRESS_FILE="$PROJECT_DIR/$DARK_FOUNDRY_DIR/progress.txt"
LOG_DIR="$PROJECT_DIR/$DARK_FOUNDRY_DIR/logs"
LOCKFILE="$PROJECT_DIR/$DARK_FOUNDRY_DIR/.pipeline.lock"

# Cleanup on exit (remove lockfile)
cleanup() {
  if [ -f "$LOCKFILE" ]; then
    rm -f "$LOCKFILE"
  fi
}
trap cleanup EXIT INT TERM

init_pipeline() {
  mkdir -p "$PROJECT_DIR/$DARK_FOUNDRY_DIR/logs"
  mkdir -p "$PROJECT_DIR/$DARK_FOUNDRY_DIR/archive"

  # Concurrent run protection (with stale PID detection — CC3 F4 fix)
  if [ -f "$LOCKFILE" ]; then
    local lock_pid
    lock_pid=$(cat "$LOCKFILE" 2>/dev/null || echo "")
    if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
      echo "ERROR: Pipeline already running (PID: ${lock_pid})"
      echo "Lock file: ${LOCKFILE}"
      exit 1
    else
      echo "[WARN] Stale lockfile found (PID ${lock_pid:-unknown} not running). Cleaning up."
      rm -f "$LOCKFILE"
    fi
  fi
  echo $$ > "$LOCKFILE"

  # Seed progress.txt
  local issue_title
  issue_title=$(gh issue view "$ISSUE_NUM" --json title -q '.title' 2>/dev/null || echo "Unknown")
  local issue_labels
  issue_labels=$(gh issue view "$ISSUE_NUM" --json labels -q '[.labels[].name] | join(", ")' 2>/dev/null || echo "none")

  cat > "$PROGRESS_FILE" <<SEED
# progress.txt — Dark Foundry Pipeline
# Issue: #${ISSUE_NUM} — ${issue_title}
# Mode: ${PIPELINE_MODE}
# Engine: ${ENGINE}
# Notebook Crucible Required: ${REQUIRE_NOTEBOOK_CRUCIBLE}
# Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)
# Labels: ${issue_labels}
# Project: $(basename "$PROJECT_DIR")

## Discoveries
SEED

  echo "[INIT] Pipeline initialized for #${ISSUE_NUM} in ${PIPELINE_MODE} mode"
}

run_stage() {
  local stage_key="$1"  # e.g., "red-team-quick", "validate-fast", "anti-regression-critical"
  local retries=0

  # Parse stage name and flags
  local stage_name="${stage_key%%-quick}"
  stage_name="${stage_name%%-fast}"
  stage_name="${stage_name%%-critical}"
  stage_name="${stage_name%%-restricted}"
  local stage_flags=""

  # CC4 Fix A: red-team variants now resolve to their OWN command files (no flags needed)
  # This eliminates the context budget bomb — each variant gets only its relevant instructions
  case "$stage_key" in
    red-team-quick)    stage_name="red-team-quick" ;;
    red-team-spec)     stage_name="red-team-spec" ;;
    compliance)        stage_name="red-team-compliance" ;;
    validate-fast)     stage_name="validate"; stage_flags="--fast" ;;
    anti-regression*)  stage_name="anti-regression" ;;
    pr-restricted)     stage_name="pr"; stage_flags="--restricted" ;;
    pr-review)         stage_name="pr-review" ;;
    issue-review)      stage_name="issue-review" ;;
    user-stories)      stage_name="user-stories" ;;
    follow-up)         stage_name="follow-up" ;;
    autoresearch)      stage_name="autoresearch" ;;
    *)                 stage_name="$stage_key" ;;
  esac

  # Built-in stages
  if [[ "$stage_name" == "anti-regression" ]]; then
    run_anti_regression "$stage_key"
    return $?
  fi
  if [[ "$stage_name" == "notebook-crucible" ]]; then
    run_notebook_crucible
    return $?
  fi

  # Select Constitution version (#14 context budget fix)
  # ASSAY and CRUCIBLE need full Constitution (reference articles for 18 docs, quality gates)
  # All other stages get the 12KB core (86% context reduction)
  case "$stage_name" in
    explore|issue-review|red-team*|user-stories)
      CONSTITUTION_FILE="$CONSTITUTION_FULL" ;;
    *)
      CONSTITUTION_FILE="$CONSTITUTION_CORE" ;;
  esac

  # Resolve command file
  local cmd_file
  cmd_file=$(resolve_command "$stage_name")

  if [ -z "$cmd_file" ]; then
    echo "[ERROR] No command file found for required stage '${stage_name}'"
    echo "[ERROR] Checked: $PROJECT_COMMANDS, $GLOBAL_COMMANDS, $SE_SKILLS"
    return 1
  fi

  # Build prompt — use awk for safe literal substitution (CC4 Finding 4)
  # awk gsub() treats replacement as literal string, not regex — no sed special char issues
  local args_value="#${ISSUE_NUM}"
  [ -n "$stage_flags" ] && args_value="#${ISSUE_NUM} ${stage_flags}"
  local prompt
  prompt=$(awk -v args="$args_value" '{ gsub(/\$ARGUMENTS/, args); print }' "$cmd_file")

  # Strip YAML frontmatter only (first ---/--- block at start of file)
  # Uses awk to remove only the leading frontmatter, not content --- dividers
  prompt=$(echo "$prompt" | awk '
    BEGIN { in_front=0; done_front=0 }
    /^---$/ && !done_front && !in_front { in_front=1; next }
    /^---$/ && !done_front && in_front  { in_front=0; done_front=1; next }
    !in_front { print }
  ')

  # Build the full prompt with context layers
  # Layer 1: Constitution (immutable rules — always first)
  # Tiering (#73): internal projects skip CLIENT-tier articles (Loading Map).
  local full_prompt=""
  if [ -f "$CONSTITUTION_FILE" ]; then
    local project_type
    project_type="$(foundry_project_type "$PROJECT_DIR/$DARK_FOUNDRY_DIR")"
    if [ "$project_type" = "internal" ] && [ "$CONSTITUTION_FILE" = "$CONSTITUTION_FULL" ]; then
      echo "[constitution] internal project — CLIENT-tier articles (14,16,19,23,33,34) skipped"
    fi
    full_prompt="$(load_constitution "$CONSTITUTION_FILE" "$project_type")

---

"
  else
    echo "[WARN] Constitution file not found at: $CONSTITUTION_FILE"
    echo "[WARN] Pipeline will run WITHOUT immutable rules. This is dangerous."
    echo "[WARN] Expected: growthpigs/the-foundry CONSTITUTION.md"
  fi

  # Layer 2: Prior progress (accumulated discoveries)
  if [ -f "$PROGRESS_FILE" ]; then
    full_prompt="${full_prompt}## Prior Progress (from earlier pipeline stages)
$(cat "$PROGRESS_FILE")

---

"
  fi

  # Layer 3: The actual stage prompt (command file content)
  full_prompt="${full_prompt}${prompt}

---

## Pipeline Instructions
After completing your work, append your key discoveries to $(realpath "$PROGRESS_FILE") using this format:
## [${stage_name}] — $(date -u +%Y-%m-%dT%H:%M:%SZ)
- DISCOVERED: ...
- DECISION: ...
- WARNING: ...
- FIXED: ...
Maximum $(get_entry_limit "$stage_name") entries. Be specific (file paths, line numbers, root causes). [SECURITY-SURFACE] tagged entries are exempt up to a ceiling of 20 total.

MANDATORY: After your entries, write a ## Carry-Forward section that synthesizes ALL findings into a coherent narrative for the NEXT stage. This is the single most important thing you write — it's how the next agent understands what you discovered. Without it, 80% of your work is lost."

  prompt="$full_prompt"

  # Determine budget
  local budget
  budget=$(get_stage_budget "$stage_name")

  # Execute with retries
  while [ "$retries" -lt "$MAX_RETRIES_PER_STAGE" ] && [ "$TOTAL_RETRIES" -lt "$MAX_RETRIES_TOTAL" ]; do
    echo ""
    echo "═══════════════════════════════════════════════"
    echo "  Stage: ${stage_name} ${stage_flags}"
    echo "  Budget: \$${budget} | Retry: ${retries}/${MAX_RETRIES_PER_STAGE}"
    echo "  Total retries: ${TOTAL_RETRIES}/${MAX_RETRIES_TOTAL}"
    echo "═══════════════════════════════════════════════"
    echo ""

    # Permission tier: read-only stages run without --dangerously-skip-permissions (CC3 F1)
    local perm_flag=""
    if stage_needs_write "$stage_name"; then
      perm_flag="--dangerously-skip-permissions"
    else
      echo "  [permissions] Read-only stage — running with default permissions"
    fi

    local stage_ok=false
    if [ "$ENGINE" = "codex" ]; then
      # Codex stages must be able to append .foundry/progress.txt as instructed.
      # Project-level workspace-write is the narrowest stable Codex sandbox that permits that.
      local codex_sandbox="workspace-write"
      if printf '%s' "$prompt" | codex exec - \
        --cd "$PROJECT_DIR" \
        --sandbox "$codex_sandbox" \
        2>&1 | tee "$LOG_DIR/${stage_name}.log"; then
        stage_ok=true
      fi
    elif claude -p "$prompt" \
      $perm_flag \
      --max-budget-usd "$budget" \
      2>&1 | tee "$LOG_DIR/${stage_name}.log"; then
      stage_ok=true
    fi

    if [ "$stage_ok" = true ]; then
      echo ""
      echo "[${stage_name}] ✅ Complete"
      return 0
    else
      retries=$((retries + 1))
      TOTAL_RETRIES=$((TOTAL_RETRIES + 1))
      echo "[${stage_name}] ❌ Failed (attempt ${retries}/${MAX_RETRIES_PER_STAGE})"

      if [ "$TOTAL_RETRIES" -ge "$MAX_RETRIES_TOTAL" ]; then
        echo "[FATAL] Total retry limit reached (${MAX_RETRIES_TOTAL}). Aborting pipeline."
        echo "[ANTI-REGRESSION] Pipeline ABORTED at stage ${stage_name}" >> "$PROGRESS_FILE"
        exit 1
      fi
    fi
  done

  echo "[${stage_name}] ❌ Max retries exhausted. Aborting pipeline."
  exit 1
}


# ─────────────────────────────────────────────────
# NOTEBOOKLM CRUCIBLE GATE (Built-in Stage)
# ─────────────────────────────────────────────────

run_notebook_crucible() {
  local report_file="$PROJECT_DIR/$DARK_FOUNDRY_DIR/notebook-crucible-${ISSUE_NUM}.md"
  local raw_dir="$PROJECT_DIR/$DARK_FOUNDRY_DIR/notebook-crucible-${ISSUE_NUM}"
  local source_json="$raw_dir/sources.json"
  local artifact_json="$raw_dir/artifacts.json"
  local findings_json="$raw_dir/findings.json"
  local gate_manifest="$raw_dir/gate-manifest.json"
  local notebook_id="${NOTEBOOKLM_CRUCIBLE_NOTEBOOK_ID:-}"

  echo ""
  echo "═══════════════════════════════════════════════"
  echo "  Stage: NotebookLM Crucible Gate"
  echo "═══════════════════════════════════════════════"
  echo ""

  mkdir -p "$raw_dir"

  if ! command -v notebooklm >/dev/null 2>&1; then
    echo "[notebook-crucible] ❌ notebooklm CLI not found"
    return 1
  fi

  if [ -n "${NOTEBOOKLM_CRUCIBLE_CMD:-}" ]; then
    echo "[notebook-crucible] Running NOTEBOOKLM_CRUCIBLE_CMD..."
    local cmd_log="$raw_dir/command.log"
    if ! bash -lc "$NOTEBOOKLM_CRUCIBLE_CMD" 2>&1 | tee "$cmd_log"; then
      echo "[notebook-crucible] ❌ Crucible command failed"
      return 1
    fi
    notebook_id=$(grep -E '^(CRUCIBLE_NOTEBOOK_ID|NOTEBOOKLM_CRUCIBLE_NOTEBOOK_ID)=' "$cmd_log" | tail -1 | cut -d= -f2-)
  fi

  if [ -z "$notebook_id" ]; then
    echo "[notebook-crucible] ❌ No notebook id provided"
    echo "[notebook-crucible] Set NOTEBOOKLM_CRUCIBLE_NOTEBOOK_ID to verify an existing notebook,"
    echo "[notebook-crucible] or set NOTEBOOKLM_CRUCIBLE_CMD to run a command that prints CRUCIBLE_NOTEBOOK_ID=<id>."
    return 1
  fi

  echo "[notebook-crucible] Verifying notebook: $notebook_id"

  if ! notebooklm source list --notebook "$notebook_id" --json > "$source_json"; then
    echo "[notebook-crucible] ❌ Could not list NotebookLM sources"
    return 1
  fi

  if ! notebooklm artifact list --notebook "$notebook_id" --json > "$artifact_json"; then
    echo "[notebook-crucible] ❌ Could not list NotebookLM artifacts"
    return 1
  fi

  local source_count audio_count
  source_count=$(node -e "const fs=require('fs'); const data=JSON.parse(fs.readFileSync(process.argv[1],'utf8')); const sources=data.sources||[]; const ready=sources.filter(s => String(s.status||'').toLowerCase()==='ready' || s.status_id===2 || s.status_id===3); console.log(ready.length);" "$source_json")
  audio_count=$(node -e "const fs=require('fs'); const data=JSON.parse(fs.readFileSync(process.argv[1],'utf8')); const artifacts=data.artifacts||[]; const complete=artifacts.filter(a => String(a.type||'').toLowerCase()==='audio' && (String(a.status||'').toLowerCase()==='completed' || a.status_id===3)); console.log(complete.length);" "$artifact_json")

  if [ "$source_count" -lt 3 ] 2>/dev/null; then
    echo "[notebook-crucible] ❌ Need at least 3 ready sources; found $source_count"
    return 1
  fi

  if [ "$audio_count" -lt 1 ] 2>/dev/null; then
    echo "[notebook-crucible] ❌ Need at least 1 completed Audio artifact; found $audio_count"
    return 1
  fi

  echo "[notebook-crucible] Extracting findings from NotebookLM..."
  if ! notebooklm ask --notebook "$notebook_id" --json \
    "For this Crucible, list the top architectural gap, the evidence from the uploaded sources, and the concrete fix required before the runner can claim the Crucible is complete." > "$findings_json"; then
    echo "[notebook-crucible] ❌ Could not extract NotebookLM findings"
    return 1
  fi

  local findings_chars
  findings_chars=$(node -e "const fs=require('fs'); const data=JSON.parse(fs.readFileSync(process.argv[1],'utf8')); const answer=String(data.answer||''); console.log(answer.trim().length);" "$findings_json")
  if [ "$findings_chars" -lt 50 ] 2>/dev/null; then
    echo "[notebook-crucible] ❌ Extracted findings are empty or too short (${findings_chars} chars)"
    return 1
  fi

  cat > "$report_file" <<REPORT
# NotebookLM Crucible Gate

- Issue: #${ISSUE_NUM}
- Notebook ID: ${notebook_id}
- Ready sources: ${source_count}
- Completed audio artifacts: ${audio_count}
- Extracted findings chars: ${findings_chars}
- Source manifest: ${source_json}
- Artifact manifest: ${artifact_json}
- Findings manifest: ${findings_json}
- Verified: $(date -u +%Y-%m-%dT%H:%M:%SZ)

Verdict: PASS
REPORT

  node - "$gate_manifest" "$ISSUE_NUM" "$notebook_id" "$source_count" "$audio_count" "$findings_chars" "$source_json" "$artifact_json" "$findings_json" "$report_file" <<'NODE'
const fs = require('fs');
const [
  out,
  issue,
  notebookId,
  readySources,
  completedAudioArtifacts,
  extractedFindingsChars,
  sourceManifest,
  artifactManifest,
  findingsManifest,
  reportPath,
] = process.argv.slice(2);

const manifest = {
  verdict: 'PASS',
  issue: Number(issue),
  notebook_id: notebookId,
  ready_sources: Number(readySources),
  completed_audio_artifacts: Number(completedAudioArtifacts),
  extracted_findings_chars: Number(extractedFindingsChars),
  source_manifest: sourceManifest,
  artifact_manifest: artifactManifest,
  findings_manifest: findingsManifest,
  report_path: reportPath,
  verified_at: new Date().toISOString(),
};

if (!manifest.notebook_id || manifest.ready_sources < 3 || manifest.completed_audio_artifacts < 1 || manifest.extracted_findings_chars < 50) {
  throw new Error(`invalid NotebookLM Crucible gate manifest: ${JSON.stringify(manifest)}`);
}

fs.writeFileSync(out, JSON.stringify(manifest, null, 2));
NODE

  echo "[notebook-crucible] ✅ Verified NotebookLM Crucible artifacts"
  echo "[notebook-crucible] Report: $report_file"
  echo "[notebook-crucible] Manifest: $gate_manifest"
  echo "[NOTEBOOK-CRUCIBLE] ✅ notebook_id=${notebook_id} sources=${source_count} completed_audio=${audio_count} findings_chars=${findings_chars} report=${report_file}" >> "$PROGRESS_FILE"
}

# ─────────────────────────────────────────────────
# ANTI-REGRESSION (Built-in Stage)
# ─────────────────────────────────────────────────

run_anti_regression() {
  local variant="$1"  # "anti-regression" or "anti-regression-critical"
  local baseline_file="$PROJECT_DIR/$DARK_FOUNDRY_DIR/baseline-${ISSUE_NUM}.md"

  echo ""
  echo "═══════════════════════════════════════════════"
  echo "  Stage: Anti-Regression Baseline"
  echo "  Variant: ${variant}"
  echo "═══════════════════════════════════════════════"
  echo ""

  cd "$PROJECT_DIR"

  echo "## Anti-Regression Baseline" > "$baseline_file"
  echo "Captured: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$baseline_file"
  echo "Issue: #${ISSUE_NUM}" >> "$baseline_file"
  echo "" >> "$baseline_file"

  # Test discovery and results
  echo "### Test Count" >> "$baseline_file"
  local test_count=0
  if [ -d server ]; then
    test_count=$((test_count + $(find server -type f \( -name '*.test.ts' -o -name '*.spec.ts' -o -name '*.test.tsx' -o -name '*.spec.tsx' \) 2>/dev/null | wc -l | tr -d ' ')))
  fi
  if [ -d client ]; then
    test_count=$((test_count + $(find client -type f \( -name '*.test.ts' -o -name '*.spec.ts' -o -name '*.test.tsx' -o -name '*.spec.tsx' \) 2>/dev/null | wc -l | tr -d ' ')))
  fi
  echo "Total test files: ${test_count}" >> "$baseline_file"
  echo "" >> "$baseline_file"

  echo "### Test Results" >> "$baseline_file"
  run_npm_script_if_present "test" "Tests" "$baseline_file" 8 || true
  echo "" >> "$baseline_file"

  echo "### TypeScript" >> "$baseline_file"
  run_npm_script_if_present "check" "TypeScript" "$baseline_file" 8 || true
  echo "" >> "$baseline_file"

  echo "### Build" >> "$baseline_file"
  run_npm_script_if_present "build" "Build" "$baseline_file" 8 || true
  echo "" >> "$baseline_file"

  # Critical variant: additional captures
  if [[ "$variant" == *"critical"* ]]; then
    echo "### Test Names (Critical Mode)" >> "$baseline_file"
    find . -type f \( -name '*.test.ts' -o -name '*.spec.ts' -o -name '*.test.tsx' -o -name '*.spec.tsx' \) 2>/dev/null | sort >> "$baseline_file" || true
    echo "" >> "$baseline_file"

    echo "### Key File Checksums" >> "$baseline_file"
    for f in shared/schema.ts server/routes.ts client/src/App.tsx netlify.toml package.json; do
      if [ -f "$f" ]; then
        echo "$(md5 -q "$f" 2>/dev/null || md5sum "$f" | cut -d' ' -f1) $f" >> "$baseline_file"
      fi
    done
    echo "" >> "$baseline_file"
  fi

  # Log to progress.txt
  echo "[ANTI-REGRESSION] Baseline: ${test_count} test files captured" >> "$PROGRESS_FILE"
  echo "[anti-regression] ✅ Baseline captured → ${baseline_file}"
}

compare_anti_regression() {
  local baseline_file="$PROJECT_DIR/$DARK_FOUNDRY_DIR/baseline-${ISSUE_NUM}.md"
  local compare_file="$PROJECT_DIR/$DARK_FOUNDRY_DIR/post-code-${ISSUE_NUM}.md"

  if [ ! -f "$baseline_file" ]; then
    echo "[ANTI-REGRESSION] No baseline found — skipping comparison"
    return 0
  fi

  echo ""
  echo "═══════════════════════════════════════════════"
  echo "  Stage: Anti-Regression Comparison (Post-Code)"
  echo "═══════════════════════════════════════════════"
  echo ""

  cd "$PROJECT_DIR"

  echo "## Anti-Regression Comparison" > "$compare_file"
  echo "Compared: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$compare_file"
  echo "" >> "$compare_file"

  # Re-run test count
  echo "### Test Count (Post-Code)" >> "$compare_file"
  local post_test_count=0
  if [ -d server ]; then
    post_test_count=$((post_test_count + $(find server -type f \( -name '*.test.ts' -o -name '*.spec.ts' -o -name '*.test.tsx' -o -name '*.spec.tsx' \) 2>/dev/null | wc -l | tr -d ' ')))
  fi
  if [ -d client ]; then
    post_test_count=$((post_test_count + $(find client -type f \( -name '*.test.ts' -o -name '*.spec.ts' -o -name '*.test.tsx' -o -name '*.spec.tsx' \) 2>/dev/null | wc -l | tr -d ' ')))
  fi
  echo "Total test files: ${post_test_count}" >> "$compare_file"
  echo "" >> "$compare_file"

  echo "### Test Results (Post-Code)" >> "$compare_file"
  run_npm_script_if_present "test" "Tests" "$compare_file" 8 || true
  echo "" >> "$compare_file"

  echo "### TypeScript (Post-Code)" >> "$compare_file"
  run_npm_script_if_present "check" "TypeScript" "$compare_file" 8 || true
  echo "" >> "$compare_file"

  echo "### Build (Post-Code)" >> "$compare_file"
  run_npm_script_if_present "build" "Build" "$compare_file" 8 || true
  echo "" >> "$compare_file"

  # Semantic comparison — extract numbers, don't rely on raw diff (CC3 F2 fix)
  local baseline_tests post_tests
  baseline_tests=$(grep -m1 'Total test files:' "$baseline_file" 2>/dev/null | grep -o '[0-9]*' || echo "0")
  post_tests=$(grep -m1 'Total test files:' "$compare_file" 2>/dev/null | grep -o '[0-9]*' || echo "0")

  local regression_found=false

  # Check 1: Test count decreased → BLOCK
  if [ "$post_tests" -lt "$baseline_tests" ] 2>/dev/null; then
    echo "[anti-regression] 🚨 BLOCKING: Test count decreased (${baseline_tests} → ${post_tests})"
    echo "[ANTI-REGRESSION] 🚨 BLOCKED — Test count decreased (${baseline_tests} → ${post_tests})" >> "$PROGRESS_FILE"
    regression_found=true
  fi

  # Check 2: TypeScript errors introduced → BLOCK
  local baseline_ts_ok post_ts_ok
  baseline_ts_ok=$(grep -c 'error TS' "$baseline_file" 2>/dev/null || echo "0")
  post_ts_ok=$(grep -c 'error TS' "$compare_file" 2>/dev/null || echo "0")
  if [ "$post_ts_ok" -gt "$baseline_ts_ok" ] 2>/dev/null; then
    echo "[anti-regression] 🚨 BLOCKING: New TypeScript errors (${baseline_ts_ok} → ${post_ts_ok})"
    echo "[ANTI-REGRESSION] 🚨 BLOCKED — New TypeScript errors (${baseline_ts_ok} → ${post_ts_ok})" >> "$PROGRESS_FILE"
    regression_found=true
  fi

  # Check 3: Build broke → BLOCK (#21 — was documented but never checked)
  local baseline_build post_build
  baseline_build=$(grep -c 'Build: PASS' "$baseline_file" 2>/dev/null || echo "0")
  post_build=$(grep -c 'Build: PASS' "$compare_file" 2>/dev/null || echo "0")
  if [ "$baseline_build" -gt 0 ] && [ "$post_build" -eq 0 ]; then
    echo "[anti-regression] 🚨 BLOCKING: Build was passing, now failing"
    echo "[ANTI-REGRESSION] 🚨 BLOCKED — Build regression (PASS → FAIL)" >> "$PROGRESS_FILE"
    regression_found=true
  fi

  # Verdict
  echo "### Comparison Result" >> "$compare_file"
  if [ "$regression_found" = true ]; then
    echo "REGRESSIONS DETECTED — pipeline blocked." >> "$compare_file"
    diff "$baseline_file" "$compare_file" >> "$compare_file" 2>&1 || true
    echo ""
    echo "[anti-regression] ❌ Regressions found — fix before proceeding"
    return 1  # Caller (run_stage) will handle retry/abort
  else
    echo "No blocking regressions detected." >> "$compare_file"
    if [ "$post_tests" -gt "$baseline_tests" ] 2>/dev/null; then
      echo "[anti-regression] ✅ Clean — test count increased (${baseline_tests} → ${post_tests})"
    else
      echo "[anti-regression] ✅ Post-code comparison clean"
    fi
    echo "[ANTI-REGRESSION] ✅ No regressions detected" >> "$PROGRESS_FILE"
  fi
}

# ─────────────────────────────────────────────────
# GATED MODE — Human Checkpoints
# ─────────────────────────────────────────────────

gate_checkpoint() {
  local gate_name="$1"

  if [ "$GATED" = true ]; then
    echo ""
    echo "╔═══════════════════════════════════════════════╗"
    echo "║  GATE: ${gate_name}"
    echo "║  Review the output above."
    echo "║  Press ENTER to continue, or Ctrl+C to abort."
    echo "╚═══════════════════════════════════════════════╝"
    echo ""
    read -r
  fi
}

# ─────────────────────────────────────────────────
# ARCHIVE (On Pipeline Complete)
# ─────────────────────────────────────────────────

archive_progress() {
  if [ -f "$PROGRESS_FILE" ]; then
    local date_stamp
    date_stamp=$(date +%Y%m%d)
    local archive_path="$PROJECT_DIR/$DARK_FOUNDRY_DIR/archive/progress-${ISSUE_NUM}-${date_stamp}.txt"
    cp "$PROGRESS_FILE" "$archive_path"
    echo "[ARCHIVE] progress.txt → ${archive_path}"
  fi
}

# ─────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────

main() {
  echo "╔═══════════════════════════════════════════════╗"
  echo "║  Dark Foundry v${VERSION}                        ║"
  echo "║  Autonomous Pipeline Orchestrator             ║"
  echo "╚═══════════════════════════════════════════════╝"
  echo ""

  # Capture start time (used in pipeline report)
  START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  cd "$PROJECT_DIR"

  if [ "$VERIFY_NOTEBOOK_CRUCIBLE_ONLY" = true ]; then
    mkdir -p "$PROJECT_DIR/$DARK_FOUNDRY_DIR/logs"
    if [ ! -f "$PROGRESS_FILE" ]; then
      cat > "$PROGRESS_FILE" <<SEED
# progress.txt — Dark Foundry Pipeline
# Issue: #${ISSUE_NUM}
# Mode: ${MODE:-VERIFY}
# Engine: ${ENGINE}
# Notebook Crucible Required: true
# Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Discoveries
SEED
    fi
    run_notebook_crucible
    exit $?
  fi

  # Engine preflight. Dry-run intentionally skips auth so planning works in audit sessions.
  if [ "$DRY_RUN" != true ]; then
    if [ "$ENGINE" = "codex" ]; then
      echo "[AUTH] Verifying codex exec availability..."
      if ! codex exec "Say OK" --cd "$PROJECT_DIR" --sandbox read-only --output-last-message /tmp/foundry-codex-preflight.txt >/dev/null 2>&1; then
        echo ""
        echo "╔═══════════════════════════════════════════════╗"
        echo "║  ❌ CODEX PREFLIGHT FAILED                    ║"
        echo "║                                               ║"
        echo "║  codex exec is not available or authenticated.║"
        echo "║  Run: codex exec \"Say OK\"                    ║"
        echo "║  Then retry the pipeline.                     ║"
        echo "╚═══════════════════════════════════════════════╝"
        exit 1
      fi
      echo "[AUTH] ✅ Codex available"
      echo ""
    else
      echo "[AUTH] Verifying claude -p authentication..."
      if ! claude -p "Say OK" --max-budget-usd 0.01 >/dev/null 2>&1; then
        echo ""
        echo "╔═══════════════════════════════════════════════╗"
        echo "║  ❌ AUTH FAILED                               ║"
        echo "║                                               ║"
        echo "║  claude -p cannot authenticate.               ║"
        echo "║  Run: ~/.claude/skills/DarkFoundry/bin/claude-reauth.sh"
        echo "║  Then retry the pipeline.                     ║"
        echo "╚═══════════════════════════════════════════════╝"
        exit 1
      fi
      echo "[AUTH] ✅ Authenticated"
      echo ""
    fi
  else
    echo "[AUTH] Skipped for dry-run"
    echo ""
  fi

  # Classify
  PIPELINE_MODE=$(classify_issue "$ISSUE_NUM")
  echo "[CLASSIFY] Issue #${ISSUE_NUM} → Mode: ${PIPELINE_MODE}"
  echo "[ENGINE] ${ENGINE}"

  # Get stage list
  local stages
  stages=$(get_stages "$PIPELINE_MODE")
  if [ "$REQUIRE_NOTEBOOK_CRUCIBLE" = true ]; then
    stages=$(add_notebook_crucible_stage "$stages")
  fi
  local stage_count
  stage_count=$(echo "$stages" | wc -w | tr -d ' ')
  echo "[PLAN] ${stage_count} stages: ${stages}"
  echo ""

  # Dry run — show plan and exit
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would execute these stages:"
    local i=1
    for stage in $stages; do
      # Parse base stage name (same logic as run_stage)
      local display_name="$stage"
      case "$stage" in
        red-team-quick)    display_name="red-team (quick)" ;;
        red-team-spec)     display_name="red-team (spec)" ;;
        compliance)        display_name="red-team (compliance)" ;;
        validate-fast)     display_name="validate (--fast)" ;;
        anti-regression*)  display_name="anti-regression (BUILT-IN)" ;;
        notebook-crucible) display_name="notebook-crucible (BUILT-IN)" ;;
        pr-restricted)     display_name="pr (--restricted)" ;;
      esac
      # CC4 Fix A: red-team variants now have their own command files
      local base_name
      case "$stage" in
        red-team-quick)   base_name="red-team-quick" ;;
        red-team-spec)    base_name="red-team-spec" ;;
        compliance)       base_name="red-team-compliance" ;;
        validate-fast)    base_name="validate" ;;
        anti-regression*) base_name="anti-regression" ;;
        notebook-crucible) base_name="notebook-crucible" ;;
        pr-restricted)    base_name="pr" ;;
        pr-review)        base_name="pr-review" ;;
        *)                base_name="$stage" ;;
      esac
      local cmd_file
      if [[ "$base_name" == "anti-regression" || "$base_name" == "notebook-crucible" ]]; then
        cmd_file="BUILT-IN"
      else
        cmd_file=$(resolve_command "$base_name")
        cmd_file="${cmd_file:-NOT FOUND}"
      fi
      echo "  ${i}. ${display_name} → ${cmd_file}"
      if [ "$cmd_file" = "NOT FOUND" ]; then
        missing_commands=true
      fi
      i=$((i + 1))
    done
    echo ""
    if [ "${missing_commands:-false}" = true ]; then
      echo "[DRY RUN] ERROR: Required command files are missing."
      exit 1
    fi
    echo "[DRY RUN] No changes made."
    exit 0
  fi

  # Initialize
  init_pipeline

  # Execute stages
  local completed=0
  for stage in $stages; do
    run_stage "$stage"
    completed=$((completed + 1))

    # Anti-regression comparison (after code, if baseline exists)
    # CRITICAL: Return code MUST be checked — regressions BLOCK the pipeline (Article 8)
    if [ "$stage" = "code" ]; then
      if ! compare_anti_regression; then
        echo ""
        echo "╔════════════════════════════════════════════════╗"
        echo "║  🚨 ANTI-REGRESSION BLOCK — PIPELINE HALTED   ║"
        echo "║  Regressions detected. Fix before proceeding.  ║"
        echo "║  See: .foundry/post-code-${ISSUE_NUM}.md       ║"
        echo "╚════════════════════════════════════════════════╝"
        echo ""
        echo "[ANTI-REGRESSION] 🚨 PIPELINE HALTED — regressions detected" >> "$PROGRESS_FILE"
        exit 1
      fi
    fi

    # Gated checkpoints
    if [ "$stage" = "explore" ]; then
      gate_checkpoint "Post-Explore — Proceed with implementation?"
    fi
    if [ "$stage" = "code" ]; then
      gate_checkpoint "Post-Code — Proceed with PR?"
    fi
    if [ "$stage" = "fsd" ]; then
      gate_checkpoint "Post-FSD — Review the spec before red-team?"
      # CC4 Fix B: Push AFTER gate passes (fsd.md only commits locally now)
      echo "[fsd] Pushing FSD to remote after gate approval..."
      git push 2>/dev/null || echo "[WARN] git push failed — FSD may not be on remote"
    fi
  done

  # Archive
  archive_progress

  # ─────────────────────────────────────────────────
  # PIPELINE REPORT — Post to GitHub issue as comment
  # ─────────────────────────────────────────────────
  echo ""
  echo "[report] Generating pipeline report for #${ISSUE_NUM}..."

  local end_time
  end_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local branch_name
  branch_name=$(git branch --show-current 2>/dev/null || echo "unknown")
  local commit_hash
  commit_hash=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
  local files_changed
  local base_ref
  base_ref=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || echo main)
  files_changed=$(git diff --stat "origin/${base_ref}...HEAD" 2>/dev/null | tail -1 || git diff --stat main...HEAD 2>/dev/null | tail -1 || echo "unknown")

  # Extract user stories from progress.txt
  local stories=""
  if [ -f "$PROGRESS_FILE" ]; then
    stories=$(grep -A1 "DISCOVERED:.*user stor\|DISCOVERED:.*story" "$PROGRESS_FILE" 2>/dev/null | head -10 || true)
  fi

  # Extract red-team verdict
  local verdict=""
  if [ -f "$PROGRESS_FILE" ]; then
    verdict=$(grep "APPROVE\|REVISE\|REJECT" "$PROGRESS_FILE" 2>/dev/null | head -1 || true)
  fi

  # Build the report
  local report_body
  report_body=$(cat <<REPORT_EOF
## Dark Foundry Pipeline Report

**Mode:** ${PIPELINE_MODE} | **Engine:** ${ENGINE} | **Notebook Crucible:** ${REQUIRE_NOTEBOOK_CRUCIBLE} | **Stages:** ${completed}/${stage_count} | **Retries:** ${TOTAL_RETRIES}
**Branch:** \`${branch_name}\` | **Commit:** \`${commit_hash}\`
**Started:** ${START_TIME:-unknown} | **Finished:** ${end_time}

### Stage Results
$(for s in $stages; do
  if [ -f "${LOG_DIR}/${s}.log" ] && [ -s "${LOG_DIR}/${s}.log" ]; then
    echo "- ✅ **${s}**"
  elif echo "$s" | grep -q "anti-regression\|notebook-crucible"; then
    echo "- ✅ **${s}** (built-in)"
  else
    echo "- ⬜ **${s}**"
  fi
done)

### Red-Team Verdict
${verdict:-No red-team stage in this mode}

### Changes
${files_changed}

### Knowledge Trail
<details>
<summary>Full progress.txt (click to expand)</summary>

\`\`\`
$(cat "$PROGRESS_FILE" 2>/dev/null || echo "No progress file")
\`\`\`
</details>

---
*Generated by Dark Foundry v${VERSION}*
REPORT_EOF
)

  # Post as GitHub issue comment
  if command -v gh &>/dev/null; then
    echo "[report] Posting to GitHub issue #${ISSUE_NUM}..."
    gh issue comment "$ISSUE_NUM" --body "$report_body" 2>/dev/null \
      && echo "[report] ✅ Report posted to #${ISSUE_NUM}" \
      || echo "[report] ⚠️  Could not post report (gh auth or network issue)"
  else
    echo "[report] ⚠️  gh CLI not found — report not posted"
    echo "[report] Report saved to: ${DARK_FOUNDRY_DIR}/report-${ISSUE_NUM}.md"
    echo "$report_body" > "${DARK_FOUNDRY_DIR}/report-${ISSUE_NUM}.md"
  fi

  echo ""
  echo "╔═══════════════════════════════════════════════╗"
  echo "║  PIPELINE COMPLETE                            ║"
  echo "║  Issue: #${ISSUE_NUM}                              "
  echo "║  Mode: ${PIPELINE_MODE}                            "
  echo "║  Stages: ${completed}/${stage_count} completed        "
  echo "║  Total retries used: ${TOTAL_RETRIES}               "
  echo "╚═══════════════════════════════════════════════╝"
}

main "$@"
