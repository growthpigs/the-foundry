# Ratify — The Inter-Phase Gate System

**Every phase transition in The Foundry passes through a Ratify gate.** Ratify is a forced cognitive mode switch — from builder to reviewer, from creator to critic. It cannot be skipped.

## The Principle

Building and reviewing are different cognitive modes. You cannot do both simultaneously. The Ratify gate forces the switch: stop building, start scrutinizing.

**Confidence threshold: ≥ 8/10 to proceed.** Below 8, you fix what's wrong before moving forward. You don't move forward on hope.

---

## The 7 Gates

### R1: Scope Gate (after Ideation)

**Question:** "Is this worth building? Is it scoped right?"

**Protocol:**
1. Run the 80-20 check: Does this deliver 80% of the value for 20% of the effort?
2. Is the feature too ambitious? Can it be split?
3. Are there existing solutions we're ignoring?
4. Kill criteria check: Are buyer personas defined? Can the client articulate the pain?

**Prompt Pattern:**
```
Tell me if the following feature is too ambitious. Apply 80-20 protocol —
80% bang for 20% effort. Do a complete audit of the feature concept, analyze,
think of improvements, and let's move forward. Feature: [NAME]
```

**Pass criteria:** Clear scope, defined personas, articulated pain, 80-20 validated.

---

### R2: Vision Gate (after Scout)

**Question:** "Do we truly understand the problem space?"

**Protocol:**
1. Perspective shift: Go 30,000 feet, then back to sea level. What do you see?
2. Assumption inversion: Pretend all assumptions are inversed. What would that mean?
3. Competitive gap: What are others doing that we're missing? What are we doing that nobody else is?
4. Research completeness: Did we find the right sources? Are there blind spots?

**Prompt Pattern:**
```
Go outside yourself. Go 30,000 feet and then back to sea level. What can we do?
Let's pretend for a second that all our assumptions are inversed. What would that mean?
What would you do now if you could do anything to make you happy with this vision?
```

**Pass criteria:** Research is thorough, assumptions are explicit, blind spots are named.

---

### R3: Spec Gate (after Metallurgy)

**Question:** "Are the specs perfect? Could a stranger implement from this?"

**Protocol:**
1. Independent Observer Score: Would a competent developer who's never seen this project score the spec ≥ 8/10 for implementability?
2. Root cause thinking: Think of 5-7 different possible sources of ambiguity. Distill to 1-2 most critical. Resolve them.
3. Cross-reference check: Do the FSDs agree with the ADRs? Do the user stories match the data model? Do the admin docs contradict each other?
4. Failure definitions: Every user story has acceptance criteria AND failure definitions?

**Prompt Pattern:**
```
Think harder. Reflect on 5-7 different possible sources of the problem, distill
those down to 1-2 most likely sources, and validate your assumptions before
moving on. Think past the classic scapegoats. Think out of the box. Use critical
thinking. You are an exceptional entity that can work anything out.

So you think it's done? Good start but keep going. What would you do next?
Think really hard, and don't just find the first problem — find the next three
or four or five as well. There are probably more than one.
```

**Pass criteria:** Independent Observer ≥ 8/10, zero contradictions between docs, all failure definitions written.

---

### R4: Adversarial Gate (after Crucible)

**Question:** "Did the stress-test find what matters?"

**Protocol:**
1. Fresh eyes CTO review: Pretend you're a 25-year veteran ratifying someone else's work.
2. False positive audit: Were any Crucible findings actually non-issues?
3. Coverage check: Did the Crucible cover every domain group? Or did it skip something?
4. Parallel agent validation: Deploy Explore, Brainstorm, and Superpower agents to independently assess the Crucible output.

**Prompt Pattern:**
```
Double-check with fresh eyes as if you're the CTO ratifying it. You're a 25-year
veteran of full-stack development correcting someone else's homework. Look at it
differently. Check all connection points. Everything you took for granted — verify it.

Assign subagents titled "Explore," "Brainstorm," and "Superpower" to work in
parallel. Each agent specializes: one scans for gaps, another for risks, a third
for opportunities. Let them compete, share findings, and produce a joint report.
```

**Pass criteria:** All Crucible findings dispositioned (fix now / fix later / won't fix with rationale), zero untested domain groups.

---

### R5: Build Gate (after Dark Factory)

**Question:** "Did we build it right? In the right place?"

**Protocol:**
1. Environmental sanity check:
   - Are you editing the right file?
   - Are you in the right repository?
   - Is this the same feature you were meant to be editing?
   - Is it an older version? Has it been commented out?
   - Has something been added by another Claude Code instance you aren't aware of?
2. Runtime-first verification: File existence ≠ functionality. Execute, don't assume.
   - For every claim ("tests pass", "selector updated", "no more duplicates"), point to SPECIFIC code or output proving it.
   - Run verification commands — don't assume previous runs are still valid.
3. Isolation: Fix issues one by one. Don't batch. Verify each individually.

**Prompt Pattern:**
```
That approach was unsuccessful. Isolate the elements using codebase-analyst and
confirm you are editing the correct file. Search for all related elements.
Conduct tests with a validator. Make a minor modification and review results to
be 100% certain. Are you in the correct directory? Double-check that you are not
making a basic mistake by working on the wrong file. Then return to first
principles and consider 2-3 alternative methods.

Verification requires Execution. File existence does not imply functionality.
```

**Pass criteria:** Every change verified by execution (not just syntax check), environmental sanity confirmed, no batched fixes.

---

### R6: Harden Gate (after Forge)

**Question:** "Is it bulletproof? Will it stay working?"

**Protocol:**
1. Stress test as Senior QA Architect:
   - Edge cases: What happens with null/empty inputs?
   - Data formats: Did we verify the shape of data from DB/API?
   - Dependencies: Are we importing libraries that aren't installed?
2. Hardening checklist:
   - [ ] E2E tests written (Playwright) and passing in CI
   - [ ] Runtime guard that throws if broken
   - [ ] Monitoring alert on drift (Sentry)
   - [ ] Feature flag killswitch if applicable
3. Anti-regression baseline: Capture BEFORE snapshot, compare AFTER.
4. Pre-flight checklist for every claim:
   - ✅ VERIFIED: Checked code/file and it exists + executes
   - ⚠️ UNVERIFIED: Guessing (state the risk)
   - ❌ MISSING: Forgot to account for this

**Prompt Pattern:**
```
Switch roles: You are now a Senior QA Architect. Be skeptical.

For every step in your plan, provide PROOF:
- If you say "it handles X," show the specific code snippet that proves it.
- If you assume a config exists, verify it NOW.
- List every assumption made.

Find the gaps — the "What Ifs":
- Edge cases with null/empty inputs?
- Data format verification from DB/API?
- Missing dependencies?

Confidence Score (0-10): Rate your own work. If <9, fix before proceeding.
```

**Pass criteria:** All claims have evidence, hardening checklist complete, confidence ≥ 9/10 (higher bar for Forge).

---

### R7: Ship Gate (after Hammer)

**Question:** "Prove it's done. Show me evidence."

**Protocol:**
1. Evidence audit:
   - `git diff HEAD~1` — show what actually changed
   - Test suite exit code 0
   - Linter clean, type check clean, build succeeds
   - For docs: exact text added, no contradictions, file exists at stated path
   - For data: read back values written, verify schema, show before/after
   - For deploys: actual logs (not "should work"), live URL working, correct commit deployed
2. Cross-system consistency:
   - Multiple files changed → verify they reference each other correctly
   - Ledger/log updated → verify numbers add up
   - Commit made → `git log -1` with message
3. ICE Report:
   ```
   repo: [name], branch: [branch]
   deployed: [host]
   skills: [list used]
   confidence: [score/10] – [justification]
   ICE: [key issue] | [confidence] | [evidence]
   ```

**Prompt Pattern:**
```
VERIFY THIS IS ACTUALLY DONE — Full Hardening Check.

I'm claiming this work is complete. Before you accept that, I need to prove it
with actual evidence:

1. Show changed files (git diff)
2. Run tests, linter, type check, build — show all passing
3. For docs: show exact text, verify no contradictions
4. For deploys: show actual logs and live URL
5. Cross-system: verify references, numbers, commits
6. Git status: should be clean

Success criteria: Actual output/evidence for every claim. Not "I think it's done" — actual proof.
```

**Pass criteria:** Every claim backed by executed evidence, ICE report produced, git status clean.

---

## Anti-Bias Prompts (Use at Any Gate)

When the AI seems stuck in a rut or confirming its own assumptions:

```
Go outside yourself. Go 30,000 feet and then back to sea level. What can we do?

Let's pretend all our assumptions are inversed. What would that mean?

What would you do now if you could do anything to make you happy with what you just did?

Review everything from first principles. Assume 40 years expert experience.
Use fresh eyes. Check for common pitfalls. Get specific documentation from web
to help. Recommend improvements. Summarize findings.
```

## Debugging Escalation (Use at R5/R6)

When bugs are persistent or tricky:

```
Diagnose recurring bugs or usability issues. Identify the underlying root cause,
trace it across modules, and explain how to address it so it never appears again.

Assign subagents "Explore," "Brainstorm," and "Superpower" to work in parallel.
Each specializes: one scans for bugs, another for performance, a third for UX.
Let them compete, share findings, and produce a joint report.

Stop chasing symptoms. Use critical thinking. Imagine you are a HUMAN senior
developer with 25 years of experience. Use first principles.
```

## The Meta-Rule

> "Verification requires Execution. File existence does not imply functionality."

This is the single most important lesson from 1,000+ AI sessions. If you didn't execute it and see the output, you don't know it works.
