# The Foundry — Project Instructions

**This is the canonical repository for The Foundry methodology.**

## What This Is

A 7-phase spec-first development methodology for AI-assisted software engineering:
MINE → SCOUT → ASSAY → CRUCIBLE → PLAN → HAMMER → TEMPER

Each phase connected by RATIFY gates (7 phase-specific validation protocols).

## Key Files

| File | Purpose |
|------|---------|
| `README.md` | Overview, pipeline diagram, quick start |
| `CONSTITUTION.md` | 37 immutable articles — the law |
| `LINEAGE.md` | Industry ancestry (IDEO → StrongDM → us) |
| `phases/*.md` | Detailed docs per phase |
| `phases/ratify.md` | The 7 Ratify gates with prompt patterns |
| `modes/MODES.md` | 7 pipeline modes with skip matrices |
| `knowledge/*.md` | Anti-regression, progress.txt, output locations |
| `bin/foundry.sh` | The pipeline runner (runs from bare terminal) |
| `research/*.md` | Industry research (spec-first 2026, DTU) |

## Rules

1. **This repo is methodology, not code.** No application code lives here.
2. **The Constitution is immutable.** Amendments require Roderic's explicit approval.
3. **Phase names are LOCKED:** MINE, SCOUT, ASSAY, CRUCIBLE, PLAN, HAMMER, TEMPER. Do not rename.
4. **GitHub Issues track work on the methodology itself** — not on projects using it.
5. **When updating, check cross-references.** A rename in one file must propagate to all files that reference it.

## Relationship to Other Systems

- `~/.claude/skills/DarkFoundry/` — Points here. Retains the execution layer (foundry.sh, mode classifier).
- `~/.claude/skills/ScoutMeta/` — Implements Phase 2 (SCOUT).
- `~/.claude/skills/StrikeMeta/` — Implements Phase 4 (CRUCIBLE).
- `~/.claude/skills/foundry-pipe-01/02/03/` — Implements Phase 3/5/6 execution.
- LifeModo #52 — Historical. Deprecated with pointer to this repo.

## Active Projects Using The Foundry

- LifeModo (`growthpigs/lifemodo`)
- IT Concierge (`growthpigs/it-concierge`)
- War Room (`growthpigs/alpha-war-room`)
