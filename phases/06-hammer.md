# Phase 6: HAMMER — Build

**Metaphor:** The blacksmith swings. Heated metal takes shape under precise, repeated blows.

**Duration:** Varies (sprint-based)
**Mode applicability:** ALL modes

---

## What Happens

Code drops. The specs from ASSAY, validated by CRUCIBLE, planned in PLAN, are now implemented. This is where the Ralph Loop and Dark Factory patterns come into play.

### Inputs (Phase Contract — HAMMER will NOT start without these)
- [ ] GitHub Issues with acceptance criteria (from PLAN)
- [ ] FSDs (the implementation blueprint)
- [ ] Anti-regression baseline (captured before first code change)
- [ ] Deployment pipeline (verified in PLAN)
- [ ] **Carry-forward from PLAN** in progress.txt (architectural decisions, dependency order, risks flagged)

**If any input is missing → HAMMER cannot start. Go back to the phase that should have produced it.**

### Process

#### Execution Modes

HAMMER operates differently depending on the mode:

| Mode | What Happens in HAMMER |
|------|----------------------|
| GREENFIELD | Full agent swarm — parallel worktrees per epic |
| FEATURE | Single agent, focused on one epic |
| FIX | Single agent, minimal scope, targeted fix |
| HOTFIX | Emergency — skip to code, minimal validation |
| REFACTOR | Behavior-preserving — anti-regression is CRITICAL |
| SECURE | Private branch, restricted access, embargo contract |

#### The Ralph Loop (Autonomous Execution)

For larger features, HAMMER uses the Ralph pattern:
1. Each iteration is a fresh `claude -p` instance with clean context
2. Memory persists via git history, progress.txt, and the issue body
3. Each iteration works on one story from the sprint
4. After completion, the story is marked done and the next one starts
5. Maximum iterations configurable (default: 10)

#### Dark Factory Mode (Level 5)

When running fully autonomous (Long Run Mode, Article 30):
- No approval needed for: branches, commits, issue updates, doc changes, test runs, draft PRs
- Still needs approval for: merging to main, production deploys, destructive git operations
- Activity Log updated every turn (not just at end)
- Work Ledger updated at session wrap

#### Fresh Context Per Stage (Article 5)

Each sub-task within HAMMER runs with fresh context:
- No accumulated state beyond progress.txt and the command file
- Prevents context drift, hallucinated dependencies, and compounding errors
- The Ralph pattern enforces this naturally

#### Anti-Regression (Article 8)

BEFORE any code changes:
1. Capture baseline: test count, test results, TypeScript compilation, build status
2. For REFACTOR mode: additionally capture test names, API response shapes, key file checksums

AFTER code changes:
3. Compare against baseline
4. Any regression BLOCKS the PR

#### Knowledge Capture (Article 6)

During HAMMER, every discovery goes to progress.txt:
```
## [Stage Name] — [Timestamp]
- DISCOVERED: [What we learned]
- DECISION: [Choice made and why]
- BLOCKED: [What prevented progress]
- WARNING: [What might bite us later]
- FIXED: [What was changed and why]
```

If a discovery recurs across 3+ features → graduates to error-patterns.md.

### Outputs
- Working code (branches, not merged to main yet)
- Draft PRs (for review)
- Test suite (unit + integration)
- progress.txt (knowledge captured)
- Anti-regression comparison
- Activity Log entries
- Work Ledger entries (DUs)

### Server Error Logging Standard (Mandatory)

**Born from:** IT Concierge retrospective (growthpigs/it-concierge#147). Silent failures — errors caught but not logged — caused bugs that took days to diagnose. The server returned 200 OK while data was silently corrupted.

**The Standard:** Every server-side error path MUST log before recovering. No silent swallows.

```
RULE 1: Every catch block MUST log (level: error/warn) before recovering
RULE 2: Every fallback/default path MUST log (level: warn) explaining WHY the fallback triggered
RULE 3: No empty catch blocks — zero tolerance (enforced by linter)
RULE 4: Error logs MUST include: error message, stack trace, context (user ID, request ID, entity ID)
```

**Browser API Exemptions:**
- `navigator.geolocation` — may fail legitimately (user denied)
- `navigator.clipboard` — may fail in non-secure contexts
- `localStorage.getItem` — may return null legitimately
- `fetch` for optional analytics/telemetry — non-critical

For these, a `console.warn` is acceptable instead of full error logging. But the exemption must be **commented** in code explaining why.

**Enforcement:** TEMPER Phase 7 includes a Server Error Logging Verification step (grep for empty catch blocks, catch blocks without logging). See Phase 7 for the verification protocol.

### The HAMMER Rules

1. **Tests first, then code.** Write the test that proves the story works, then write the code to pass it.
2. **One story at a time.** Don't parallelise stories within the same epic unless they're truly independent.
3. **Commit early, commit often.** Every logical change is a commit. Not one big commit at the end.
4. **Draft PR immediately.** As soon as the first commit is pushed, create a draft PR. This enables CodeRabbit and CI to run continuously.
5. **Don't merge.** HAMMER produces draft PRs. Merging happens in TEMPER after hardening.
6. **No silent failures.** Every error path logs. Every fallback explains itself. See Server Error Logging Standard above.

---

## ⚖️ R6: Build Gate

See [ratify.md](ratify.md#r6-build-gate-after-hammer)

**Key question:** "Did we build it right? In the right place?"

**Must pass:**
- [ ] Environmental sanity confirmed (right file, right repo, right branch)
- [ ] Every change verified by execution (not just syntax)
- [ ] Anti-regression baseline compared — no regressions
- [ ] Tests pass (exit code 0)
- [ ] TypeScript compiles (`tsc --noEmit`)
- [ ] Build succeeds
- [ ] Draft PR created with CI passing
- [ ] progress.txt updated with discoveries
- [ ] Confidence ≥ 8/10
