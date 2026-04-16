# Phase 6b: LAUNCH — Go-to-Market Planning

**Metaphor:** The blade is forged. Before the warrior takes it to battle, they must know the terrain, the enemy, and the strategy. LAUNCH is that briefing.

**Duration:** 2-4 hours
**Mode applicability:** GREENFIELD, FEATURE only. All other modes skip.
**Position in pipeline:** Between PLAN and HAMMER.

> ⚠️ **Naming note:** This is NOT `phases/00-launch.md` (the session-startup script). This is the GTM Planning phase, added 2026-04-16. See [FR-METH-2 #48](https://github.com/growthpigs/the-foundry/issues/48).

---

## What Happens

Before writing a single line of code, we answer: **who are we building this for, how do they find out it exists, and what does "won" look like at 12 weeks?**

LAUNCH is not a marketing course. It is a forcing function for specificity. Vague GTM plans produce shipped products nobody uses.

**The test:** Every recommendation in `docs/gtm.md` must be specific enough to execute tomorrow. "Use LinkedIn" fails. "Post 3x/week on LinkedIn with threads on [specific pain point], targeting [specific persona], using [specific hook angle]" passes.

---

## Inputs (Phase Contract — LAUNCH will NOT start without these)

- [ ] GitHub issues with acceptance criteria from PLAN
- [ ] FSDs substantially complete from ASSAY
- [ ] Target user(s) defined (from MINE/ASSAY buyer personas)
- [ ] Revenue model confirmed (from ASSAY or PLAN)
- [ ] Tech stack locked (cannot have GTM without knowing what you're shipping)

---

## Process

### Step 1: Market Context Audit (30 min)

Before generating GTM content, answer these with evidence (not opinion):

1. Who is the target user? (Name them. "CTOs at 50-200 person SaaS companies" not "decision-makers".)
2. What do they use today instead of this product? (Name the alternatives.)
3. What is the specific frustration with those alternatives? (Quote from a real conversation or review.)
4. Why now? (What changed in the last 12-18 months that makes this timing right?)
5. Who will be hostile to this product? (Identify the headwind before it appears.)

Record answers in `docs/gtm.md` Section 1. If you cannot answer all 5 with specificity, pause LAUNCH and return to MINE/SCOUT.

### Step 2: Three-Phase Launch Strategy (45 min)

Define three phases with explicit success criteria per phase:

**Pre-Launch (weeks -8 to 0):**
- Goal: build an audience before you have a product
- Activities: specific, weekly, named
- Success metric: X people on waitlist / X committed to beta

**Soft Launch (weeks 0–4):**
- Goal: validate core assumption with paying (or committed) users
- Who gets access: named criteria (not "selected users")
- Success metric: X users doing X behavior X times per week

**Public Launch (week 4+):**
- Trigger: soft launch success criteria met (not a date)
- Channel: specific first announcement venue
- Success metric: X signups / X revenue in first 30 days

### Step 3: Channel Strategy (60 min)

Rank channels 1–N where N is the maximum number you can execute simultaneously with current team (usually 2-3 for solo founders, max 5 for small teams).

For each ranked channel:

| Rank | Channel | Why this audience | Effort/week | Expected reach | ROI basis |
|------|---------|-------------------|-------------|----------------|-----------|
| 1 | [specific] | [specific user type here] | [hours] | [realistic] | [evidence] |

**Ruthless filter:** If you cannot name a specific community, publication, subreddit, newsletter, or conference for a channel — it does not make the list. "Social media" is not a channel. "r/startups (450k members, weekly Show HN thread)" is a channel.

### Step 4: Content & Community Strategy (30 min)

**Content:** What ONE format will you produce consistently? (Thread series, case study, teardown, tutorial, etc.) Define: cadence, topic territory, distribution platform.

**Community:** Where does your target user already gather? (Slack groups, Discord servers, subreddits, LinkedIn groups, industry Slack, conferences.) Define how you participate — as a member, not a promoter.

### Step 5: Metrics & Budget (20 min)

**Funnel metrics:**
- Awareness → Acquisition: [target and measurement method]
- Acquisition → Activation: [target and measurement method]
- Activation → Retention: [target and measurement method]
- Retention → Revenue: [target and measurement method]

**Budget:** For each channel, what does it cost? Separate time cost from money cost. Be honest about both.

### Step 6: Risk Mitigation (15 min)

List 3-5 GTM-specific risks (not technical risks — those are in ASSAY):
- Who could copy this and be better resourced to execute?
- What assumption about user behavior are you most likely to be wrong about?
- What external event could invalidate the timing rationale?

For each risk: mitigation and early warning signal.

---

## Output

**`docs/gtm.md`** — single document with 11 sections (one per step above, plus final summary). Written in first person, specific enough to act on, no marketing speak.

---

## ⚖️ R-LAUNCH: Go-to-Market Gate — Soft Gate

See [ratify.md](ratify.md#r-launch-go-to-market-gate-soft-gate)

**Key question:** "Do we know who we're building this for and how they'll find out it exists?"

**Must pass:**
- [ ] `docs/gtm.md` exists with all 11 sections populated
- [ ] Target user named specifically (not a vague archetype)
- [ ] Three alternatives to this product named explicitly
- [ ] Channel #1 ranked with specific community/publication named
- [ ] Three-phase launch strategy with explicit success criteria per phase
- [ ] At least 3 GTM risks identified with mitigations
- [ ] Confidence ≥ 7/10 (soft gate — GTM plans evolve, but foundation must be solid)

**Why a soft gate (not hard):** GTM plans change. A hard gate here would block shipping on uncertainty that can only be resolved by being in market. The gate ensures the plan exists and is specific — not that it's perfect.
