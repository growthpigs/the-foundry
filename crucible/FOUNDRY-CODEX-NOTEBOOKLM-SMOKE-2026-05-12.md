# Foundry Codex + NotebookLM Smoke Crucible — 2026-05-12

**Purpose:** Prove that Foundry Crucible execution can create real NotebookLM artifacts instead of only claiming a red-team stage ran.

## NotebookLM Artifacts

- Notebook: `490ce25d-479a-4cd8-8797-bd2179234693`
- Title: `Crucible Smoke — Foundry Codex Engine — 2026-05-12`
- Audio artifact: `2a76b925-bf0b-41c2-9cda-fbb9d1d9d767`
- Audio title: `Stopping fake Adversarial Smoke Crucible claims`
- Audio type: `Audio`
- Audio status: `completed`
- Audio status id: `3`

## Separate Sources

1. `14b773d7-8cbb-47a6-839f-6209335c3c9b` — `Architecture Anchor — Dual Engine Foundry`
2. `87771e30-bfa5-4fcd-af27-38053ecd06d4` — `Subject Document — Crucible Completion Rules`
3. `78d815b1-536d-4c24-9033-b2b8f311a7fd` — `foundry-crucible-smoke-external.txt`

## Extraction Query

Question:

> Based on the completed debate audio context and the three sources, what is the top risk that could still allow fake Crucible claims, and what concrete runner change would prevent it?

NotebookLM answer summary:

- The top risk is that the runner might pretend a stage ran when the selected execution engine was unavailable, or might pass off chat-only review as a completed Crucible.
- Required fixes:
  - Make engine selection explicit and visible in dry-run and reports.
  - Programmatically invoke NotebookLM for Crucible work.
  - Require notebook id, source ids, audio artifact/task id, and extracted findings outside the model transcript.

## Verification Commands

```bash
notebooklm doctor
notebooklm source list --notebook 490ce25d-479a-4cd8-8797-bd2179234693 --json
notebooklm artifact list --notebook 490ce25d-479a-4cd8-8797-bd2179234693 --json
notebooklm ask --notebook 490ce25d-479a-4cd8-8797-bd2179234693 --json "Based on the completed debate audio context and the three sources, what is the top risk that could still allow fake Crucible claims, and what concrete runner change would prevent it?"
```

## Verdict

This was a real NotebookLM Crucible smoke test. It created a real notebook, uploaded three separate sources, generated a completed debate-format audio artifact, and extracted findings with citations.

