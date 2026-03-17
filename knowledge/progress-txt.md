# The Foundry — progress.txt Lifecycle

**Issue:** growthpigs/pai-system #20
**Origin:** Adopted from snarktank/ralph

## What progress.txt Is

A per-feature knowledge file that accumulates discoveries during pipeline execution. Each `claude -p` invocation reads it for context and appends new findings. It is the "offensive" knowledge system — actively accelerating current work.

Contrast with `error-patterns.md` — the "defensive" knowledge system that prevents repeating past mistakes across ALL features.

## Lifecycle

```
SEED (pipeline start)
  ↓
APPEND (each stage adds findings)
  ↓
GRADUATE (recurring findings → error-patterns.md)
  ↓
ARCHIVE (on merge, move to .foundry/archive/)
```

## 1. SEED (Pipeline Start)

Created by `bin/foundry.sh` when the pipeline begins:

```
# progress.txt — The Foundry Pipeline
# Issue: #123 — Fix chat formatting regression
# Mode: FIX
# Started: 2026-03-13T14:30:00Z
# Branch: claude/fix-chat-formatting

## Context
- Project: war-room
- Error patterns consulted: 41, 54, 55 (chat-related)
- Affected files (from issue): CitationText.tsx, enhancedPerplexityChatService.ts

## Discoveries
(Appended by each stage below)
```

### What Gets Seeded

| Field | Source |
|-------|--------|
| Issue number + title | `gh issue view` |
| Mode | Classifier output |
| Timestamp | `date -u` |
| Branch name | Generated from issue |
| Related error patterns | Grep error-patterns.md for affected file names |
| Affected files | From issue body (if listed) |

## 2. APPEND (Each Stage)

Every `claude -p` stage receives progress.txt as context (prepended to the prompt) and is instructed to append discoveries.

### What Gets Appended

```
## [Stage Name] — [Timestamp]
- DISCOVERED: [Something we learned]
- DECISION: [Choice made and why]
- BLOCKED: [Something that prevented progress]
- WARNING: [Something that might bite us later]
- FIXED: [What was changed and why]
```

### Append Rules

1. **Append only, never modify.** Each stage adds below previous entries. Never edit prior stage entries.
2. **Be specific.** "Fixed the bug" is useless. "Fixed CitationText.tsx:47 — safeInsertParagraphBreaks was splitting table rows across paragraphs because regex didn't account for pipe characters" is useful.
3. **Include file paths and line numbers.** Future stages (and future humans) need to find the code.
4. **Include failed approaches.** "Tried X, didn't work because Y" prevents the next stage from repeating the attempt.
5. **Maximum 5 entries per stage.** Prioritize the most important discoveries.

### What Does NOT Go In progress.txt

- Full code snippets (that's what git is for)
- Test output dumps (too verbose, put in logs)
- Generic observations ("the code is well-structured")
- Anything that belongs in the PR description instead

## 3. GRADUATE (Recurring Findings → error-patterns.md)

When a discovery in progress.txt recurs across **3 or more different features**, it graduates to the permanent `error-patterns.md` file.

### Graduation Criteria

| Criteria | Threshold |
|----------|-----------|
| Same discovery in N features | N ≥ 3 |
| Same file/pattern involved | Must be the same root cause, not coincidence |
| Actionable prevention | Must be expressible as a rule ("always do X" or "never do Y") |

### Graduation Process

1. After pipeline completes, scan progress.txt for DISCOVERED/WARNING entries
2. Cross-reference against `.foundry/archive/` — has this appeared before?
3. If ≥ 3 occurrences: create a new error pattern entry
4. Format:

```markdown
## Error Pattern [N]: [Name]

**First seen:** [date, feature]
**Recurred:** [date, feature], [date, feature]
**Root cause:** [why this keeps happening]
**Prevention:** [what to do/not do]
**Files:** [commonly affected files]
```

### Graduation is Automated in the Follow-up Stage

The follow-up command file includes instructions to check for graduation candidates. This happens at the end of every pipeline run.

## 4. ARCHIVE (On Merge)

When the PR is merged:

1. Move progress.txt to `.foundry/archive/progress-{issue-number}-{date}.txt`
2. The archive is gitignored but kept locally for graduation cross-referencing
3. Archive retention: 90 days, then delete

```bash
archive_progress() {
  local issue_num="$1"
  local date_stamp
  date_stamp=$(date +%Y%m%d)

  mkdir -p .foundry/archive
  mv progress.txt ".foundry/archive/progress-${issue_num}-${date_stamp}.txt"
}
```

## File Location

```
project-root/
├── progress.txt                          ← Active (current pipeline run)
├── .foundry/
│   ├── archive/
│   │   ├── progress-123-20260313.txt     ← Completed features
│   │   ├── progress-124-20260314.txt
│   │   └── ...
│   ├── baseline-123.md                   ← Anti-regression baselines
│   └── ...
├── .claude/
│   └── error-patterns.md                 ← Permanent (graduated findings)
└── .gitignore                            ← .foundry/ is gitignored
```

## Integration with Pipeline Stages

Each stage prompt is prepended with:

```
## Prior Progress
[contents of progress.txt]

---

[original command file content]

---

## Instructions
After completing your work, append your key discoveries to progress.txt using this format:
## [Stage Name] — [timestamp]
- DISCOVERED: ...
- DECISION: ...
- WARNING: ...
- FIXED: ...

Maximum 5 entries. Be specific (file paths, line numbers, root causes).
```
