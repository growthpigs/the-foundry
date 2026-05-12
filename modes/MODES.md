# The Foundry — Pipeline Modes

Not every task needs every phase. Modes define which phases to run.

---

## Mode Matrix

| Mode | MINE | SCOUT | ASSAY | CRUCIBLE | PLAN | **LAUNCH** | HAMMER | TEMPER | AUTORESEARCH | Budget |
|------|------|-------|-------|----------|------|-----------|--------|--------|-------------|--------|
| **GREENFIELD** (alias: FULL) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ~$35 |
| **FEATURE** | ⏭ | ⏭ | ✅ | ✅ (quick) | ✅ | ✅ | ✅ | ✅ | ✅ | ~$28 |
| **FIX** | ⏭ | ⏭ | ✅ | ⏭ | ⏭ | ⏭ | ✅ | ✅ | ⏭ | ~$12 |
| **HOTFIX** | ⏭ | ⏭ | ⏭ | ⏭ | ⏭ | ⏭ | ✅ | ✅ (fast) | ⏭ | ~$8 |
| **SPEC** | ✅ | ✅ | ✅ | ✅ | ⏭ | ⏭ | ⏭ | ⏭ | ⏭ | ~$15 |
| **REFACTOR** | ⏭ | ⏭ | ✅ | ⏭ | ✅ | ⏭ | ✅ | ✅✅ | ✅ | ~$28 |
| **SECURE** | ⏭ | ⏭ | ✅ | ✅ | ✅ | ⏭ | ✅ | ✅ | ✅ | ~$30 |

✅ = Run | ⏭ = Skip | ✅✅ = Extra rigor | ✅ (quick) = Abbreviated version

### Sub-Step Applicability (ASSAY + TEMPER Enhancements)

| Mode | CRUD Matrix (ASSAY) | Persona Walkthrough (ASSAY) | Persona Code Tracing (TEMPER) |
|------|--------------------|-----------------------------|-------------------------------|
| **GREENFIELD** | ✅ All entities | ✅ All personas (max 3) | ✅ All personas |
| **FEATURE** | ✅ Feature entities | ✅ Affected personas only | ✅ Affected personas only |
| **FIX** | ⏭ Skip | ⏭ Skip | ⏭ Skip (unless CRUD lifecycle touched) |
| **HOTFIX** | ⏭ Skip (ASSAY skipped) | ⏭ Skip | ⏭ Skip |
| **SPEC** | ✅ All entities | ✅ All personas (max 3) | ⏭ Skip (no code) |
| **REFACTOR** | ⏭ Skip (behavior unchanged) | ⏭ Skip | ⏭ Skip |
| **SECURE** | ✅ Security entities | ✅ Security persona only | ✅ Auth/RLS paths only |

**Born from:** IT Concierge FSD Gap Report (March 2026). These sub-steps catch missing CRUD operations and UI dead-ends at spec time (ASSAY) and verify them at code time (TEMPER). See `phases/03-assay.md` Step 2 — CRUD Coverage Matrix sub-section, and Step 4 — Structured Walkthrough, and `phases/07-temper.md` Step 1 — Persona-Level Code Tracing sub-section.

### IT Concierge #147 Gate Applicability

| Mode | State Sync Spike (ASSAY) | Migration Verify (TEMPER) | Error Logging (HAMMER+TEMPER) | Visual Review (TEMPER) | Red-Team (TEMPER) |
|------|-------------------------|--------------------------|------------------------------|----------------------|------------------|
| **GREENFIELD** | ✅ If signals present | ✅ If migrations exist | ✅ Always | ✅ If UI touched | ✅ Per epic |
| **FEATURE** | ✅ If signals present | ✅ If migrations exist | ✅ Always | ✅ If UI touched | ✅ Per epic |
| **FIX** | ⏭ Skip | ✅ If migrations exist | ✅ Always | ✅ If UI touched | ⏭ Skip (unless 3+ stories) |
| **HOTFIX** | ⏭ Skip | ✅ If migrations exist | ✅ Always | ⏭ Skip | ⏭ Skip |
| **SPEC** | ✅ If signals present | ⏭ Skip (no code) | ⏭ Skip (no code) | ⏭ Skip (no code) | ⏭ Skip (no code) |
| **REFACTOR** | ⏭ Skip | ✅ If migrations exist | ✅ Always | ⏭ Skip (behavior unchanged) | ✅ Breaker + Auditor only |
| **SECURE** | ✅ If signals present | ✅ If migrations exist | ✅ Always | ✅ Auth UI only | ✅ + security scenarios |

**Born from:** IT Concierge retrospective (growthpigs/it-concierge#147). 34% of production fixes were preventable with these gates. See individual phase files for full protocols.

---

## Mode Descriptions

### LAUNCH (between PLAN and HAMMER)
**Required for:** GREENFIELD, FEATURE
**Skipped for:** FIX, HOTFIX, SPEC, REFACTOR, SECURE
**Produces:** `docs/gtm.md` — 11-section go-to-market playbook covering market context, launch phases, channel strategy, content/community plan, KPIs, budget, and risk mitigations. See [FR-METH-2](https://github.com/growthpigs/the-foundry/issues/48) for full spec and `phases/LAUNCH.md` when created.

### GREENFIELD (~$35, includes LAUNCH phase)
**When:** New project from scratch. No existing code.
**Runs:** All 7 phases, full depth.
**Example:** Starting IT Concierge, LifeModo V6.

### FEATURE (~$28, includes LAUNCH phase)
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

NotebookLM Crucible enforcement is opt-in at the runner level:

```
./bin/foundry.sh --require-notebook-crucible --mode SPEC #123
```

When enabled, the runner inserts a built-in `notebook-crucible` gate immediately after `red-team`, `red-team-quick`, or `red-team-spec`. The gate blocks unless it can verify a real NotebookLM notebook with at least three ready sources, at least one completed Audio artifact, and a saved findings extraction response. Provide either:

- `NOTEBOOKLM_CRUCIBLE_NOTEBOOK_ID=<id>` to verify an existing notebook.
- `NOTEBOOKLM_CRUCIBLE_CMD='<command>'` to run a command that creates a notebook and prints `CRUCIBLE_NOTEBOOK_ID=<id>`.

Use `--verify-notebook-crucible-only` to verify the NotebookLM gate without running the full pipeline.

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
