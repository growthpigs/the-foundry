# The Software Foundry — Project Instructions

**This is the canonical repository for The Foundry methodology** (also called **The Software Foundry** for clarity).

**Do not confuse with The Thinking Foundry:**
- **The Thinking Foundry** (`growthpigs/thinking-foundry`) = Structured thinking for decision-making. Outputs FSDs.
- **The Software Foundry** (this repo) = Structured building from FSDs. Builds software.

Both use similar phase structures but apply to different domains. See [The Thinking Foundry CLAUDE.md](https://github.com/growthpigs/thinking-foundry/blob/main/CLAUDE.md) for the thinking system.

## What This Is

A complete product lifecycle methodology for AI-assisted software engineering:

```
PRE-FOUNDRY → LAUNCH → MINE → SCOUT → ASSAY → CRUCIBLE → PRODUCT-AUDIT
→ EXT.AUDITOR → PLAN → HAMMER → TEMPER → AUTORESEARCH → RALPH LOOP → POST-FOUNDRY
```

13 Ratify gates (R0 through R8 + R4b + R4c + R-AR + R-Triage). The Squeeze after every gate.

## Key Files

| File | Purpose |
|------|---------|
| **Lifecycle** | |
| `phases/pre-foundry.md` | Client intake, Gemini Gem interview, kill criteria, handoff format |
| `phases/00-launch.md` | Phase 0: run `bin/launch.sh` to generate session prompt |
| `phases/01-mine.md` | Phase 1: firehose capture |
| `phases/02-scout.md` | Phase 2: research + deployment pipeline setup |
| `phases/03-assay.md` | Phase 3: spec (18 admin docs, FSDs with CRUD matrices, Assumption Table, Persona walkthrough) |
| `phases/04-crucible.md` | Phase 4: adversarial NotebookLM debates per domain (≥9/10 confidence gate) |
| `phases/04c-product-audit.md` | Phase 4c: post-Crucible product strategy stress-test (5-prompt template) |
| `phases/04b-external-auditor.md` | Phase 4b: independent model review (Gemini/GPT circuit breaker) |
| `phases/05-plan.md` | Phase 5: GitHub issues, sprints, "Drop the Hammer" |
| `phases/06-hammer.md` | Phase 6: build (Dark Factory, Ralph pattern, DTU) |
| `phases/07-temper.md` | Phase 7: harden, test, deploy, ship |
| `phases/07b-autoresearch.md` | Phase 7b: Karpathy experimental loop — validate through experimentation |
| `phases/08-ralph-loop.md` | Phase 8: capture learnings, feed forward |
| `phases/post-foundry.md` | Bug triage, issue intake (60s), rollback protocol, maintenance |
| `phases/ratify.md` | The 13 Ratify gates + The Squeeze + toolkit prompts |
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
| `knowledge/autoresearch-template.md` | Shared program.md template for AutoResearch (both Foundries) |
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

## Production-Validated Improvements (March 2026)

Five improvements integrated from IT Concierge retrospective (`growthpigs/it-concierge#147`). All proven in production — 34% of IT Concierge fixes were preventable with these gates.

| Improvement | Phase | What It Catches |
|---|---|---|
| State Sync Architecture Spike | ASSAY (Step 3) | Complex state bugs from unverified sync assumptions |
| Migration Verification Gate | TEMPER (Step 3b) | Ghost migrations — committed but never applied to database |
| Server Error Logging Standard | HAMMER (standard) + TEMPER (Step 3c) | Silent failures — errors caught but never logged |
| Visual Review Gate | TEMPER (Step 5a) | UI regressions invisible to code review |
| Red-Team After Every Epic | TEMPER (Step 5c) | Systemic issues missed by per-story testing |

## Three-Tier Project System

Ideas flow through three tiers. No repo sprawl.

```
TIER 1: Thinking Foundry Vault (growthpigs/thinking-foundry-vault)
  → Each thinking session = one GitHub issue
  → 90% stay here forever. That's fine.
  ↓ FSD Approval Gate (confidence >= 7)

TIER 2: Fledgling (growthpigs/fledgling)
  → Promoted ideas incubating before build
  → Each gets a folder with FSD + research
  ↓ "Drop the Hammer" (confidence >= 9, budget allocated)

TIER 3: Project Repo (growthpigs/project-name)
  → Full scaffold via: launch.sh --new "project-name" "growthpigs" "vision"
  → Creates: repo, CLAUDE.md, HANDOVER.md, 18 admin issues, labels, Activity Log
```

**Scaffold command:** `./bin/launch.sh --new "project-name" "org" "vision sentence"`

## Active Projects Using The Foundry

- LifeModo (`growthpigs/lifemodo`)
- IT Concierge (`growthpigs/it-concierge`)
- War Room (`growthpigs/alpha-war-room`)
