# Phase 5: PLAN — Blueprint the Work

**Metaphor:** Before the blacksmith swings, they read the blueprint. Every cut, every bend, every joint is planned.

**Duration:** 1-2 hours
**Mode applicability:** GREENFIELD, FEATURE, REFACTOR, SECURE

---

## What Happens

The validated specs from ASSAY + CRUCIBLE are decomposed into executable GitHub Issues, organized into Milestones and Sprints. This is where "Drop the Hammer" happens — the conscious decision to transition from thinking to building.

### Inputs
- Validated FSDs (post-Crucible)
- 18 Admin Documents (complete)
- Crucible findings (all dispositioned)
- Work Ledger (budget tracking)

### Process

#### Step 1: Decompose into Epics

Break the project into logical epics (3-8 typically):
- Each epic is a cohesive feature set
- Each epic can be built and tested independently
- Epics have a natural dependency order (some must come first)

#### Step 2: Shard into Stories

Each epic breaks into stories (3-10 per epic):
- Each story is completable in 1-2 DUs
- Each story has acceptance criteria from the FSD
- Each story has failure definitions from the User Stories doc
- ISC (Independently Shippable Criteria): 8-word binary — can this ship alone?

#### Step 3: Create GitHub Issues

For each story:
- Title: `[EPIC-NN] Story name`
- Body: Acceptance criteria, failure definitions, FSD reference
- Labels: milestone, epic, priority
- Milestone: Assigned to correct domain milestone

#### Step 4: Sprint Planning

Organize stories into sprints:
- Sprint capacity: 10-15 DUs (AI-accelerated)
- Priority: What's blocking production first, user value second, tech debt third
- Dependencies: Which stories must complete before others can start

#### Step 4.5: Metadata Tool Registry (FR-METH-11, [#57](https://github.com/growthpigs/the-foundry/issues/57))

**Before HAMMER runs, define what each agent type is allowed to call.** This prevents agents from triggering destructive ops outside their scope and reduces context noise from irrelevant tools.

Create `.foundry/tool-registry.json`:

```json
{
  "agents": {
    "hammer-frontend": {
      "allowed_tools": ["Read", "Edit", "Write", "Bash", "Glob", "Grep"],
      "allowed_domains": ["src/components/", "src/pages/", "public/"],
      "prohibited_tools": ["gh", "git push", "rm -rf"]
    },
    "hammer-backend": {
      "allowed_tools": ["Read", "Edit", "Write", "Bash", "Glob", "Grep"],
      "allowed_domains": ["src/api/", "src/services/", "src/db/"],
      "prohibited_tools": ["gh", "git push", "rm -rf"]
    },
    "temper-reviewer": {
      "allowed_tools": ["Read", "Glob", "Grep", "Bash"],
      "allowed_domains": ["*"],
      "prohibited_tools": ["Edit", "Write", "git commit"]
    }
  }
}
```

**Why define it here:** Orchestrators reference this registry at workflow start, not mid-build. Defining it during PLAN keeps it alongside the story decomposition that drove the agent structure.

**Orchestrator use:** At HAMMER start, the orchestrator reads `tool-registry.json` and passes each agent only its allowed tools. Agents that receive the full tool list are implicitly untrusted.

---

#### Step 5: The Hammer Decision

This is the explicit moment where you say: "The specs are done. The Crucible found nothing blocking. The issues are created. We are ready to code."

**This is NOT automatic.** It's a conscious decision. The Candid Self-Assessment (Article 24) runs here:

```
1. WHERE ARE WE NOW? Status, what changed, what's unchanged.
2. ASSUMPTIONS — list every one.
3. CONFIDENCE SCORES (1-10): Correctness, UX/intent, Performance.
4. WHAT NEEDS RUNTIME VERIFICATION?
5. DOCS & HOUSEKEEPING — what needs updating right now?
6. YOUR RECOMMENDATION — what would YOU do next?
7. WHAT AM I NOT ASKING?
```

Any score below 7 → BLOCKED. Go back to ASSAY.

### Outputs
- GitHub Issues (all stories with acceptance criteria)
- Sprint plan (stories assigned to sprints)
- Epic dependency graph
- Work Ledger updated with planning DUs
- "Hammer Decision" documented in Activity Log

---

## ⚖️ R5: Ready Gate

See [ratify.md](ratify.md#r5-ready-gate-after-plan)

**Key question:** "Is every issue complete enough to build from?"

**Must pass:**
- [ ] Every issue has acceptance criteria
- [ ] Every issue has failure definitions
- [ ] Every issue references its FSD
- [ ] Sprint 1 stories have no unresolved dependencies
- [ ] Candid Self-Assessment scores all ≥ 7
- [ ] Deployment pipeline verified (Article 25)
- [ ] Confidence ≥ 8/10
