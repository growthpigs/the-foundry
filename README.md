# The Foundry

**Spec-First Development Methodology for AI-Assisted Software Engineering**

---

## The Metaphor

The Foundry is a metallurgical pipeline. Raw ore (ideas) is mined, prospected, smelted into refined specifications, stress-tested in a crucible, autonomously forged into code, hardened through testing, and shipped as a finished product.

Every phase transition passes through a **Ratify** gate — a forced cognitive mode switch from builder to reviewer.

## The 7 Phases

```
1. IDEATION        Mine the ore — capture raw ideas, firehose, brain dump
   └── ⚖️ R1: Scope Gate
2. SCOUT           Prospect — research, competitors, IDEO sprint, art direction
   └── ⚖️ R2: Vision Gate
3. METALLURGY      Smelt — thrash specs, FSDs, user stories, 18 admin docs
   └── ⚖️ R3: Spec Gate
4. CRUCIBLE        Stress-test — adversarial NotebookLM debates, per domain group
   └── ⚖️ R4: Adversarial Gate
5. DARK FACTORY    Autonomous build — digital twin, code drops, Ralph loop
   └── ⚖️ R5: Build Gate
6. FORGE           Harden — E2E testing, anti-regression, compliance check
   └── ⚖️ R6: Harden Gate
7. HAMMER          Ship — PR, deploy, blood test, CIC validation
   └── ⚖️ R7: Ship Gate
```

## Phase Classification

| Phases | Domain | What's Happening |
|--------|--------|-----------------|
| 1-4 | **Thrashing** | Thinking, speccing, debating. Zero code. |
| 5-6 | **Coding** | Building and hardening. Code is a commodity. |
| 7 | **Shipping** | Deploying and proving it works. |

## The Ratify System

**Ratify** is the bridge between every phase. It's not optional. See [phases/ratify.md](phases/ratify.md).

Each gate has a **phase-specific protocol** — different prompts, different checks, different cognitive mode. R1 asks "is this worth building?" R7 asks "prove it's done with evidence."

A Ratify gate requires **confidence ≥ 8/10** to proceed. Below 8, you fix what's wrong. You don't move forward on hope.

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
