# Phase 4: CRUCIBLE — Adversarial Stress-Test

**Metaphor:** The crucible melts metal to separate impurities. What survives is pure.

**Duration:** 1-3 days (per domain group)
**Mode applicability:** GREENFIELD, FEATURE, SPEC, SECURE

---

## What Happens

The specs from ASSAY are stress-tested through adversarial NotebookLM debates. The project is broken into logical domain groups, each tested independently, then combined for a final integration debate.

This is the Foundry's most distinctive phase. Nobody else in the industry does dual-phase adversarial review (pre-code AND post-code). The Crucible is pre-code. The Compliance Check in TEMPER is post-code.

### Inputs
- All 18 Admin Documents from ASSAY
- FSDs per component
- Research sources from SCOUT
- External documentation (API docs, framework guides, competitor analysis)

### Process

#### Step 1: Group the Project into Domains

Break the project into 3-7 logical groups. Each group gets its own Crucible session.

**Example (IT Concierge):**
| Group | Topics | Sources |
|-------|--------|---------|
| Security | RLS, auth, role escalation | FSD-Auth + Supabase RLS docs + OWASP |
| Offline | PWA, sync, conflict resolution | FSD-Offline + PWA docs + competitor analysis |
| Business Logic | Ticket workflow, status transitions, billing | FSD-Tickets + FSD-Billing + domain expert interviews |
| Integration | Calendar, notifications, WhatsApp | FSD-Integration + Google Calendar API docs + Clawdbot architecture |

**Do NOT test everything at once.** IT Concierge ran a single-pass Crucible and found 16 issues. Grouped Crucibles would have found more, with better depth per domain.

#### Step 2: Per-Group Crucible Session

For each domain group:

1. **Create a NotebookLM notebook** (one per group, never batch)
2. **Load sources** (minimum 3, maximum 8):
   - Architecture anchor document (the FSD or ADR for this domain)
   - Subject-specific document (the detailed spec)
   - **Buyer Persona document** (MANDATORY — how does this domain feel to the target user?)
   - 2-7 external sources (official API docs, competitor analysis, academic papers, Stack Overflow deep dives)
   - **Assumption Table entries** for this domain (any assumption below 70% that hasn't been spiked)
3. **Run the debate** — Two-host adversarial format:
   - "Argue FOR and AGAINST this architecture decision"
   - "What are we missing? What will break?"
   - "Where will this fail at scale?"
   - "What's the security exploit path?"
   - **"How does [Buyer Persona] EXPERIENCE this? Does it feel like [the promise] or like generic software?"**
4. **Audio IS the Crucible** — The two-host debate is required. Chat alone doesn't count. The audio format forces the AI to argue with itself, producing insights that direct prompting misses.
5. **Self-processing** — After audio, extract findings via 5 queries:
   - What were the top 3 concerns raised?
   - What was the strongest counterargument?
   - What was NOT discussed that should have been?
   - What would a skeptic say about this design?
   - Rate confidence 1-10 in this architecture surviving production.

### ⚠️ CRUCIBLE EXECUTION IS PROGRAMMATIC, NOT CLAIMED (March 2026 — Non-Negotiable)

**The Problem:** An AI agent can read the steps above and CLAIM it ran a Crucible without actually invoking NotebookLM. NotebookLM is an isolated Google workspace — it has no read access to your local machine, GitHub, or Claude Code's terminal. Files must be explicitly uploaded.

**The Rule:** The Crucible is NOT complete until NotebookLM has been programmatically invoked and a notebook ID is recorded. An AI agent saying "I ran the Crucible" without a notebook ID is lying.

**The Tool:** `teng-lin/notebooklm-py` — a Python API wrapper for NotebookLM. Installed globally. Auth via `~/.notebooklm/storage_state.json` (Playwright browser state).

**The Canonical Pattern (proven March 17, 2026):**

```python
import asyncio
from notebooklm import NotebookLMClient

async def run_crucible(domain_name, source_files, questions):
    async with await NotebookLMClient.from_storage() as client:
        # Step 1: Create notebook (one per domain group)
        notebook = await client.notebooks.create(f"Crucible: {domain_name}")
        notebook_id = notebook.id

        # Step 2: Upload sources (MUST be explicit — files don't auto-sync)
        for filepath, title in source_files:
            with open(filepath) as f:
                await client.sources.add_text(
                    notebook_id=notebook_id,
                    title=title,
                    content=f.read(),
                    wait=True
                )

        # Step 3: Ask adversarial questions
        for question in questions:
            result = await client.chat.ask(
                notebook_id=notebook_id,
                question=question
            )
            print(f"Q: {question[:80]}...")
            print(f"A: {result.answer}\n")

        # Step 4: Return notebook ID as VERIFICATION ARTIFACT
        return notebook_id

# Example: run and capture the notebook ID
notebook_id = asyncio.run(run_crucible(
    domain_name="Security & Auth",
    source_files=[
        ("docs/02-specs/FSD-247-concurrency.md", "FSD-247 Concurrency"),
        ("docs/04-technical/TECH-STACK.md", "Tech Stack"),
        ("docs/02-specs/ASSUMPTION-TABLE.md", "Assumption Table"),
    ],
    questions=[
        "Will the ghost_canvases table become a bottleneck at 50 concurrent agents?",
        "Does the queued_behind debounce solve the race condition or create a new deadlock?",
        "Where is data loss most likely between the Async Action Queue and Slack delivery?",
    ]
))
print(f"CRUCIBLE ARTIFACT: {notebook_id}")  # THIS is the proof
```

**The Verification Artifact:**
Every Crucible session MUST produce a notebook ID. This ID is:
- Appended to `progress.txt` as: `[CRUCIBLE] notebook_id={id} domain={name}`
- Posted as a GitHub issue comment on the parent issue
- Checked by the R4 gate (no notebook ID = gate FAILS)

**What Does NOT Count as a Crucible:**
- An AI agent reviewing specs in-context and calling it a "Crucible" — that's a red-team, not a Crucible
- Chat-only interaction with NotebookLM (Rule 3: Audio IS the Crucible for full debates)
- Claiming "I created a notebook" without the notebook ID artifact
- Any review that doesn't use NotebookLM as a SEPARATE system with uploaded sources
- **CONCATENATING ALL SOURCES INTO ONE FILE** — see rule below

### ⛔ THE CONCATENATION BAN (March 2026 — Incident-Driven)

**Incident:** Two separate CC sessions (IT Concierge, LifeModo) concatenated all source files into a single `CRUCIBLE_SOURCES_COMBINED.md` and uploaded it as one source to NotebookLM. This completely destroys the Crucible.

**Why concatenation kills the Crucible:** NotebookLM's entire architecture relies on mapping relationships BETWEEN distinct source documents. When everything is in one file, there are no semantic boundaries. The debate becomes a biased echo chamber because there is no external "ground truth" to challenge internal assumptions. A single-source Crucible is like a prosecutor, defense attorney, and witness all being the same person.

**The Rule:** You are STRICTLY FORBIDDEN from:
1. Combining multiple files into one before upload
2. Creating a "combined" or "compiled" or "merged" source document
3. Using `cat file1.md file2.md > combined.md` or any equivalent
4. Passing concatenated content as a single `add_text()` call

**Each source file = one `add_text()` call.** The loop in the canonical pattern exists for this reason:
```python
# CORRECT: Each file is a separate source
for filepath, title in source_files:
    await client.sources.add_text(notebook_id=notebook_id, title=title, content=f.read())

# WRONG: Concatenating everything into one source
combined = "\n".join(open(f).read() for f, _ in source_files)
await client.sources.add_text(notebook_id=notebook_id, title="All Sources", content=combined)  # ⛔ BANNED
```

### 🌍 EXTERNAL GROUND TRUTH REQUIREMENT (March 2026 — Non-Negotiable)

**The Problem:** A Crucible that only debates YOUR specs against YOUR specs is an echo chamber. Your FSD says "we use RLS for security." Your data model implements RLS. NotebookLM cross-references them and says "looks consistent." But neither document asked whether your RLS IMPLEMENTATION actually follows Supabase best practices. The specs agree with each other — that doesn't mean they're correct.

**The Rule:** Every domain group MUST include at least ONE external ground truth source — official documentation for the technology being debated. This source acts as an unbiased referee.

| Domain | External Ground Truth (examples) |
|--------|----------------------------------|
| Database/RLS/Security | Official Supabase RLS docs, OWASP guidelines |
| Offline/Sync | Official PowerSync conflict resolution docs |
| State machines | Academic state machine completeness theory, framework docs |
| Auth/JWT | Official auth provider docs (Supabase Auth, Auth0, etc.) |
| Storage | Official Supabase Storage policy docs |
| API design | REST/GraphQL best practices, framework docs |
| Concurrency | Postgres isolation level docs, OCC pattern references |

**How to fetch external docs programmatically:**
```python
# Use WebFetch or curl to get official docs, then upload as a source
import subprocess
result = subprocess.run(
    ["curl", "-s", "https://supabase.com/docs/guides/auth/row-level-security"],
    capture_output=True, text=True
)
await client.sources.add_text(
    notebook_id=notebook_id,
    title="EXTERNAL: Supabase RLS Official Docs",
    content=result.stdout,
    wait=True
)
```

**Minimum source composition per domain notebook:**
- 1-2 internal specs (FSD, data model, ADR)
- 1 external ground truth (official docs for the technology)
- 1 buyer persona document (how does this feel to the user?)
- Optional: competitor analysis, academic papers, Stack Overflow deep dives
- **Minimum 3 sources, maximum 8, ALL SEPARATE**

#### Step 3: Synthesis Crucible

After all domain groups are tested individually:

1. Create a **final synthesis notebook**
2. Load: All domain group findings + the full system architecture
3. Run an integration debate: "Now that we've tested each domain, what breaks when they interact?"
4. This catches cross-domain issues (e.g., the security model interacts with the offline sync in ways neither domain-specific Crucible predicted)

#### Step 4: Disposition Findings

Every Crucible finding gets dispositioned:

| Disposition | Meaning | Action |
|-------------|---------|--------|
| **Fix now** | Real issue, blocks coding | Create GitHub issue, fix in ASSAY docs |
| **Fix later** | Real issue, doesn't block | Create GitHub issue in Demo Readiness milestone |
| **Won't fix** | Acceptable risk | Document WHY in ADR Log |
| **False positive** | Not actually an issue | Note in Crucible findings for learning |

### Outputs
- Crucible findings per domain group (GitHub issues labeled `crucible`)
- Synthesis findings (cross-domain issues)
- Updated FSDs (incorporating Crucible fixes)
- Updated ADR Log (new decisions from Crucible debates)
- Confidence score per domain

#### Step 5: Persona Validation (Consumer/Experience Products)

**Optional but recommended** for products where "how it feels" is the product (LifeModo, consumer apps). Skip for infrastructure, internal tools, APIs.

After Crucible debates are complete and findings dispositioned:

1. **Mock the key user touchpoints** — not code, not UI. Print the formats:
   - The Morning Brief as it would appear in Slack
   - The dashboard view with sample data
   - The notification that arrives at 8am
   - The onboarding message on Day 0
2. **Show to 1-3 people who match the Buyer Persona** — not developers, not friends. People who ARE the target user.
3. **Ask one question:** "Would you pay [price] for this arriving every [cadence]?"
4. **Record reactions** — what surprises them, what confuses them, what they wish it did instead.
5. **Feed reactions back into FSDs** — update before PLAN.

**Why here, not in ASSAY?** Because the Crucible has already stress-tested the architecture. You know the spec is CORRECT. Now you're testing whether the spec is DESIRABLE. These are different questions with different judges — architects judge correctness, users judge desirability.

**Why before PLAN?** Because if the user says "I wouldn't pay for this," you need to redesign before creating 50 GitHub issues against the wrong spec.

---

### The 5 Crucible Rules (from IT Concierge)

1. **Minimum 3 sources per notebook** — Architecture anchor + subject doc + external sources
2. **One notebook per topic** — Never batch topics into one notebook
3. **Audio IS the Crucible** — Two-host debate required; chat alone doesn't count
4. **Cross-reference specs against specs** — The best findings come from comparing FSD vs ADR vs data model, not from single-document review
5. **Zero false positives is achievable** — IT Concierge's Crucible had 0% false positive rate across 16 findings

---

## ⚖️ R4: Adversarial Gate

See [ratify.md](ratify.md#r4-adversarial-gate-after-crucible)

**Key question:** "Did the stress-test find what matters?"

**Must pass:**
- [ ] Every domain group tested independently
- [ ] **NotebookLM notebook ID recorded for EACH domain group** (no ID = no Crucible)
- [ ] **NO concatenated sources** — each file uploaded as a SEPARATE source (verify source count ≥ 3 per notebook)
- [ ] **External ground truth loaded** — at least 1 official external doc per domain (not just your own specs debating themselves)
- [ ] **Buyer Persona loaded as mandatory source** in every domain group notebook
- [ ] Synthesis Crucible run (cross-domain integration)
- [ ] All findings dispositioned (fix now / fix later / won't fix)
- [ ] "Fix now" items resolved in ASSAY docs
- [ ] Updated FSDs reflect Crucible learnings
- [ ] Fresh eyes CTO review on Crucible output
- [ ] Confidence ≥ 8/10
- [ ] All notebook IDs posted as GitHub issue comments (audit trail)
