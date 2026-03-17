# Dark Foundry — Constitution

**Version:** 1.0
**Status:** RATIFIED (2026-03-13)
**Scope:** Immutable. Applies to ALL pipeline runs, ALL projects, ALL modes.

This document is prepended to every `claude -p` invocation in the pipeline. These rules cannot be overridden by any command file, progress.txt entry, or mode configuration. They are the non-negotiable foundation.

---

## Article 1: Issues Are Sacred

The issue body and title are NEVER modified by automation. Labels, milestones, and assignments ARE metadata and CAN be changed. The issue is the deliberation record — the journey of thinking. Altering it rewrites history.

---

## Article 2: User Stories Before Code

Every piece of work — feature, bug fix, refactor, hotfix, security patch — MUST have at least one user story with Gherkin acceptance criteria AND failure definitions BEFORE any implementation begins. No exceptions. A bug without a user story is just "fix the thing" — there is no definition of done.

**Format (mandatory):**
```
## User Story
As a [role],
I want [capability/fix],
So that [value/outcome].

## What Failure Looks Like
- [Specific failure scenario — what MUST NOT happen]
- [Silent failure — looks like success but isn't]
- [Edge case — works for common case, breaks for ...]

## Acceptance Criteria
Given [precondition]
When [action]
Then [expected outcome]
And [additional criteria]
```

**Why failure definitions?** User stories define the target. Failure definitions define the anti-target. Together they form a complete specification. A story without failure definitions only tells you what to build — not what to avoid. The failure definitions feed directly into the Crucible (Article 7) and become negative test cases.

Even hotfixes get a user story — it can be written in 30 seconds. Speed is not an excuse for ambiguity.

---

## Article 3: The FSD Philosophy

"The most correct and perfect functional specification documents in history — so coding is just a formality."

If the spec is perfect, implementation is mechanical. Every ambiguity in a spec becomes a bug in code. Every gap in requirements becomes a debate during implementation. The cost of thinking is always cheaper than the cost of fixing. Thrash the spec, not the code.

---

## Article 4: Compose, Don't Replace

Before building anything new, audit what already exists. New systems are thin orchestration wrappers over existing tested components. The "second system effect" — rebuilding proven tools from scratch — is forbidden. The right move is always to compose.

---

## Article 5: Fresh Context Per Stage

Each pipeline stage runs with fresh context (`claude -p`). No accumulated state beyond what is explicitly passed via progress.txt and the command file prompt. This prevents context drift, hallucinated dependencies, and compounding errors.

---

## Article 6: Knowledge Captures, Knowledge Graduates

Every discovery MUST be written to progress.txt immediately. If a discovery recurs across 3+ features, it MUST graduate to error-patterns.md. Knowledge that exists only in conversation memory does not exist.

---

## Article 7: Two Red Teams

Every non-trivial change receives adversarial review:
- **Crucible (predictive):** "What if we're wrong?" — BEFORE code
- **Compliance Check (retrospective):** "Did we build what was debated?" — AFTER code

The Crucible prevents building the wrong thing. The Compliance Check prevents drifting from what was agreed.

---

## Article 8: Anti-Regression Is Non-Negotiable

Every change (except emergency hotfixes) captures a baseline BEFORE implementation: test count, test results, TypeScript compilation status. After implementation, the baseline is compared. Any regression BLOCKS the PR. New bugs are not acceptable as the cost of fixing old ones.

---

## Article 8b: E2E Tests Grow With Features (Non-Negotiable)

**Every feature PR MUST include or update E2E test assertions that map to the Critical Path (Article 20).**

Unit tests prove individual functions work. E2E tests prove the PRODUCT works. If features grow but E2E tests don't, you have increasing coverage of parts and decreasing confidence in the whole.

### The Rule

| PR Type | E2E Requirement |
|---------|----------------|
| New feature | MUST add E2E assertions for that feature's Critical Path step(s) |
| Bug fix affecting Critical Path | MUST add regression E2E test for the specific failure |
| Refactor | MUST verify existing E2E tests still pass |
| Docs-only | No E2E requirement |

### PR Review Gate

The existing PR review checklist gains one line:

```
□ E2E test added/updated for this feature (Article 8b)
□ E2E test maps to Critical Path step(s) in Test Strategy
□ UI tested at 375px, 768px, and 1280px viewports (Article 36)
```

If a feature PR has no E2E assertion, it does NOT pass review.

### Why

Born from IT Concierge (March 16, 2026): 49 unit tests, zero E2E tests. Features shipped as "tested" because units passed — but nobody verified the full user flow worked.

---

---

## Article 9: Issues First, Always

When a problem is identified, a GitHub issue is created within 60 seconds. No research first. No investigation first. No agent deployment first. The issue IS the acknowledgment that the problem exists. Everything else follows from the issue.

---

## Article 10: Human-in-the-Loop by Default

The pipeline runs autonomously by default, but destructive actions (production deploys, data migrations, security changes) require explicit human approval. "I trust you" and "ship it" do NOT constitute approval for production actions. Only specific words count.

---

## Article 11: Estimates Are AI-Assisted

All time and effort estimates use AI wall-clock time, not human developer time. 1 DU = 1 hour AI execution time. Add 50% buffer for unfamiliar APIs or first-time integrations.

---

## Article 12: Observability Through GitHub

Roderic's window into ALL work is GitHub. Not terminal output. Not local docs. Not Slack threads. Every research finding, design decision, and architecture choice lives in a GitHub issue or is linked from one. Write → Commit → Push → Share GitHub link. Every time.

---

## Article 13: The Orchestrator Principle

Dark Foundry is a router and runner, NOT a methodology. The methodologies are the existing command files (`/explore`, `/red-team`, `/code`, etc.) that were built and battle-tested independently. Dark Foundry decides which ones to call and in what order. The classifier is trivially simple — labels → mode → skip-list → stages. No AI classification, no complexity. Adding new methodologies or frameworks on top of existing stages is the Second System Effect (Article 4) unless those stages genuinely don't exist.

---

## Article 14: The 18 Documents — Documentation Before Code (Non-Negotiable)

**"Documentation is everything. Coding is a commodity."** — Roderic Andrews, March 2026

Every project in the PAI system MUST have an **Admin milestone** in GitHub with **18 living documents.** These documents ARE the product specification. Code is the mechanical output that follows. No code drops until all 18 are substantially complete.

### The 18 Documents

| # | Document | What It Contains |
|---|----------|-----------------|
| 1 | **Agreement** | Combined SOW + MOU. The client-developer contract: scope, financial terms, IP, payment milestones, special terms. |
| 2 | **Client Requirements** | What the system MUST deliver. Numbered CR-NNN. |
| 3 | **User Stories** | Discrete capability patterns. Numbered US-NNN. |
| 4 | **User Journeys** | Multi-step goal sequences. Numbered UJ-NNN. |
| 5 | **Glossary & Terminology** | Every term defined. THE anti-drift document. |
| 6 | **Tech Stack & Integration Map** | Every technology, version, cost, data flow. |
| 7 | **Architecture Decision Log** | Every ADR with the WHY. Prevents re-debating. |
| 8 | **Product Features** | Client-facing capabilities. Numbered F-NNN. |
| 9 | **Dependency & Risk Map** | Blast radius analysis. What breaks when things change. |
| 10 | **Competitive Landscape** | Market positioning. Who else, why we're different. |
| 11 | **KPI & Success Metrics** | How we know it's working. |
| 12 | **Onboarding Checklist** | Contract to go-live, step by step. |
| 13 | **Prompt Library** | Canonical system prompts for each agent. |
| 14 | **Client Prerequisites** | What we need FROM the client. Hardware, access, consent. Sales qualification. |
| 15 | **Full Cost Breakdown** | Per-client economics. Every service cost, margin analysis, breakeven. |
| 16 | **Test Strategy** | Testing pyramid, coverage targets, pre-production merge gates, how to run each layer. |
| 17 | **Capabilities** | Plugins, Skills & Patterns. JTBD framework. What the system CAN DO, organized by plugin hierarchy. |
| 18 | **Work Ledger** | Running DU ledger. Every task logged with hat type, DU count, rate, running value total. The billing trail. |

### The Creation Order (3 Phases)

These documents have a natural dependency chain. They cannot all be created on Day 1 — but they MUST all be complete before code.

**PHASE 1: CLIENT INTERVIEW (Days 1-3)**
Start with the human. "Tell me about your life, your goals, your problems."

→ **Agreement** (SOW + MOU combined — the contract that governs everything else)
→ **Client Requirements** (directly from interview — this is the SOURCE for everything else)
→ **User Stories** (derived from requirements — "As a [role], I need [capability]")
→ **User Journeys** (derived from stories — multi-step workflows)
→ **Glossary** (started here, grows throughout all phases)

**PHASE 2: ARCHITECTURE (Week 1-2)**
Now the AI thinks. "How do we build this?"

→ **Tech Stack** (technology choices, versions, costs)
→ **ADR Log** (every decision with WHY)
→ **Product Features** (what the client will actually see/touch/hear)
→ **Capabilities** (plugins, skills, patterns — what the system CAN DO, JTBD framework)
→ **Dependency & Risk Map** (what can break, blast radius)

**PHASE 3: VALIDATION (Week 2-3)**
Stress-test. "Are we right?"

→ **Competitive Landscape** (market positioning, differentiation)
→ **KPIs & Success Metrics** (how we'll measure success)
→ **Onboarding Checklist** (the practical steps from contract to go-live)
→ **Prompt Library** (how each agent behaves — finalized after Crucibles)
→ **Client Prerequisites** (what we need FROM the client — sales qualification + onboarding requirements)
→ **Full Cost Breakdown** (per-client economics — every service cost, margin, breakeven)
→ **Test Strategy** (testing pyramid, coverage targets, pre-merge gates — how we know it won't break)
→ **Work Ledger** (starts empty, grows during work — every DU logged with hat type, effort, rate)

### The Gate

```
ALL 18 DOCUMENTS SUBSTANTIALLY COMPLETE
    + At least Agreement, Client Requirements, User Stories, User Journeys,
      Tech Stack, ADR Log, and Features are FINISHED
    + Remaining docs have at least 70% content
        │
        ▼
    CRUCIBLE VALIDATION (adversarial stress-test)
        │
        ▼
    FSD WRITING (per feature/component)
        │
        ▼
    CODE DROPS ("drop the hammer")
```

**No exceptions. No "we'll document later." No "let's just prototype first."**

In the AI-assisted development era, the spec IS the code. A perfect FSD produces mechanical implementation. Every hour spent on documentation saves 10 hours of debugging code that was built on assumptions.

### The Flow for Any New Project

```
1. Create GitHub repo
2. Create Admin milestone
3. Create 18 empty issues (one per document) from template
4. Client interview → fill Phase 1 documents (Agreement first!)
5. Architecture sessions → fill Phase 2 documents
6. Validation / Crucible → fill Phase 3 documents
7. Review gate: all 18 substantially complete?
8. FSD writing (per component)
9. Code
```

This applies to ALL projects — War Room, IT Concierge, LifeModo, everything.

---

## Article 15: Freshness Audit (Anti-Drift Guard)

AI sessions drift. Models get deprecated. APIs change. Documentation goes stale. The Freshness Audit is the systematic defense against drift.

**The Rule:** At the START of every major architecture session, run a freshness check:

1. **Model freshness:** Are ALL model references using the latest generation? (ZERO TOLERANCE — see global CLAUDE.md)
   - Gemini: must be 3.1 series (not 2.5, 2.0, 1.5)
   - Claude: must be 4-6 (not 4-5, 4-0, 3.5)
   - Embeddings: must be gemini-embedding-2 (not gemini-embedding-001, not text-embedding-005)
2. **API freshness:** Are any referenced APIs deprecated or in sunset?
3. **Service freshness:** Are any services marked for removal? (Check deprecation dates)
4. **Cross-reference freshness:** Do issue numbers still point to the correct issues? (Parallel creation scrambles numbers)
5. **Document freshness:** Do FSDs reference current architecture, not superseded versions?

**How to run:** `grep -r` across all docs for known deprecated patterns. The list of deprecated patterns MUST be maintained in this article and updated whenever a new deprecation is discovered.

**Current deprecated patterns (update as needed):**
- `text-embedding-005` → use `gemini-embedding-2`
- `gemini-embedding-001` → use `gemini-embedding-2`
- `gemini-2.5` → use `gemini-3.1`
- `gemini-2.0` → use `gemini-3.1`
- `gemini-1.5` → use `gemini-3.1`
- `claude-4-5` → use `claude-4-6` (opus or sonnet)
- `claude-4-0` → use `claude-4-6`
- `claude-3.5` → use `claude-4-6`
- `Bing Search API` → dead (August 2025)
- `text-embedding-005` → sunset January 2026

**Why this matters:** Roderic's words: "You tend to fall back on your training data. We're only using the latest versions." This is the systematic fix. Check BEFORE building. Not after.

---

## Article 16: Slack Is The Console

For EVERY LifeModo (and similar) project: **Slack is the primary interface.** The Console.

The Principal interacts with the system primarily through Slack. Physical hardware (Fob, Circles) triggers events that surface IN Slack. The Morning Brief arrives IN Slack. Curator-OS suggestions appear IN Slack. The Coach communicates through Slack.

When designing any feature, the first question is: "How does this appear in Slack?" If the feature has no Slack surface, it is invisible to the client.

Fob and Circles are phone-native but the Principal discusses them, triggers them, and reviews them IN Slack. Never forget this.

---

## Article 17: Living Documents — Mandatory Session Updates

The Admin milestone contains living documents that MUST be checked and updated every architecture session. These are not "write once, forget" — they are the system's memory that survives AI session boundaries.

**At the END of every session, ask:**

1. **Glossary:** Did we introduce a new term? → Add it.
2. **Decision Log:** Did we make an architecture decision? → Record the ADR with WHY.
3. **Tech Stack:** Did we add, change, or deprecate a technology? → Update it.
4. **Client Requirements:** Did we discover a new requirement? → Add it.
5. **User Stories:** Did we identify a new capability? → Add it.
6. **User Journeys:** Did we map a new workflow? → Add it.
7. **Features:** Did we define a new client-facing capability? → Add it.
8. **Dependency Map:** Did we add a new external dependency? → Add it with blast radius.
9. **KPIs:** Did we define a new success metric? → Add it.
10. **Client Prerequisites:** Did we discover something the client must have/do? → Add it.
11. **Cost Breakdown:** Did costs change? New service added? → Update the economics.
12. **Test Strategy:** Did we define testing approach or coverage targets? → Update it.
13. **Capabilities:** Did we identify new plugins, skills, or patterns? → Add to the capability map.

**This is NOT optional.** If an AI session makes decisions but doesn't update the living documents, the next session will re-debate the same decisions. The documents are the institutional memory. Without them, every session starts from zero.

**The question to ask the human at every session end:** "Did anything change that should be reflected in the Admin documents?"

---

## Article 18: GitHub Issues Are The Gold Standard (Non-Negotiable)

**The 18 Admin documents live as GitHub Issues. The GitHub Issue IS the document. Not a mirror. Not a summary. THE document.**

### The Hierarchy

```
GOLD STANDARD:  GitHub Issue body (e.g., growthpigs/lifemodo/issues/416)
     │
     ▼
BACKUP ONLY:    docs/ folder .md files (e.g., docs/02-specs/USER-STORIES.md)
```

**Why GitHub Issues, not .md files?**

1. **Every AI session has GitHub access.** Claude Code can read, write, and search issues. It cannot always find the right .md file in the right folder.
2. **Issues are searchable.** Labels, milestones, full-text search across all issues. `.md` files require knowing the exact path.
3. **Issues are linkable.** `#416` creates a clickable cross-reference anywhere. `.md` files require relative paths that break when copied.
4. **Issues are versioned.** GitHub tracks every edit to an issue body. `.md` files require git commits to track changes.
5. **Issues survive AI session boundaries.** A new Claude Code session can read `gh issue view 416` instantly. It may not know to look in `docs/02-specs/USER-STORIES.md`.
6. **Roderic can read issues on his phone.** He cannot browse `.md` files on his phone.

### The Rule

When creating or updating any of the 18 Admin documents:
1. **Update the GitHub Issue FIRST** — this is the gold standard
2. **Optionally sync to docs/ .md file** — as a backup, for local access, for git history
3. **If they conflict, the GitHub Issue wins** — always

When READING a document:
1. **Read the GitHub Issue** — `gh issue view NNN`
2. **Do NOT treat a docs/ .md file as authoritative** — it may be stale

### What This Means for AI Sessions

When an AI session starts scaffolding the 18 documents for a new project:
- **Create GitHub Issues** in the Admin milestone ← THIS IS THE WORK
- Optionally create matching .md files in docs/ ← this is a backup
- The issue body IS the document content — not a pointer to a file

**WRONG:** "Source: docs/02-specs/USER-STORIES.md" (issue points to file)
**RIGHT:** The issue body CONTAINS the user stories directly

### Cross-Project Standard

This applies to ALL projects. LifeModo, War Room, IT Concierge, everything. The Admin milestone GitHub Issues are the canonical 18 documents. Local .md files may exist as backups but are NEVER the source of truth.

---

---

## Article 19: Admin Document Quality Gate (Post-Scaffolding)

After creating the 18 Admin documents for any project, run this quality gate BEFORE moving on. No exceptions.

### The Check (Run Immediately After Scaffolding)

```bash
# For each admin issue in the milestone:
for issue in $(gh issue list --milestone "Admin" --json number --jq '.[].number'); do
  body=$(gh issue view $issue --json body --jq '.body')

  # CHECK 1: JSONL corruption (agent transcript leaked into body)
  if echo "$body" | grep -q "parentUuid\|isSidechain\|agentId"; then
    echo "FAIL #$issue: Raw JSONL agent transcript in body. REWRITE."
  fi

  # CHECK 2: Too short (empty or placeholder only)
  lines=$(echo "$body" | wc -l)
  if [ "$lines" -lt 10 ]; then
    echo "FAIL #$issue: Body too short ($lines lines). Needs real content."
  fi

  # CHECK 3: Points to .md file as source instead of containing content
  if echo "$body" | grep -qi "^source:.*\.md\|^source of truth:.*\.md"; then
    echo "WARN #$issue: Points to .md as source. Article 18 says issue IS the doc."
  fi

  # CHECK 4: Article 18 header present
  if ! echo "$body" | grep -qi "Article 18\|this issue IS"; then
    echo "WARN #$issue: Missing Article 18 acknowledgment."
  fi
done
```

### What Each Check Catches

| Check | Failure Mode | Root Cause | Fix |
|-------|-------------|-----------|-----|
| JSONL corruption | Raw agent transcript dumped as issue body | Subagent output piped to `--body-file` without processing | Rewrite the issue with clean content |
| Too short | Placeholder or empty issue | CC created issues but didn't fill them | Fill with real content from source docs |
| Source pointing to .md | "Source: docs/02-specs/X.md" | CC treats .md as gold, issue as mirror | Remove Source line, put content in issue body |
| Missing Article 18 | No acknowledgment that issue IS the doc | CC doesn't know about Article 18 | Add the header: "Per Article 18: This issue IS the document" |

### When to Run

1. **Immediately after scaffolding** — before doing anything else
2. **At session end** — as part of Article 17 living document check
3. **When CTO reviews** — cross-project quality audit

### The Fix Protocol

If any check FAILS:
1. Read the corresponding `docs/` .md file for source content
2. Rewrite the issue body with clean, human-readable content
3. Add the Article 18 header
4. Re-run the checks

**Never leave a corrupted issue. Fix it in the same session that finds it.**

---

## Article 20: Critical Path & Continuous Health (The "Demo Script" Principle)

**Every project must define its single most important end-to-end flow. This is the Critical Path.**

The Critical Path is NOT a new document (#16). It is a **mandatory section of Document #15 (Test Strategy)**. This keeps the document count at 16 while enforcing the concept.

### What the Critical Path Section Must Contain

```markdown
## Critical Path Smoke Test

### The Flow (N steps)
1. [Step] — [What happens] — [Pass/fail assertion]
2. [Step] — [What happens] — [Pass/fail assertion]
...

### Automation Tiers
- Track 1 (Agent Browser, headless): [which steps]
- Track 2 (Claude in Chrome, visual): [which steps]
- Track 3 (Human walkthrough): [all steps]

### Non-Software Steps
[Steps that are verbal/human-only, marked as automatable: no]

### Tier Priority
- Track 1 FAILS → BLOCKED (functional break)
- Track 2 FAILS but Track 1 passes → WARNING (visual regression)
- Only Manual passes → DEGRADED (automation broken, product may be fine)
```

### The Spec/Implementation Boundary

The Critical Path section in the Test Strategy issue is the **SPEC** (human-readable, in the GitHub Issue body). The actual test code (E2E test files, Agent Browser scripts) is the **IMPLEMENTATION**. The spec references the implementation file. Article 17 requires checking they stay in sync. This mirrors User Stories (spec) → Code (implementation).

### When the Health Check Activates

The Critical Path health check is **CONDITIONAL:**

| Project State | Obligation |
|--------------|-----------|
| **Pre-code (DEFCON 0)** | Define the Critical Path steps. Mark as "not yet testable." |
| **In development** | Run Critical Path manually after major changes. |
| **Production deployed** | Run Critical Path at EVERY session start. Automated daily if possible. |

Pre-code projects are NOT required to automate something that doesn't exist yet. But they MUST define what the Critical Path WILL be — this forces the team to think about "what does success look like?" from day one.

### Examples by Project Type

| Project | Critical Path |
|---------|-------------|
| **SaaS with sales demo** (War Room) | The sales demo itself — the 10 steps Jackson shows prospects |
| **AI concierge** (LifeModo) | First client experience — Fob tap → voice → Morning Brief → proactive suggestion |
| **Field service tool** (IT Concierge) | Lino's daily workflow — create ticket → assign → technician completes → bill |
| **API-only service** | Health endpoint → create resource → query → delete → verify |
| **Mobile app** | Launch → auth → primary action → verify state → logout |

### Gap Analysis (Mandatory After Defining Critical Path)

After defining the Critical Path, systematically compare each step against the actual product:

1. **For each step:** Does the product fully deliver what the step promises?
2. **If yes:** Mark as covered. Link to the feature/test that validates it.
3. **If no:** Create a `critical-path-gap` issue describing the delta between promise and reality.
4. **Prioritize gaps by:** "How badly does this hurt the demo/user journey?"

Gap issues are labeled `critical-path-gap` and live in the Demo Readiness milestone (see below). They are NOT in the Admin milestone — Admin is for specifications, not work items.

**Re-run the gap analysis** every time the Critical Path document is updated. New steps = potentially new gaps.

### The Demo Readiness Milestone (Permanent)

Every project with a Critical Path MUST have a **permanent milestone** (e.g., "Demo Readiness") that groups:

| Category | What Goes Here |
|----------|---------------|
| **Critical Path document** | The demo script / user journey spec |
| **Gap issues** | Delta between Critical Path promises and product reality |
| **Vocabulary/tone issues** | AI language alignment with domain terminology |
| **Self-awareness issues** | Platform knowledge (AI knows about its own app) |
| **E2E tests** | Automated validation of Critical Path steps |
| **Health checks** | Automated daily "can we run the demo?" checks |

**This milestone never closes.** It is a permanent quality dashboard. Its health = the project's readiness for its most important user journey.

### The Daily Question

Once a project is in production, every morning the system asks:

> **"Can we run the Critical Path right now without hitting a single failure?"**

If yes → proceed with confidence. If no → fix it before anything else.

### Daily Demo Readiness Report (Recommended for Production Projects)

For projects with a production deployment AND a sales/demo process, a **daily PDF report** is recommended (not mandatory). This report:

- Is generated automatically (cron, GitHub Action, or session-start trigger)
- Uses Gamma API in `"document"` mode (no images, detailed text, 4-6 pages)
- Is readable by non-technical stakeholders (no raw test output, no GitHub jargon)
- Contains: Critical Path status (pass/fail per step), open gaps, what changed since yesterday
- Is delivered to Slack or email before the business day starts

**When to implement:** Only when ALL of these are true:
1. The project has a production deployment
2. Someone demos or sells the product regularly
3. A non-technical stakeholder needs daily status without opening GitHub

**When NOT to implement:** Pre-code projects, internal tools, projects without a sales process. These get the Daily Question (above) but not the PDF report.

---

## Article 21: Activity Log — Continuous Thinking Journal (Non-Negotiable)

Every project's Admin milestone includes an **Activity Log** issue. This is a **continuous, real-time record** of all actions AND thinking by Claude Code sessions.

### 🔴 THE RULE: EVERY TURN GETS AN ENTRY

**After every user→CC turn, update the Activity Log.** Not at session end. Not after "significant actions." EVERY TURN.

The Activity Log captures:
- **Actions:** What you did (commits, deploys, file changes)
- **Thinking:** What you analyzed, hypothesized, decided, ruled out
- **Dead ends:** What you tried that didn't work and why
- **Decisions:** What you chose and the reasoning behind it
- **Research:** What you discovered (API behavior, root causes, architecture insights)

If it happened in your head, it goes in the log. Roderic cannot see your terminal. The Activity Log is his ONLY window.

### Cadence (Non-Negotiable)

| Trigger | Action |
|---------|--------|
| **After every user message response** | Append entry to Activity Log |
| **After every significant discovery** | Append entry immediately |
| **Every 15 minutes of continuous work** | Append progress entry |
| **Before context compaction** | Mandatory flush of all pending thoughts |
| **Session end** | Final summary entry |

**The 3-hour gap incident (2026-03-16):** CC did 13 commits of CI pipeline work, diagnosed V8 coverage bugs, ran CTO ratification, analyzed 45 E2E failures — and logged NONE of it for 3 hours. This is exactly what the Activity Log exists to prevent.

### Entry Format

```
YYYY-MM-DD HH:MM — [Action Title] ([CC Session Name])

What: [1-2 sentences]
Thinking: [analysis, hypothesis, reasoning — the WHY not just the WHAT]
Before → After: [if applicable]
Evidence: [quality gate output, char counts, issue links]
```

### Rules

- **Newest entries at top.** Most recent action is always the first thing you see.
- **When the issue body exceeds 60K chars,** older entries move to issue comments.
- **Every CC turn appends.** Not "significant actions" — every turn. A 2-line thinking entry is better than silence.
- **Cross-CC visibility:** If CTO fixes something in another project's session, it's logged in THAT project's Activity Log.
- **Thinking entries are first-class.** "Investigated X, ruled out Y because Z, proceeding with W" is a valid entry even with zero code changes.

### Why This Exists

Conversations get compacted. Terminal scrolls away. The Activity Log persists. When Roderic opens ONE issue, he sees everything that happened — including the REASONING. When a NEW CC session starts, it reads the Activity Log to know what was done AND what was thought recently.

### Progressive Decay — Keep It Readable

The Activity Log grows forever but entries decay in detail over time. This prevents the log from becoming an unreadable wall of text while preserving the complete thinking record.

| Entry Age | Detail Level | Action |
|-----------|-------------|--------|
| **< 1 week** | Full detail (5-15 lines per entry) | Keep as-is |
| **1-3 weeks** | Condensed (2-3 lines per entry) | Summarize, keep key decisions and outcomes |
| **1-3 months** | One-liner per entry | Date + action + outcome only |
| **> 3 months** | Move to comment archive | Entry moves from issue body to a comment titled "Archive: [Month Year]" |

**When to decay:** At session start, if the Activity Log body exceeds ~40K chars, apply progressive decay to older entries before adding new ones.

**What survives decay:** Decisions, architecture choices, and dead ends that inform future work survive longer than routine action entries. If an entry contains "decided," "chose," "rejected," or "learned" — it decays one tier slower.

### The Activity Log Is NOT One of the 18 Core Documents

It is an **operational companion**. It does not block the coding gate. It does not need to be "substantially complete" before code drops. It exists from the moment the project is scaffolded and grows forever.

---

---

## Article 22: Platform Self-Awareness (AI-Powered Products)

**If the product has an AI interface, that AI must know about the product itself.**

Users will ask the AI about the platform: "Where do I find X?", "How do I do Y?", "What can you do?" If the AI gives a blank stare or a generic answer, the product feels broken — regardless of how good the underlying intelligence is.

### When This Applies

| Project Type | Applies? | Why |
|-------------|----------|-----|
| AI-powered SaaS with chat/assistant | **Yes** | Users will ask the AI about the product |
| AI-powered mobile app | **Yes** | Users expect the assistant to know the app |
| API-only service | **No** | No user-facing AI to ask |
| Static website / non-AI tool | **No** | No AI interface |
| Children's app / simple utility | **No** | No conversational AI |

**The test:** If a user can type a question to an AI in the product, Platform Self-Awareness applies.

### What the AI Must Know

Every qualifying product must inject a **Platform Knowledge Block** into AI context containing:

1. **Navigation map** — Every page/screen, what it does, how to get there
2. **Feature inventory** — What the product can do, expressed as user capabilities
3. **Identity statement** — What the AI calls itself (white-label safe)
4. **Capability boundaries** — What the AI CAN and CANNOT do (prevents hallucinated promises)
5. **Vocabulary alignment** — Domain-specific terms the AI should use (see Article 20, vocabulary rules)

### Implementation Pattern

```
PLATFORM KNOWLEDGE (injected into all AI prompts):

PAGES:
- [Page Name]: [What it does] — [How to navigate there]
- [Page Name]: [What it does] — [How to navigate there]

CAPABILITIES:
- "I can [capability 1]"
- "I can [capability 2]"
- "I cannot [limitation 1]"

IDENTITY:
- "I am [product name]'s [role description]"
- NEVER mention: [banned provider names]
- SAFE to say: [approved descriptions]
```

### The Self-Awareness Test (Run During Gap Analysis)

After defining the Platform Knowledge Block, test these questions against the AI:

1. "Where do I find [feature]?" → Should give navigation instructions
2. "What can you do?" → Should list capabilities accurately
3. "What are you built on?" → Should give white-label-safe answer
4. "Can you [thing it can't do]?" → Should honestly say no
5. "How do I [common task]?" → Should give step-by-step guidance

Any question that produces a blank stare, generic answer, or white-label violation = a `critical-path-gap` issue.

### Relationship to Other Articles

- **Article 14 (Admin Documents):** The Platform Knowledge Block lives as a constant in code, NOT as an Admin document. It's implementation, not specification.
- **Article 20 (Critical Path):** Platform Self-Awareness failures surface during Gap Analysis and belong in the Demo Readiness milestone.
- **Article 17 (Living Documents):** The Platform Knowledge Block must be updated whenever pages/features are added or removed.

---

---

## Article 23: Service Billing Pre-Flight (External Dependencies)

**Born from:** War Room Perplexity quota exhaustion (March 16, 2026). Web search silently failed for hours because the API returned 401 "quota exceeded" and the code treated it as "temporarily unavailable."

### The Principle

**Any product that depends on external paid APIs MUST verify billing/quota status before running functional tests.** Silent quota exhaustion is a production outage with a billing receipt, not a technical problem — but it looks identical to a code bug and wastes hours of engineering time.

### Applicability

Every project that uses ANY of these:
- LLM APIs (OpenAI, Anthropic, Google, Perplexity, OpenRouter)
- Hosting platforms (Render, Netlify, Vercel, Railway)
- Database services (Neon, Supabase, PlanetScale)
- Monitoring services (Sentry, PostHog)
- Any service with usage-based billing or credit limits

### Implementation Pattern

#### 1. Error Differentiation (Code)

Services MUST return specific failure reasons, not generic messages:

```
GOOD: "Perplexity quota exhausted — top up at perplexity.ai/settings/api"
BAD:  "Web search is temporarily unavailable"
```

Minimum status taxonomy:
- `enabled` — working normally
- `disabled` — key not configured (setup issue)
- `quota_exceeded` — billing issue (ACTIONABLE — tell the human WHERE to fix it)
- `rate_limited` — temporary, retry later
- `auth_failed` — key invalid/revoked
- `error` — API failure

#### 2. Billing Pre-Flight (Testing)

Health checks and E2E tests MUST include a "Tier 0" pre-flight that runs BEFORE functional tests:
- Ping each external service with a minimal request (1-token LLM call, health endpoint, etc.)
- Specifically check for billing/quota HTTP responses (401, 402, 429 with quota context)
- Report the SPECIFIC service and the SPECIFIC fix URL
- Fail loudly — this is RED, not yellow

#### 3. Self-Healing Response

When billing pre-flight detects quota exhaustion:
- Auto-create a GitHub issue tagged with the service name
- Include: which service, what error, where to fix it (URL), when it last worked
- Notify the team (Slack, email) — this is time-sensitive

### Why This Is Non-Negotiable

External API billing failures are the #1 invisible production outage across ALL projects. They:
- Look like code bugs (same error messages)
- Pass code review (the code is correct)
- Pass unit tests (mocked services don't have billing)
- Only fail in production (where real API calls happen)
- Waste 2-6 hours per incident on misdiagnosis

The fix is always 2 minutes: top up credits or update a card. The diagnosis without this article takes hours.

### The Economic Argument

A $5 Perplexity top-up prevents a 4-hour debugging session on a $400/month AI subscription. The ROI of billing pre-flight is infinite.

---

---

## Article 24: Candid Self-Assessment Gate ("Are You Happy?")

**Before transitioning from documentation to coding, the CC MUST run a candid self-assessment.** This is the last gate before code.

### When to Run

- After Admin documents are complete — before FSDs
- After FSDs are complete — before code
- After any major phase transition

### The Prompt

```
You are my senior engineer doing a candid debrief, not a servant.
1. WHERE ARE WE NOW? Status, what changed, what's unchanged.
2. ASSUMPTIONS — list every one you made.
3. CONFIDENCE SCORES (1-10): Correctness, UX/intent, Performance.
   For each: WHY and what EVIDENCE.
4. WHAT NEEDS RUNTIME VERIFICATION? Step-by-step.
5. DOCS & HOUSEKEEPING — what needs updating right now?
6. YOUR RECOMMENDATION — what would YOU do next?
7. WHAT AM I NOT ASKING?
Permission to be frank: approved.
```

### The Gate

- Any score **below 7** → BLOCKED. Raise it with evidence, not words.
- All scores **9+** → proceed.
- Scores **7-8** → proceed with explicit verification list.

### Why

AI sessions are sycophantic by default. This forces honest assessment at the most expensive moment — before code starts.

---

---

## Article 25: Deployment Pipeline (Pre-Code Requirement)

**Every project must have a verified deployment pipeline BEFORE writing FSDs.**

### Verification Checklist

| Check | Method |
|-------|--------|
| Hosting account exists | `vercel whoami` or dashboard |
| Repo connected to hosting | Push triggers build |
| Preview deploys work | Test branch → verify URL loads |
| Env vars configured | All required vars in all environments |
| Database accessible from deploy | Deployed preview can query DB |
| Domain configured (if applicable) | DNS + SSL verified |
| Build succeeds | `npm run build` — zero errors |

### Pipeline Section (in Onboarding Checklist or standalone)

```
| Environment | URL | Verified |
|-------------|-----|----------|
| Local dev | localhost:3000 | [date] |
| Preview | [auto].vercel.app | [date] |
| Production | [domain] | [date] |
```

### Why Before FSDs?

FSDs assume a deployment model. Puppeteer was rejected because of Vercel's bundle limit — a deployment constraint that shaped architecture. Verify the pipeline first, then write specs that fit it.

---

---

## Article 26: Ratification Gate — Second-Pass Validation Before Sign-Off

**Every major deliverable must be ratified before it's considered done.**

Ratification is a mandatory second-pass review using a fresh-eyes perspective. The implementer becomes the reviewer. The question changes from "did I build it?" to "would I sign off on this if someone else built it?"

### When Ratification Is Required

| Deliverable | Ratification Required? |
|-------------|----------------------|
| Admin document scaffolding (18 docs) | **YES** — run `admin-quality-gate.sh` |
| Major User Story/Journey additions (10+) | **YES** — validator agent with cross-reference check |
| Architecture decisions (new ADRs) | **YES** — check for contradictions with existing ADRs |
| FSD completion | **YES** — independent observer score >= 8/10 |
| Constitution amendments | **YES** — Roderic's explicit approval |
| Single issue creation | No — too granular |
| Bug fix PR | No — tests validate |
| Minor doc update | No — session-end check covers it |

### How to Ratify

1. **Switch roles.** You are no longer the implementer. You are a skeptical 25-year veteran CTO reviewing someone else's work.
2. **Use a validator agent.** Spawn a subagent with the explicit instruction to find problems. Give it the deliverable and say "find what's wrong."
3. **Check cross-references.** Every issue number, every document reference, every count (document count, story count, article count) — verify against reality.
4. **Check for drift.** Did the deliverable introduce inconsistencies with existing documents? Run the Freshness Audit (Article 15).
5. **Report honestly.** Confidence score 1-10. If under 9, state what you'd fix.

### Why This Exists

This session proved it: every ratification pass found bugs. The #406/#407 swap. The garbled "Google Text Gemini Embedding 2" names. The duplicate Article 21. The stats saying 176 when it was 186. The missing C1-REFRESH issue. None of these were caught during implementation — they were ALL caught during ratification.

**The pattern:** Implementation is creative and fast. Ratification is skeptical and thorough. They are different cognitive modes. You cannot do both simultaneously. The ratification step forces the mode switch.

### The Anti-Sycophancy Rule

During ratification, the AI must NOT confirm that everything is fine unless it actually IS fine. If the validator finds zero issues, that is suspicious — re-run with a more aggressive prompt. Real work always has imperfections. The goal is not perfection; it's catching the imperfections that would break things downstream.

---

---

## Article 27: CIC Validation Prompt (Pre-Merge Gate)

**Born from:** War Room production deploy PR #410 (March 16, 2026). Adding a human-in-the-loop visual validation step using Claude in Chrome before every production merge.

### The Principle

**Every PR that ships to production MUST include a CIC Validation Prompt** — a copy-pasteable prompt that the human reviewer puts into Claude in Chrome (or any browser-based AI) to visually validate the deploy before merging.

This is the final gate. Code review catches logic bugs. CI catches build failures. CIC Validation catches **what the user actually sees**.

### When to Generate

The CC session MUST generate a CIC Validation Prompt:
- After creating any PR to `production` or `main`
- After any PR that touches UI components, routes, or user-facing behavior
- Before telling the human "ready to merge"

**The CC MUST NOT say "ready to merge" without including the CIC prompt in the same message.** This is non-negotiable.

### Prompt Structure (Template)

Every CIC Validation Prompt follows this structure:

```
I need you to validate PR #[NUMBER] on [REPO] before we merge.
[1-line summary of what the PR contains]

## Check 1: GitHub PR Status
Go to [PR URL]
- CI checks passing? (list specific workflows)
- CodeRabbit/SonarQube comments?
- Any blocking reviews?

## Check 2: Production (baseline — current state)
Go to [PRODUCTION URL]
- [Login instructions with credentials]
- [2-3 specific things to verify as baseline]

## Check 3: Staging (has the new code)
Go to [STAGING URL]
- [Login with same credentials]
- [Specific test for EACH new feature in the PR]
- [White-label check if applicable]
- [Console error check]

## Check 4: Backend Health
[Health endpoint URLs with expected responses]

## Known Issues (NOT blockers):
[List any known issues that should NOT block the merge]

## Validation Report (MANDATORY — give this back to the CC session)
After completing all checks, produce this report:

### CIC Validation Report — PR #[NUMBER]
| Check | Result | Notes |
|-------|--------|-------|
| GitHub CI | PASS/FAIL/WARN | [one-line] |
| Production baseline | PASS/FAIL/WARN | [one-line] |
| Staging features | PASS/FAIL/WARN | [one-line] |
| Backend health | PASS/FAIL/WARN | [one-line] |
| Console errors | PASS/FAIL/WARN | [one-line] |
| White-label | PASS/FAIL/WARN | [one-line] |

**Verdict:** SAFE TO MERGE / BLOCK — [reason]
**Issues found:** [list any new issues, or "None"]
**Screenshots:** [attach any relevant screenshots]

IMPORTANT: Copy this entire report and paste it back into the Claude Code
session that generated this prompt. The CC session will use it to finalize
the merge decision and create any follow-up issues.
```

### The Round-Trip Pattern

This is a **separation of concerns** workflow:

1. **CC Session** (Claude Code) → generates the CIC Validation Prompt (code-aware, knows the diff)
2. **Human** → pastes prompt into CIC (Claude in Chrome)
3. **CIC** (browser AI) → executes visual checks, produces the Validation Report
4. **Human** → copies the Validation Report back to CC Session
5. **CC Session** → reads the report, decides: merge / create issues / abort

**Why round-trip?** The CC session has code context but no eyes. CIC has eyes but no code context. The round-trip combines both perspectives into one decision. Neither AI alone can make a fully informed merge decision.

### Rules

1. **Project-specific**: Include actual URLs, credentials, and test steps — not generic placeholders
2. **PR-specific**: Reference the actual features being deployed, not boilerplate
3. **Known issues included**: Prevent false negatives by listing known non-blocking issues
4. **Credentials included**: The reviewer shouldn't have to look up test accounts
5. **Verdict required**: CIC must give a clear SAFE/BLOCK recommendation
6. **Under 50 lines**: Concise enough to paste into a browser extension (increased from 40 for report section)
7. **Report feeds back**: CIC report is designed to be pasted back into CC for final decision

### Why This Works

- **Visual validation catches what CI can't**: broken layouts, z-index issues, white-label leaks, missing data
- **Human-in-the-loop**: The reviewer sees the actual app, not just a diff
- **Round-trip closes the loop**: CIC findings feed back into CC for informed merge decisions
- **Separation of concerns**: Code AI (CC) handles logic, Browser AI (CIC) handles visuals
- **Repeatable**: Same prompt structure every time, no missed steps
- **Low cost**: 2 minutes of CIC time prevents hours of production firefighting

### Integration with Other Articles

- **Article 14 (Admin Documents)**: CIC prompt is ephemeral (per-PR), not a persistent document
- **Article 20 (Critical Path)**: CIC validation is part of the critical path gate
- **Article 23 (Billing Pre-Flight)**: CIC prompt should include health/billing checks

---

---

## Article 28: CI Pipeline — Five Gates (Mandatory for All Projects)

**Born from:** War Room PR #410 (March 16, 2026). SonarCloud failing with 0% coverage, Playwright tests hanging, white-label scan producing false positives. All CI gates must work — green means green, red means a real problem.

### The Principle

**Every project CI pipeline MUST have exactly five gates. All five MUST pass green. A red check that "doesn't really matter" is not acceptable — either fix it or remove it.**

### The Five Gates

| Gate | What It Checks | Blocks Merge? | Tool |
|------|---------------|---------------|------|
| **Gate 1: Type Safety** | TypeScript compiles (`tsc --noEmit`) | YES | PR Sanity Check |
| **Gate 2: Build** | Production build succeeds | YES | PR Sanity Check |
| **Gate 3: Unit Tests + Coverage** | Vitest/Jest with coverage → SonarCloud | YES (advisory for now) | SonarQube workflow |
| **Gate 4: Security Scan** | White-label, secrets, multi-tenant | YES | PR Sanity Check |
| **Gate 5: E2E Health** | Blood test / Playwright against staging | YES for production PRs | Blood test + Playwright workflows |

### Coverage Reporting (Non-Negotiable)

Every project with a SonarCloud integration MUST:
1. Run tests with `--coverage` in CI (not just locally)
2. Output `lcov` format (`coverage/lcov.info`)
3. Point `sonar.javascript.lcov.reportPaths` to the lcov file
4. SonarCloud Quality Gate sees real coverage, not 0%

### White-Label Scan Rules

The white-label scan MUST be smart enough to distinguish:
- **User-visible strings** (JSX text, UI labels, tooltips) → VIOLATION
- **Internal code** (comments, imports, schema, types, admin-only) → NOT a violation

Exclusion taxonomy:
- `server/*` — server code is never client-visible
- `shared/schema.ts`, `shared/types.ts` — DB column names are internal
- `client/src/components/admin/*` — admin pages are internal team only
- `client/src/services/*` — API wrappers, not UI
- Comments (`//`, `{/* */}`) — developer notes, not rendered text
- Import statements — code structure, not UI
- `dataSource:` assignments — internal identifiers

### Blood Test as CI Gate

For projects with a blood test script (comprehensive E2E health check):
1. Blood test runs on **PRs to production** (pre-merge gate)
2. Blood test runs **daily** (regression detection)
3. Blood test results feed into **demo readiness reports** (Gamma PDF)
4. The pipeline: `blood test → JSON → demo readiness report → PDF`

### The "All Green" Rule

**If a CI check exists, it MUST pass.** Options when a check fails:
1. **Fix the code** — the check found a real problem
2. **Fix the check** — the check has a false positive (update exclusions/filters)
3. **Remove the check** — the check provides no value

**NOT acceptable:** Leaving a failing check as "it's fine, we know about it." That trains everyone to ignore CI, which defeats the entire purpose.

---

---

## Article 29: Pre-Completion Self-Check — Fresh Eyes Review (Mandatory)

**Before claiming ANY task is complete, the CC MUST switch roles and perform a skeptical CTO review of its own work.** This is the final gate before declaring "done."

### When to Run

- Before saying "this is complete" or "ready for review"
- Before creating a PR
- Before marking a Running Notes item as Complete
- After any multi-file change (3+ files)
- After CI/pipeline changes (highest risk of invisible breakage)

### The 5-Point Review

**1. Connection Points Sanity Check**
- Are changes on the right branch?
- Are all files saved and committed?
- Do the changed files match what was intended? (no accidental edits)
- Are changes pushed? (`git log origin/main..HEAD` should be empty)
- Do environment targets (URLs, branches, triggers) point to the right places?

**2. Evidence, Not Assumptions**
- For every claim ("tests pass", "selector updated", "no more duplicates"), point to SPECIFIC code or output proving it
- Run verification commands — don't assume previous runs are still valid
- `grep` for the OLD pattern to confirm zero remaining instances
- Read the ACTUAL file state, don't trust memory of what you wrote

**3. Edge & Failure Cases**
- What happens if the upstream changes? (e.g., brand name changes again → all selectors break again)
- Are there hardcoded values that should be constants?
- What fails if a dependency is unavailable? (DB down, API timeout, missing secret)
- Are error messages accurate? (stale summary lines, misleading comments)

**4. Consistency Audit**
- Do comments match the code? (e.g., "advisory" comment when tests are blocking)
- Do related files agree? (same pattern across all workflows, all test files)
- Are there half-finished changes? (fixed in 6 of 7 files)
- Do config values align with documentation?

**5. Confidence Score & Verdict**

| Score | Meaning | Action |
|-------|---------|--------|
| **9-10/10** | High confidence, evidence-backed | Proceed |
| **7-8/10** | Good but unverified gaps exist | List gaps explicitly, proceed with caveats |
| **Below 7** | Significant risk | STOP. Fix issues before declaring complete. |

### Output Format

```
## SELF-CHECK: [Task Name]

### Connection Points: ✅/⚠️/❌
[Specific evidence]

### Evidence Audit: ✅/⚠️/❌
[What was verified, how]

### Edge Cases: ✅/⚠️/❌
[What could break, mitigations]

### Consistency: ✅/⚠️/❌
[Mismatches found and fixed]

### Confidence: X/10
[Why this score, what would raise it]
```

### Incident Record (2026-03-16)

`pr-sanity-check.yml` summary line said "Tests: ⚠️ (advisory)" after tests were made blocking. A fresh-eyes review caught this; without it, the lie would have shipped. Stale comments are silent failures.

### Why This Is Separate From Article 24

Article 24 (Candid Self-Assessment) runs BEFORE coding — "are we ready to build?"
Article 29 (Self-Check) runs AFTER work — "did we actually build it correctly?"
Both are mandatory. Neither replaces the other.

---

---

## Article 30: Long Run Mode — Autonomous Execution

When Roderic says **"long run"** in any instruction, the CC session activates maximum autonomy.

### What Changes

- **No approval needed for:** branches, commits, issue updates, doc changes, test runs, draft PRs, quality gates, agent spawning, GitHub issue comments, Slack project channel posts, Mem0 writes
- **Still needs approval for:** merging PRs to main, production deploys, destructive git operations (reset --hard, force push, branch -D), emails to clients/external contacts, Slack DMs to people outside the team, anything that leaves the PAI system boundary

### The Pattern

1. Pick highest-priority unblocked item
2. Work to completion (branch → code → test → draft PR)
3. **LOG TO ACTIVITY LOG** — detailed entry with:
   - What was done and why
   - Link to PR/branch (note: "unmerged" or "draft")
   - Before → After state
   - Decisions made autonomously and rationale
   - What's next in the queue
4. DO NOT WAIT for merge — move to next item immediately
5. Repeat until blocked on ALL fronts or session ends
6. Only stop to ask if genuinely unsure about architecture direction

### Activity Log Is The Long Run Receipt

During Long Run mode, the Activity Log (Article 21) is the primary output Roderic reads to understand what happened. Entries should be **DETAILED** — not one-liners. Include enough context that Roderic can review the work, merge the PRs, and understand every decision without opening the conversation transcript.

A Long Run Activity Log entry should be **3x longer** than a normal entry. Link to every PR, branch, and issue touched. Note what's merged vs unmerged. This is how context survives the conversation window.

**The Activity Log must be complete enough that a fresh CC session can continue the Long Run without any conversation context.** If the session crashes at 2am, the next session reads the Activity Log and picks up exactly where it left off.

**Long Run does NOT override the per-turn cadence from Article 21.** Even during autonomous Long Run execution, every significant step gets logged immediately — not batched at the end. If you do 4 hours of autonomous work and crash, the Activity Log should show exactly where you were.

### Roderic's Veto Is Final

If Roderic closes a draft PR, reverts a change, or disagrees with an autonomous decision — that decision is final. Do not re-create or re-attempt the same approach without discussing why. The reversibility argument works both ways: Roderic can undo anything you did, and you must respect that.

### Why This Works

Everything before merge is reversible. Branches can be deleted. Draft PRs can be closed. Issues can be updated. The only irreversible action is merging to main — and that gate stays with Roderic.

### The Economics

Roderic pays $400/month for MAX. Every minute an AI session sits idle waiting for approval on reversible work is wasted subscription cost. Long Run mode maximizes throughput per dollar.

### Deactivation

Long Run mode ends when:
- The session naturally ends
- Roderic says "stop" or "pause"
- ALL remaining items are blocked on merges
- A genuine architecture question needs human judgment

---

---

## Article 31: Default Design System — Linear UI Library

**All business/SaaS projects use the Linear UI Library as the default design system.** No custom UI, no Material UI, no shadcn/ui, no Chakra — unless Roderic explicitly approves an alternative.

### The Default

| Setting | Value |
|---------|-------|
| **Repository** | `growthpigs/linear-ui-library` |
| **Local path** | `~/_PAI/projects/experiments/linear-ui-library` |
| **Style** | Clean, minimal, professional — inspired by Linear.app |
| **Components** | Button, Card, Input, Label + extensible |
| **CSS** | Tailwind CSS with Linear design tokens |
| **Accessibility** | WCAG 2.1 AA |

### When Linear UI Applies (Default)

- Business SaaS (IT Concierge, War Room, AudienceOS, RevOS)
- Admin dashboards
- Internal tools
- Client-facing professional apps
- Any project where the user is a business professional

### When to Ask Roderic

- Consumer mobile apps (kids, gaming, social)
- Marketing/landing pages (may need more personality)
- Client with existing brand guidelines that conflict
- Experimental/creative projects

### How to Use

```typescript
// Import from the library
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Input } from '@/components/ui/input'

// Design tokens are in tailwind.config.ts
// Font weight: font-510 (Linear's custom weight)
// Colors: neutral palette with accent
// Spacing: consistent 4px grid
```

### The Rule

When a CC session starts building UI for any project:
1. Check: is Linear UI Library referenced in the project's CLAUDE.md or Tech Stack?
2. If yes → use it, no questions asked
3. If no → check if it's a business/SaaS project → if yes, use Linear UI and add it to the Tech Stack
4. If it's a consumer/creative project → ask Roderic before choosing a design system

**Never install a different component library without checking this article first.**

---

---

## Article 32: Project Scaffolding Checklist (New Project Bootstrap)

**When a new project is initialized, BEFORE any documentation or code, these infrastructure items must be set up and verified.** This is the "bootstrap" that makes all other articles possible.

### The Scaffolding Checklist

Run this after `git init` and before creating Admin milestone documents:

| # | Item | Verification | Applicability |
|---|------|-------------|---------------|
| 1 | **GitHub repo created** | `gh repo view` returns data | All projects |
| 2 | **Admin milestone created** | `gh api milestones` shows "Admin" | All projects |
| 3 | **Demo Readiness milestone created** | `gh api milestones` shows "Demo Readiness" | All projects |
| 4 | **18 Admin document issues created** | `admin-quality-gate.sh` passes | All projects |
| 5 | **Activity Log issue created** | Issue exists in Admin milestone | All projects |
| 6 | **Vercel project linked** | `.vercel/project.json` exists | Web projects |
| 7 | **Vercel env vars set** | All required vars in dashboard | Web projects |
| 8 | **Preview deploy verified** | `vercel deploy --yes` returns URL | Web projects |
| 9 | **SonarCloud project created** | `SONAR_TOKEN` in repo secrets | Business/SaaS |
| 10 | **PR Sanity Check workflow** | `.github/workflows/pr-sanity-check.yml` exists | All code projects |
| 11 | **SonarQube workflow** | `.github/workflows/sonarqube.yml` exists | Business/SaaS |
| 12 | **CodeRabbit configured** | `.coderabbit.yaml` exists OR CodeRabbit enabled in repo settings | All code projects |
| 13 | **Husky pre-commit hooks** | `.husky/pre-commit` runs type-check + lint | All code projects |
| 14 | **Deployment Pipeline issue** | `[ADMIN] Deployment Pipeline` exists in Admin milestone | All projects |
| 15 | **GitHub repo secrets match Vercel env vars** | `gh secret list` shows all required vars | Web projects |

### Item 15: GitHub Secrets = Vercel Env Vars (Learned the Hard Way)

**Born from:** IT Concierge PR #57 CI failure (March 16, 2026). Build passed locally and on Vercel, but failed in GitHub Actions because Supabase env vars were only in Vercel, not in GitHub repo secrets. Next.js pre-renders pages at build time — if env vars are missing, the build crashes.

**The Rule:** Every env var in Vercel MUST also be in GitHub repo secrets. CI workflows need them for builds. The two must stay in sync.

```bash
# Verification command
gh secret list --repo <owner/repo>
# Must show ALL vars that Vercel has
```

**When vars change:** Update BOTH Vercel dashboard AND `gh secret set`. Never update one without the other.

### CodeRabbit: Always On (Non-Negotiable)

CodeRabbit MUST review every PR to the default branch. If CodeRabbit skips a review:
- Check `.coderabbit.yaml` — is the branch excluded?
- Check the PR target — is it targeting the default branch?
- If targeting a non-default branch (feature → feature), CodeRabbit won't run. This is acceptable ONLY for stacked PRs. The final PR to main MUST be reviewed.

### SonarCloud: Coverage Must Be Real

Tests MUST run with `--coverage` in CI and produce `lcov` format. SonarCloud quality gate must see REAL coverage, not 0%. The `|| true` pattern (run tests but don't block on failure) is acceptable ONLY during initial setup. Once tests are stable, remove `|| true` and make failures blocking.

### The Classifier

Not all projects need all items. The classifier:

| Project Type | Items Required |
|-------------|---------------|
| **Business SaaS** (War Room, IT Concierge) | ALL 14 items |
| **Consumer web app** | 1-8, 10, 12-14 (skip SonarCloud if overkill) |
| **Internal tool** | 1-5, 6-8, 10, 14 (skip SonarCloud, CodeRabbit optional) |
| **Experiment/POC** | 1-3 only |
| **Documentation-only** | 1-5 only |

### Round-Trip Quality Flow

The full quality pipeline for a feature:

```
Feature spec (Admin doc / FSD)
  → Code (with unit tests — Article 8 baseline)
  → Pre-commit: type-check + lint (Husky)
  → Push → PR created
  → PR Sanity Check: build + tests + white-label scan
  → SonarCloud: coverage analysis + quality gate
  → CodeRabbit: AI code review
  → E2E tests (if applicable): Playwright against preview
  → Human review (Roderic merges)
  → Production deploy (Vercel automatic)
  → Demo Readiness: blood test validates Critical Path still works
```

This is the "round trip" — from spec to production with quality checks at every stage.

---

---

## Article 33: Agreement — Client-Developer Contract (Non-Negotiable)

**Every project MUST have an Agreement document in the Admin milestone.** This is a combined SOW + MOU — the single canonical contract that governs the entire engagement.

### Why It's Document #1

The Agreement is created FIRST, before any other Admin document. Without it, there is no shared understanding of scope, payment, IP, or expectations. Every other document flows from what was agreed.

### What the Agreement Contains

| Section | Content |
|---------|---------|
| **Context** | Relationship, background, how this engagement started |
| **Scope** | What will be delivered (phases, modules, features) |
| **Financial Terms** | Total value, payment schedule, milestones, currency |
| **IP Ownership** | Who owns the code, who can resell, licensing |
| **Timeline** | Estimated delivery windows (in sessions/DUs, not calendar dates) |
| **Response Time SLA** | How fast each party must respond to questions |
| **Change Control** | How scope changes are handled |
| **Special Terms** | Anything unique to this engagement (debt settlement, friendship terms, white-label rights, JV split) |
| **Termination** | How either party can exit |

### Agreement Types

Different projects have different commercial arrangements. The Agreement document adapts:

| Type | Example | Key Difference |
|------|---------|----------------|
| **Debt Settlement** | IT Concierge (€10K for Lino) | Payment is debt repayment, not commercial fee |
| **Commercial** | War Room | Standard SaaS build engagement |
| **Personal Product** | LifeModo | Roderic is both developer and client |
| **Partnership** | LifeModo + Daniel | Revenue share, joint ownership terms |

### The Rule

- The Agreement is a **GitHub Issue** in the Admin milestone (Article 18 — gold standard)
- It is created in **Phase 1** of the document creation order (Article 14)
- It MUST be substantially complete before any other Admin document
- If the engagement changes (scope grows, payment changes), the Agreement is UPDATED — not replaced
- The Agreement is the ONLY document that both the human client and the AI reference for "what was promised"

### Relationship to docs/07-business/

The Agreement issue is the **gold standard** (per Article 18). Individual .md files in `docs/07-business/` (SOW.md, MOU.md, etc.) are **backups** of content from the Agreement. They may exist for local reference, but the GitHub Issue is the source of truth.

---

---

## Article 34: Work Ledger — DU Value Tracking (Non-Negotiable)

**Every project MUST have a Work Ledger document in the Admin milestone.** This is the running financial record of all value delivered, tracked in Development Units (DUs).

### Why This Exists

Roderic delivers AI-accelerated work at rates of $100-$175/DU. Without a ledger, there's no clear record of how much value has been delivered, what it cost, or how it breaks down by type. The Work Ledger is how Roderic proves value to clients and tracks budget consumption.

### What the Work Ledger Contains

The ledger is a **continuously growing table** — newest entries at top.

```
## Work Ledger

**Agreement Total:** [from Agreement document — e.g., €10,000 = ~100 DUs]
**Delivered to Date:** X DUs ($Y,YYY value)
**Remaining Budget:** Z DUs

### Ledger

| Date | Task | Hat | DUs | Rate | Value | Running Total | Notes |
|------|------|-----|-----|------|-------|---------------|-------|
| 2026-03-16 | Admin docs scaffolded | Architecture (Blue) | 2.0 | $150 | $300 | $300 | 18 docs created |
| 2026-03-16 | Client interview | Strategy (Red) | 1.0 | $175 | $175 | $475 | Requirements gathered |
```

### The Six-Hat DU Rates

| Hat | Rate | Examples |
|-----|------|----------|
| Strategy (Red) | $175/DU | Architecture decisions, roadmap, risk analysis |
| Design (Yellow) | $150/DU | UI/UX, wireframes, design systems |
| Architecture (Blue) | $150/DU | Data models, API contracts, infrastructure |
| Engineering (Green) | $125/DU | Features, bug fixes, integrations |
| Quality (White) | $100/DU | Testing, QA, code review |
| Brand (Purple) | $125/DU | Content, marketing, copy |

**1 DU = 1 hour of focused AI-accelerated work.**

### Rules

1. **Updated every session.** At session wrap, all work is logged to the Work Ledger with timestamps.
2. **Hat type is mandatory.** Every entry must specify which hat the work falls under — this determines the rate.
3. **Running total always current.** The top of the ledger shows total DUs delivered and remaining budget.
4. **Cross-referenced with Activity Log.** The Activity Log (Article 21) captures the THINKING. The Work Ledger captures the VALUE. They are complementary, not duplicates.
5. **Budget warnings.** When remaining budget drops below 20%, the Work Ledger must flag it. When it hits 0, work stops until the Agreement is amended.

### Relationship to Other Systems

| System | What It Tracks | Overlap |
|--------|---------------|---------|
| **Work Ledger** (this) | DUs, rates, value, budget | SOURCE for project-level billing |
| **Activity Log** (Article 21) | Actions, thinking, decisions | Feeds Work Ledger with task descriptions |
| **Master Dashboard** (Google Sheets) | Cross-project DU rollup | Work Ledger entries sync here at wrap |
| **Running Notes** (Slack) | Task status, outcomes | Running Notes items reference Work Ledger DUs |

### The Flow

```
1. CC session does work
2. Activity Log captures WHAT happened and WHY (every turn)
3. At session wrap: Work Ledger captures HOW MUCH value (DUs + hat + rate)
4. Master Dashboard gets the cross-project rollup
5. Client sees: Agreement (what was promised) + Work Ledger (what was delivered)
```

### Why It's Separate from Activity Log

The Activity Log is a thinking journal — it grows with every CC turn, captures hypotheses, dead ends, and reasoning. It's for the AI and the developer.

The Work Ledger is a billing record — it grows per task completion, captures DUs and dollar value. It's for the client and the business.

Merging them would make the Activity Log too structured for thinking and the Work Ledger too noisy for billing. They reference each other but serve different audiences.

---

---

## Article 35: NotebookLM Crucible — Programmatic Access Only (Non-Negotiable)

**ALL NotebookLM operations use `teng-lin/notebooklm-py`. NEVER use Claude in Chrome (CIC) for NotebookLM. NEVER.**

### The Tool

| Setting | Value |
|---------|-------|
| **Package** | `teng-lin/notebooklm-py` |
| **Source** | `~/clawd/notebooklm-py/` |
| **Version** | `v0.3.3` |
| **Runtime** | `uv run python` (from `~/clawd/notebooklm-py/`) — requires Python 3.10+ |
| **Import** | `from notebooklm import NotebookLMClient` |
| **Auth** | `~/.notebooklm/storage_state.json` (browser auth, run `notebooklm auth` to refresh) |

### Why NOT CIC

CIC cannot:
- Upload files (native OS file picker blocks automation)
- Paste large documents efficiently (30K chars = minutes of typing)
- Create notebooks programmatically
- Generate Audio Overviews programmatically
- Extract debate results for GitHub issues

`notebooklm-py` can do ALL of these via Python. There is zero reason to use CIC.

### 🔴 THE AUDIO OVERVIEW IS THE CRUCIBLE (Non-Negotiable)

**The Crucible is an Audio Overview (podcast debate), NOT a chat query.**

NotebookLM's Audio Overview generates a debate between two AI hosts who argue about the source material. This is the adversarial review mechanism — it surfaces disagreements, gaps, and blind spots that chat Q&A cannot. Chat queries are supplementary follow-up only.

| Method | Purpose | When |
|--------|---------|------|
| `artifacts.generate_audio()` | **THE CRUCIBLE** — two hosts debate the architecture | Step 1: Generate |
| `artifacts.download_audio()` | Download the debate MP3 | Step 2: Download |
| `chat.ask()` | **EXTRACT FINDINGS** — structured queries to pull out gaps, scores, recommendations | Step 3: Self-process |

**If you skip the Audio Overview and only use chat, you have NOT run the Crucible.**

### 🔴 THE AI SELF-PROCESSES THE RESULTS (Non-Negotiable)

**The human does NOT need to listen to the audio for the Crucible to be complete.**

After generating the Audio Overview, the AI MUST extract findings programmatically using chat follow-ups on the SAME notebook. The audio debate creates adversarial tension inside NotebookLM's context — the chat API then lets you harvest that analysis.

**The 5-query extraction protocol (run these in order after audio is generated):**

```
Query 1: "List every architectural gap, vulnerability, or design flaw you identified,
          with severity (CRITICAL/HIGH/MEDIUM/LOW) and specific evidence from the sources."

Query 2: "For each CRITICAL and HIGH finding, what is the specific fix?
          Reference the data model tables, columns, or code that needs to change."

Query 3: "What assumptions in our architecture did the external sources contradict?
          Quote the specific external source that disproves our assumption."

Query 4: "What did competitor products (ServiceTitan, Jobber, etc.) do differently
          that we should consider adopting? Be specific about features and patterns."

Query 5: "Score this architecture 1-10 for production readiness.
          What must be fixed before code, and what can be deferred to V2?"
```

**After extraction:**
1. Save each chat response to `/tmp/crucible-[topic]-findings.md`
2. Create GitHub issues for CRITICAL and HIGH findings (Demo Readiness milestone)
3. Update the Activity Log with Crucible scoring
4. The MP3 is available for Roderic to listen at his leisure — but it is NOT a blocker

**Why this matters:** If the AI generates audio and then says "here, listen to this" — the human becomes the bottleneck. The entire point of programmatic NotebookLM access is that the AI does the work end-to-end. The human reviews findings in GitHub issues, not by listening to 45 minutes of podcast.

### 🔴 ONE NOTEBOOK PER DEBATE TOPIC (Non-Negotiable)

**Each Crucible debate topic gets its OWN notebook.** Never dump all sources into one notebook.

Each notebook contains exactly 3 types of sources (per StrikeMeta minimum-3 rule):

| # | Source Type | Max Count | Example |
|---|-----------|-----------|---------|
| 1 | **Architecture Anchor** | 1 | The epic's user stories + acceptance criteria |
| 2 | **Subject Document** | 1-3 | The relevant data model section, ADR, tech stack section |
| 3 | **External Research** | 3-8 | Official docs (Supabase, MDN), security audits, competitor docs, engineering blogs |

**Why scoped notebooks?** When all 28 sources are in one notebook, the Audio Overview tries to cover everything superficially. When 8-12 focused sources are in one notebook, the Audio Overview goes deep on that specific topic and finds real architectural gaps.

### The Crucible Flow (Correct — v0.3.3 API)

```python
import asyncio
from notebooklm import NotebookLMClient, AudioLength

TOPIC = "Notification Architecture"

async def run_crucible():
    client = await NotebookLMClient.from_storage()
    async with client:
        # ── PHASE 1: SETUP (scoped notebook + sources) ──
        nb = await client.notebooks.create(f"Crucible — {TOPIC}")
        nid = nb.id

        # Architecture anchor
        await client.sources.add_text(nid, "User Stories — Notifications", us_content)
        # Subject documents
        await client.sources.add_text(nid, "Data Model — notification_queue", dm_content)
        # External research (3-8 URLs)
        await client.sources.add_url(nid, "https://supabase.com/docs/guides/realtime")
        await client.sources.add_url(nid, "https://developer.mozilla.org/en-US/docs/Web/API/Push_API")
        # ... more scoped external sources

        # Wait for all sources to finish processing before generating audio.
        # Without this, audio may be generated against partially-indexed sources.
        all_sources = await client.sources.list(nid)
        for s in all_sources:
            if hasattr(s, 'status') and s.status != 3:  # 3 = READY
                import asyncio as _aio
                await _aio.sleep(5)  # Brief wait; sources typically process in <10s

        # ── PHASE 2: GENERATE AUDIO (THE CRUCIBLE) ──
        status = await client.artifacts.generate_audio(
            nid,
            instructions=f"""ADVERSARIAL REVIEW of {TOPIC}.
            Argue FOR and AGAINST the current design.
            What assumptions are wrong? What will break in production?
            What are competitors doing differently and why?""",
            audio_length=AudioLength.LONG
        )
        # Audio generation takes 5-15 minutes server-side.
        # wait_for_completion may timeout — that's OK, generation continues server-side.
        try:
            await client.artifacts.wait_for_completion(nid, status.task_id, timeout=900)
        except TimeoutError:
            pass  # Timed out — poll manually below

        # Poll until audio is complete (status 3). Do NOT call download_audio
        # before confirming completion — it will throw ArtifactNotReadyError.
        import asyncio as _aio
        audio_ready = False
        for _ in range(60):  # Poll up to 10 min at 10s intervals
            audios = await client.artifacts.list_audio(nid)
            if any(a.status == 3 for a in audios):
                audio_ready = True
                break
            await _aio.sleep(10)

        # Download MP3 (for human to listen at leisure — NOT a blocker)
        if audio_ready:
            await client.artifacts.download_audio(nid, f"/tmp/crucible-{TOPIC.lower().replace(' ', '-')}.mp3")
        else:
            print("WARNING: Audio still generating. Proceeding to chat extraction.")

        # ── PHASE 3: SELF-PROCESS (extract findings via chat) ──
        # The audio debate created adversarial context inside NotebookLM.
        # Now harvest that analysis with structured queries.

        EXTRACTION_QUERIES = [
            "List every architectural gap, vulnerability, or design flaw you identified, "
            "with severity (CRITICAL/HIGH/MEDIUM/LOW) and specific evidence from the sources.",

            "For each CRITICAL and HIGH finding, what is the specific fix? "
            "Reference the data model tables, columns, or code that needs to change.",

            "What assumptions in our architecture did the external sources contradict? "
            "Quote the specific external source that disproves our assumption.",

            "What did competitor products do differently that we should consider? "
            "Be specific about features and patterns.",

            "Score this architecture 1-10 for production readiness. "
            "What must be fixed before code, and what can be deferred to V2?"
        ]

        findings = []
        for i, query in enumerate(EXTRACTION_QUERIES, 1):
            result = await client.chat.ask(nid, query)
            findings.append(f"## Query {i}\n\n{result.answer}")

        # Save findings
        with open(f"/tmp/crucible-{TOPIC.lower().replace(' ', '-')}-findings.md", "w") as f:
            f.write(f"# Crucible Findings: {TOPIC}\n\n")
            f.write("\n\n---\n\n".join(findings))

        # ── PHASE 4: DOCUMENT (GitHub issues for CRITICAL/HIGH) ──
        # Parse findings, create issues in Demo Readiness milestone
        # Update Activity Log with Crucible scoring
        # This completes the Crucible — human does NOT need to listen

asyncio.run(run_crucible())
```

### API Gotchas (Learned 2026-03-16)

| Issue | Fix |
|-------|-----|
| `wait_for_completion` default timeout is only 300s | Audio takes 5-15 min. Always pass `timeout=900` explicitly. Also has `initial_interval` and `max_interval` params. If it still times out, poll with `artifacts.list_audio(nid)` — status 3 = complete. Never call `download_audio` without confirming completion first. |
| `notebooks.create()` returns a `Notebook` dataclass | Get the ID with `nb.id`. This is not documented in the library but confirmed by source inspection. |
| `download_audio` takes `output_path` as string, not bytes | `download_audio(nid, "/tmp/file.mp3", artifact_id=id)` — returns the path string |
| `GenerationStatus` uses `task_id`, not `artifact_id` | `status.task_id` for polling |
| `add_text` full sig: `(nid, title, content, wait=False, wait_timeout=120.0)` | Title comes BEFORE content. Optional `wait=True` blocks until source is processed. |
| `from_storage()` init pattern | **Two-step:** `client = await NotebookLMClient.from_storage()` then `async with client:` — The single-line `async with NotebookLMClient.from_storage() as client:` throws TypeError in v0.3.3 despite what the docstring says. |
| Python 3.9 won't work | Library requires 3.10+. Use `uv run python` from `~/clawd/notebooklm-py/` |
| `ArtifactStatus` enum values | PROCESSING=1, PENDING=2, COMPLETED=3, FAILED=4 — use `list_audio()` and check `status == 3` |

### 🔴 PRE-FLIGHT CHECKLIST (Read Before Starting ANY Crucible)

**Before running a single line of NotebookLM code, you MUST:**

- [ ] Read `~/.claude/skills/StrikeMeta/SKILL.md` Stage 2 (scoping rules, minimum-3-docs, execution steps)
- [ ] Read this Article 35 in full (audio mandate, one-notebook-per-topic, self-processing protocol)
- [ ] Identify debate topics — each gets its OWN notebook
- [ ] For EACH topic: identify 1 architecture anchor + 1-3 subject docs + plan 3-8 external research URLs
- [ ] Search the web for external sources BEFORE creating notebooks (use WebSearch or research agents)
- [ ] Confirm `uv run python` works from `~/clawd/notebooklm-py/` and auth is valid

**If you skip this checklist, you WILL make the same mistakes documented in "Born From" below.**

### Cross-References (Read Both — They Are Complementary)

| Document | What It Covers |
|----------|---------------|
| **This Article (Constitution Art. 35)** | The HOW — API code, self-processing protocol, gotchas |
| **StrikeMeta SKILL.md Stage 2** | The WHAT — document scoping rules, minimum-3-docs, scoring pattern |
| **Constitution Article 7** | The WHY — Two Red Teams philosophy |

**An AI that reads only one of these will get it wrong.** Article 35 without StrikeMeta = correct code but wrong scoping. StrikeMeta without Article 35 = correct scoping but wrong execution method.

### When Crucible Is Required

Per Article 7 (Two Red Teams), a NotebookLM Crucible debate is required for:
- Architecture decisions that affect multiple features
- Security model designs (RLS, auth)
- Offline/conflict resolution strategies
- Notification system design
- Any decision where "what if we're wrong?" has high blast radius

### The Gate

**No FSD writing begins until at least one NotebookLM Crucible Audio Overview has been generated, self-processed via the 5-query extraction, and findings documented in GitHub issues** on the project's most critical architecture decisions.

### Born From — Incident Record (IT Concierge, 2026-03-16)

A CC session made 10 mistakes running the Crucible. This Article exists to prevent all of them:

| # | Mistake | Root Cause | Fix In This Article |
|---|---------|-----------|-------------------|
| 1 | Didn't read StrikeMeta before starting | No pre-flight checklist existed | PRE-FLIGHT CHECKLIST section |
| 2 | Used chat queries instead of Audio Overviews | Old Article 35 had broken `notebook.chat()` code | AUDIO OVERVIEW IS THE CRUCIBLE section |
| 3 | Dumped 28 sources into one notebook | "Don't batch" was a buried bullet in StrikeMeta | ONE NOTEBOOK PER TOPIC section |
| 4 | No external research sources | Didn't read StrikeMeta's minimum-3-docs rule | PRE-FLIGHT CHECKLIST + Cross-References |
| 5 | Asked human to listen to audio | Self-processing was undocumented | AI SELF-PROCESSES section |
| 6 | No 5-query extraction after audio | Post-audio workflow didn't exist | 5-query extraction protocol |
| 7 | Wrong API class name (`NotebookLM`) | Code was never tested | Correct code example |
| 8 | Wrong API method signatures | API gotchas never captured | API Gotchas table |
| 9 | No Python version warning (3.9 fails) | Runtime requirements undocumented | Tool table + API Gotchas |
| 10 | Didn't cross-reference related docs | No pointers between Constitution and StrikeMeta | Cross-References section |

**The principle:** Every mistake became a section. If a future AI makes a new mistake, add it to this table and create a corresponding section.

---

---

## Article 36: Responsive Design — Three Viewports (Non-Negotiable)

**Every feature, every page, every component MUST work across three viewports: mobile (375px), tablet (768px), and desktop (1280px+).**

This is not a nice-to-have. This is not "we'll add responsive later." If a feature is built for desktop only, it is **not done**.

### The Three Viewports

| Viewport | Width | Primary User | Design Pattern |
|----------|-------|-------------|----------------|
| **Mobile** | 375px–767px | Field technicians | Touch-first, single-column, large tap targets (44px min), bottom navigation |
| **Tablet** | 768px–1279px | Dispatchers on iPad, technicians on larger devices | Two-column where appropriate, collapsible sidebar |
| **Desktop** | 1280px+ | Dispatchers, Admin, Finance | Full layout, sidebar navigation, data tables, multi-panel views |

### The Rules

1. **Mobile-first CSS.** Base styles target mobile. Use `min-width` media queries to add complexity for larger screens. Never `max-width` to "fix" desktop for mobile.

2. **Every PR touching UI must be tested at all 3 viewports.** This is a blocking review gate. Evidence: screenshot or CIC/Agent Browser verification at 375px, 768px, 1280px.

3. **Touch targets: 44px minimum.** Apple HIG and WCAG require this. A technician wearing work gloves on a wet screen cannot hit a 24px button. This is not negotiable.

4. **No horizontal scroll on mobile.** If content overflows at 375px, the layout is wrong. Fix the layout, don't add scroll.

5. **Data tables convert to cards on mobile.** The ticket list is a table on desktop, a card stack on mobile. Each card shows: ticket number, status badge, client name, priority. Tap to expand.

6. **Forms are single-column on mobile.** Two-column form layouts on desktop collapse to single-column on mobile. Labels above inputs, not beside them.

### Breakpoint Tokens (for Linear UI / Tailwind)

```
--breakpoint-sm: 375px   /* Mobile */
--breakpoint-md: 768px   /* Tablet */
--breakpoint-lg: 1280px  /* Desktop */
--breakpoint-xl: 1536px  /* Wide desktop */
```

### Why This Exists

IT Concierge technicians work on 5-inch phones in basements wearing gloves. Dispatchers work on desktop monitors. Finance uses tablets. The same app serves all three. A desktop-only feature forces technicians back to WhatsApp — which is the exact problem we're solving.

**Testing:** Use Agent Browser (`agent-browser open <url> --viewport 375x812`) or CIC (`mcp__claude-in-chrome__resize_window`) to verify at each breakpoint. Screenshots are evidence.

### E2E Integration (Article 8b)

Every E2E test that touches UI MUST include a mobile viewport assertion. Add to the existing E2E test:

```typescript
// Desktop assertion (default)
await page.setViewportSize({ width: 1280, height: 800 });
// ... test passes

// Mobile assertion (mandatory)
await page.setViewportSize({ width: 375, height: 812 });
// ... same test must still pass (layout adapts, no broken elements)
```

### Incident Record

IT Concierge session 2026-03-16: Responsiveness was mentioned in scattered docs ("mobile-first", "responsive PWA") but never enforced as a blocking standard. No Article existed. No E2E viewport requirement existed. This created risk that features would be built desktop-only and "fixed for mobile later" — which never happens.

---

---

## Amendments

Amendments require explicit approval from Roderic. No AI agent may modify this document autonomously. Proposed amendments are filed as GitHub issues with the `constitution` label and must be thrashed before ratification.
