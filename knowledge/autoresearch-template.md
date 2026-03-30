# AutoResearch — program.md Template

**Use this template to create `.foundry/autoresearch/program.md` for any project.**

Both the Software Foundry and the Thinking Foundry use the same program.md structure. The difference is in the experiment types.

---

## Template

```markdown
# AutoResearch Protocol — [Epic/Decision Name]

## Context
- Epic/Decision: [what was built or decided]
- Phase completed: [TEMPER for software / VERIFY for thinking]
- Confidence at phase exit: [score from R7 or VERIFY gate]
- Key assumptions to validate: [list from Assumption Table]

## Questions to Answer
<!--
  Rules:
  - Specific and measurable (not "does it work well?")
  - Derived from: Red-Team findings, gap reports, assumption table
  - Include at least one performance question and one failure-mode question
  - Maximum 7 questions (focus beats breadth)
-->
1. [Question 1 — with measurable threshold]
2. [Question 2 — with measurable threshold]
3. [Question 3 — with measurable threshold]

## Experiment Types

### Software Foundry Experiments
<!-- Pick from this menu for code validation -->
- [ ] **Load test:** [endpoint/feature] with [N] concurrent users, target P95 < [X]ms
- [ ] **Chaos test:** [what to break] — verify [expected recovery behavior]
- [ ] **Data experiment:** Run [migration/query] against [production-clone/staging data]
- [ ] **A/B comparison:** [metric] before vs after, target [X]% improvement
- [ ] **Edge case discovery:** Fuzz [inputs], boundary [values], race [conditions]
- [ ] **Regression hunt:** Automated exploration of [unchanged features] after [refactor]

### Thinking Foundry Experiments
<!-- Pick from this menu for reasoning validation -->
- [ ] **Market research:** [competitor/pricing/TAM data] to validate [assumption]
- [ ] **Expert precedent:** Query [framework: YC/Hormozi/McKinsey/IDEO] for [similar decisions]
- [ ] **Knowledge base:** Supabase semantic search for [constraint-matched research]
- [ ] **Stakeholder validation:** [who to check with] about [assumption]
- [ ] **Counter-example search:** Find cases where [our conclusion] was wrong
- [ ] **Cost/timeline reality check:** [comparable projects/decisions] with actual outcomes

## Success Criteria
<!-- Each must be quantitative or binary — no "feels right" -->
- [ ] [Criterion 1: metric > threshold]
- [ ] [Criterion 2: zero occurrences of X]
- [ ] [Criterion 3: Y within Z% of target]

## Configuration
- **Max iterations:** [3-10, default 5]
- **Terminate if:** No new signal after [1-3, default 2] consecutive cycles
- **Time budget:** [hours] maximum
- **Escalation:** If confidence drops below [threshold, default 8] → route back to [HAMMER/ASSAY]
```

---

## Question Generation Heuristics

When writing questions, mine these sources:

| Source | Question Pattern |
|--------|-----------------|
| **Assumption Table** | "Is [assumption] still true at [scale/in production]?" |
| **Red-Team Report** | "Did the fix for [finding] actually prevent the failure mode?" |
| **FSD Gap Report** | "Can [persona] actually complete [action] end-to-end?" |
| **Error Patterns** | "Does [known pattern] still occur after this change?" |
| **Performance Requirements** | "Does [endpoint] meet [threshold] under [load]?" |
| **Migration files** | "Is the schema actually applied? Do existing rows handle [new constraint]?" |
| **Competitor Analysis** | "Does our approach outperform [competitor] on [metric]?" |
| **Framework Wisdom** | "What would [Hormozi/YC/McKinsey] say about [our conclusion]?" |

---

## Anti-Patterns (Do NOT Do These)

| Anti-Pattern | Why It's Bad | Instead |
|-------------|-------------|---------|
| "Does the feature work?" | Not measurable | "Does [endpoint] return 200 for [input] in < 200ms?" |
| Running 10+ experiments per cycle | Dilutes focus | 1 experiment per question per cycle |
| Fixing bugs during AutoResearch | Changes the codebase mid-experiment | Create issue, note in findings, fix in HAMMER |
| Skipping termination conditions | Creates infinite loops | Always set max iterations AND signal-based termination |
| Deleting findings from previous cycles | Breaks ratchet integrity | findings.md is append-only |
| Running AutoResearch on HOTFIX | Waste of time | HOTFIX skips AutoResearch by design |
