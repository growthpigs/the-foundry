# Digital Twin Universe (DTU) — Research

**Date:** 2026-03-17
**Author:** Chi CTO
**Status:** Research Complete — Awaiting Decision

---

## What StrongDM Does

StrongDM's Software Factory uses a **Digital Twin Universe (DTU)** — behavioral clones of every third-party service their software depends on. The DTU is a core pillar of their autonomous coding pipeline (Attractor), enabling scenario-based validation without human code review.

### Services Cloned

| Service | Category |
|---------|----------|
| Okta | Identity / Auth |
| Jira | Issue Tracking |
| Slack | Messaging / Notifications |
| Google Docs | Document Collaboration |
| Google Drive | File Storage |
| Google Sheets | Spreadsheet / Data |

### How Twins Are Built

1. **API-contract-first:** The complete public API documentation of a target service is fed into their coding agent harness.
2. **Agent builds the twin:** The agent generates an imitation of that API as a **self-contained Go binary** with a simplified UI on top.
3. **SDK compatibility targeting:** They use popular reference SDK client libraries as compatibility targets, aiming for 100% SDK compatibility (not just API shape, but SDK-level behavioral compatibility).
4. **Iterative validation:** The twin is validated against the live dependency until behavioral differences stop being found. Key quote: *"We build test doubles from API contracts and observed edge cases, then validate them against the live dependency until we stop finding behavioral differences."*

### What a Twin Simulates

A Digital Twin is NOT a simple HTTP stub. It simulates behavior:
- **State management** — responds to sequences of operations the way the real service would
- **Error cases** — returns realistic error responses
- **Asynchronous callbacks** — handles webhooks and async patterns
- **Rate limiting** — simulates throttling behavior
- **Authentication flows** — handles auth handshakes

### Architectural Approach

- Each twin is a **standalone Go binary** (not a Docker image, though likely containerized for orchestration)
- Simplified UI layer on top for visual debugging/interaction
- Behavioral replication at the **boundary** (API surface), not internal reimplementation
- Runs locally alongside the coding agents during development

### Why It Works for StrongDM

- **Thousands of scenarios per hour** without rate limits, abuse detection, or API costs
- **Dangerous failure modes** testable safely (network partitions, auth revocations, etc.)
- **Deterministic** — replayable, controlled test conditions for every scenario
- **Holdout validation** — scenarios stored outside the codebase (like ML holdout sets) that agents execute against DTU

### What's NOT Disclosed

StrongDM's public documentation is deliberately light on implementation details:
- No container orchestration specifics (Docker Compose? K8s? Plain binaries?)
- No details on how twins are kept in sync as real services evolve their APIs
- No details on data persistence/state reset between test runs
- No metrics on twin fidelity or coverage percentages

---

## Feasibility Assessment

### LifeModo DTU

LifeModo's agent layer (Deputy, plugins, cron jobs) interacts with Slack, Google Calendar, and NFC events. A DTU would let us test the full agent pipeline without hitting real APIs.

| Service | Simulator | Fidelity | Effort | Priority |
|---------|-----------|----------|--------|----------|
| Slack API | **mad-fake-slack** — Node.js Slack emulator with WebSocket support, channels, users, message history. Full UI. OR **slack-server-mock** for headless HTTP+WS mock. | HIGH — covers Web API + Events API + WebSocket RTM | 2 DU setup, 1 DU per plugin integration | P1 — blocks all agent testing |
| Google Calendar API | **WireMock** with recorded Calendar API responses. CalDAV is well-documented, stubs are straightforward. | MEDIUM — CRUD operations easy, push notifications harder | 2 DU | P2 |
| NFC Event Source | **Custom event emitter** — NFC tags produce simple JSON payloads. Mock is trivial: a script that emits tag-scan events on a schedule. | HIGH — simple payload format | 0.5 DU | P3 |
| Mem0 API | **WireMock stub** — search/add endpoints with canned responses | HIGH — simple REST API | 0.5 DU | P3 |

**Total estimated effort:** 6 DU
**Value:** Test Deputy's full decision loop (receive event → reason → act → respond) without Slack workspace pollution or API rate limits.

### IT Concierge DTU

IT Concierge routes WhatsApp messages through Supabase (tickets, RLS) and integrates with Google Calendar for scheduling.

| Service | Simulator | Fidelity | Effort | Priority |
|---------|-----------|----------|--------|----------|
| Supabase (PostgreSQL + Auth + RLS) | **`supabase start`** — official Supabase CLI. Spins up full local stack: PostgreSQL, GoTrue auth, PostgREST, Realtime, Storage, Edge Functions. Already installed (`supabase v2.75.0`). Runs on Docker. | VERY HIGH — this IS the real Supabase, locally | 1 DU (already have CLI) | P0 — trivial win |
| WhatsApp Business API | **Twilio Sandbox** (shared number, 50 msg/day free) for real-ish testing. For DTU: **WireMock** recording real WhatsApp Cloud API responses, replaying locally. | MEDIUM — message send/receive easy, template approval flow harder | 2 DU | P1 |
| Google Calendar API | Same as LifeModo — WireMock stubs | MEDIUM | 1 DU (shared with LifeModo) | P2 |

**Total estimated effort:** 4 DU
**Value:** Full ticket lifecycle testing (WhatsApp intake → Supabase ticket → assignment → Calendar booking → resolution) without burning Twilio credits or polluting production DB.

### War Room DTU

War Room uses AI APIs (Perplexity, OpenAI) for research and content generation.

| Service | Simulator | Fidelity | Effort | Priority |
|---------|-----------|----------|--------|----------|
| OpenAI API | **llmock** (CopilotKit) — deterministic mock server, fixture-based, supports SSE streaming, tool calls, multi-turn. OpenAI + Anthropic + Gemini formats. Zero dependencies. | HIGH — authentic SSE streaming, tool call support | 1 DU | P1 |
| Perplexity API | **llmock** or **MockLLM** — Perplexity uses OpenAI-compatible format, so same mock works. Add fixtures for search-augmented responses. | MEDIUM — compatible format but citation metadata needs custom fixtures | 1 DU | P1 |
| Anthropic API | **llmock** — native Claude Messages API support with SSE | HIGH | 0.5 DU (shared setup) | P2 |

**Total estimated effort:** 2.5 DU
**Value:** Run AI feature tests without burning API credits ($15/M tokens for Opus). Deterministic responses make tests reproducible. Critical for CI/CD.

---

## Container Runtime

### Current State of This Machine

| Runtime | Installed | Version | Notes |
|---------|-----------|---------|-------|
| **OrbStack** | YES (`/Applications/OrbStack.app`) | — | Docker context set to `orbstack` |
| **Docker CLI** | YES (`/usr/local/bin/docker`) | 28.5.2 | Routed through OrbStack |
| **Docker Desktop** | NO | — | Not installed |
| **Podman** | NO | — | Not installed |
| **Colima** | NO | — | Not installed |
| **Supabase CLI** | YES (`/opt/homebrew/bin/supabase`) | 2.75.0 | Uses Docker via OrbStack |
| **macOS** | — | 26.2 (Tahoe) | Apple Silicon |

### OrbStack Assessment

**Pros:**
- 2-second startup (vs Docker Desktop's 30+ seconds)
- ~0.1% CPU when idle (vs Docker Desktop's persistent overhead)
- 180mW power draw vs Docker Desktop's 726mW — **4x more efficient**
- VirtioFS with optimizations — mounted volumes nearly as fast as native
- Drop-in Docker CLI replacement (already configured on this machine)
- Supports Linux VMs alongside containers (15 distros)
- Native Apple Silicon optimization

**Cons:**
- Commercial product (free for personal use, $8/month Pro for business, Enterprise custom)
- Less ecosystem support than Docker Desktop (extensions, Scout, etc.)
- Smaller community — fewer Stack Overflow answers when things go wrong

### Alternatives Comparison

| Runtime | Speed | Resources | Docker Compat | Cost | Status |
|---------|-------|-----------|---------------|------|--------|
| **OrbStack** | Fastest (2s) | Lowest (180mW) | Full drop-in | Free (personal) / $8/mo (Pro) | INSTALLED, ACTIVE |
| Docker Desktop | Slow (30s+) | Heavy (726mW) | Native | Free (personal) | Not installed |
| Colima | Medium | Low | Good | Free (OSS) | Not installed |
| Podman | Medium | Low | Partial (rootless) | Free (OSS) | Not installed |
| Apple Containers | Fast | Minimal | OCI only (no Compose) | Free (built-in) | Available on macOS 26, v0.1.0, very early |

### Recommendation

**Stay with OrbStack.** It is already installed, already the Docker context, and outperforms every alternative on macOS. The `supabase start` command already works through it. Apple Containers is interesting but too immature (v0.1.0, no volumes, no Compose, no multi-container orchestration). Revisit Apple Containers in 6 months.

---

## Available Simulators

### Slack API

| Tool | Type | Language | Features | Maintenance |
|------|------|----------|----------|-------------|
| [mad-fake-slack](https://github.com/maddevsio/mad-fake-slack) | Full simulator | Node.js | Web API + RTM WebSocket + UI + channels + users + message history. JSON file storage. | ⚠️ STALE (last commit 2019, RTM-only — Slack deprecated RTM in 2020, no Docker image published) |
| [slack-server-mock](https://github.com/ygalblum/slack-server-mock) | HTTP+WS mock | — | Mock HTTP and WebSocket server for subsystem testing | Community |
| [slack-mock](https://github.com/Skellington-Closet/slack-mock) | Test library | Node.js | API mocker for bot integration tests | Community |
| [slack-testing-library](https://github.com/chrishutchinson/slack-testing-library) | Test library | Node.js | Mock server for interactive Slack apps | Community |
| [Mockoon](https://mockoon.com/mock-samples/slackcom/) | Generic mock | Cross-platform | Pre-built Slack Web API mock sample | Active |

**Recommendation:** ⚠️ mad-fake-slack is **abandoned** (last commit 2019, uses deprecated RTM API, no published Docker image). Start with **WireMock + recorded Slack API stubs** or **Mockoon** (has pre-built Slack Web API sample). Evaluate **slack-server-mock** (Python, last push Feb 2025) as an alternative. Building a lightweight Events API + Socket Mode mock may be necessary for production-grade testing.

### Supabase (PostgreSQL + Auth + RLS)

| Tool | Type | Features | Maintenance |
|------|------|----------|-------------|
| **`supabase start`** (official CLI) | Full local stack | PostgreSQL, GoTrue auth, PostgREST, Realtime, Storage, Edge Functions, Mailpit (email capture), pgTAP testing, `supabase db reset` for clean state | Official, active |

**Recommendation:** Use `supabase start`. This is not a mock — it IS Supabase running locally in Docker. Already installed on this machine. **This is a solved problem.**

### WhatsApp Business API

| Tool | Type | Features |
|------|------|----------|
| [Twilio Sandbox](https://www.twilio.com/docs/whatsapp/sandbox) | Cloud sandbox | Shared number, 50 msg/day free, real WhatsApp delivery |
| [360dialog Sandbox](https://docs.360dialog.com/docs/get-started/sandbox) | Cloud sandbox | 200 messages per sandbox key |
| WireMock + recorded responses | Local mock | Full offline testing, deterministic |

**Recommendation:** **WireMock** for DTU (offline, deterministic). Twilio Sandbox for smoke tests against real WhatsApp.

### LLM APIs (OpenAI, Anthropic, Perplexity)

| Tool | Type | Language | Features | Maintenance |
|------|------|----------|----------|-------------|
| [llmock](https://github.com/CopilotKit/llmock) | Deterministic mock server | Node.js | OpenAI + Claude + Gemini SSE streaming, fixture-based, tool calls, error injection. Zero deps. | Active (CopilotKit) |
| [MockLLM](https://github.com/StacklokLabs/mockllm) | YAML-config mock | Python | OpenAI + Anthropic format, predefined responses | Active |
| [MockGPT](https://www.wiremock.io/post/mockgpt-mock-openai-api) | WireMock extension | Java | OpenAI API simulation, canned responses | Active (WireMock) |
| [LM Studio](https://lmstudio.ai) | Local LLM server | — | Run real models locally, OpenAI-compatible API | Active |
| [Docker Model Runner](https://www.docker.com/blog/ai-powered-mock-apis-for-testing-with-docker-and-microcks/) | Local LLM in Docker | — | OpenAI-compatible, uses local GPU | Active |

**Recommendation:** **llmock** for deterministic testing (fixture-based, fast, no GPU needed). **LM Studio** when you need actual model reasoning in tests.

### Generic Service Mocking

| Tool | Type | Language | Best For |
|------|------|----------|----------|
| [WireMock](https://wiremock.org/) | HTTP stub/mock server | Java (standalone JAR) | Recording + replaying real API traffic. 6M+ downloads. |
| [Mountebank](https://www.mbtest.dev/) | Multi-protocol mock | Node.js | HTTP, HTTPS, TCP, SMTP. ⚠️ Project moved to mbtest.dev; old .org domain is dead. |
| [Hoverfly](https://hoverfly.io/) | Service virtualization | Go | Capture-replay workflows, K8s sidecar, performance testing |
| [Mockoon](https://mockoon.com/) | API mock GUI + CLI | Electron/Node | Quick mock API setup with GUI. Pre-built templates. |

**Recommendation:** **WireMock** as the generic backbone. It can record real API traffic and replay it deterministically. Use it for any service that doesn't have a dedicated simulator.

---

## Integration with Phase 6 (HAMMER)

### How DTU Fits the Pipeline

DTU operates as the **test environment layer** that wraps HAMMER execution. It starts before code drops begin and persists throughout the build phase.

```
PLAN (Phase 5) ─── Issues ready, FSDs locked
        │
        ▼
┌─────────────────────────────────────────┐
│  DTU BOOTSTRAP                          │
│  1. supabase start (PostgreSQL + Auth)  │
│  2. mad-fake-slack up (Slack twin)      │
│  3. llmock start (LLM twin)            │
│  4. WireMock start (Calendar, WhatsApp) │
│  5. Health check all twins              │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  HAMMER EXECUTION                       │
│                                         │
│  Ralph Loop iteration N:                │
│  ┌─────────────────────────────────┐    │
│  │  1. Fresh claude -p instance    │    │
│  │  2. Read issue + FSD            │    │
│  │  3. Write tests (against DTU)   │    │
│  │  4. Write code                  │    │
│  │  5. Run tests (DTU validates)   │    │
│  │  6. Anti-regression check       │    │
│  │  7. Commit + draft PR           │    │
│  └─────────────────────────────────┘    │
│  Repeat for each story...               │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  DTU TEARDOWN                           │
│  1. Capture test coverage report        │
│  2. Export DTU state snapshots           │
│  3. supabase stop                       │
│  4. Stop all mock servers               │
└─────────────────────────────────────────┘
                 │
                 ▼
TEMPER (Phase 7) ─── Hardening + merge
```

### Integration Points with Existing HAMMER Rules

| HAMMER Rule | DTU Integration |
|-------------|-----------------|
| **Tests first, then code** | Tests run against DTU services, not real APIs. Enables TDD for external integrations. |
| **Anti-regression baseline** | Baseline captured with DTU in known state. DTU state resets between test runs for determinism. |
| **Fresh context per stage** | DTU persists across Ralph Loop iterations (state accumulates like a real environment). Reset between stories if needed. |
| **Dark Factory Mode** | DTU is essential for Level 5 autonomy — agents can run thousands of integration tests without human API key management. |

### DTU Configuration

A `dtu.yaml` at project root would define the twin constellation:

```yaml
# dtu.yaml — Digital Twin Universe configuration
version: 1
project: lifemodo  # or it-concierge, war-room

twins:
  supabase:
    type: supabase-local
    command: supabase start
    health: http://localhost:54321/rest/v1/
    reset: supabase db reset

  slack:
    type: mad-fake-slack
    image: maddevs/mad-fake-slack:latest
    port: 9001
    health: http://localhost:9001/api/api.test
    config:
      channels: [general, alerts, deputy]
      users: [deputy-bot, roderic]

  llm:
    type: llmock
    command: npx llmock --port 9002
    health: http://localhost:9002/health
    fixtures: ./test/fixtures/llm/

  calendar:
    type: wiremock
    image: wiremock/wiremock:latest
    port: 9003
    mappings: ./test/fixtures/calendar/

lifecycle:
  before_hammer: [supabase, slack, llm, calendar]  # start order
  reset_between_stories: [supabase]  # reset state between stories
  after_hammer: [calendar, llm, slack, supabase]  # stop order (reverse)
```

### New HAMMER Sub-Phase: DTU Bootstrap

Add to Phase 6 process, before the Ralph Loop begins:

1. **Read `dtu.yaml`** — determine which twins this project needs
2. **Start twins** — in dependency order
3. **Health check** — verify all twins respond
4. **Seed data** — load test fixtures into twins (Supabase seed.sql, Slack channels, LLM fixtures)
5. **Export env vars** — set `SLACK_API_URL=http://localhost:9001`, `OPENAI_BASE_URL=http://localhost:9002`, etc.
6. **Proceed to Ralph Loop**

---

## Implementation Roadmap

### Phase 1: Foundation (3 DU)

| Task | Effort | Deliverable |
|------|--------|-------------|
| Install llmock, configure fixtures for OpenAI/Anthropic | 1 DU | `test/fixtures/llm/*.json` |
| Create `dtu.yaml` schema and bootstrap script | 1.5 DU | `bin/dtu-start.sh`, `bin/dtu-stop.sh` |
| Document DTU in CONSTITUTION.md (new Article) | 0.5 DU | Article in Constitution |

### Phase 2: Project-Specific Twins (6 DU)

| Task | Effort | Deliverable |
|------|--------|-------------|
| IT Concierge: `supabase start` + seed data + test harness | 1 DU | Working local Supabase with test data |
| IT Concierge: WireMock WhatsApp twin + recorded responses | 2 DU | WhatsApp API mock with 10+ scenarios |
| LifeModo: mad-fake-slack setup + Deputy integration | 2 DU | Slack twin with channels, events, WebSocket |
| War Room: llmock fixtures for Perplexity search responses | 1 DU | Perplexity-compatible fixtures |

### Phase 3: HAMMER Integration (2 DU)

| Task | Effort | Deliverable |
|------|--------|-------------|
| Integrate DTU bootstrap into HAMMER phase | 1 DU | Updated `06-hammer.md`, bootstrap in Ralph Loop |
| Add DTU health checks to Build Gate (R6) | 0.5 DU | R6 checklist updated |
| CI pipeline: DTU in GitHub Actions | 0.5 DU | `.github/workflows/dtu-test.yml` |

### Phase 4: Fidelity Hardening (Ongoing, 1 DU/sprint)

| Task | Effort | Deliverable |
|------|--------|-------------|
| Record real API traffic → WireMock mappings | 0.5 DU/sprint | Growing fixture library |
| Validate twins against live services (drift detection) | 0.5 DU/sprint | Fidelity reports |

**Total: 11 DU foundation + 1 DU/sprint maintenance**

### Priority Order

1. **llmock** (War Room) — lowest effort, highest immediate savings (API credits)
2. **supabase start** (IT Concierge) — already installed, basically free
3. **mad-fake-slack** (LifeModo) — highest complexity but blocks agent testing
4. **WireMock WhatsApp** (IT Concierge) — moderate effort, moderate value
5. **WireMock Calendar** (shared) — low priority, Calendar API is simple

---

## Key Insight from StrongDM

> *"This kind of capability was always possible, but never economically feasible."*

The DTU concept is not technically novel — it is **economically novel**. AI coding agents make it feasible to generate high-fidelity API simulators from documentation alone, at a fraction of the cost of manually building service virtualizations. This is the same unlock we should exploit: use the Foundry's own HAMMER phase to build the twins.

---

## Sources

- [StrongDM Software Factory Blog](https://www.strongdm.com/blog/the-strongdm-software-factory-building-software-with-ai)
- [StrongDM DTU Techniques Page](https://factory.strongdm.ai/techniques/dtu)
- [Simon Willison's Analysis](https://simonwillison.net/2026/Feb/7/software-factory/)
- [mad-fake-slack](https://github.com/maddevsio/mad-fake-slack)
- [slack-server-mock](https://github.com/ygalblum/slack-server-mock)
- [llmock (CopilotKit)](https://github.com/CopilotKit/llmock)
- [MockLLM](https://github.com/StacklokLabs/mockllm)
- [MockGPT (WireMock)](https://www.wiremock.io/post/mockgpt-mock-openai-api)
- [Supabase Local Development Docs](https://supabase.com/docs/guides/local-development)
- [Twilio WhatsApp Sandbox](https://www.twilio.com/docs/whatsapp/sandbox)
- [OrbStack](https://orbstack.dev/)
- [OrbStack vs Docker Desktop](https://orbstack.dev/docs/compare/docker-desktop)
- [Apple Containers vs Docker vs OrbStack](https://www.repoflow.io/blog/apple-containers-vs-docker-desktop-vs-orbstack)
- [WireMock](https://wiremock.org/)
- [Hoverfly](https://hoverfly.io/)
- [Mockoon Slack Mock Sample](https://mockoon.com/mock-samples/slackcom/)
