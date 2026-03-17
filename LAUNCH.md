# The Foundry — Session Launch Template

**Use this template to start ANY Foundry session on ANY project.**

Replace everything in `[BRACKETS]` with your project specifics.

---

## The Prompt

```
# The Foundry — [MODE] Pipeline for [PROJECT NAME]

You are running The Foundry methodology. Read the methodology FIRST, then the project.

## Step 1: Load The Foundry (read in this order)
1. Methodology: ~/_PAI/projects/system/the-foundry/README.md
2. Phases: ~/_PAI/projects/system/the-foundry/phases/ (all files)
3. Ratify gates: ~/_PAI/projects/system/the-foundry/phases/ratify.md
4. Modes: ~/_PAI/projects/system/the-foundry/modes/MODES.md
5. Stage map: ~/_PAI/projects/system/the-foundry/modes/STAGE-MAP.md

## Step 2: Load Project Context
1. Project CLAUDE.md: [PROJECT PATH]/CLAUDE.md
2. Project HANDOVER.md: [PROJECT PATH]/HANDOVER.md
3. Admin docs: gh issue list --repo [REPO] --milestone "Admin" --state open
4. Activity Log: gh issue view [ACTIVITY_LOG_ISSUE] --repo [REPO]

## Step 3: Determine Starting Phase

[Choose ONE — delete the others]

### GREENFIELD (new project, start from scratch)
Start at Phase 1 (MINE). Run all 7 phases sequentially.
No existing specs. No existing code. Full pipeline.

### FEATURE (new feature on existing project)
Start at Phase 3 (ASSAY). MINE and SCOUT already done.
Existing architecture. New feature needs speccing + building.

### FIX (bug fix)
Start at Phase 6 (HAMMER). Spec the fix, then build it.
Issue already exists. Architecture unchanged.

### SPEC (architecture only, no code)
Start at Phase 3 (ASSAY). Stop after Phase 4b (External Auditor).
Output is validated specs, not code.

## Step 4: Your Mission

[DESCRIBE WHAT NEEDS TO BE DONE — e.g.,
"Run LifeModo E1 (Platform Foundation) through PLAN → HAMMER → TEMPER.
Validate: Does Supabase RLS with SET LOCAL work through PgBouncer?
Does OpenClaw registerService() support 5-min cron?"]

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
```

---

## Quick-Fill Examples

### LifeModo E1 (Platform Foundation)
```
PROJECT NAME: LifeModo
MODE: FEATURE
PROJECT PATH: ~/_PAI/projects/personal/lifemodo
REPO: growthpigs/lifemodo
ACTIVITY_LOG_ISSUE: 447
STARTING PHASE: Phase 5 (PLAN) — MINE/SCOUT/ASSAY/CRUCIBLE already done
MISSION: Run E1 through PLAN → HAMMER → TEMPER. Validate PgBouncer
SET LOCAL and OpenClaw cron. Build Supabase project + schema migrations.
```

### IT Concierge (New Feature)
```
PROJECT NAME: IT Concierge
MODE: FEATURE
PROJECT PATH: ~/_PAI/projects/personal/it-concierge
REPO: growthpigs/it-concierge
ACTIVITY_LOG_ISSUE: 46
STARTING PHASE: Phase 3 (ASSAY)
MISSION: [describe the feature]
```

### New Project (Greenfield)
```
PROJECT NAME: [New Project]
MODE: GREENFIELD
PROJECT PATH: ~/_PAI/projects/[category]/[name]
REPO: growthpigs/[name]
ACTIVITY_LOG_ISSUE: [create one]
STARTING PHASE: Phase 1 (MINE)
MISSION: Bootstrap from zero. Full 7-phase pipeline.
```
