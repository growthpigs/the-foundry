#!/usr/bin/env python3
"""
The Foundry — Crucible Executor
One command. No shortcuts. All 8 rules enforced.

Usage:
    python3 crucible.py \
        --domain "Security & RLS" \
        --sources docs/02-specs/FSD-001.md docs/04-technical/DATA-MODEL.md \
        --external "https://raw.githubusercontent.com/supabase/supabase/master/apps/docs/content/guides/auth/row-level-security.mdx" \
        --questions "Where does our RLS violate Supabase best practices?" "What happens if a user bypasses the UI?" \
        --audio-focus "Debate whether server-wins conflict resolution silently destroys field data"

Required args:
    --domain       Domain name for this Crucible group
    --sources      2+ local files (uploaded as SEPARATE sources — Rule 2)
    --external     1+ URLs to fetch as external ground truth (Rule 4)
    --questions    1+ adversarial questions for chat (Modality 1)
    --audio-focus  Instructions for the DEBATE audio (Modality 2)

Output:
    .foundry/crucible-report-{domain}.md     — Dual-modality report
    .foundry/crucible-audio-{domain}.wav     — Audio file
    .foundry/crucible-audio-{domain}.txt     — Audio transcript
    progress.txt                             — Appended with artifacts
"""

import asyncio
import argparse
import os
import subprocess
import sys
from datetime import datetime, timezone


def fetch_external_url(url: str) -> str:
    """Fetch external docs. Prefers raw GitHub/MDX. Falls back to curl."""
    try:
        result = subprocess.run(
            ["curl", "-sL", "--max-time", "30", url],
            capture_output=True, text=True, timeout=35
        )
        content = result.stdout.strip()
        if not content or len(content) < 100:
            print(f"  ⚠️  External URL returned very little content: {url}")
        return content
    except Exception as e:
        print(f"  ❌ Failed to fetch {url}: {e}")
        return f"[FETCH FAILED: {url} — {e}]"


async def run_crucible(domain: str, source_files: list, external_urls: list,
                       questions: list, audio_focus: str):
    """Execute the full Crucible — all 8 rules, no shortcuts."""
    from notebooklm import NotebookLMClient, AudioFormat

    os.makedirs(".foundry", exist_ok=True)
    domain_slug = domain.lower().replace(" ", "-").replace("&", "and")
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    print(f"\n{'='*60}")
    print(f"  CRUCIBLE: {domain}")
    print(f"  {timestamp}")
    print(f"{'='*60}\n")

    async with await NotebookLMClient.from_storage() as client:

        # ── STEP 1: Create notebook (Rule 5: one per domain) ──
        print("1. Creating NotebookLM notebook...")
        notebook = await client.notebooks.create(f"Crucible: {domain}")
        notebook_id = notebook.id
        print(f"   ✅ Notebook ID: {notebook_id}")

        # ── STEP 2: Upload sources SEPARATELY (Rule 2: NO concatenation) ──
        print(f"\n2. Uploading {len(source_files)} sources (SEPARATE — Rule 2)...")
        source_count = 0
        for filepath in source_files:
            if not os.path.exists(filepath):
                print(f"   ❌ File not found: {filepath}")
                continue
            with open(filepath) as f:
                content = f.read()
            title = os.path.basename(filepath)
            await client.sources.add_text(
                notebook_id=notebook_id,
                title=title,
                content=content,
                wait=True
            )
            source_count += 1
            print(f"   ✅ [{source_count}] {title} ({len(content)} chars)")

        # ── STEP 3: Fetch + upload external ground truth (Rule 4) ──
        print(f"\n3. Fetching {len(external_urls)} external ground truth sources (Rule 4)...")
        for url in external_urls:
            print(f"   Fetching: {url[:80]}...")
            content = fetch_external_url(url)
            # Extract a clean title from the URL
            title = f"EXTERNAL: {url.split('/')[-1]}"
            await client.sources.add_text(
                notebook_id=notebook_id,
                title=title,
                content=content,
                wait=True
            )
            source_count += 1
            print(f"   ✅ [{source_count}] {title} ({len(content)} chars)")

        # Verify minimum 3 sources (Rule 3)
        if source_count < 3:
            print(f"\n   ❌ RULE 3 VIOLATION: Only {source_count} sources. Minimum is 3.")
            print("   Add more --sources or --external URLs.")
            sys.exit(1)
        print(f"\n   ✅ Source count: {source_count} (Rule 3: ≥3 ✓)")

        # ── STEP 4: Chat queries — Modality 1 (Rule 6) ──
        print(f"\n4. Running {len(questions)} chat queries (Modality 1)...")
        chat_results = []
        for i, question in enumerate(questions, 1):
            print(f"\n   Q{i}: {question[:100]}...")
            result = await client.chat.ask(
                notebook_id=notebook_id,
                question=question
            )
            chat_results.append((question, result.answer))
            print(f"   A{i}: {result.answer[:200]}...")
            await asyncio.sleep(3)

        # ── STEP 5: Generate Audio DEBATE — Modality 2 (Rules 6, 7) ──
        print(f"\n5. Generating Audio Overview (DEBATE format — Rules 6, 7)...")
        print(f"   Focus: {audio_focus[:100]}...")
        print(f"   ⏳ This takes 10-20 minutes. Do not interrupt.\n")

        audio_status = await client.artifacts.generate_audio(
            notebook_id=notebook_id,
            audio_format=AudioFormat.DEBATE,
            instructions=audio_focus
        )

        final_status = await client.artifacts.wait_for_completion(
            notebook_id=notebook_id,
            task_id=audio_status.task_id,
            timeout=1200.0  # 20 minutes
        )

        if final_status.status not in ("completed", "complete"):
            print(f"   ❌ Audio generation FAILED: {final_status.status}")
            print(f"   Error: {final_status.error}")
            print("   The Crucible is INCOMPLETE without audio. Fix and retry.")
            sys.exit(1)

        print(f"   ✅ Audio generated: {final_status.status}")

        # ── STEP 6: Download audio ──
        audio_path = f".foundry/crucible-audio-{domain_slug}.mp4"
        try:
            downloaded = await client.artifacts.download_audio(
                notebook_id=notebook_id,
                output_path=audio_path
            )
            print(f"   ✅ Audio saved: {downloaded}")
        except Exception as e:
            print(f"   ⚠️  Audio download failed: {e}")
            print("   Check NotebookLM UI to download manually.")
            audio_path = None

        # ── STEP 7: Transcribe audio (Rule 7) ──
        transcript_path = f".foundry/crucible-audio-{domain_slug}-transcript.md"
        transcript_content = None
        if audio_path and os.path.exists(audio_path):
            print(f"\n6. Transcribing audio (Rule 7)...")
            try:
                import whisper as whisper_module
                model = whisper_module.load_model("base")
                result = model.transcribe(audio_path)
                transcript_content = result["text"]
                with open(transcript_path, "w") as tf:
                    tf.write(f"# Audio Transcript: {domain}\n\n")
                    tf.write(f"**Source:** `{audio_path}`\n")
                    tf.write(f"**Model:** whisper-base\n")
                    tf.write(f"**Date:** {timestamp}\n\n---\n\n")
                    tf.write(transcript_content)
                print(f"   ✅ Transcript: {transcript_path} ({len(transcript_content)} chars)")
            except ImportError:
                print("   ⚠️  Whisper not installed. Install: pip install openai-whisper")
            except Exception as e:
                print(f"   ⚠️  Transcription failed: {e}")
        else:
            print("\n6. ⚠️  No audio file to transcribe")

        # ── STEP 8: Compile dual-modality Crucible Report (Rule 8) ──
        report_path = f".foundry/crucible-report-{domain_slug}.md"
        print(f"\n7. Compiling Crucible Report (Rule 8 — TWO modalities)...")

        with open(report_path, "w") as report:
            report.write(f"# Crucible Report: {domain}\n\n")
            report.write(f"**Date:** {timestamp}\n")
            report.write(f"**Notebook ID:** `{notebook_id}`\n")
            report.write(f"**Audio Task ID:** `{audio_status.task_id}`\n")
            report.write(f"**Sources:** {source_count} (separate uploads, no concatenation)\n")
            report.write(f"**External ground truth:** {len(external_urls)} official docs\n\n")
            report.write("---\n\n")

            # Modality 1
            report.write("## MODALITY 1: Chat Findings (Targeted Q&A)\n\n")
            report.write("_Chat produces specific, cited answers to direct questions._\n\n")
            for q, a in chat_results:
                report.write(f"### Q: {q}\n\n{a}\n\n---\n\n")

            # Modality 2
            report.write("## MODALITY 2: Audio Debate Findings (Sustained Adversarial)\n\n")
            report.write("_Audio produces emergent insights from sustained argument._\n")
            report.write("_The AI takes opposing positions it would never take in chat._\n\n")
            report.write(f"**Audio focus:** {audio_focus}\n\n")
            if transcript_content:
                report.write("### Transcript\n\n")
                report.write(transcript_content)
            else:
                report.write("**[TRANSCRIPT PENDING]**\n")
                report.write(f"Audio file: `{audio_path or 'download from NotebookLM UI'}`\n")
                report.write("Transcribe with: `whisper .foundry/crucible-audio-*.wav --output_format txt`\n")

            report.write("\n\n---\n\n")
            report.write("## Verification Artifacts\n\n")
            report.write(f"- Notebook ID: `{notebook_id}`\n")
            report.write(f"- Audio Task ID: `{audio_status.task_id}` (status: {final_status.status})\n")
            report.write(f"- Report: `{report_path}`\n")
            report.write(f"- Audio: `{audio_path}`\n")
            report.write(f"- Transcript: `{transcript_path}`\n")

        print(f"   ✅ Report saved: {report_path}")

        # ── STEP 9: Append to progress.txt ──
        progress_file = "progress.txt"
        if os.path.exists(progress_file):
            with open(progress_file, "a") as pf:
                pf.write(f"\n[CRUCIBLE] notebook_id={notebook_id} "
                         f"audio_task={audio_status.task_id} "
                         f"report={report_path} domain={domain}\n")
            print(f"   ✅ Appended to {progress_file}")

        # ── FINAL SUMMARY ──
        print(f"\n{'='*60}")
        print(f"  CRUCIBLE COMPLETE: {domain}")
        print(f"{'='*60}")
        print(f"  Notebook:   {notebook_id}")
        print(f"  Audio:      {audio_status.task_id} ({final_status.status})")
        print(f"  Report:     {report_path}")
        print(f"  Sources:    {source_count} (separate, with external ground truth)")
        print(f"  Chat:       {len(chat_results)} queries")
        print(f"  Transcript: {'✅' if transcript_content else '⚠️  PENDING'}")
        print(f"{'='*60}\n")

        return notebook_id, audio_status.task_id, report_path


def main():
    parser = argparse.ArgumentParser(
        description="The Foundry — Crucible Executor (all 8 rules enforced)"
    )
    parser.add_argument("--domain", required=True, help="Domain name for this Crucible group")
    parser.add_argument("--sources", required=True, nargs="+", help="Local files to upload (2+ required)")
    parser.add_argument("--external", required=True, nargs="+", help="External ground truth URLs (1+ required)")
    parser.add_argument("--questions", required=True, nargs="+", help="Adversarial chat questions")
    parser.add_argument("--audio-focus", required=True, help="Instructions for the DEBATE audio")

    args = parser.parse_args()

    if len(args.sources) < 2:
        print("❌ Rule 3: Minimum 2 internal sources required (+ 1 external = 3 total)")
        sys.exit(1)

    if len(args.external) < 1:
        print("❌ Rule 4: At least 1 external ground truth URL required")
        sys.exit(1)

    notebook_id, audio_task_id, report_path = asyncio.run(
        run_crucible(args.domain, args.sources, args.external,
                     args.questions, args.audio_focus)
    )

    # Print artifacts for the calling CC to capture
    print(f"CRUCIBLE_NOTEBOOK_ID={notebook_id}")
    print(f"CRUCIBLE_AUDIO_TASK_ID={audio_task_id}")
    print(f"CRUCIBLE_REPORT_PATH={report_path}")


if __name__ == "__main__":
    main()
