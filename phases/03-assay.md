# Phase 3: ASSAY — Spec the Metal

**Metaphor:** Assaying determines the composition and quality of the ore. What exactly do we have? How pure is it?

**Duration:** 2-10 days (the most important phase)
**Mode applicability:** GREENFIELD, FEATURE, FIX (light), SPEC, REFACTOR, SECURE

---

## What Happens

This is where thinking happens. The 18 Admin Documents are written. FSDs are crafted. User stories get failure definitions. Architecture decisions are recorded with WHY. The spec becomes so precise that coding is mechanical.

> "We spent 10 days making the documentation and FSDs for LifeModo. The reason, above and beyond making the specs top-notch, is that it took 10 days to actually find our real purpose, our raison d'etre. Pushing back coding because it's become more of a commodity is the industry standard. And I push it further than anyone else." — Roderic Andrews

### Inputs
- Research synthesis from SCOUT
- Buyer personas (refined)
- Technical feasibility assessment

### Process

#### Step 1: The 18 Admin Documents (Article 14)

Every project creates 18 living documents in a GitHub Admin milestone:

**Phase A: Client Interview (Days 1-3)**
1. Agreement (SOW + MOU combined)
2. Client Requirements (CR-NNN)
3. User Stories (US-NNN) with failure definitions
4. User Journeys (UJ-NNN)
5. Glossary & Terminology

**Phase B: Architecture (Week 1-2)**
6. Tech Stack & Integration Map
7. Architecture Decision Log (ADRs with WHY)
8. Product Features (F-NNN)
9. Capabilities (Plugins, Skills, Patterns — JTBD)
10. Dependency & Risk Map

**Phase C: Validation (Week 2-3)**
11. Competitive Landscape
12. KPI & Success Metrics
13. Onboarding Checklist
14. Prompt Library
15. Client Prerequisites
16. Full Cost Breakdown
17. Test Strategy
18. Work Ledger (DU tracking)

#### Step 2: FSDs + Test Stubs (VSDD Pattern)

After Admin docs are substantially complete, write FSDs per feature/component — **and write test stubs simultaneously.**

This is the VSDD (Verified Spec-Driven Development) pattern: specs and tests are written together, not sequentially. The test stubs define what "done" looks like in executable form. They don't need to pass yet — they're the contract.

- One FSD per logical component
- Each FSD includes test stubs (acceptance criteria as code)
- Independent Observer Score ≥ 8/10
- "Could a competent developer who's never seen this project implement from this FSD alone?"
- If no → the FSD isn't done

```
// Example test stub written during ASSAY (not HAMMER)
describe('Ticket status transitions', () => {
  it('should allow NEW → ASSIGNED when technician is available', () => {
    // Stub — implementation comes in HAMMER phase
    expect(true).toBe(false); // Deliberately failing until implemented
  });

  it('should BLOCK ASSIGNED → COMPLETED without work order photos', () => {
    // Failure definition from User Story US-017
    expect(true).toBe(false);
  });
});
```

**Why test stubs in ASSAY, not HAMMER?** Because writing the test forces you to think about edge cases, failure modes, and acceptance criteria WITH PRECISION. Prose specs hide ambiguity. Code specs expose it.

#### Step 3: Assumption Table (Mandatory)

Before thrashing, produce an **Assumption Table** — every assumption the specs rely on, with confidence and blast radius:

```
| # | Assumption | Confidence | What Breaks If Wrong |
|---|-----------|------------|---------------------|
| 1 | Supabase RLS with SET LOCAL works through PgBouncer | 50% | Every table has broken isolation. Business-ending. |
| 2 | EUR 50K clients will use Slack daily | 75% | Console-first architecture is wrong for persona |
| 3 | Gmail snippet (~200 chars) is enough signal | 65% | False negative rate balloons |
```

**Rules:**
- Any assumption below **70% confidence** → triggers a **technical spike** during ASSAY (30-60 min to verify with real tools, not prose)
- Any assumption below **50% confidence** → becomes a CRUCIBLE topic (Phase 4) with mandatory adversarial debate
- The Assumption Table is a living document — update it as confidence changes
- Assumptions at 90%+ after a spike can be removed from the table

**What is a technical spike?** Spin up the real tool. Test the actual API. Run the query. The DTU (Digital Twin Universe) exists for this — verify assumptions against real services, not documentation.

#### Step 4: Buyer Persona Pressure Test

**Every FSD must be read through the eyes of each Buyer Persona.** Not in the abstract — specifically.

Load the Buyer Persona document and for each FSD, ask:
- "How does **[Persona Name]** experience this feature?"
- "Does this feel like [the promise] or like [generic software]?"
- "What would **[Persona Name]** complain about?"
- "Would **[Persona Name]** even use this, or is it for us?"

**Example (LifeModo):**
- Jean-Marc (retired CEO): "Does the Morning Brief feel like having an EA again, or like a notification digest?"
- David (expat): "Does the obligation tracker feel like a concierge helping me navigate French bureaucracy, or like a to-do app?"

The Buyer Persona document must be a mandatory input to every Crucible session (Phase 4) as one of the minimum 3 sources.

#### Step 5: Thrash

The spec is not done on the first pass. Thrash it:
- Challenge every assumption (reference the Assumption Table)
- Find contradictions between documents
- Ask "what if the opposite were true?"
- Find gaps: what did we NOT specify?
- Run failure scenarios: what happens when things go wrong?
- **Read every FSD through each Buyer Persona's eyes**

### Outputs
- 18 Admin Documents (GitHub Issues — gold standard)
- FSDs per component
- **Assumption Table** (with confidence scores and spike results)
- **Buyer Persona pressure test notes** (per FSD)
- Activity Log entries (thinking captured)
- Work Ledger entries (DUs logged)
- Sources list for Crucible (Phase 4)

### The Key Insight

The Assay phase is where you discover what you're actually building. LifeModo spent 10 days here and found its raison d'etre on day 9. IT Concierge spent 3 days and caught 16 real architectural issues that would have been weeks of debugging if found in code.

The cost of thinking is ALWAYS less than the cost of fixing.

---

## ⚖️ R3: Spec Gate

See [ratify.md](ratify.md#r3-spec-gate-after-assay)

**Key question:** "Are the specs perfect? Could a stranger implement from this?"

**Must pass (dual confidence scores):**
- [ ] All 18 Admin Documents substantially complete
- [ ] At least Agreement, Client Requirements, User Stories, User Journeys, Tech Stack, ADR Log, and Features are FINISHED
- [ ] Every user story has acceptance criteria AND failure definitions
- [ ] Independent Observer Score ≥ 8/10 on each FSD
- [ ] Zero contradictions between Admin docs
- [ ] Glossary has every term defined
- [ ] **Assumption Table produced** — all assumptions below 70% have been spiked
- [ ] **Buyer Persona pressure test completed** on every FSD
- [ ] **Correctness confidence ≥ 8/10**
- [ ] **UX/Intent confidence ≥ 7/10** (judged through Buyer Persona lens — would the target user FEEL this is what was promised?)
