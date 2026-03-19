# Stage Map — 7 Foundry Phases ↔ 13 Pipeline Stages

The Foundry has **7 conceptual phases** (MINE → TEMPER). The `bin/foundry.sh` runner executes **13 granular stages**. This document maps between them.

## Why Two Systems?

The 7 phases are for humans — they describe WHAT you're doing (mining ideas, scouting, assaying specs, etc.).

The 13 stages are for the machine — they describe HOW the pipeline runner executes each step via `claude -p` with fresh context.

## The Map

```
FOUNDRY PHASE          PIPELINE STAGES (foundry.sh)
─────────────          ─────────────────────────────
1. MINE                (manual — not automated by foundry.sh)

2. SCOUT               explore

3. ASSAY               issue
                       user-stories
                       fsd

4. CRUCIBLE            issue-review
                       red-team / red-team-quick / red-team-spec

5. PLAN                (manual — GitHub issue creation via scrum-master skill)

6. HAMMER              anti-regression (baseline capture)
                       code
                       validate / validate-fast

7. TEMPER              e2e
                       pr / pr-restricted
                       pr-review
                       compliance
                       follow-up
                       (anti-regression comparison — runs after code)
```

## Detailed Mapping

| foundry.sh Stage | Foundry Phase | What It Does |
|-----------------|---------------|-------------|
| `issue` | ASSAY | Create/refine the GitHub issue |
| `user-stories` | ASSAY | Generate user stories with failure definitions |
| `explore` | SCOUT | Read-only codebase research |
| `issue-review` | CRUCIBLE | Independent review of issue quality |
| `fsd` | ASSAY | Write Functional Specification Document |
| `red-team` | CRUCIBLE | Adversarial stress-test (predictive) |
| `red-team-quick` | CRUCIBLE | Abbreviated red-team for FIX mode |
| `red-team-spec` | CRUCIBLE | Spec-only red-team (no code review) |
| `anti-regression` | HAMMER | Capture baseline before code changes |
| `anti-regression-critical` | HAMMER | Extended baseline for REFACTOR mode |
| `code` | HAMMER | Main implementation work |
| `validate` | TEMPER | TypeScript check + test suite |
| `validate-fast` | TEMPER | Quick validation for HOTFIX |
| `e2e` | TEMPER | End-to-end browser testing |
| `pr` | TEMPER | Create pull request |
| `pr-restricted` | TEMPER | Private PR for SECURE mode |
| `pr-review` | TEMPER | AI-assisted PR review |
| `compliance` | TEMPER | Post-code compliance check (retrospective red-team) |
| `follow-up` | TEMPER | Knowledge capture, cleanup, next steps |

## What's Manual vs Automated

| Phase | Automated by foundry.sh? | How It's Done |
|-------|--------------------------|---------------|
| MINE | No | Human firehose capture, interviews, brain dumps |
| SCOUT | Partially | `explore` stage runs, but IDEO sprint / art direction are manual skills |
| ASSAY | Yes | `issue` → `user-stories` → `fsd` stages |
| CRUCIBLE | Yes | `issue-review` → `red-team` stages. NotebookLM debates are manual. |
| PLAN | No | GitHub issue creation via `foundry-pipe-02-scrum-master` skill |
| HAMMER | Yes | `anti-regression` → `code` → `validate` stages |
| TEMPER | Yes | `e2e` → `pr` → `pr-review` → `compliance` → `follow-up` stages |

## Mode Impact on Stage Execution

See [MODES.md](MODES.md) for which modes skip which phases. Within a phase, the mode may also change which stage variant runs:

| Mode | Stage Variants |
|------|---------------|
| GREENFIELD | All stages, standard variants |
| FEATURE | Skips `explore`. Uses `red-team-quick` instead of full `red-team` |
| FIX | Skips `issue-review`, `fsd`, `pr-review`. Skips `compliance` unless fix touches CRUD lifecycle (in which case persona code tracing runs). |
| HOTFIX | Only `code` → `validate-fast` → `pr` → `follow-up` |
| REFACTOR | Uses `anti-regression-critical` (captures test names + file checksums) |
| SECURE | Uses `pr-restricted` (private branch, embargo) |
| SPEC | Only `issue` → `user-stories` → `explore` → `issue-review` → `fsd` → `red-team-spec` → `follow-up`. No code. |
