# Solutions Directory

A structured library of reusable patterns, failure modes, and package combinations discovered during HAMMER/TEMPER cycles. Populated by RALPH LOOP entries. Searched by HAMMER Step 0 (Prior Art Check) before each story.

**See:** [FR-METH-8 #54](https://github.com/growthpigs/the-foundry/issues/54)

---

## How to Search

```bash
# Search by pattern type
grep -ri "oauth" solutions/ --include="*.md" -l

# Search by technology
grep -ri "prisma" solutions/ --include="*.md" -l

# Search by project
grep -ri "lifemodo" solutions/ --include="*.md" -l
```

Or via GitHub: `gh search issues --repo growthpigs/the-foundry "oauth" --label solution`

---

## Entry Format

Each file in `solutions/` follows this template:

```markdown
## SOLUTION: [Pattern Name]
**Pattern type:** [API integration / Auth / State / Migration / Queue / etc.]
**applies_when:** [specific trigger context — e.g., "implementing OAuth2 with Supabase and seeing 403 on token refresh", "adding WebSocket reconnection after Gemini 15-min limit", "concurrent writes failing with unique constraint violations"]
**Technologies:** [specific packages + versions at time of writing]
**Project:** [where this was validated]
**Date:** YYYY-MM-DD
**Status:** Active | Deprecated | Superseded by [link]

### Problem
[2 sentences: what problem this solves]

### Solution
[Code snippet or pattern description — specific enough to implement]

### Failure modes
[What we tried that didn't work and why]

### When NOT to use this
[Explicit anti-patterns or scope boundaries]
```

---

## Quarterly Refresh Cycle

Every quarter (or after every 3rd RALPH LOOP, whichever comes first), run a refresh scan:

1. `grep -r "Status: Active" solutions/ --include="*.md" -l` → get all active entries
2. For entries older than 90 days: verify the package is still current, the pattern still applies
3. Update `Status:` field accordingly: **Active** / **Deprecated** / **Superseded by [link]**
4. Log the refresh in `solutions/REFRESH-LOG.md`

**Trigger:** At the start of every 3rd RALPH LOOP session, check the last refresh date in `REFRESH-LOG.md`. If > 90 days ago, run the scan before closing the session.

---

## Refresh Log

See [REFRESH-LOG.md](REFRESH-LOG.md) — tracks when scans were run and what changed.

*This directory starts empty. It grows as teams add entries via RALPH LOOP.*
