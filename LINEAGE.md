# The Foundry — Intellectual Lineage

**Every idea has ancestors.** The Foundry doesn't exist in a vacuum — it stands on 35 years of methodology from design thinking to autonomous software factories.

---

## The Through-Line

The industry has been converging on "think more, code less" for decades:

```
1991  IDEO: Empathize first
2001  Agile: Iterate but ship
2005  Double Diamond: Diverge before converging
2011  ADRs: Document decisions with WHY
2011  Lean Startup: Validate before scaling
2025  Jones: Safe agent operations
2026  StrongDM: Specs drive autonomous agents
2026  The Foundry: The spec IS the product
```

---

## Source Map

### IDEO Design Thinking (1991+)

**Contribution:** Empathize → Define → Ideate → Prototype → Test
**Where it lives in The Foundry:** SCOUT phase (Phase 2). The DesignSprint skill runs a full IDEO 5-stage synthesis with parallel research agents.
**What we took:** The radical idea that you should understand humans before building technology.
**What we added:** AI-accelerated parallel research. 3 agents in 20 minutes produce what a human design team does in 3 days.

### British Design Council — Double Diamond (2005)

**Contribution:** Discover → Define → Develop → Deliver. Diverge twice, converge twice.
**Where it lives in The Foundry:** The overall shape. MINE+SCOUT = first diamond (diverge on ideas, converge on vision). ASSAY+CRUCIBLE = second diamond (diverge on specs, converge on validated architecture).
**What we took:** The double diverge/converge pattern. You must explore broadly before narrowing.
**What we added:** A third diamond: HAMMER+TEMPER (diverge on implementation, converge on shipped product).

### Agile / Scrum (2001+)

**Contribution:** Iterative delivery, user stories, sprint cadence, definition of done.
**Where it lives in The Foundry:** PLAN phase (Phase 5). Sprint planning, story decomposition, ISC criteria.
**What we took:** Time-boxed delivery, user stories as the unit of work, sprint retrospectives.
**What we added:** The ASSAY phase before sprints. Agile says "start sprinting." The Foundry says "finish thinking, THEN sprint."

### Architecture Decision Records (2011+)

**Contribution:** Document every decision with context, options considered, and consequences.
**Where it lives in The Foundry:** Admin Document #7 (Architecture Decision Log). Every ADR has a WHY.
**What we took:** The discipline of recording decisions to prevent re-debating.
**What we added:** The ADR Log as a living GitHub Issue (Article 18), updated every session, cross-referenced with Crucible findings.

### Lean Startup (2011+)

**Contribution:** Build-Measure-Learn. MVP. Validated learning. Pivot or persevere.
**Where it lives in The Foundry:** CRUCIBLE phase (Phase 4). The spec is the hypothesis. The Crucible is the experiment. The findings are the measurement.
**What we took:** The idea that assumptions must be tested before scaling.
**What we added:** Testing assumptions BEFORE building (not after). Lean Startup builds an MVP to test. The Foundry tests the spec itself — cheaper, faster, and you don't ship broken code.

### Nate B. Jones — Five Primitives & Second Brain (2025+)

**Contribution:** Five levels of AI automation (from autocomplete to Dark Factory). Safe agent operations. Persistent knowledge as a "second brain."
**Where it lives in The Foundry:** The knowledge systems (progress.txt, error-patterns.md, Activity Log). The 5-level framework informs the MODE system — HOTFIX is Level 3, GREENFIELD is Level 4-5.
**What we took:** The taxonomy of automation levels. The idea that knowledge must persist across sessions.
**What we added:** Knowledge graduation (conversation → progress.txt → error-patterns.md at 3+ recurrences). Jones's Open Brain is a flat store. The Foundry has a promotion hierarchy.

### StrongDM — Software Factory (2026)

**Contribution:** "Code must not be written by humans. Code must not be reviewed by humans." Digital Twin Universe (DTU). Probabilistic satisfaction metrics.
**Where it lives in The Foundry:** HAMMER phase (Phase 6) in Dark Factory mode. The aspiration of fully autonomous coding.
**What we took:** The proof that spec-as-source works at production quality. The DTU concept — behavioral clones of every 3rd-party service running locally.
**What we added:** The Crucible pre-gate. StrongDM assumes specs are correct. The Foundry stress-tests specs before coding. Also: the Foundry handles greenfield projects, not just feature additions to established codebases.

### GitHub spec-kit (2026)

**Contribution:** Constitution → Specify → Plan → Tasks pipeline. 72.7k stars.
**Where it lives in The Foundry:** The Constitution concept. spec-kit calls their rules file a "Constitution" — same name, same idea.
**What we took:** Validation that the Constitution pattern is industry-standard.
**What we added:** 37 articles of hard-won rules vs. spec-kit's lightweight template. The Foundry Constitution is battle-tested across 3+ projects; spec-kit is a starter kit.

### The Ralph Pattern (2026)

**Contribution:** Autonomous AI development loop using `claude -p`. Fresh context per iteration. Memory via git history.
**Where it lives in The Foundry:** HAMMER phase (Phase 6). The Ralph Loop is the execution pattern for autonomous coding.
**What we took:** Fresh context per stage (Article 5). Memory via progress.txt and git history.
**What we added:** The entire pipeline BEFORE the Ralph Loop runs. Ralph assumes the spec is done. The Foundry produces the spec.

### claude-wizard (2026)

**Contribution:** 8-phase development skill with TDD and adversarial self-review. Refined through hundreds of PRs on a fintech platform.
**Where it lives in The Foundry:** Inspiration for the Ratify gate system. claude-wizard does adversarial self-review during coding. The Foundry formalizes this into 7 distinct gates.
**What we took:** The concept of adversarial self-review as a routine practice, not an exception.
**What we added:** Phase-specific Ratify protocols. claude-wizard has one adversarial mode. The Foundry has 7, each tuned to its phase.

---

## What's Unique to The Foundry

Things no other system does:

1. **Dual-phase adversarial review** — CRUCIBLE (pre-code) + Compliance Check in TEMPER (post-code)
2. **Multi-document NotebookLM debates** — Minimum 3 sources, audio-based, per domain group
3. **Issues-as-Thinking** — Label phases track deliberation: `idea → research → architecture → crucible → ready-to-code`
4. **Independent Observer Score** — Quantified spec quality gate (≥ 8/10)
5. **Progressive knowledge graduation** — conversation → progress.txt → error-patterns.md → system insights
6. **7 phase-specific Ratify gates** — Not one review step; seven, each tuned to its phase
7. **The 10-day proof** — LifeModo spent 10 days in ASSAY+CRUCIBLE. Found its raison d'etre on day 9. The thinking IS the product.

---

## Reading List

- [Martin Fowler on SDD Tools](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [StrongDM Software Factory](https://www.strongdm.com/blog/the-strongdm-software-factory-building-software-with-ai)
- [GitHub spec-kit](https://github.com/github/spec-kit)
- [Nate B. Jones — The Dark Factory Is Real](https://natesnewsletter.substack.com/p/the-5-level-framework-that-explains)
- [Ralph Pattern](https://github.com/snarktank/ralph)
- [claude-wizard](https://github.com/vlad-ko/claude-wizard)
- [Anthropic — Advanced Tool Use](https://www.anthropic.com/engineering/advanced-tool-use)
- [Stanford Law — Built by Agents, Trusted by Whom?](https://law.stanford.edu/2026/02/08/built-by-agents-tested-by-agents-trusted-by-whom/)
