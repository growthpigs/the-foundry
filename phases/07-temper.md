# Phase 7: TEMPER — Harden & Ship

**Metaphor:** Tempering is the final heat treatment that gives steel its strength and resilience. Without it, the blade is brittle.

**Duration:** 1-4 hours per PR
**Mode applicability:** ALL modes

---

## What Happens

The code from HAMMER is hardened through testing, reviewed through compliance check, validated visually through CIC, and shipped to production. This is where draft PRs become merged code and deployed product.

### Inputs (Phase Contract — TEMPER will NOT start without these)
- [ ] Draft PRs from HAMMER
- [ ] Anti-regression baseline
- [ ] Test suite
- [ ] CIC Validation Prompt template
- [ ] **Carry-forward from HAMMER** in progress.txt (what was built, what was tricky, what warnings were raised)

**If any input is missing → TEMPER cannot start. Go back to HAMMER.**

### Process

#### Step 0: Adversarial Review (FR-METH-6, #52)

**Runs before Compliance Check. Separate agent instance — NOT the same agent that wrote the code.**

**Hold-Out Enforcement (FR-METH-14):** The adversarial reviewer MUST NOT read `progress.txt`, HAMMER session notes, or any reasoning the implementing agent wrote. It receives ONLY: the original FSD spec + the git diff + the test suite. It must form its own hypothesis about what the code does before evaluating it. This prevents sycophantic validation of implementation choices.

This is distinct from CRUCIBLE (pre-build, design-level). TEMPER adversarial review is post-build, implementation-level.

The adversarial reviewer constructs **failure scenarios across implementation boundaries**:

1. **Cross-component failures** — what breaks when component A fails mid-operation while B is running?
2. **Concurrent load** — race conditions that sequential tests never exercise
3. **Data boundaries** — null, empty string, max-length, unicode, injection, extreme values
4. **Integration seams** — every external API call, every DB write, every queue message is a failure surface
5. **Recovery paths** — what does the system actually do when the happy path fails?

**Output:** A typed "Adversarial Report" in `.foundry/adversarial-report.md`:
- FAIL: [scenario] — this breaks in production
- WARN: [scenario] — this is fragile, consider hardening
- PASS: [scenario] — verified resilient

Any FAIL must be addressed before R7. WARNs are triaged (fix now or file as tech debt issue).

**Note:** For FIX and HOTFIX modes, scope this to the changed components only. Skip for SPEC (no code).

---

#### Step 1: 5-Axis Code Review (FR-METH-15)

**Grade every HAMMER output on exactly five axes. No vague "Is this good?" assessments.**

| Axis | Score (0–10) | What to Check |
|------|-------------|---------------|
| **Correctness** | | Does it do what the FSD spec says? Edge cases covered? |
| **Readability** | | Can a developer unfamiliar with this understand it in 5 minutes? |
| **Architecture** | | Follows established patterns? No premature abstractions? |
| **Security** | | OWASP top 10, injection surfaces, auth gaps, RLS coverage |
| **Performance** | | Meets FSD measurable thresholds (P95 latency, etc.)? |

**Pass criteria:** ≥7 on ALL axes. Any single axis <5 = automatic block. R7 cannot pass until all axes ≥5.

---

#### Step 2: Compliance Check (Post-Code Red Team)

The second of the Two Red Teams (Article 7):
- CRUCIBLE (Phase 4) asked: "What if we're wrong?" — BEFORE code
- COMPLIANCE CHECK asks: "Did we build what was debated?" — AFTER code

Compare the implementation against:
- The FSD — did we implement what was specified?
- The Crucible findings — did we address what was found?
- The acceptance criteria — does it pass?
- The failure definitions — did we avoid what we said we'd avoid?

##### Persona-Level Code Tracing (Mandatory for UI-touching PRs)

**Born from:** IT Concierge FSD Gap Report (March 2026). Point-by-point FSD compliance said "yes, we built what was specified." But Lino couldn't edit a client, track materials, or export an invoice. The FSD compliance check validates specs vs code. Persona tracing validates that the user can actually run their business.

**Protocol:** For each primary persona (max 3), trace their critical daily path through actual code:

```
Persona: Lino Lazo (Owner/Dispatcher)
Action: Edit client billing address
Path: /clients/[id] page → ClientDetailPage component → [MISSING: no edit button]
      → ClientForm accepts client prop for edit mode → [MISSING: nothing triggers edit mode]
      → updateClient() server action → [EXISTS but unreachable from UI]
Verdict: ❌ GAP — server action exists, UI trigger missing
```

For each action, trace: **UI Component → Event Handler → Server Action → Database Operation**. A broken link anywhere in that chain = a gap.

**Input:** Use the Proof Report from ASSAY (`.foundry/proof-report.md`) as the checklist. If ASSAY was run with the Structured Walkthrough, the Proof Report already lists every action to verify. If no Proof Report exists (FIX mode, older projects), trace the persona's top 10 daily tasks.

**Output:** FSD Gap Report — prioritized P0/P1/P2/P3, with exact file paths, US references, FR references.

```markdown
## FSD Gap Report — [Project Name]

### Summary
| Priority | Count | Impact |
|----------|-------|--------|
| P0 — Blocking | X | Cannot run business |
| P1 — High Value | Y | Daily ops impacted |
| P2 — Important | Z | Feature completeness |

### Gaps
- **GAP-01**: [Action] — [Component path] → [Server action] → [DB] — [What's missing] (US-NNN, FSD-NNN FR-NNN)
- ...
```

**Artifact location:** `.foundry/gap-report.md` — referenced in progress.txt as `[GAP-REPORT] report=.foundry/gap-report.md`

##### Mode Applicability for Persona Tracing

| Mode | Runs Persona Tracing? | Scope |
|------|----------------------|-------|
| GREENFIELD | ✅ Full (all personas, all features) | All FSDs |
| FEATURE | ✅ Scoped (affected personas, affected features) | Feature FSDs only |
| FIX | ⏭ Skip (unless fix touches CRUD lifecycle) | — |
| HOTFIX | ⏭ Skip | — |
| SPEC | ⏭ Skip (no code to trace) | — |
| REFACTOR | ⏭ Skip (behavior-preserving) | — |
| SECURE | ✅ Security-relevant paths only | Auth/RLS paths |

#### Step 2: E2E Testing

Every feature PR must include E2E test assertions:
- Maps to the Critical Path (the project's single most important flow)
- Bug fixes add regression E2E tests for the specific failure
- Refactors verify existing E2E tests still pass

#### Step 3: Anti-Regression Comparison

Compare current state against the baseline captured before HAMMER:
- Test count: must not decrease
- Test results: no new failures
- TypeScript errors: must not increase
- API shapes: must not change unexpectedly (REFACTOR mode)

Any regression → BLOCK. Fix before proceeding.

#### Step 3b: Migration Verification Gate (from IT Concierge #147)

**Born from:** IT Concierge retrospective (growthpigs/it-concierge#147). SQL migration files were committed to git and passed all code review — but were never actually applied to the database. Tests ran against a stale schema. The app deployed with migration files that the database had never seen. This caused production failures that looked like application bugs but were actually schema mismatches.

**Trigger:** Any PR that includes database migrations (SQL files, Prisma migrations, Drizzle migrations, Supabase migrations, etc.)

**The Verification Protocol:**

```
STEP 1: List all migration files in the PR
STEP 2: Connect to the target database (staging or preview branch)
STEP 3: Verify each migration was APPLIED:
  - Supabase: Check supabase_migrations.schema_migrations table
  - Prisma: Check _prisma_migrations table
  - Drizzle: Check __drizzle_migrations table
  - Raw SQL: Check that the tables/columns/indexes actually exist
STEP 4: Run a query that exercises the new schema
  - SELECT from new columns, INSERT with new constraints, etc.
STEP 5: Compare schema snapshot (before vs after)
```

**Evidence required:** Show the migration table entry OR the schema diff proving the migration ran. Screenshots of "migration file exists in git" are NOT evidence.

**What this catches:** Ghost migrations (committed but not run), partial migrations (ran halfway then failed silently), wrong-database migrations (ran against dev but not staging).

**R7 enforcement:** If PR contains migration files and no migration verification evidence → R7 fails.

#### Step 3c: Server Error Logging Verification (from IT Concierge #147)

**Companion to:** HAMMER Phase 6 Server Error Logging Standard.

**The Verification Protocol:**

```bash
# Check for empty catch blocks (zero tolerance)
grep -rn 'catch.*{' --include='*.ts' --include='*.tsx' | grep -A1 '{}'

# Check for catch blocks without logging
# Pattern: catch block that doesn't contain console.error, logger., log.error, etc.
grep -rn 'catch' --include='*.ts' --include='*.tsx' -A5 | grep -v 'console\.\(error\|warn\)' | grep -v 'logger\.' | grep -v 'log\.'

# Check for bare try-catch-ignore patterns
# Any catch block that only contains a comment = silent failure
```

**What to verify:**
- [ ] Zero empty catch blocks in changed files
- [ ] Every catch block logs with context (error message + stack + entity ID)
- [ ] Every fallback/default path has a warn-level log
- [ ] Browser API exemptions are commented with justification

**R7 enforcement:** Empty catch blocks in any changed file → R7 fails.

#### Step 4: CI Pipeline (5 Gates)

Every PR must pass all 5 CI gates:
1. **Type Safety** — `tsc --noEmit`
2. **Build** — Production build succeeds
3. **Unit Tests + Coverage** — Tests pass, coverage reported to SonarCloud
4. **Security Scan** — White-label check, secrets scan, multi-tenant isolation
5. **E2E Health** — Blood test / Playwright against staging

**The "All Green" Rule:** If a CI check exists, it must pass. No "it's fine, we know about it."

#### Step 5: Visual Review Gate (Enhanced CIC Validation) (from IT Concierge #147)

**Born from:** IT Concierge retrospective (growthpigs/it-concierge#147). Code review approved PRs where the UI was visually broken — misaligned layouts, missing elements, wrong colors. The code was "correct" but the user experience was damaged. Before/after screenshots would have caught it instantly.

For PRs that touch UI:

##### 5a: Before/After Screenshot Comparison (Mandatory)

```
BEFORE starting HAMMER:
  → Screenshot every page/component that will be modified
  → Store in .foundry/screenshots/before/

AFTER HAMMER completes:
  → Screenshot the same pages/components
  → Store in .foundry/screenshots/after/

REVIEW:
  → Side-by-side comparison of before/after
  → Check: layout, spacing, colors, text, responsive breakpoints
  → Any visual regression not explained by the PR → BLOCK
```

**Tools:** CIC screenshot, agent-browser screenshot, or manual screenshot. Any method is acceptable — the evidence is what matters.

**Minimum screenshots:** Every page/component modified by the PR. For component libraries, screenshot the Storybook stories.

##### 5b: CIC Automated Validation

1. CC generates a CIC Validation Prompt (Article 27)
2. Human pastes prompt into Claude in Chrome
3. CIC executes visual checks, produces a Validation Report
4. Human copies report back to CC
5. CC reads report, decides: merge / create issues / abort

**R7 enforcement:** UI-touching PRs without before/after screenshots → R7 fails. The screenshots are evidence, not optional.

#### Step 5c: Red-Team After Every Epic (from IT Concierge #147)

**Born from:** IT Concierge retrospective (growthpigs/it-concierge#147). Standard testing found bugs individually, but missed systemic issues — interaction effects between features, load behavior, edge cases that only appear when the full epic is integrated. A 3-agent adversarial sequence after epic completion caught issues that per-story testing missed.

**Trigger:** After every epic's stories are merged (not per-story — per-epic). Runs before Ralph Loop captures learnings.

**The 3-Agent Red Team Protocol:**

```
AGENT 1: BREAKER (Destructive Testing)
  → Try to break every feature in the epic
  → Invalid inputs, boundary values, rapid actions, concurrent operations
  → Network failures mid-operation, timeout scenarios
  → Output: List of failures with reproduction steps

AGENT 2: AUDITOR (Compliance Verification)
  → Compare implementation against every FSD acceptance criterion
  → Verify every failure definition is actually prevented
  → Check CRUD Coverage Matrix — can the user actually do everything specified?
  → Output: Compliance scorecard (% of acceptance criteria met)

AGENT 3: USER (Persona Walkthrough)
  → Walk through the Proof Report from ASSAY as the primary persona
  → Every action the persona takes: does it work end-to-end?
  → Focus on the FLOW, not individual features — does the daily workflow feel right?
  → Output: Persona experience report with friction points
```

**Duration:** 1-2 hours for the full 3-agent sequence.

**Output:** Red Team Report saved to `.foundry/red-team-report.md`. Any P0 finding blocks the Ralph Loop — fix first, then capture learnings.

**Mode applicability:**

| Mode | Runs Red-Team? | Scope |
|------|---------------|-------|
| GREENFIELD | ✅ Full (all 3 agents) | Per epic |
| FEATURE | ✅ Full (all 3 agents) | Per epic |
| FIX | ⏭ Skip (unless fix spans 3+ stories) | — |
| HOTFIX | ⏭ Skip | — |
| REFACTOR | ✅ Breaker + Auditor only (no Persona) | Per epic |
| SECURE | ✅ Full + security-specific scenarios | Per epic |

#### Step 6: Merge & Deploy

Once all gates pass:
1. Merge PR to main
2. Deploy to staging (auto)
3. Verify staging
4. Deploy to production (manual for most projects)
5. Blood test against production
6. Update Demo Readiness milestone

#### Step 7: Knowledge Graduation

After merge:
1. Archive progress.txt to `.foundry/archive/`
2. Graduate recurring findings to error-patterns.md (3+ occurrences)
3. Update Activity Log with final summary
4. Update Work Ledger with DUs
5. Update features/*.md if impacted

### Outputs
- Merged code on main
- Deployed to staging/production
- CIC Validation Report
- Updated Activity Log
- Updated Work Ledger
- Graduated knowledge (error-patterns.md)
- Demo Readiness milestone updated

---

## ⚖️ R7: Ship Gate

See [ratify.md](ratify.md#r7-ship-gate-after-temper)

**Key question:** "Prove it's done. Show me evidence."

**Must pass:**
- [ ] `git diff` shows exactly what changed
- [ ] All tests pass (exit code 0)
- [ ] Linter clean, type check clean, build succeeds
- [ ] CI pipeline all green (5 gates)
- [ ] CIC Validation Report: SAFE TO MERGE (if UI changes)
- [ ] Anti-regression: no regressions
- [ ] **Migration Verification:** all migration files confirmed applied to database (if PR contains migrations)
- [ ] **Server Error Logging:** zero empty catch blocks, all error paths log with context
- [ ] **Visual Review:** before/after screenshots for all UI-touching PRs
- [ ] Compliance Check: implementation matches FSD
- [ ] Persona-Level Code Tracing completed (GREENFIELD/FEATURE/SECURE; FIX if CRUD lifecycle touched) — FSD Gap Report produced (`.foundry/gap-report.md`)
- [ ] All P0 gaps from FSD Gap Report addressed OR tracked as known debt with GitHub issue numbers
- [ ] **Adversarial Report:** Step 0 Adversarial Review completed (`.foundry/adversarial-report.md`) — all FAIL items addressed, WARNs triaged
- [ ] **Red-Team Report:** 3-agent sequence completed per epic, all P0 findings addressed (`.foundry/red-team-report.md`)
- [ ] Production deploy verified (if applicable)
- [ ] Activity Log updated
- [ ] Work Ledger updated
- [ ] ICE Report produced
- [ ] Confidence ≥ 9/10 (highest bar — this is shipping)
