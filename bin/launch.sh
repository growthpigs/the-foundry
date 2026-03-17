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
# DETECT PROJECT
# ─────────────────────────────────────────────────

FOUNDRY_DIR="$HOME/_PAI/projects/system/the-foundry"

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
1. Methodology: ~/_PAI/projects/system/the-foundry/README.md
2. Phases: ~/_PAI/projects/system/the-foundry/phases/ (all files)
3. Ratify gates: ~/_PAI/projects/system/the-foundry/phases/ratify.md
4. Modes: ~/_PAI/projects/system/the-foundry/modes/MODES.md
5. Stage map: ~/_PAI/projects/system/the-foundry/modes/STAGE-MAP.md

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
