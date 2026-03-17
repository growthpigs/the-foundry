# Spec-First Development — Industry Landscape (March 2026)

**Compiled:** 2026-03-17
**Purpose:** Map the spec-first / SDD / VSDD ecosystem as it stands today. Identify what The Foundry does that nobody else does.

---

## What's Proven

Tools and approaches with production evidence or significant adoption:

- **GitHub spec-kit** (77.6k stars, 110 releases) — Constitution + Specify + Plan + Tasks + Implement pipeline. Supports 20+ AI agents. Industry-standard starter kit for SDD. Experimental but widely adopted.
- **Kiro (AWS)** — Full IDE (VS Code fork) with built-in SDD. 250k+ users in first 3 months. Powered by Claude Sonnet. Ships Requirements → Design → Tasks as three markdown docs. Still in preview.
- **StrongDM Software Factory** — Production security software (Rust, Go) built and shipped by a 3-person team where no human writes or reviews code. Level 5 "Dark Factory" validated. DTU (Digital Twin Universe) enables thousands of test scenarios/hour. Real product, real customers.
- **MetaGPT** (65.3k stars) — Multi-agent framework simulating a full software company (PM, architect, project manager, engineer). SOP-driven. AFlow paper accepted for ICLR 2025 oral (top 1.8%). MGX product hit #1 on ProductHunt (March 2025). Research-grade, moving toward production.
- **METR study** — Randomized controlled trial (16 experienced OSS devs, 246 real issues) found AI tools made developers 19% SLOWER. Developers believed they were 24% faster. Perception-reality gap is the most important finding in AI-assisted development to date. Follow-up in Feb 2026 confirmed: -18% for original cohort, -4% for new recruits.

## What's Emerging

New tools and approaches gaining traction but not yet production-proven at scale:

- **Tessl** ($750M valuation, $125M raised, founded by Snyk's Guy Podjarny) — Pursuing "spec-as-source" where code is generated from specs and marked `DO NOT EDIT`. Currently in beta. Maps one spec to one code file. Hosting AI Native DevCon 2026.
- **BMAD-METHOD** (Breakthrough Method for Agile AI-Driven Development) — 21 specialized AI agents (PM, Architect, Developer, Scrum Master, UX Designer, etc.) as "Agent-as-Code" markdown files. Free, open-source. Growing community but still early.
- **claude-wizard** — 8-phase development skill for Claude Code with TDD and adversarial self-review. Battle-tested on a fintech platform (wealthbot.io) through hundreds of PRs. Small but opinionated.
- **Ralph pattern** — Autonomous bash-based loop that runs Claude Code or Amp repeatedly until all PRD items pass. Fresh context per iteration, memory via git + progress.txt + prd.json. Simple, elegant, proven for small-medium scope.
- **OpenSpec** — Brownfield-first SDD framework with delta markers (ADDED/MODIFIED/REMOVED). Lighter specs (~250 lines vs spec-kit's ~800). Addresses the real-world problem: most codebases aren't greenfield.
- **GSD (Get-Shit-Done)** — Meta-prompting + context engineering + spec-driven system for Claude Code by TACHES. Three pillars: meta-prompting (prompts that write prompts), context engineering, and .spec files. Ported to OpenCode, Codex, Gemini CLI.
- **Martin Fowler / Birgitta Bockeler analysis** — The most rigorous critique of SDD tooling to date. Identified three SDD levels (spec-first → spec-anchored → spec-as-source). Found agents ignore instructions despite specs, generate unrequested features, and shift review burden from code to "verbose and tedious" markdown. Drew parallel to Model-Driven Development (MDD), which failed for similar reasons.

## What's Unique to The Foundry

Things our approach does that nobody else does:

1. **Dual-phase adversarial review** — CRUCIBLE (pre-code, predictive) + Compliance Check in TEMPER (post-code, retrospective). Every other system has at most one adversarial step, and it's always post-code.

2. **Multi-document NotebookLM debates** — Minimum 3 sources, audio-based, per domain group. No other system uses audio-based AI debate as a spec validation mechanism.

3. **7 phase-specific Ratify gates** — Not one generic review step. Seven gates, each with phase-specific prompts, checks, and cognitive modes. R1 (Scope, soft, >= 6/10) through R7 (Ship, hard, >= 9/10 + evidence). spec-kit has no gates. claude-wizard has one adversarial step. BMAD has none.

4. **Independent Observer Score** — Quantified spec quality gate (>= 8/10). "Could someone with no context read this spec and build the right thing?" No other framework measures this.

5. **Issues-as-Thinking with label phases** — `idea → research → architecture → crucible → ready-to-code`. Issues are deliberation records, not code tickets. The journey IS the documentation.

6. **Progressive knowledge graduation** — conversation → progress.txt → error-patterns.md (at 3+ recurrences) → system insights. Ralph has flat progress.txt. Jones has flat Open Brain. The Foundry has a promotion hierarchy.

7. **Failure definitions in user stories** — Not just "what to build" but "what must NOT happen" — silent failures, edge cases, anti-patterns. These feed directly into Crucible negative test cases. No other framework mandates this.

8. **The "Drop the Hammer" decision** — An explicit, named, irreversible commitment point between PLAN and HAMMER. Before it, everything is reversible. After it, you're building. No other system names this moment.

9. **37-article Constitution** — Battle-tested across 3+ projects. spec-kit's constitution is a lightweight template. The Foundry's is a living legal document with ratification dates and incident-driven amendments.

10. **The 10-day proof** — LifeModo spent 10 days in ASSAY+CRUCIBLE before writing a line of code. Found its raison d'etre on day 9. The thinking IS the product. No other system has this kind of proof that extended spec thrashing pays off.

---

## Source Map

### GitHub spec-kit

**What it is:** Open-source CLI toolkit from GitHub that scaffolds SDD workflows into any AI coding assistant. Creates a `.specify/` folder with constitution, specs, plans, and tasks. Interact via slash commands (`/speckit.constitution`, `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`).

**Status (Mar 2026):** 77.6k stars, v0.1.4, 110 releases. Supports 20+ AI agents (Claude Code, Copilot, Cursor, Windsurf, Gemini, etc.). GitHub stresses this is experimental — "not a production scenario."

**Key innovation:** The "Constitution" concept — project-level governing principles that constrain all subsequent AI-generated work. Inspired the same concept in The Foundry (Article 13 acknowledges this).

**Comparison to The Foundry:** spec-kit is a starter kit; The Foundry is a full methodology. spec-kit creates branches per spec (suggesting spec-first, not spec-anchored). No adversarial review. No gates. No knowledge graduation. No failure definitions. The Foundry's Constitution has 35 battle-tested articles vs. spec-kit's lightweight template. spec-kit is where you start; The Foundry is where you arrive.

**URL:** https://github.com/github/spec-kit

---

### Kiro (AWS)

**What it is:** A VS Code fork IDE from Amazon with built-in spec-driven development. Powered by Claude Sonnet (Anthropic). Generates three markdown docs: Requirements (user stories + acceptance criteria), Design (technical design document), and Tasks (implementation checklist). Includes a "steering" memory bank (product.md, tech.md, structure.md). Native MCP integration.

**Status (Mar 2026):** Preview/early access. 250,000+ users in first 3 months (since July 2025 launch at AWS Summit). Featured heavily at re:Invent 2025. AWS case study shows a drug discovery agent built in 3 weeks with 3 developers using Kiro + Bedrock AgentCore.

**Key innovation:** SDD baked into the IDE itself, not bolted on. The lightweight Requirements → Design → Tasks flow is simple enough that developers actually use it. 94% satisfaction score reported.

**Comparison to The Foundry:** Kiro is spec-first only — no spec-anchored or spec-as-source capability. No adversarial review. No Crucible equivalent. Specs and code can fall out of sync (acknowledged limitation). The Foundry's 7-phase pipeline with Ratify gates is far more rigorous. Kiro is good for "Level 3-4" (junior dev to developer); The Foundry targets "Level 4-5" (developer to dark factory).

**URL:** https://kiro.dev/

---

### Tessl

**What it is:** An AI-native software development platform founded by Guy Podjarny (founder of Snyk, scaled to $8B). Positions itself at the "spec-as-source" level — code is generated from specs and marked `DO NOT EDIT`. The human only ever edits the spec. Currently maps one spec to one code file.

**Status (Mar 2026):** Beta. $750M valuation. $125M raised ($25M seed from GV, $100M Series A led by Index Ventures). Expected to support Java, JavaScript, and Python. Hosting AI Native DevCon Spring 2026.

**Key innovation:** The most ambitious spec-as-source vision in the industry. If it works, code becomes a build artifact — like compiled binaries. You version and review specs, not code.

**Comparison to The Foundry:** Tessl is trying to make code disappear entirely. The Foundry still treats code as a deliverable (in HAMMER phase) but with spec-first rigor. Tessl has no adversarial review, no Crucible, no progressive knowledge system. The Foundry could adopt Tessl's code generation approach in HAMMER while keeping its own pre-code pipeline. They're complementary, not competing.

**URL:** https://tessl.io/

---

### claude-wizard (vlad-ko)

**What it is:** An 8-phase Claude Code skill that enforces senior engineering habits. Built and refined through hundreds of production PRs on wealthbot.io (fintech).

**The 8 Phases:**
1. **Read CLAUDE.md** — Understand project rules before touching code
2. **Find/create GitHub issue** — Define acceptance criteria and "done"
3. **Explore codebase** — Grep, search, verify; never assume APIs exist
4. **Write failing tests** — TDD with mutation-resistant assertions (no `assertTrue(worked)`)
5. **Implement minimum** — Make tests pass; follow existing patterns
6. **Run test suite** — Fix regressions before proceeding
7. **Adversarial self-review** — Attack own code for race conditions, null edges, security holes
8. **Open PR & Bug Bot cycle** — Monitor automated review bot, fix findings, repeat until clean

**Status (Mar 2026):** Active development. Small community. Production-proven on fintech platform.

**Key innovation:** Phase 7 (adversarial self-review) — making Claude attack its own code before submission. Phase 8 (Bug Bot cycle) — treating automated code review as a quality gate loop, not a one-shot check.

**Comparison to The Foundry:** claude-wizard operates entirely within the coding phase — it has no research, no spec thrashing, no Crucible. It's essentially what happens inside HAMMER + TEMPER. The Foundry has 7 adversarial modes (one per Ratify gate); claude-wizard has 1. claude-wizard's TDD enforcement is stronger than The Foundry's current HAMMER phase. Good inspiration for tightening Article 8.

**URL:** https://github.com/vlad-ko/claude-wizard

---

### StrongDM Software Factory

**What it is:** A production "Dark Factory" where a 3-person AI team ships security software (Rust, Go) with two rules: no human writes code, no human reviews code. Built by Dan Shapiro's team at StrongDM.

**Key concepts:**
- **Five Levels of AI Coding** (Shapiro's taxonomy, Jan 2026): Level 0 = Spicy Autocomplete. Level 1 = Coding Intern. Level 2 = Junior Developer. Level 3 = Developer. Level 4 = Engineering Team. Level 5 = Dark Factory (lights out, robots only).
- **Digital Twin Universe (DTU):** Behavioral clones of Okta, Jira, Slack, Google Docs, Drive, Sheets. Enables thousands of test scenarios/hour without hitting real APIs, rate limits, or incurring costs.
- **Probabilistic Satisfaction:** Not boolean pass/fail — "of all observed trajectories through all scenarios, what fraction likely satisfy the user?" A fundamentally different quality metric.
- **Evaluation Independence:** Test scenarios are stored OUTSIDE the codebase. AI never sees them during development. Same principle as holdout sets in ML — prevents teaching-to-the-test.
- **Economic benchmark:** "If you haven't spent at least $1,000 on tokens today per human engineer, your software factory has room for improvement."

**Status (Mar 2026):** Production. Shipping real security software. factory.strongdm.ai is live. Stanford Law School wrote about it ("Built by Agents, Tested by Agents, Trusted by Whom?"). Garnered attention from Wharton's Generative AI Lab director and Y Combinator's CEO.

**Comparison to The Foundry:** StrongDM proves Level 5 is real. But StrongDM assumes specs are correct — there's no Crucible, no adversarial spec review, no Independent Observer Score. The Foundry stress-tests specs BEFORE they enter the factory. StrongDM also operates on established codebases with known patterns; The Foundry handles greenfield where the spec IS the discovery process. The DTU concept and probabilistic satisfaction are ideas The Foundry should adopt.

**URL:** https://www.strongdm.com/blog/the-strongdm-software-factory-building-software-with-ai / https://factory.strongdm.ai/

---

### Ralph Pattern (snarktank)

**What it is:** A bash-based autonomous AI development loop by Ryan Carson (Geoffrey Huntley's pattern). Runs Claude Code or Amp repeatedly until all PRD items are complete.

**The loop:**
1. Identify highest-priority incomplete story from prd.json
2. Spawn fresh AI instance (clean context)
3. Implement the single story
4. Run quality checks (typecheck, tests)
5. Commit if checks pass, update prd.json to `passes: true`
6. Append learnings to progress.txt
7. Repeat until all stories pass or max iterations reached (default: 10)

**Memory architecture:** Git history (previous commits) + progress.txt (append-only learnings) + prd.json (completion status). Each iteration is independent — sidesteps context window limits.

**Status (Mar 2026):** Active. Simple, effective for small-medium scope. Supports Amp (default) and Claude Code.

**Key innovation:** Fresh context per iteration. Memory through artifacts, not conversation. The prd.json as executable requirements (each story has a `passes` boolean).

**Comparison to The Foundry:** Ralph is the HAMMER phase execution engine. The Foundry adopted Ralph's fresh-context-per-stage principle (Article 5) and memory-via-artifacts approach. Ralph assumes the PRD is done and correct. The Foundry produces and validates the PRD through 4 phases before Ralph runs. Ralph's progress.txt is flat; The Foundry has graduated knowledge (progress.txt → error-patterns.md → system insights).

**URL:** https://github.com/snarktank/ralph

---

### MetaGPT

**What it is:** Multi-agent framework that simulates a full software company. Agents play roles (Product Manager, Architect, Project Manager, Engineer) following Standardized Operating Procedures (SOPs). Takes a one-line requirement and outputs user stories, competitive analysis, requirements, data structures, APIs, and documentation.

**Status (Mar 2026):** 65.3k stars, 8.2k forks, v0.8.1. AFlow paper at ICLR 2025 (oral, top 1.8%). MGX product launched Feb 2025, hit #1 ProductHunt. Active development with 6,367 commits. Research-grade, moving toward production use.

**Key innovation:** "Code = SOP(Team)" — the insight that multi-agent systems need organizational structure (SOPs), not just individual agent capabilities. Agents verify each other's intermediate results.

**Comparison to The Foundry:** MetaGPT is role-based (PM, architect, etc.); The Foundry is phase-based (MINE, SCOUT, ASSAY, etc.). MetaGPT automates the entire team; The Foundry keeps the human as strategic decision-maker with AI as executor. MetaGPT has no adversarial review, no Crucible, no Ratify gates. The Foundry is more conservative — it trusts AI for execution but not for judgment on spec quality.

**URL:** https://github.com/FoundationAgents/MetaGPT

---

### METR Study

**What it is:** A randomized controlled trial measuring AI tool impact on experienced open-source developer productivity. The most rigorous study of its kind.

**Methodology:** 16 experienced developers from large OSS repos (avg 22k+ stars, 1M+ LOC). 246 real issues randomly assigned to AI-allowed or AI-forbidden conditions. Developers used Cursor Pro with Claude 3.5/3.7 Sonnet. $150/hour compensation. Screen recordings captured.

**Key finding:** AI tools made experienced developers 19% SLOWER. Developers predicted 24% speedup. Even after experiencing the slowdown, they still believed AI had helped (perceived 20% speedup).

**Why developers were slower:** Context switching to AI tools. Time spent reviewing/correcting AI output. AI-generated code requiring rework. Experienced developers' existing mental models are faster than formulating prompts.

**2026 follow-up (Feb 2026):** Original cohort: -18% (CI: -38% to +9%). New recruits: -4% (CI: -15% to +9%). Recruitment harder — developers who benefit most from AI refused to do 50% of work without it, creating selection bias.

**Comparison to The Foundry:** The METR study validates The Foundry's core thesis: AI without structured process makes things WORSE for experienced developers. The Foundry's answer is to give AI a rigorous pipeline (spec → crucible → plan → build → temper) rather than letting developers ad-hoc prompt during coding. The METR study measures "AI during coding." The Foundry uses AI for "everything before coding" — where the thinking leverage is highest.

**URL:** https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/

---

### Martin Fowler / Birgitta Bockeler on SDD

**What it is:** The most thorough critical analysis of SDD tooling, published on martinfowler.com. Examines Kiro, spec-kit, and Tessl. Defines three levels of SDD maturity.

**Three SDD levels:**
1. **Spec-first** — Write spec before coding, then discard it
2. **Spec-anchored** — Retain and evolve specs alongside code during maintenance
3. **Spec-as-source** — Humans edit only specs; code is generated (Tessl's vision)

**Critical findings:**
- "One workflow to fit all sizes?" — Small bug fixes trigger unnecessarily elaborate spec workflows
- Non-determinism persists despite detailed specs — agents ignore instructions, generate unrequested features, claim success when builds fail
- Review burden shifts from code to "lots of markdown files" that are "verbose and tedious"
- Historical parallel to Model-Driven Development (MDD), which failed for similar reasons (inflexibility + overhead)
- Term "SDD" remains "poorly defined and semantically diffused"

**Comparison to The Foundry:** Fowler's critique validates The Foundry's MODE system — not every issue needs the full 7-phase pipeline. HOTFIX mode skips to HAMMER. BUGFIX mode abbreviates ASSAY. The Foundry addresses the "one workflow for all sizes" problem explicitly. Fowler's concern about review burden is real — The Foundry's Ratify gates add structure but also add review overhead. The Foundry should track whether Ratify gates create net value or net drag per issue size.

**URL:** https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html

---

### BMAD-METHOD

**What it is:** "Breakthrough Method for Agile AI-Driven Development." Open-source framework with 21 specialized AI agents as "Agent-as-Code" markdown files (PM, Architect, Developer, Scrum Master, UX Designer, etc.). Over 50 guided workflows. Free and open-source.

**Status (Mar 2026):** Active development. Growing community. Install via `npx bmad-method install`. Optional Claude Code skills package.

**Key innovation:** Agent-as-Code pattern — each AI persona is a markdown file describing expertise, responsibilities, constraints, and expected outputs. Documentation (PRDs, architecture, user stories) is the source of truth; code is a downstream derivative.

**Comparison to The Foundry:** BMAD is role-based (like MetaGPT); The Foundry is phase-based. BMAD has no adversarial review, no Crucible, no Ratify gates. BMAD's 21 agents add complexity; The Foundry uses one AI (Claude) in different cognitive modes per phase. BMAD and The Foundry share the same philosophy (spec is truth, code is derivative) but diverge on execution model.

**URL:** https://github.com/bmad-code-org/BMAD-METHOD

---

### OpenSpec

**What it is:** A lightweight, brownfield-first SDD framework. Uses a three-phase state machine (proposal → apply → archive) and delta markers (ADDED/MODIFIED/REMOVED) to track changes relative to existing functionality. Markdown-based, lives alongside code in git.

**Status (Mar 2026):** OpenSpec 1.0 released Jan 2026. Active development. Niche but growing adoption for teams working on existing codebases.

**Key innovation:** Brownfield-first design. Most SDD tools assume greenfield (0→1). OpenSpec handles 1→n. Lighter specs (~250 lines vs spec-kit's ~800 lines), reducing review overhead.

**Comparison to The Foundry:** OpenSpec solves a problem The Foundry currently doesn't emphasize — evolving existing codebases incrementally. The Foundry's ASSAY phase could adopt OpenSpec's delta markers for brownfield features. OpenSpec has no adversarial review, no knowledge graduation, no Crucible.

**URL:** https://github.com/Fission-AI/OpenSpec / https://openspec.dev/

---

### GSD (Get-Shit-Done)

**What it is:** A meta-prompting, context engineering, and spec-driven development system for Claude Code by TACHES. Three core pillars: meta-prompting (prompts that write prompts), context engineering (gathering only relevant codebase context), and spec-driven development (.spec files).

**Status (Mar 2026):** Active. Ported to OpenCode, Codex, Gemini CLI.

**Key innovation:** The meta-prompting layer — using AI to generate the prompts that drive AI development. Prevents "context rot" by assigning individual tasks to subagents with scoped context.

**Comparison to The Foundry:** GSD focuses on the execution layer (context engineering during coding). The Foundry focuses on the thinking layer (spec quality before coding). Complementary approaches. GSD's subagent orchestration with scoped context could improve The Foundry's HAMMER phase.

**URL:** https://github.com/gsd-build/get-shit-done

---

## Key Takeaways

1. **SDD is the new default, but nobody agrees what it means.** Fowler's analysis is right — the term is "semantically diffused." spec-kit, Kiro, Tessl, BMAD, and The Foundry all claim SDD but mean very different things. The industry needs a taxonomy (Fowler's spec-first / spec-anchored / spec-as-source is the best candidate).

2. **The METR study is the elephant in the room.** AI makes experienced developers 19% slower when used ad-hoc during coding. This validates every spec-first methodology's core claim: the value of AI is in structured thinking, not faster typing. The Foundry should cite METR prominently.

3. **The Crucible is The Foundry's moat.** No other system adversarially stress-tests specs before coding. StrongDM assumes specs are correct. spec-kit generates specs but doesn't challenge them. Kiro creates requirements but doesn't debate them. The Crucible is where The Foundry's value concentrates.

4. **StrongDM proved Level 5 is real, but it requires two things nobody else has:** (a) complete spec quality, and (b) evaluation independence (test scenarios stored outside the codebase, invisible to agents). The Foundry's Crucible addresses (a). The Foundry should adopt StrongDM's evaluation independence principle for (b).

5. **The market is bifurcating: starter kits vs. full methodologies.** spec-kit, OpenSpec, and GSD are starter kits — lightweight, easy to adopt, limited depth. The Foundry, StrongDM, and BMAD are full methodologies — heavy, opinionated, deep. The winners will be methodologies that can flex between light (HOTFIX mode) and heavy (GREENFIELD mode) based on issue complexity. The Foundry's MODE system already does this.

---

## Sources

- [GitHub spec-kit](https://github.com/github/spec-kit)
- [Microsoft Developer Blog — Diving Into Spec-Driven Development](https://developer.microsoft.com/blog/spec-driven-development-spec-kit)
- [Visual Studio Magazine — GitHub Open Sources Kit for Spec-Driven AI Development](https://visualstudiomagazine.com/articles/2025/09/03/github-open-sources-kit-for-spec-driven-ai-development.aspx)
- [Kiro — Agentic AI Development](https://kiro.dev/)
- [InfoQ — Beyond Vibe Coding: Amazon Introduces Kiro](https://www.infoq.com/news/2025/08/aws-kiro-spec-driven-agent/)
- [AWS Blog — From Spec to Production with Kiro](https://aws.amazon.com/blogs/industries/from-spec-to-production-a-three-week-drug-discovery-agent-using-kiro/)
- [Tessl — Agent Enablement Platform](https://tessl.io/)
- [Fortune — Tessl $750M Valuation](https://fortune.com/2024/11/14/tessl-funding-ai-software-development-platform/)
- [vlad-ko/claude-wizard](https://github.com/vlad-ko/claude-wizard)
- [DEV Community — I Made Claude Code Think Before It Codes](https://dev.to/_vjk/i-made-claude-code-think-before-it-codes-heres-the-prompt-bf)
- [StrongDM Software Factory](https://www.strongdm.com/blog/the-strongdm-software-factory-building-software-with-ai)
- [factory.strongdm.ai](https://factory.strongdm.ai/)
- [factory.strongdm.ai — Digital Twin Users](https://factory.strongdm.ai/techniques/dtu)
- [Dan Shapiro — Five Levels from Spicy Autocomplete to the Dark Factory](https://www.danshapiro.com/blog/2026/01/the-five-levels-from-spicy-autocomplete-to-the-software-factory/)
- [Simon Willison — StrongDM Software Factory](https://simonwillison.net/2026/Feb/7/software-factory/)
- [Stanford Law — Built by Agents, Tested by Agents, Trusted by Whom?](https://law.stanford.edu/2026/02/08/built-by-agents-tested-by-agents-trusted-by-whom/)
- [snarktank/ralph](https://github.com/snarktank/ralph)
- [MetaGPT](https://github.com/FoundationAgents/MetaGPT)
- [METR — Measuring Impact of Early-2025 AI on Developer Productivity](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)
- [METR — 2026 Follow-up](https://metr.org/blog/2026-02-24-uplift-update/)
- [Martin Fowler — Understanding SDD: Kiro, spec-kit, and Tessl](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)
- [OpenSpec](https://github.com/Fission-AI/OpenSpec)
- [GSD — Get-Shit-Done](https://github.com/gsd-build/get-shit-done)
- [Augment Code — 6 Best SDD Tools for AI Coding in 2026](https://www.augmentcode.com/tools/best-spec-driven-development-tools)
- [Medium — SDD Is Eating Software Engineering: 30+ Frameworks](https://medium.com/@visrow/spec-driven-development-is-eating-software-engineering-a-map-of-30-agentic-coding-frameworks-6ac0b5e2b484)
- [Red Hat — How SDD Improves AI Coding Quality](https://developers.redhat.com/articles/2025/10/22/how-spec-driven-development-improves-ai-coding-quality)
- [arXiv — Spec-Driven Development: From Code to Contract](https://arxiv.org/abs/2602.00180)
