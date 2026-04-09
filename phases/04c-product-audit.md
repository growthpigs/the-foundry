# Phase 4c: PRODUCT-AUDIT — Product Strategy Stress-Test

**Metaphor:** After the crucible purifies the metal, a master craftsman inspects it — not for impurities, but for whether it will become the right object.

**Duration:** 2-4 hours
**Mode applicability:** GREENFIELD, FEATURE, SPEC
**Prerequisite:** Crucible confidence ≥ 9/10 + FSD updated with all Crucible findings
**Outputs feed into:** EXTERNAL-AUDITOR, PLAN

---

## What Happens

The post-Crucible FSD is stress-tested through structured product strategy thinking. Unlike the Crucible (which finds engineering gaps), PRODUCT-AUDIT finds:
- What competitors will miss
- What hidden data or feature combination creates the real moat
- What moment makes the product feel magical vs. merely useful
- What governance or monetisation angle the engineers didn't see
- What the top 20 product ideas actually are, ranked by defensibility

This phase was discovered during the Convergence FSD development (thinking-foundry#31, 2026-04-09). The Crucible surfaced architectural gaps. PRODUCT-AUDIT surfaced the knowledge-doc competitive moat, CTCH governance framework, PMI² dynamic weighting, and the "Generate Draft" magical moment — none of which the Crucible produced.

---

## Setup

### 1. Create a fresh NotebookLM notebook

```
Name: "[N]. Product-Audit: [Feature Name]"
Example: "2. Product-Audit: Convergence — Cross-Domain Intelligence Engine"
```

Never reuse a Crucible notebook. The Crucible chat history biases product strategy questions toward engineering concerns.

### 2. Sources (5-8 total)

**Required:**
- The full post-Crucible FSD body (`add_text`, the entire issue body, 1000+ words, not a summary)

**Web references (4-7 additional sources via `add_url`):**
- ≥1 academic paper on the core technology or market (arxiv preferred)
- ≥1 domain-specific article (the specific industry or problem space)
- ≥1 authoritative reference (government portal, official API docs, industry body)
- ≥1 product strategy / business intelligence piece (how companies in this space compete)
- ≥1 opinion/analysis piece (Substack, blog, think-tank) on the underlying problem

**Why web sources matter:** The FSD alone produces FSD-shaped product ideas. Web sources seed conceptual frameworks the FSD cannot contain. In the Convergence PRODUCT-AUDIT: the Substack prediction-markets article seeded PMI² Dynamic Weighting; the AI business intelligence article seeded the CTCH governance framework. Neither idea was in the FSD.

### 3. Wait for all sources to be processed

```python
await client.sources.wait_until_ready(notebook_id, fsd_source.id, timeout=180)
await asyncio.sleep(5)  # buffer for web sources
```

---

## The 5-Prompt Template

Run these sequentially in the Chat panel. Each prompt uses the previous output as input.

### Prompt 1 — Discovery
```
Review all sources as a principal product strategist for [Product Name].
[Product] is [one-line description — e.g., "a cross-domain reasoning engine that surfaces intelligence from a bench of public and private signal sources"].

Generate [N=50-75] original product and intelligence ideas broken down into:
1. Raw feature ideas (15)
2. UX / interaction patterns (10)
3. Monetisation angles (10)
4. Competitive positioning moves (10)
5. Technical architecture insights (5-10)
6. Governance and compliance angles (5-10)

For each idea: what it is, which sources power it, which decision it improves, why it's better than existing approaches.
```

### Prompt 2 — Prioritization
```
Take the ideas you generated and score each on:
- Impact (1-5): how much does this move the needle for the target user?
- Novelty (1-5): how differentiated is this from existing solutions?
- Ease of Implementation (1-5): how achievable in the current phase?
- Defensibility (1-5): how hard for a competitor to copy?
- Customer Value (1-5): how much would a paying customer pay for this?

Maximum score: 25.

Produce:
- A ranked table of the top 20 ideas (score + 1-line rationale)
- Top 5 highest-leverage ideas (max impact + defensibility)
- Top 3 fastest wins (high value, immediate implementation via existing surfaces)
- Top 3 "wow factor" ideas (highest novelty for demos and executive presentations)
- Top 3 most likely to become paid product tiers
```

### Prompt 3 — Product Design
```
Take the top 5 highest-leverage ideas and turn them into product concepts ready for design and development.

For each concept, define:
- Target user persona (role + context)
- Specific problem it solves (what the user cannot do today)
- Exact source fusion that powers it (which bench sources + which private data)
- User workflow step by step (what they do, what the system does)
- Output format (what they see / receive)
- UI surface (where in the product this lives)
- MVP scope (smallest version that proves the value)
- Example user story
- Example insight the product surfaces
- Reason for trust (why does the user believe it?)
- Reason for defensibility (why can't a competitor replicate it?)
```

### Prompt 4 — Differentiation (THE KEY PROMPT)
```
Now challenge each top concept adversarially.

For each:
1. What would a competitor probably miss? (What engineering path will they default to that misses the real value?)
2. What hidden data or feature combination creates the most value? (What's the non-obvious pairing?)
3. What signal would a human analyst likely overlook? (What's invisible to manual review that the system can catch?)
4. What false assumption might users make about it? (What will they misunderstand that could undermine adoption?)
5. What could make the product feel magical rather than merely useful? (The "instant paralegal" moment — what is the wow?)
```

### Prompt 5 — Execution
```
Turn the best ideas into a practical build plan.

For the strongest concept (the one with the highest leverage + most magical moment), define:
- The smallest viable version (stealth POC scope)
- The data sources required (public + private, specific APIs)
- The enrichment steps (how raw data becomes intelligence)
- The scoring or ranking logic (how items are prioritised — no synthetic scores)
- The alert logic (what fires a notification and why)
- The minimum interface needed (what surfaces, what doesn't)
- What must be built vs. what already exists
- The riskiest assumption in the build plan
```

---

## Audio (Generate After Text Chat)

Generate 2 audio pieces using the same notebook:

**Audio 1 — Deep Dive:** Focus on the top 3 product concepts from Prompt 3. Instructions should name the concepts explicitly so hosts engage with specifics.

**Audio 2 — Debate:** Set up adversarial tension between the top 2 competing ideas from Prompt 2. Instructions: "Stay adversarial throughout. Do NOT agree at the end. The product must make a choice."

```python
from notebooklm.rpc.types import AudioFormat, AudioLength

# Deep Dive
await client.artifacts.generate_audio(
    notebook_id,
    audio_format=AudioFormat.DEEP_DIVE,
    audio_length=AudioLength.DEFAULT,
    instructions="Focus on [concept 1], [concept 2], and [concept 3]..."
)

# Debate
await client.artifacts.generate_audio(
    notebook_id,
    audio_format=AudioFormat.DEBATE,
    audio_length=AudioLength.DEFAULT,
    instructions="Host A argues [position]. Host B argues [counter]. Stay adversarial. Do NOT agree at the end."
)
```

---

## What To Do With Output

### Feed back into the FSD
- New FRs or Phase 2 notes from Prompt 1 ideas → add to the FSD issue
- Competitive moat articulation from Prompt 4 → add to the FSD's "Why this matters" / "Moat" section
- Governance/CTCH insights → add as design principles in the FSD
- Magical moment from Prompt 4 → elevate to #1 in the product pitch

### Feed into PLAN
- Top 20 ranked ideas → input for sprint story decomposition
- Product concepts from Prompt 3 → candidate epic definitions
- Build plan from Prompt 5 → candidate Day 0 research spikes

### Feed into EXTERNAL-AUDITOR
- Contrarian insights from Prompt 4 → external auditor challenges these directly
- False user assumptions → external auditor asks "did you account for this?"

---

## Success Criteria

✅ Fresh notebook created (not reused from Crucible)
✅ Full post-Crucible FSD uploaded (uncut, 1000+ words)
✅ 4-6 web reference sources added
✅ All 5 prompts completed sequentially
✅ Output includes at least 1 insight NOT in the FSD before this phase
✅ FSD updated with PRODUCT-AUDIT findings
✅ 2 audio pieces generated (Deep Dive + Debate)
✅ Notebook ID recorded and posted as GitHub issue comment

❌ Wrong if:
❌ Ran prompts without web reference sources (echo chamber)
❌ Skipped Prompt 4 (differentiation is the secret weapon — non-optional)
❌ Only ran audio, skipped the 5 prompts
❌ FSD NOT updated after PRODUCT-AUDIT (findings wasted)
❌ All output already existed in the FSD (PRODUCT-AUDIT found nothing new = process failure)

---

## Placement in the Foundry Pipeline

```
ASSAY → CRUCIBLE (R4) → PRODUCT-AUDIT → EXTERNAL-AUDITOR (R4b) → PLAN (R5)
```

PRODUCT-AUDIT sits between CRUCIBLE and EXTERNAL-AUDITOR:
- Needs the stress-tested FSD (post-Crucible) as input — running against a draft produces shallower output
- Its findings should go through EXTERNAL-AUDITOR before being promoted to PLAN
- The contrarian insights from Prompt 4 are a second pass of external-auditor-style thinking, from product strategy rather than engineering

---

## Related

- `phases/04-crucible.md` — The engineering stress-test that precedes this phase
- `phases/04b-external-auditor.md` — The independent model review that follows this phase
- thinking-foundry#32 — Crucible SOP (Thinking Foundry)
- thinking-foundry#31 — Convergence FSD (the case study that produced this phase)
- the-foundry#46 — Issue tracking this phase addition

**Phase added:** 2026-04-09
**Discovered during:** Convergence FSD PRODUCT-AUDIT, thinking-foundry#31
