# The Foundry

**Spec-First Development Methodology for AI-Assisted Software Engineering**

---

## The Metaphor

The Foundry is a metallurgical pipeline. Raw ore (ideas) is mined, prospected, smelted into refined specifications, stress-tested in a crucible, autonomously forged into code, hardened through testing, and shipped as a finished product.

Every phase transition passes through a **Ratify** gate — a forced cognitive mode switch from builder to reviewer.

## The 7 Phases

```
  ┌──────────┐  R  ┌──────────┐  R  ┌──────────┐  R  ┌──────────┐
  │ 1. MINE  │──►──│ 2. SCOUT │──►──│ 3. ASSAY │──►──│4.CRUCIBLE│
  │ Capture  │  A  │ Research │  A  │  Thrash  │  A  │ Validate │
  └──────────┘  T  └──────────┘  T  └──────────┘  T  └──────────┘
                I                I                I        │
                F                F                F        │ R
                Y                Y                Y        │ A
                                                           │ T
  ┌──────────┐  R  ┌──────────┐  R  ┌──────────┐         │ I
  │ 7. TEMPER│◄─◄──│ 6.HAMMER │◄─◄──│ 5. PLAN  │◄────────┘ F
  │  Harden  │  A  │  Build   │  A  │Blueprint │           Y
  └──────────┘  T  └──────────┘  T  └──────────┘
       │        I                I
       │        F                F
       ▼        Y                Y
  ┌──────────┐
  │  RALPH   │  ← Learnings from TEMPER feed back to MINE
  │  LOOP    │
  └──────────┘
```

| # | Stage | What Happens | Duration |
|---|-------|-------------|----------|
| 1 | **MINE** | Firehose capture. Raw ideas, links, transcripts. Zero filtering. | 30-60 min |
| 2 | **SCOUT** | Research. Competitors, APIs, IDEO sprint, art direction. | 1-4 hours |
| 3 | **ASSAY** | Thrash specs. 18 admin docs, FSDs, user stories + test stubs. | 2-10 days |
| 4 | **CRUCIBLE** | Adversarial NotebookLM debates. Per domain group. Score ≥ 75%. | 1-2 hrs/group |
| 5 | **PLAN** | GitHub issues, sprints, epics. "Drop the Hammer" decision. | 1-2 hours |
| 6 | **HAMMER** | Code. Dark Factory mode. Ralph loop. Digital twin testing. | Days-weeks |
| 7 | **TEMPER** | Harden. E2E, anti-regression, compliance check, deploy, ship. | 1-4 hrs/PR |

**"Drop the Hammer"** = the decision between PLAN and HAMMER. After this, you commit to building. Before it, everything is reversible.

## Phase Classification

| Phases | Domain | What's Happening |
|--------|--------|-----------------|
| 1-4 | **Thrashing** | Thinking, speccing, debating. Zero code. |
| 5-6 | **Coding** | Building and hardening. Code is a commodity. |
| 7 | **Shipping** | Hardening, deploying, and proving it works. |

## The Ratify System

**Ratify** is the bridge between every phase. It's not optional. See [phases/ratify.md](phases/ratify.md).

Each gate has a **phase-specific protocol** — different prompts, different checks, different cognitive mode. R1 asks "is this worth building?" R7 asks "prove it's done with evidence."

| Gate | After | Type | Threshold |
|------|-------|------|-----------|
| R1 Scope | MINE | Soft | ≥ 6/10 |
| R2 Vision | SCOUT | Soft | ≥ 6/10 |
| R3 Spec | ASSAY | **Hard** | ≥ 8/10 + Independent Observer |
| R4 Adversarial | CRUCIBLE | **Hard** | ≥ 8/10 + all domains scored |
| R5 Ready | PLAN | **Hard** | ≥ 8/10 + "Drop the Hammer" |
| R6 Build | HAMMER | **Hard** | ≥ 8/10 + tests pass |
| R7 Ship | TEMPER | **Hard** | ≥ 9/10 + evidence for every claim |

**Hard gate** = pipeline STOPS. Go back and fix. **Soft gate** = flag concerns, proceed with awareness.

## Industry Lineage

The Foundry stands on the shoulders of 35 years of methodology:

| Source | Year | Contribution |
|--------|------|-------------|
| IDEO Design Thinking | 1991 | Empathize-first, 5-stage diverge/converge |
| Double Diamond | 2005 | Discover → Define → Develop → Deliver |
| Agile/Scrum | 2001 | Iterative delivery, user stories, sprints |
| Architecture Decision Records | 2011 | Document decisions with WHY |
| Lean Startup | 2011 | Build-Measure-Learn, validated learning |
| Nate B. Jones Five Primitives | 2025 | Safe agent operations, knowledge persistence |
| StrongDM Dark Factory | 2026 | Level 5 autonomous coding, digital twin |
| GitHub spec-kit | 2026 | Constitution concept, spec-driven development |
| Ralph Pattern | 2026 | Fresh context per stage, `claude -p` execution |

See [LINEAGE.md](LINEAGE.md) for the full intellectual ancestry.

## Repository Structure

```
the-foundry/
├── README.md                 # This file
├── CONSTITUTION.md           # 35 immutable articles (the law)
├── LINEAGE.md                # Industry ancestry
├── phases/
│   ├── 01-ideation.md        # Mine the ore
│   ├── 02-scout.md           # Prospect
│   ├── 03-metallurgy.md      # Smelt (specs, FSDs, admin docs)
│   ├── 04-crucible.md        # Stress-test (NotebookLM debates)
│   ├── 05-dark-factory.md    # Autonomous build
│   ├── 06-forge.md           # Harden (E2E, anti-regression)
│   ├── 07-hammer.md          # Ship (PR, deploy, validate)
│   └── ratify.md             # The 7 Ratify gates
├── knowledge/
│   ├── anti-regression.md    # Baseline capture spec
│   ├── progress-txt.md       # Offensive knowledge lifecycle
│   └── output-locations.md   # Where artifacts land
├── modes/
│   └── MODES.md              # FULL, FIX, HOTFIX, REFACTOR, SECURE, SPEC
├── bin/
│   └── foundry.sh            # The pipeline runner
└── research/
    └── spec-first-2026.md    # Industry landscape research
```

## Quick Start

1. Every project gets a `CLAUDE.md` that references this methodology
2. New project? Start at Phase 1 (Ideation) and work through sequentially
3. Bug fix on existing project? Jump to Phase 5 (Dark Factory) in FIX mode
4. Production emergency? Phase 5 in HOTFIX mode
5. Architecture question? Phase 3-4 in SPEC mode (no code)

## Core Philosophy

> "Documentation is everything. Coding is a commodity." — Roderic Andrews

The Foundry exists because AI has made code generation cheap but hasn't made thinking cheap. A perfect spec produces mechanical code. An imperfect spec produces expensive debugging. The cost of thinking is always less than the cost of fixing.

The Foundry is how you think before you build.

---

**Created:** March 2026
**Author:** Roderic Andrews
**License:** Private (growthpigs)
