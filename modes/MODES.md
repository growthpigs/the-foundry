# The Foundry — Pipeline Modes

Not every task needs every phase. Modes define which phases to run.

---

## Mode Matrix

| Mode | MINE | SCOUT | ASSAY | CRUCIBLE | PLAN | HAMMER | TEMPER | Budget |
|------|------|-------|-------|----------|------|--------|--------|--------|
| **GREENFIELD** (alias: FULL) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ~$29 |
| **FEATURE** | ⏭ | ⏭ | ✅ | ✅ (quick) | ✅ | ✅ | ✅ | ~$22 |
| **FIX** | ⏭ | ⏭ | ✅ | ⏭ | ⏭ | ✅ | ✅ | ~$12 |
| **HOTFIX** | ⏭ | ⏭ | ⏭ | ⏭ | ⏭ | ✅ | ✅ (fast) | ~$8 |
| **SPEC** | ✅ | ✅ | ✅ | ✅ | ⏭ | ⏭ | ⏭ | ~$15 |
| **REFACTOR** | ⏭ | ⏭ | ✅ | ⏭ | ✅ | ✅ | ✅✅ | ~$25 |
| **SECURE** | ⏭ | ⏭ | ✅ | ✅ | ✅ | ✅ | ✅ | ~$27 |

✅ = Run | ⏭ = Skip | ✅✅ = Extra rigor | ✅ (quick) = Abbreviated version

---

## Mode Descriptions

### GREENFIELD (~$29)
**When:** New project from scratch. No existing code.
**Runs:** All 7 phases, full depth.
**Example:** Starting IT Concierge, LifeModo V6.

### FEATURE (~$22)
**When:** Adding a new feature to an existing project.
**Skips:** MINE (project exists), SCOUT (architecture known).
**Starts at:** ASSAY (spec the feature), CRUCIBLE (quick stress-test), PLAN, HAMMER, TEMPER.

### FIX (~$12)
**When:** Bug fix, minor enhancement.
**Skips:** MINE, SCOUT, CRUCIBLE, PLAN.
**Runs:** ASSAY (understand the bug), HAMMER (fix it), TEMPER (verify).
**Note:** Crucible runs only if the fix touches architecture. PLAN skipped because the issue already exists.

### HOTFIX (~$8)
**When:** Production is down. Emergency.
**Skips:** Everything except HAMMER and TEMPER.
**Runs:** HAMMER (fix immediately), TEMPER (fast validation — type check, build, critical path).
**Note:** Even hotfixes get a user story (30 seconds). Speed is not an excuse for ambiguity.

### SPEC (~$15)
**When:** Architecture exploration. No code.
**Runs:** MINE, SCOUT, ASSAY, CRUCIBLE. Output is validated specs, not code.
**Skips:** PLAN, HAMMER, TEMPER (no code to build or ship).
**Example:** LifeModo V6 architecture phase. DEFCON 0.

### REFACTOR (~$25)
**When:** Behavior-preserving structural changes.
**Anti-regression is CRITICAL (✅✅):** Baseline captures test names, API response shapes, and key file checksums — not just pass/fail.
**Crucible skipped** (behavior unchanged), but TEMPER gets extra rigor.

### SECURE (~$27)
**When:** Security vulnerability, CVE, or audit finding.
**Runs:** Nearly everything — security needs thorough analysis AND careful implementation.
**Special:** Issue is private, PR is restricted, embargo contract applies until patch ships.

---

## Classifier (Automatic Mode Detection)

Label-based routing. Simple, no AI needed.

```
Labels containing:                    → Mode
hotfix, production-down, P0, emergency → HOTFIX
security, vulnerability, cve           → SECURE
refactor, tech-debt, cleanup           → REFACTOR
bug, fix, regression                   → FIX
new, greenfield                        → GREENFIELD
Default (no matching labels)           → FEATURE
```

Override: `./bin/foundry.sh --mode HOTFIX #123`

---

## Ratify Gates Per Mode

Not every mode needs every Ratify gate:

| Mode | R1 Scope | R2 Vision | R3 Spec | R4 Adversarial | R5 Ready | R6 Build | R7 Ship |
|------|----------|-----------|---------|----------------|----------|----------|---------|
| GREENFIELD | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| FEATURE | ⏭ | ⏭ | ✅ | ✅ (light) | ✅ | ✅ | ✅ |
| FIX | ⏭ | ⏭ | ✅ (light) | ⏭ | ⏭ | ✅ | ✅ |
| HOTFIX | ⏭ | ⏭ | ⏭ | ⏭ | ⏭ | ✅ (fast) | ✅ (fast) |
| SPEC | ✅ | ✅ | ✅ | ✅ | ⏭ | ⏭ | ⏭ |
| REFACTOR | ⏭ | ⏭ | ✅ | ⏭ | ✅ | ✅✅ | ✅✅ |
| SECURE | ⏭ | ⏭ | ✅ | ✅ | ✅ | ✅ | ✅ |
