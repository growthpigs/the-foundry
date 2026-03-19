# The Foundry — Project Instructions

**This is the canonical repository for The Foundry methodology.**

## What This Is

A complete product lifecycle methodology for AI-assisted software engineering:

```
PRE-FOUNDRY → LAUNCH → MINE → SCOUT → ASSAY → CRUCIBLE → EXT.AUDITOR
→ PLAN → HAMMER → TEMPER → RALPH LOOP → POST-FOUNDRY
```

11 Ratify gates (R0 through R8 + R4b + R-Triage). The Squeeze after every gate.

## Key Files

| File | Purpose |
|------|---------|
| **Lifecycle** | |
| `phases/pre-foundry.md` | Client intake, Gemini Gem interview, kill criteria, handoff format |
| `phases/00-launch.md` | Phase 0: run `bin/launch.sh` to generate session prompt |
| `phases/01-mine.md` | Phase 1: firehose capture |
| `phases/02-scout.md` | Phase 2: research + deployment pipeline setup |
| `phases/03-assay.md` | Phase 3: spec (18 admin docs, FSDs with CRUD matrices, Assumption Table, Persona walkthrough) |
| `phases/04-crucible.md` | Phase 4: adversarial NotebookLM debates per domain |
| `phases/04b-external-auditor.md` | Phase 4b: independent model review (Gemini/GPT circuit breaker) |
| `phases/05-plan.md` | Phase 5: GitHub issues, sprints, "Drop the Hammer" |
| `phases/06-hammer.md` | Phase 6: build (Dark Factory, Ralph pattern, DTU) |
| `phases/07-temper.md` | Phase 7: harden, test, deploy, ship |
| `phases/08-ralph-loop.md` | Phase 8: capture learnings, feed forward |
| `phases/post-foundry.md` | Bug triage, issue intake (60s), rollback protocol, maintenance |
| `phases/ratify.md` | The 11 Ratify gates + The Squeeze + toolkit prompts |
| **System** | |
| `README.md` | Overview, pipeline diagram, philosophy, quick start |
| `CONSTITUTION.md` | 37 immutable articles (symlinked from DarkFoundry) |
| `LINEAGE.md` | Industry ancestry (IDEO → StrongDM → us) |
| `modes/MODES.md` | 7 pipeline modes with skip matrices |
| `modes/STAGE-MAP.md` | Maps 7 phases ↔ 13 foundry.sh stages |
| `bin/launch.sh` | Phase 0 script: auto-generates session prompt from project context |
| `bin/foundry.sh` | The pipeline runner (Bash 3.2 safe, runs from bare terminal) |
| `knowledge/anti-regression.md` | Baseline capture specification |
| `knowledge/progress-txt.md` | Offensive knowledge lifecycle |
| `knowledge/output-locations.md` | Where artifacts land per project |
| `research/spec-first-2026.md` | Industry landscape (spec-kit, Kiro, Tessl, StrongDM, METR) |
| `research/dtu-digital-twin.md` | Digital Twin Universe feasibility assessment |

## Rules

1. **This repo is methodology, not code.** No application code lives here.
2. **The Constitution is immutable.** Amendments require Roderic's explicit approval.
3. **Phase names are LOCKED:** MINE, SCOUT, ASSAY, CRUCIBLE, PLAN, HAMMER, TEMPER. Do not rename.
4. **GitHub Issues track work on the methodology itself** — not on projects using it.
5. **When updating, check cross-references.** A rename in one file must propagate to all files that reference it.
6. **The Squeeze runs after every Ratify gate.** Don't skip it.
7. **Pre-Foundry and Post-Foundry are part of the lifecycle.** Not afterthoughts.

## Relationship to Other Systems

- `~/.claude/skills/DarkFoundry/` — Points here. CONSTITUTION.md is a symlink.
- `~/.claude/skills/ScoutMeta/` — Implements Phase 2 (SCOUT).
- `~/.claude/skills/StrikeMeta/` — Implements Phase 4 (CRUCIBLE).
- `~/.claude/skills/foundry-pipe-01/02/03/` — Implements Phase 3/5/6 execution.
- `~/.claude/skills/IssueIntake/` — Implements Post-Foundry's 60-second capture.
- Gemini Gem (AI App Intake Workshop) — Implements Pre-Foundry interview.
- LifeModo #52 — Historical. Deprecated with pointer to this repo.

## Active Projects Using The Foundry

- LifeModo (`growthpigs/lifemodo`)
- IT Concierge (`growthpigs/it-concierge`)
- War Room (`growthpigs/alpha-war-room`)
