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
- [ ] Synthesis Crucible run (cross-domain integration)
- [ ] All findings dispositioned (fix now / fix later / won't fix)
- [ ] "Fix now" items resolved in ASSAY docs
- [ ] Updated FSDs reflect Crucible learnings
- [ ] Fresh eyes CTO review on Crucible output
- [ ] Confidence ≥ 8/10
