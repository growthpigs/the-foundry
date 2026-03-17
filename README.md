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
| **R4b Auditor** | **Ext. Auditor** | **Hard** | Different model, verdict YES/CONDITIONAL |
| R5 Ready | PLAN | **Hard** | ≥ 8/10 + "Drop the Hammer" |
| R6 Build | HAMMER | **Hard** | ≥ 8/10 + tests pass |
| R7 Ship | TEMPER | **Hard** | ≥ 9/10 + evidence for every claim |
| **R8 Honest** | **ALL phases** | **Hard** | ≥ 9/10 on all 3 scores + "what am I not asking?" |

**Hard gate** = pipeline STOPS. Go back and fix. **Soft gate** = flag concerns, proceed with awareness.

**R8 is special** — it runs after EVERY mode completes, including HOTFIX. It bypasses AI sycophancy by asking "Are you happy?" with permission to be frank. If any confidence score is below 9, you're not done.

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
├── CLAUDE.md                 # Project instructions for CC sessions
├── README.md                 # This file
├── CONSTITUTION.md           # 37 immutable articles (the law)
├── LINEAGE.md                # Industry ancestry (IDEO → StrongDM → us)
├── .gitignore                # Excludes .foundry/ runtime artifacts
├── phases/
│   ├── 01-mine.md            # Mine the ore
│   ├── 02-scout.md           # Prospect
│   ├── 03-assay.md           # Smelt (specs, FSDs, admin docs)
│   ├── 04-crucible.md        # Stress-test (NotebookLM debates)
│   ├── 04b-external-auditor.md # Independent model review (circuit breaker)
│   ├── 05-plan.md            # Blueprint (issues, sprints)
│   ├── 06-hammer.md          # Build (Dark Factory, Ralph loop)
│   ├── 07-temper.md          # Harden & ship (E2E, deploy)
│   └── ratify.md             # The 8 Ratify gates (R1-R7 + R8 Honest)
├── knowledge/
│   ├── anti-regression.md    # Baseline capture spec
│   ├── progress-txt.md       # Offensive knowledge lifecycle
│   └── output-locations.md   # Where artifacts land
├── modes/
│   ├── MODES.md              # 7 pipeline modes with skip matrices
│   └── STAGE-MAP.md          # Maps 7 phases ↔ 13 pipeline stages
├── bin/
│   └── foundry.sh            # The pipeline runner (Bash 3.2 safe)
├── templates/
│   └── session-launch.md    # Launch template for any project
└── research/
    ├── spec-first-2026.md    # Industry landscape research
    └── dtu-digital-twin.md   # Digital Twin Universe feasibility
```

## Quick Start

1. Every project gets a `CLAUDE.md` that references this methodology
2. New project? Start at Phase 1 (MINE) and work through sequentially in GREENFIELD mode
3. Bug fix on existing project? Jump to Phase 6 (HAMMER) in FIX mode
4. Production emergency? Phase 6 in HOTFIX mode
5. Architecture question? Phase 3-4 (ASSAY + CRUCIBLE) in SPEC mode (no code)

## Core Philosophy

> "Documentation is everything. Coding is a commodity." — Roderic Andrews

The Foundry exists because AI has made code generation cheap but hasn't made thinking cheap. A perfect spec produces mechanical code. An imperfect spec produces expensive debugging. The cost of thinking is always less than the cost of fixing.

The Foundry is how you think before you build.

### Why Spec-First, Not Code-First

AI models are trained on billions of "just ship it" posts. Every instinct in the model screams: start coding, iterate, fix bugs as they come. **This instinct is wrong for AI-assisted development.**

The evidence:

- **LifeModo** spent 10 days in ASSAY+CRUCIBLE before writing a line of code. On day 9, they discovered the product's actual identity — the Life Admin Engine. If they'd started coding on day 2, they'd have built the wrong product and discovered it 3 months later.
- **IT Concierge** ran a Crucible with 0% false positive rate — 16 real architectural issues found in specs, not in code. Every one would have been a week of debugging if found during implementation.
- **The METR study** (2025) found experienced developers using AI tools WITHOUT structure took 19% LONGER than without AI at all. Spec-first is the structure that makes AI coding productive.

### The Greenfield Principle

> Build it right the first time. Greenfield is cheap. Brownfield is expensive.

When you have perfect specs and zero existing code, AI generates clean, consistent implementations in hours. When you have imperfect specs and thousands of lines of existing code, AI generates conflicts, regressions, and integration bugs that take days to untangle.

The Foundry pushes coding as late as possible — not because coding is hard, but because coding the WRONG THING is catastrophically expensive. Every hour in ASSAY saves 10 hours in HAMMER. Every Crucible finding saves a week of debugging.

### The "How It Feels" Gap

Specs tell you WHAT the system does. They cannot tell you HOW it FEELS. A Morning Brief specification can define the format, timing, and content — but it can't tell you whether it feels like "having an EA again" or like "another notification digest."

This is the gap between ASSAY and HAMMER. The spec defines the contract. The prototype reveals the experience. The Foundry acknowledges this gap explicitly: **ASSAY produces correctness. HAMMER produces feeling. Both are required.**

The answer is NOT to skip ASSAY and "just build it to see how it feels." The answer is to spec thoroughly (so you know WHAT to build), then prototype precisely (so you know HOW it feels), then iterate on the feeling (not the architecture).

### When AI Pushes Back

AI will tell you to start coding. It will say "we've spent a lot of time on docs." It will suggest "let's just prototype this." Recognize this as a training artifact, not engineering wisdom.

The correct response: "The spec isn't done until I've found the soul of the product. LifeModo found it on day 9. IT Concierge found 16 bugs on day 3. The cost of thinking is always less than the cost of fixing. Keep speccing."

---

**Created:** March 2026
**Author:** Roderic Andrews
**License:** Private (growthpigs)
