#!/usr/bin/env bash
# The Foundry — Phase 0: LAUNCH
# Generates the exact prompt to paste into a fresh CC session.
#
# Usage (from any project directory):
#   ~/.foundry/bin/launch.sh
#   ~/.foundry/bin/launch.sh --mode GREENFIELD
#   ~/.foundry/bin/launch.sh --mode FEATURE --epic "E1: Platform Foundation"
#   ~/.foundry/bin/launch.sh --mode FIX --issue 123
#
# What it does:
#   1. Detects which project you're in (from git remote)
#   2. Reads the project's CLAUDE.md to understand context
#   3. Finds the Activity Log and Work Ledger issue numbers
#   4. Determines the right starting phase based on mode
#   5. Outputs a ready-to-paste prompt for a fresh CC session

set -euo pipefail

# ─────────────────────────────────────────────────
# SCAFFOLD MODE (--new)
# Creates a new project from scratch
# ─────────────────────────────────────────────────

FOUNDRY_DIR="$HOME/_PAI/operations/the-foundry"

scaffold_project() {
  local name="$1"
  local org="$2"
  local vision="$3"
  local repo="${org}/${name}"

  echo "═══════════════════════════════════════════════"
  echo "  THE FOUNDRY — SCAFFOLD"
  echo "  Creating: $repo"
  echo "═══════════════════════════════════════════════"
  echo ""

  # 1. Create GitHub repo
  echo "[1/7] Creating GitHub repo..."
  if gh repo view "$repo" &>/dev/null; then
    echo "  WARN: Repo $repo already exists. Skipping creation."
  else
    gh repo create "$repo" --public --description "$vision" --clone=false
    echo "  Created: https://github.com/$repo"
  fi

  # 2. Clone and create thin scaffold
  echo "[2/7] Creating thin scaffold..."
  local tmp_dir="/tmp/scaffold-${name}"
  rm -rf "$tmp_dir"
  gh repo clone "$repo" "$tmp_dir" 2>/dev/null || { mkdir -p "$tmp_dir" && cd "$tmp_dir" && git init && git remote add origin "https://github.com/${repo}.git"; }
  cd "$tmp_dir"

  mkdir -p docs/05-planning features .foundry

  # CLAUDE.md
  cat > CLAUDE.md << CLAUDEMD
# ${name} — Project Instructions

**Repo:** ${repo}
**Vision:** ${vision}
**Created:** $(date +%Y-%m-%d) via The Foundry scaffold

## What This Is

${vision}

## Key Files

| File | Purpose |
|------|---------|
| \`CLAUDE.md\` | This file — project identity and AI context |
| \`HANDOVER.md\` | Live working context (updated continuously during work) |
| \`features/\` | Living component docs (one file per domain) |
| \`docs/05-planning/\` | Plans and roadmaps |
| \`.foundry/\` | Pipeline runtime artifacts |

## Rules

1. **GitHub is the single source of truth.** Issues, milestones, project boards.
2. **HANDOVER.md is ephemeral.** Updated during work, cleared when task completes.
3. **features/ docs are living.** They grow and evolve over the project lifetime.
4. **No 10-folder docs/ sprawl.** Only \`docs/05-planning/\` for Claude Code plans.
5. **Every piece of work gets a GitHub issue.** No work without a tracker entry.

## Methodology

This project uses **The Software Foundry** (\`growthpigs/the-foundry\`).
Pipeline: MINE → SCOUT → ASSAY → CRUCIBLE → PLAN → HAMMER → TEMPER → AUTORESEARCH → RALPH LOOP

## Active Work

Check GitHub issues: \`gh issue list --repo ${repo}\`
CLAUDEMD

  # HANDOVER.md
  cat > HANDOVER.md << 'HANDOVERMD'
# HANDOVER

**Status:** New project — no work started yet.

<!-- This file is updated CONTINUOUSLY during work. Not at session end. -->
<!-- If the session crashes, zero context should be lost. -->
HANDOVERMD

  # .foundry/.gitkeep
  touch .foundry/.gitkeep
  touch features/.gitkeep
  touch docs/05-planning/.gitkeep

  # Commit and push
  git add -A
  git commit -m "feat: Initialize project via Foundry scaffold

Thin scaffold: CLAUDE.md, HANDOVER.md, features/, docs/05-planning/, .foundry/
Vision: ${vision}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
  git branch -M main
  git push -u origin main 2>/dev/null || git push origin main
  echo "  Scaffold pushed to main."

  # 3. Create labels
  echo "[3/7] Creating labels..."
  for label in "admin-doc" "epic" "story" "spike" "P0-blocking" "P1-high" "P2-important" "P3-nice" "autoresearch-finding"; do
    gh label create "$label" --repo "$repo" --color "ededed" 2>/dev/null
  done
  for phase in mine scout assay crucible plan hammer temper autoresearch; do
    gh label create "phase:$phase" --repo "$repo" --color "c5def5" 2>/dev/null
  done
  echo "  Labels created."

  # 4. Create Admin milestone
  echo "[4/7] Creating Admin milestone..."
  gh api repos/${repo}/milestones -f title="Admin Documents" -f description="The 18 Admin Documents (The Foundry ASSAY phase)" 2>/dev/null
  echo "  Admin milestone created."

  # 5. Create the 18 Admin Document issues
  echo "[5/7] Creating 18 Admin Document issues..."
  local admin_docs=(
    "01: Agreement (SOW + MOU)"
    "02: Client Requirements"
    "03: User Stories (with failure definitions)"
    "04: User Journeys"
    "05: Glossary & Terminology"
    "06: Tech Stack & Integration Map"
    "07: Architecture Decision Log (ADRs)"
    "08: Product Features"
    "09: Capabilities (Plugins, Skills, Patterns)"
    "10: Dependency & Risk Map"
    "11: Competitive Landscape"
    "12: KPI & Success Metrics"
    "13: Onboarding Checklist"
    "14: Prompt Library"
    "15: Client Prerequisites"
    "16: Full Cost Breakdown"
    "17: Test Strategy"
    "18: Work Ledger (DU tracking)"
  )
  for doc in "${admin_docs[@]}"; do
    gh issue create --repo "$repo" --title "[ADMIN] $doc" --label "admin-doc" --milestone "Admin Documents" --body "Admin Document for ${name}. To be completed during ASSAY phase.

## Status
- [ ] Draft
- [ ] Review
- [ ] Final

## Content

<!-- Fill during ASSAY phase -->" 2>/dev/null
  done
  echo "  18 Admin issues created."

  # 6. Create Activity Log and Work Ledger issues
  echo "[6/7] Creating Activity Log & Work Ledger..."
  gh issue create --repo "$repo" --title "Activity Log" --label "admin-doc" --body "# Activity Log — ${name}

Session-by-session activity tracking. Updated every turn during work.

## Format
\`\`\`
## [Date] — [Session Summary]
- [Turn N]: [What happened]
- DECISION: [Choice made and why]
- DISCOVERED: [What we learned]
\`\`\`" --pin 2>/dev/null

  gh issue create --repo "$repo" --title "Work Ledger" --label "admin-doc" --body "# Work Ledger — ${name}

Development Units (DU) tracking. Updated at session wrap.

| Date | Task | Est. DUs | Actual DUs | Phase | Notes |
|------|------|----------|------------|-------|-------|
" --pin 2>/dev/null
  echo "  Activity Log & Work Ledger created and pinned."

  # 7. Create Phase Master Index issue
  echo "[7/7] Creating Phase Master Index..."
  gh issue create --repo "$repo" --title "Phase Master Index — Initial Setup" --body "# Phase Master Index — ${name}

## Status: Scaffolded
Created $(date +%Y-%m-%d) via The Foundry scaffold.

## P0 — High Priority
| # | Issue | Feature | Est. DUs | Dependency |
|---|-------|---------|----------|------------|
| | (to be filled during PLAN phase) | | | |

## Recommended Build Order
TBD — populate during PLAN phase after ASSAY completes.

## Methodology
This project uses The Software Foundry. See \`growthpigs/the-foundry\` for methodology docs." --pin 2>/dev/null
  echo "  Phase Master Index created and pinned."

  # Summary
  echo ""
  echo "═══════════════════════════════════════════════"
  echo "  SCAFFOLD COMPLETE"
  echo "═══════════════════════════════════════════════"
  echo ""
  echo "  Repo:        https://github.com/$repo"
  echo "  CLAUDE.md:   YES"
  echo "  HANDOVER.md: YES"
  echo "  Folders:     features/, docs/05-planning/, .foundry/"
  echo "  Labels:      $(gh label list --repo "$repo" --json name -q 'length') created"
  echo "  Admin docs:  18 issues in Admin milestone"
  echo "  Activity Log: pinned"
  echo "  Work Ledger:  pinned"
  echo "  Master Index: pinned"
  echo ""
  echo "  Next: cd into the project and run:"
  echo "    gh repo clone $repo"
  echo "    cd $name"
  echo "    $FOUNDRY_DIR/bin/launch.sh --mode GREENFIELD"
  echo ""

  # Cleanup
  rm -rf "$tmp_dir"
}

# Check for --new flag BEFORE detecting project
if [ "${1:-}" = "--new" ]; then
  SCAFFOLD_NAME="${2:-}"
  SCAFFOLD_ORG="${3:-growthpigs}"
  SCAFFOLD_VISION="${4:-}"

  if [ -z "$SCAFFOLD_NAME" ]; then
    echo -n "Project name (kebab-case): "
    read -r SCAFFOLD_NAME
  fi
  if [ -z "$SCAFFOLD_VISION" ]; then
    echo -n "Vision (one sentence): "
    read -r SCAFFOLD_VISION
  fi

  scaffold_project "$SCAFFOLD_NAME" "$SCAFFOLD_ORG" "$SCAFFOLD_VISION"
  exit 0
fi

# ─────────────────────────────────────────────────
# DETECT PROJECT (existing project mode)
# ─────────────────────────────────────────────────

# Get repo info from current directory
REPO=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com/||; s|\.git$||' || echo "")
if [ -z "$REPO" ]; then
  echo "ERROR: Not in a git repo with a GitHub remote." >&2
  echo "Run this from inside your project directory." >&2
  exit 1
fi

PROJECT_NAME=$(basename "$REPO")
PROJECT_PATH=$(git rev-parse --show-toplevel 2>/dev/null)
OWNER=$(echo "$REPO" | cut -d'/' -f1)

echo "═══════════════════════════════════════════════"
echo "  THE FOUNDRY — Phase 0: LAUNCH"
echo "  Project: $PROJECT_NAME ($REPO)"
echo "═══════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────
# DETECT MODE
# ─────────────────────────────────────────────────

MODE="${1:-}"
EPIC=""
ISSUE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE=$(echo "$2" | tr '[:lower:]' '[:upper:]')
      shift 2
      ;;
    --epic)
      EPIC="$2"
      shift 2
      ;;
    --issue)
      ISSUE="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Default mode
if [ -z "$MODE" ]; then
  echo "Available modes: GREENFIELD, FEATURE, FIX, HOTFIX, SPEC, REFACTOR, SECURE"
  echo -n "Select mode [FEATURE]: "
  read -r MODE
  MODE=$(echo "${MODE:-FEATURE}" | tr '[:lower:]' '[:upper:]')
fi

# ─────────────────────────────────────────────────
# DETECT PROJECT ARTIFACTS
# ─────────────────────────────────────────────────

# Find Activity Log issue
ACTIVITY_LOG=$(gh issue list --repo "$REPO" --state open --json number,title -q '.[] | select(.title | test("[Aa]ctivity [Ll]og")) | .number' 2>/dev/null | head -1)
ACTIVITY_LOG="${ACTIVITY_LOG:-UNKNOWN}"

# Find Work Ledger issue
WORK_LEDGER=$(gh issue list --repo "$REPO" --state open --json number,title -q '.[] | select(.title | test("[Ww]ork [Ll]edger")) | .number' 2>/dev/null | head -1)
WORK_LEDGER="${WORK_LEDGER:-UNKNOWN}"

# Check for HANDOVER.md
HAS_HANDOVER="NO"
if [ -f "$PROJECT_PATH/HANDOVER.md" ]; then
  HAS_HANDOVER="YES"
fi

# Check for CLAUDE.md
HAS_CLAUDE_MD="NO"
if [ -f "$PROJECT_PATH/CLAUDE.md" ]; then
  HAS_CLAUDE_MD="YES"
fi

# Count admin issues
ADMIN_COUNT=$(gh issue list --repo "$REPO" --milestone "Admin" --state open --json number -q 'length' 2>/dev/null || echo "0")

# ─────────────────────────────────────────────────
# DETERMINE STARTING PHASE
# ─────────────────────────────────────────────────

case "$MODE" in
  GREENFIELD)
    START_PHASE="Phase 1 (MINE) — full pipeline from scratch"
    ;;
  FEATURE)
    START_PHASE="Phase 3 (ASSAY) — MINE/SCOUT already done"
    if [ "$ADMIN_COUNT" -ge 15 ]; then
      START_PHASE="Phase 5 (PLAN) — specs exist, ready to decompose"
    fi
    ;;
  FIX|HOTFIX)
    START_PHASE="Phase 6 (HAMMER) — fix and ship"
    ;;
  SPEC)
    START_PHASE="Phase 3 (ASSAY) — spec only, no code"
    ;;
  REFACTOR|SECURE)
    START_PHASE="Phase 3 (ASSAY) — understand, then build carefully"
    ;;
  *)
    START_PHASE="Phase 3 (ASSAY) — default"
    ;;
esac

# ─────────────────────────────────────────────────
# GENERATE THE PROMPT
# ─────────────────────────────────────────────────

echo "Generating launch prompt..."
echo ""
echo "════════════════════════════════════════════════════════"
echo "  COPY EVERYTHING BELOW INTO A FRESH CC SESSION"
echo "════════════════════════════════════════════════════════"
echo ""

cat << PROMPT
# The Foundry — $MODE Pipeline for $PROJECT_NAME

You are running The Foundry methodology. Read the methodology FIRST, then the project.

## Step 1: Load The Foundry (read in this order)
1. Methodology: ~/_PAI/operations/the-foundry/README.md
2. Phases: ~/_PAI/operations/the-foundry/phases/ (all files)
3. Ratify gates: ~/_PAI/operations/the-foundry/phases/ratify.md
4. Modes: ~/_PAI/operations/the-foundry/modes/MODES.md
5. Stage map: ~/_PAI/operations/the-foundry/modes/STAGE-MAP.md

## Step 2: Load Project Context
1. Project CLAUDE.md: $PROJECT_PATH/CLAUDE.md
2. Project HANDOVER.md: $PROJECT_PATH/HANDOVER.md
3. Admin docs: gh issue list --repo $REPO --milestone "Admin" --state open
4. Activity Log: gh issue view $ACTIVITY_LOG --repo $REPO
5. Work Ledger: gh issue view $WORK_LEDGER --repo $REPO

## Step 3: Mode & Starting Phase
- **Mode:** $MODE
- **Starting phase:** $START_PHASE
PROMPT

# Add epic/issue context if provided
if [ -n "$EPIC" ]; then
  echo "- **Epic:** $EPIC"
fi
if [ -n "$ISSUE" ]; then
  echo "- **Issue:** #$ISSUE (gh issue view $ISSUE --repo $REPO)"
fi

cat << 'PROMPT'

## Step 4: Your Mission

[DESCRIBE YOUR MISSION HERE — what needs to be done]

## Rules
- Follow The Foundry methodology exactly as documented
- Run every applicable Ratify gate — NEVER skip R8 (Honest Gate)
- Log to Activity Log every turn
- Update Work Ledger at session wrap
- "Verification requires Execution. File existence does not imply functionality."
- If an assumption fails, STOP and report. Don't work around it.
- Active projects: LifeModo, IT Concierge, War Room ONLY

## At Session End
Produce a SITREP with:
- What worked in the methodology
- What was confusing or missing
- What you'd change about The Foundry
- R8 Honest Gate scores (Correctness, UX/Intent, Stability)
PROMPT

echo ""
echo "════════════════════════════════════════════════════════"
echo "  END OF PROMPT — paste the above into a fresh CC tab"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Project detected:"
echo "  Repo:         $REPO"
echo "  Path:         $PROJECT_PATH"
echo "  Mode:         $MODE"
echo "  Start:        $START_PHASE"
echo "  Activity Log: #$ACTIVITY_LOG"
echo "  Work Ledger:  #$WORK_LEDGER"
echo "  CLAUDE.md:    $HAS_CLAUDE_MD"
echo "  HANDOVER.md:  $HAS_HANDOVER"
echo "  Admin docs:   $ADMIN_COUNT issues"
