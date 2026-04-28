#!/usr/bin/env bash
# create-foundation.sh — Scaffold the canonical Foundation + Features milestones
# with 11 always-true doc issues. INDEX issue gets pinned.
#
# Usage: create-foundation.sh OWNER/REPO
#
# Pattern established in growthpigs/personal-brand (2026-04-28).
# Foundation milestone holds slowly-changing reference docs:
#   INDEX (TOC, AI's map)
#   README (what this project IS)
#   ARCHITECTURE (system design)
#   DESIGN SYSTEM (palette, typography, spacing)
#   RUNBOOK (deploy, DNS, recovery)
#   HANDOVER (current session state — mirrors HANDOVER.md)
#   ACTIVE TASKS (today's TODO — mirrors ACTIVE-TASKS.md)
#   TECHNIQUES (reusable patterns catalog)
#   GLOSSARY (project vocabulary)
#   BRAND STRATEGY (positioning, voice, audience)
#   LEARNINGS (gotchas, anti-patterns)
# Features milestone holds feature epics — added as work progresses.

set -euo pipefail

REPO="${1:-}"
if [ -z "$REPO" ]; then
  echo "Usage: $0 OWNER/REPO"
  exit 1
fi

echo "→ Scaffolding Foundation pattern for $REPO"

# Skip if Foundation already exists
EXISTING=$(gh api "repos/$REPO/milestones?state=all" --jq '.[].title' 2>/dev/null | grep -F "📚 Foundation" || true)
if [ -n "$EXISTING" ]; then
  echo "  ⚠  Foundation milestone already exists — skipping milestone creation."
  FOUNDATION_NUM=$(gh api "repos/$REPO/milestones?state=all" --jq '.[] | select(.title == "📚 Foundation") | .number')
else
  FOUNDATION_NUM=$(gh api "repos/$REPO/milestones" -X POST \
    -f title="📚 Foundation" \
    -f description="Always-true project documentation. The INDEX (top of milestone) is the AI's map — read it first." \
    -f state=open --jq '.number')
  echo "  ✓ Foundation milestone #$FOUNDATION_NUM created"
fi

EXISTING_FEAT=$(gh api "repos/$REPO/milestones?state=all" --jq '.[].title' 2>/dev/null | grep -F "🎬 Features" || true)
if [ -z "$EXISTING_FEAT" ]; then
  FEATURES_NUM=$(gh api "repos/$REPO/milestones" -X POST \
    -f title="🎬 Features" \
    -f description="Feature epics — each significant feature gets its own issue here." \
    -f state=open --jq '.number')
  echo "  ✓ Features milestone #$FEATURES_NUM created"
fi

# Helper: create a doc issue, skip if it already exists
create_doc_issue() {
  local title="$1"; shift
  local body="$1"; shift
  local existing
  existing=$(gh issue list --repo "$REPO" --milestone "📚 Foundation" --state all --search "$title in:title" --json number --jq '.[0].number' 2>/dev/null || echo "")
  if [ -n "$existing" ]; then
    echo "  ⚠  Issue '$title' exists as #$existing — skipping"
    echo "$existing"
    return
  fi
  gh issue create --repo "$REPO" --milestone "📚 Foundation" --label "documentation" --title "$title" --body "$body" 2>&1 | tail -1 | sed 's|.*/||'
}

# Note: we create INDEX LAST so it can reference all the others' numbers.
# Create the 10 non-INDEX docs first, capturing their numbers.

README_BODY=$(cat <<'EOF'
## Project: <PROJECT_NAME>

**Owner**: <OWNER>
**Repo**: <REPO>
**Domain**: <DOMAIN, if applicable>

## What this is

<One-paragraph description of what this project does and who it's for.>

## Tech stack

<List the key technologies. e.g., React 19 + Vite, Python + FastAPI, etc.>

## How to run

```bash
# Setup commands
# Dev server command
# Test command
# Build command
```

## File map

- `<key dirs and what's in them>`

## Key decisions (locked)

| Decision | Value |
|---|---|
| <decision> | <value> |

## Discoverability

The INDEX issue (first issue in this Foundation milestone) is the canonical map of where everything lives.
EOF
)
README_NUM=$(create_doc_issue "README — What this project IS" "$README_BODY")

ARCH_BODY=$(cat <<'EOF'
## High-level architecture

<System diagram / description.>

### Layers

1. **Routing**: <details>
2. **State**: <details>
3. **Data**: <details>
4. **Build**: <details>
5. **Hosting**: <details>

### Key architectural patterns

<List or link patterns from the TECHNIQUES catalog.>

## Tech-debt notes

<Known compromises, future refactors.>

## Future architecture decisions

<Pending decisions that need to be made.>
EOF
)
ARCH_NUM=$(create_doc_issue "ARCHITECTURE — System Design" "$ARCH_BODY")

DESIGN_BODY=$(cat <<'EOF'
## Locked palette

<Color list with HEX values. Define in CSS once, reference everywhere.>

## Typography law

<Font families and rules — what each font is for.>

## Spacing & layout

<Variables, breakpoints, common spacing units.>

## Component primitives

<List of reusable design components and where they live.>

## Rules

- <Style rule 1>
- <Style rule 2>
EOF
)
DESIGN_NUM=$(create_doc_issue "DESIGN SYSTEM — Palette, Typography, Spacing" "$DESIGN_BODY")

RUNBOOK_BODY=$(cat <<'EOF'
## Domain & DNS

**Domain**: <domain>
**Registrar**: <registrar>
**DNS**: <where DNS is hosted>
**SSL**: <SSL provider and renewal>

## Deploy story

<How to deploy. Production vs staging environments.>

## Local development

```bash
# Setup commands
```

## Tests

```bash
# Test commands
```

## Recovery scenarios

### If main branch breaks
1. <steps>

### If regression tests fail
**Do NOT lower assertions.** Read the test, find the regression, fix the code.

## Secrets / accounts

<List of services and which accounts they're under. NO actual secrets here — just pointers.>

## Cross-machine

<Notes if project moves between dev machines.>
EOF
)
RUNBOOK_NUM=$(create_doc_issue "RUNBOOK — Deploy, DNS, Recovery" "$RUNBOOK_BODY")

HANDOVER_BODY=$(cat <<'EOF'
## Purpose

Mirrors `HANDOVER.md` in repo root. Living doc — updated every session. Tells the next AI what's currently in-flight.

**Update protocol**: When you start a session, read this. When you stop a session, update it.

## Current state (YYYY-MM-DD)

### Last commit on main
<sha> — <subject>

### Locked & shipped
- <feature 1>

### In-flight / pending
- <task 1>

### What's NOT touched
<Areas of the project not yet built.>

### Active CC sessions
- <machine>: <work>

### Coordination notes for parallel sessions
- <Notes on file locks, branches, who-touches-what>
EOF
)
HANDOVER_NUM=$(create_doc_issue "HANDOVER — Current Session State (LIVING)" "$HANDOVER_BODY")

ACTIVE_BODY=$(cat <<'EOF'
## Purpose

Mirrors `ACTIVE-TASKS.md` in repo root. Today's work queue, prioritized.

## TODO

### P0 — blocking
- [ ] <task>

### P1 — high
- [ ] <task>

### P2 — important
- [ ] <task>

### P3 — nice
- [ ] <task>

## Done today

- ✅ <completed item>
EOF
)
ACTIVE_NUM=$(create_doc_issue "ACTIVE TASKS — Today's TODO (LIVING)" "$ACTIVE_BODY")

TECH_BODY=$(cat <<'EOF'
## Purpose

Reusable architectural patterns and animation techniques verified to work in this project. Each is project-agnostic and can be lifted into other projects.

When you solve something tricky, document the TECHNIQUE here so future-you (and other AI) can reuse it.

## Catalog

### #T01 — <name>
<description>
**Source**: <link>
**Use when**: <conditions>

## How to add a new technique

1. New comment with format: `### #TXX — <name>` + description + source link
2. If the technique introduces invariants, add regression tests
3. Update INDEX issue if the technique becomes critical to a feature
EOF
)
TECH_NUM=$(create_doc_issue "TECHNIQUES — Reusable Patterns Catalog" "$TECH_BODY")

GLOSSARY_BODY=$(cat <<'EOF'
## Purpose

Single source of truth for project-specific vocabulary. Prevents two AI sessions using the same term with different meanings.

## Terms

| Term | Means |
|---|---|
| <term> | <meaning> |

## Anti-glossary (terms NOT to use)

| Don't say | Say instead |
|---|---|
| <wrong> | <right> |

## How to add a term

New comment with: `### <Term>`, what it means, where to find an example.
EOF
)
GLOSSARY_NUM=$(create_doc_issue "GLOSSARY — Project Terms (Disambiguation)" "$GLOSSARY_BODY")

BRAND_BODY=$(cat <<'EOF'
## Purpose

Locked brand truths. What this project IS, who it serves, how it sounds. Single source of truth for any copy / design / content decision.

> **🚀 Filling this out: run the `Impact` skill** (`~/.claude/skills/Impact/`).
> Impact is a 7-phase Content Intelligence Analysis (CIA) system that researches
> the audience, market, competitors, and emotional landscape, then produces the
> full Marketing Blueprint covering Jon Benson's BNSN 112-point framework.
> Trigger: say "run impact" or "marketing research".

## 🧱 Marketing Blueprint Skeleton (BNSN-aligned)

Fill in each section. Every field below should be answered with specifics — no hand-waving.

### Identity & Positioning
- **[Name]**: <project name>
- **[URL]**: <domain>
- **[Niche]**:
- **[Key Thematics]**:
- **[Core SEO Keywords]**:
- **[Mission]**:
- **[Vision]**:
- **[Core Values]**:
- **[Tone and Personality]**:

### Avatar (audience psychology — BNSN points 1-25)
- **[Avatar]**:
- **[Avatar Story]**:
- **[Target Audience]**:
- **[Core Emotions]**:
- **[Biggest Fears]**:
- **[Key Relationships Affected]**:
- **[Hurtful Relationship Soundbites]**:

### Pain Points & Problems (BNSN points 26-45)
- **[Core Problem]**:
- **[Primary Complaint]**:
- **[Secondary Complaints]**:
- **[Failed Solutions]**:
- **[Failed Solution Soundbites]**:
- **[Deal Breaker Fixes]**:
- **[Deal Breaker Soundbites]**:

### Desires & Goals (BNSN points 46-65)
- **[Primary Goal]**:
- **[Secondary Goals]**:
- **[Primary Transformation]**:
- **[Key Relationship Post Transformation]**:
- **[Key Relationship Post Transformation Soundbites]**:
- **[Market Success Hinges-on]**:
- **[Market Success By Giving Up]**:

### Objections & Resistance (BNSN points 66-80)
- **[Primary Objection]**:
- **[Ultimate Fear]**:
- **[Mistaken Beliefs]**:
- **[Expensive Alternatives]**:
- **[Market Blames]**:
- **[Market Objections]**:

### Solution Positioning (BNSN points 81-95)
- **[Promises]**:
- **[Benefits]**:
- **[Unique Mechanism]**:
- **[Emotionalized Unique Mechanism]**:
- **[Gaddie Product Story]**:
- **[Simple Product Story]**:
- **[Market]**:
- **[Market Narrative]**:

### Trust & Credibility (BNSN points 96-105)
- **Flagship case study**:
- **Authority indicators**:
- **Social proof elements**:
- **Customer transformation evidence**:

### Conversion Psychology (BNSN points 106-112)
- **Urgency triggers**:
- **Decision catalysts**:
- **Funnel**:
- **[Content Goal 1]**:
- **[Content Goal 2]**:

## Voice & tone

- <voice attribute>

## Visual identity

<key visual rules>

## Locked decisions index

| Decision | Issue |
|---|---|
| <decision> | <issue ref> |

---

> **Reference**: full BNSN 7-category framework in `~/.claude/skills/Impact/PROMPTS/phase-6-convergence.md`.
> Working template example: Drive doc "Serene Mind + Marketing Blueprint" (showing the structure applied to a real project).
EOF
)
BRAND_NUM=$(create_doc_issue "BRAND STRATEGY — Positioning, Voice, Audience" "$BRAND_BODY")

LEARNINGS_BODY=$(cat <<'EOF'
## Purpose

Lessons learned. Gotchas. "We tried X, it broke." Read before declaring any work done.

When you discover something the hard way, document it here so future-you doesn't repeat it.

## Lessons

### #L01 — <name>
**Context**: <what we were doing>
**Anti-pattern**: <the wrong move we made>
**Right answer**: <what works>
**Source**: <link if relevant>

## How to add a lesson

New comment with: `### #LNN — <name>` + Context / Anti-pattern / Right answer / Source structure.
EOF
)
LEARNINGS_NUM=$(create_doc_issue "LEARNINGS — Gotchas, Anti-Patterns" "$LEARNINGS_BODY")

# Now create INDEX with all references
INDEX_BODY=$(cat <<EOF
# 📍 INDEX

> **If you're an AI picking up this project for the first time, read this. It's your map.**

This issue tells you where everything lives, what it means, and what to read in what order.

## ⚡ TL;DR for fresh AI

You are working on **<PROJECT_NAME>**. Read these in order:
1. **[#$README_NUM README](https://github.com/$REPO/issues/$README_NUM)** — what this project IS
2. **[#$HANDOVER_NUM HANDOVER](https://github.com/$REPO/issues/$HANDOVER_NUM)** — what's currently in-flight
3. **[#$ACTIVE_NUM ACTIVE TASKS](https://github.com/$REPO/issues/$ACTIVE_NUM)** — today's TODO

Everything else is reference material.

## 🗺️ Foundation milestone (always-true docs)

| What | Issue | When to read |
|---|---|---|
| 📍 INDEX (this) | this | First, every session |
| README | [#$README_NUM](https://github.com/$REPO/issues/$README_NUM) | First, then on need |
| ARCHITECTURE | [#$ARCH_NUM](https://github.com/$REPO/issues/$ARCH_NUM) | Before touching architecture |
| DESIGN SYSTEM | [#$DESIGN_NUM](https://github.com/$REPO/issues/$DESIGN_NUM) | Before any visual change |
| RUNBOOK | [#$RUNBOOK_NUM](https://github.com/$REPO/issues/$RUNBOOK_NUM) | Before deploying or debugging prod |
| HANDOVER | [#$HANDOVER_NUM](https://github.com/$REPO/issues/$HANDOVER_NUM) | Every session start |
| ACTIVE TASKS | [#$ACTIVE_NUM](https://github.com/$REPO/issues/$ACTIVE_NUM) | Every session start |
| TECHNIQUES | [#$TECH_NUM](https://github.com/$REPO/issues/$TECH_NUM) | Before solving a tricky problem |
| GLOSSARY | [#$GLOSSARY_NUM](https://github.com/$REPO/issues/$GLOSSARY_NUM) | When confused about terms |
| BRAND STRATEGY | [#$BRAND_NUM](https://github.com/$REPO/issues/$BRAND_NUM) | Before any copy/content decision |
| LEARNINGS | [#$LEARNINGS_NUM](https://github.com/$REPO/issues/$LEARNINGS_NUM) | Before declaring done |

## 🎬 Features milestone (feature epics)

Each feature is its own issue. Sub-tasks live as comments or linked issues.

(Features will be added here as scoped.)

## 🗂️ File system map

| Where | What |
|---|---|
| \`/HANDOVER.md\` | Mirrors HANDOVER issue |
| \`/ACTIVE-TASKS.md\` | Mirrors ACTIVE TASKS issue |
| \`/CLAUDE.md\` | Project-level Claude instructions |
| \`/features/\` | Local AI working memory; mirrors GitHub Foundation issues |

## 🔄 The "GitHub is SOT" rule

GitHub issues are SINGLE SOURCE OF TRUTH for this project. Local .md files MIRROR GitHub. If they diverge, GitHub wins.

When you update a Foundation doc locally, update the matching GitHub issue in the same commit.

## 🚦 Order of operations for any new task

1. Read this INDEX
2. Read HANDOVER — what's in-flight
3. Check ACTIVE TASKS — what to work on
4. If touching architecture, read ARCHITECTURE
5. If touching visuals, read DESIGN SYSTEM
6. If touching brand/copy, read BRAND STRATEGY
7. Before declaring done, check LEARNINGS for relevant gotchas

## 🤝 Multi-session coordination

When 2+ CC sessions are active simultaneously:
1. Each session updates HANDOVER before starting
2. Use \`/lock\` skill to claim work
3. Prefer working on different files
4. Pull frequently if working on shared files
EOF
)
INDEX_NUM=$(create_doc_issue "📍 INDEX — Project Map (READ THIS FIRST)" "$INDEX_BODY")

echo ""
echo "✅ Foundation scaffolded for $REPO"
echo "   Foundation milestone: #$FOUNDATION_NUM"
echo "   INDEX issue: #$INDEX_NUM"
echo ""
echo "→ Next: pin INDEX (gh issue pin $INDEX_NUM --repo $REPO)"
echo "→ Next: edit each doc issue with project-specific content"
echo "→ Next: create /HANDOVER.md and /ACTIVE-TASKS.md as local mirrors"
echo ""
echo "INDEX_NUM=$INDEX_NUM"  # parseable output for downstream automation
