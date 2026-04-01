# The Foundry — Constitution (Core Principles)

**Version:** 1.0
**Status:** RATIFIED (2026-03-13)
**Scope:** Immutable. Loaded for EVERY pipeline stage.

These are the non-negotiable principles. For detailed reference articles (18 Documents, Activity Log, Crucible, CI Pipeline, etc.), see `CONSTITUTION.md` (full version — loaded for ASSAY/CRUCIBLE/red-team stages only).

---

## Article 1: Issues Are Sacred

The issue body and title are NEVER modified by automation. Labels, milestones, and assignments ARE metadata and CAN be changed. The issue is the deliberation record — the journey of thinking. Altering it rewrites history.

---

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

---

## Article 3: The FSD Philosophy

"The most correct and perfect functional specification documents in history — so coding is just a formality."

If the spec is perfect, implementation is mechanical. Every ambiguity in a spec becomes a bug in code. Every gap in requirements becomes a debate during implementation. The cost of thinking is always cheaper than the cost of fixing. Thrash the spec, not the code.

---

---

## Article 4: Compose, Don't Replace

Before building anything new, audit what already exists. New systems are thin orchestration wrappers over existing tested components. The "second system effect" — rebuilding proven tools from scratch — is forbidden. The right move is always to compose.

---

---

## Article 5: Fresh Context Per Stage

Each pipeline stage runs with fresh context (`claude -p`). No accumulated state beyond what is explicitly passed via progress.txt and the command file prompt. This prevents context drift, hallucinated dependencies, and compounding errors.

---

---

## Article 6: Knowledge Captures, Knowledge Graduates

Every discovery MUST be written to progress.txt immediately. If a discovery recurs across 3+ features, it MUST graduate to error-patterns.md. Knowledge that exists only in conversation memory does not exist.

---

---

## Article 7: Two Red Teams

Every non-trivial change receives adversarial review:
- **Crucible (predictive):** "What if we're wrong?" — BEFORE code
- **Compliance Check (retrospective):** "Did we build what was debated?" — AFTER code

The Crucible prevents building the wrong thing. The Compliance Check prevents drifting from what was agreed.

---

---

## Article 8: Anti-Regression Is Non-Negotiable

Every change (except emergency hotfixes) captures a baseline BEFORE implementation: test count, test results, TypeScript compilation status. After implementation, the baseline is compared. Any regression BLOCKS the PR. New bugs are not acceptable as the cost of fixing old ones.

---

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

---

## Article 9: Issues First, Always

When a problem is identified, a GitHub issue is created within 60 seconds. No research first. No investigation first. No agent deployment first. The issue IS the acknowledgment that the problem exists. Everything else follows from the issue.

---

---

## Article 10: Human-in-the-Loop by Default

The pipeline runs autonomously by default, but destructive actions (production deploys, data migrations, security changes) require explicit human approval. "I trust you" and "ship it" do NOT constitute approval for production actions. Only specific words count.

---

---

## Article 11: Estimates Are AI-Assisted

All time and effort estimates use AI wall-clock time, not human developer time. 1 DU = 1 hour AI execution time. Add 50% buffer for unfamiliar APIs or first-time integrations.

---

---

## Article 12: Observability Through GitHub

Roderic's window into ALL work is GitHub. Not terminal output. Not local docs. Not Slack threads. Every research finding, design decision, and architecture choice lives in a GitHub issue or is linked from one. Write → Commit → Push → Share GitHub link. Every time.

---

---

## Article 13: The Orchestrator Principle

Dark Foundry is a router and runner, NOT a methodology. The methodologies are the existing command files (`/explore`, `/red-team`, `/code`, etc.) that were built and battle-tested independently. Dark Foundry decides which ones to call and in what order. The classifier is trivially simple — labels → mode → skip-list → stages. No AI classification, no complexity. Adding new methodologies or frameworks on top of existing stages is the Second System Effect (Article 4) unless those stages genuinely don't exist.

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
