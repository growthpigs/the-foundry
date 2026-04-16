# Phase 8: RALPH LOOP — Capture & Feed Back

**Metaphor:** The blacksmith inspects the finished blade, notes what worked, sharpens the tools, and prepares for the next piece.

**Duration:** 30-60 minutes per epic completion
**Mode applicability:** ALL modes (even HOTFIX gets a 5-minute version)

---

## What Happens

After TEMPER ships code and R8 confirms you're happy, the Ralph Loop captures everything learned and feeds it back. Without this, every epic starts from zero. With it, every epic is smarter than the last.

This is the arrow from TEMPER back to MINE in the pipeline diagram.

## Process

### 1. Knowledge Graduation

Review progress.txt from this epic:
- Any discovery that appeared 3+ times → **graduates to error-patterns.md** (permanent defensive knowledge)
- Any discovery that's project-specific → stays in progress.txt archive
- Any discovery that improves The Foundry methodology → create an issue in `growthpigs/the-foundry`

### 2. Solutions Directory Update (FR-METH-8, #54)

After each epic, extract reusable patterns into the Solutions Directory (`solutions/` in project repo, or `growthpigs/the-foundry/solutions/` for cross-project patterns).

**What qualifies for an entry:**
- A pattern that took >1 hour to figure out and will appear again
- A failure mode discovered the hard way
- A package combination that works unexpectedly well (or badly)

**Entry format:**

```markdown
## SOLUTION: [Pattern Name]
**Pattern type:** [API integration / Auth / State management / Migration / etc.]
**Technologies:** [specific packages + versions]
**Project:** [project name]
**Date:** YYYY-MM-DD
**Status:** Active

### Problem
[2 sentences]

### Solution
[code snippet or pattern description]

### Failure modes discovered
[what didn't work]

### When NOT to use this
[explicit anti-patterns]
```

**Quarterly Refresh Cycle (curation rot prevention):**
Every quarter, RALPH LOOP triggers a `compound-refresh` scan:
1. Flag all entries older than 90 days
2. Per entry: **Keep** / **Update** / **Supersede** / **Archive**
3. Log: "X kept, Y updated, Z archived" in `solutions/REFRESH-LOG.md`

Without this cycle, the Solutions Directory becomes a liability — outdated patterns pulled with false confidence.

---

### 3. AutoResearch Self-Improvement Loop (FR-METH-16)

**The Karpathy 3-File Pattern — for measurable quality improvement on any goal.**

Three sacred files — never mix their roles:

| File | Role | Who Edits It |
|------|------|-------------|
| `program.md` | The goal / hypothesis to test | Human or Orchestrator |
| `train.py` (or `implement.md`) | The implementation / solution | **Agent ONLY** |
| `prepare.py` (or `evaluate.sh`) | The evaluation / metric script | **UNTOUCHABLE — human-written** |

**The Loop:**
1. Agent reads `program.md` (the goal)
2. Agent edits `train.py` only (the implementation)
3. `prepare.py` runs automatically (evaluation — agent cannot touch this)
4. If metric improves → git commit (keep)
5. If metric worsens → git revert (discard automatically)
6. Loop until convergence or N iterations

**Why the untouchable evaluator is critical:** If the agent can edit `prepare.py`, it optimizes the metric rather than the actual goal. The untouchable evaluator is the anti-sycophancy mechanism for self-improvement.

**Apply to:** Performance bottlenecks, quality scores, test coverage gaps — any problem with a measurable target.

---

### 4. Assumption Table Reconciliation

Go back to the Assumption Table from ASSAY:
- Which assumptions were **validated** by real code? → Update confidence to 95%+
- Which assumptions were **invalidated**? → Document what actually happened, update FSDs
- Which assumptions are **still untested**? → Carry forward to next epic

This is how the Assumption Table evolves from theory to evidence.

### 3. Buyer Persona Reality Check

If the epic touched user-facing features:
- Did the implementation FEEL right when tested?
- Did the UX/Intent confidence score from R8 match reality?
- Any user feedback (even informal) → feed back into Buyer Persona doc

### 4. Methodology Feedback

What worked and what didn't about The Foundry itself during this epic:
- Did the Ratify gates catch real issues?
- Was any gate unnecessary or too heavy?
- Did the External Auditor find something the Crucible missed?
- Were the prompts in ratify.md useful or did you skip them?

Capture this as a SITREP for The Foundry repo.

### 5. Session Wrap

Mandatory paperwork:
- [ ] Activity Log updated with final summary
- [ ] Work Ledger updated with DUs
- [ ] HANDOVER.md updated for next session
- [ ] progress.txt archived to `.foundry/archive/`
- [ ] Commits pushed, branches cleaned

### Outputs
- Updated error-patterns.md (graduated knowledge)
- Updated Assumption Table (theory → evidence)
- SITREP for The Foundry (methodology feedback)
- Clean git state
- Activity Log + Work Ledger current

---

## Why This Phase Exists

Without the Ralph Loop, every epic is an isolated event. With it, each epic feeds the next:

```
Epic 1: "SET LOCAL works but needs session-mode PgBouncer, not transaction-mode"
  → error-patterns.md: "Always verify PgBouncer pool mode before using SET LOCAL"
  → Assumption Table: PgBouncer confidence 50% → 95% (validated)
  → Next epic starts KNOWING this, not guessing

Epic 2: "Gemini classifies French emails at 87% accuracy, not the 70% we feared"
  → Assumption Table: Gemini French confidence 70% → 87% (measured)
  → FSD updated with real numbers instead of guesses
  → Next epic's estimates are based on data, not hope
```

This is how the system gets smarter over time. Not through AI memory (which is unreliable across sessions), but through documented, version-controlled, graduated knowledge.
