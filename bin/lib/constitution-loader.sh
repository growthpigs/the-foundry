#!/usr/bin/env bash
# constitution-loader.sh — progressive-disclosure loading of the Constitution (#73).
# Enforces the Loading Map in CONSTITUTION.md: CLIENT-tier articles are stripped
# from the prompt for internal (non-client-engagement) projects.
#
# Function library only — no side effects on source. Bash 3.2 compatible (macOS).
# Sourced by bin/foundry.sh; unit-tested by bin/__tests__/constitution-tiering.test.sh.

# CLIENT-tier article numbers — MUST match the Loading Map in CONSTITUTION.md.
# 14 (18 Documents), 16 (Slack Console), 19 (Admin Doc Quality Gate),
# 23 (Service Billing Pre-Flight), 33 (Agreement), 34 (Work Ledger).
FOUNDRY_CLIENT_TIER_ARTICLES="14|16|19|23|33|34"

# foundry_project_type <.foundry-dir>
# Resolution order: FOUNDRY_PROJECT_TYPE env → <.foundry-dir>/project-type file → "client".
# DEFAULT IS client (fail-safe): loading extra rules is harmless; silently skipping
# binding rules is not. Internal projects opt IN to the context savings.
# Unknown values fall back to client with a warning on stderr.
foundry_project_type() {
  local foundry_dir="${1:-}"
  local raw=""
  if [ -n "${FOUNDRY_PROJECT_TYPE:-}" ]; then
    raw="$FOUNDRY_PROJECT_TYPE"
  elif [ -n "$foundry_dir" ] && [ -f "$foundry_dir/project-type" ]; then
    raw="$(head -1 "$foundry_dir/project-type")"
  fi
  # trim + lowercase (tr, not ${var,,} — bash 3.2)
  raw="$(printf '%s' "$raw" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')"
  case "$raw" in
    client|internal) printf '%s' "$raw" ;;
    "")              printf 'client' ;;
    *)
      echo "[WARN] Unknown project type '${raw}' — defaulting to client (all articles load)" >&2
      printf 'client' ;;
  esac
}

# load_constitution <constitution-file> <project-type>
# Prints the constitution to stdout. For internal projects, strips CLIENT-tier
# articles (header through the line before the next '## ' heading). CORE-tier
# articles and non-article sections (Loading Map, Amendments) are never touched.
#
# FENCE-AWARE (adversarial review, #73 / #75): article bodies contain fenced code
# templates with lines that LOOK like H2 headings (e.g. '## Work Ledger' inside
# Article 34's template). Heading rules only apply OUTSIDE code fences — a
# fence-blind version leaked Article 34's entire DU rate card into internal
# output. Both fence syntaxes are handled: ``` and ~~~. Per CommonMark they are
# independent — a fence opened with one char is closed only by the SAME char, so
# a ~~~ line inside a ``` block (or vice-versa) is content, not a delimiter. We
# track the OPENING fence char, not a naive toggle, so nested-syntax cases can't
# spuriously flip fence state and reopen the leak. State tracks every line,
# including skipped ones.
load_constitution() {
  local file="$1"
  local project_type="${2:-client}"
  if [ "$project_type" != "internal" ]; then
    cat "$file"
    return
  fi
  awk -v arts="$FOUNDRY_CLIENT_TIER_ARTICLES" '
    BEGIN { pat = "^## Article (" arts "):" ; skip = 0 ; fence = 0 ; fchar = "" }
    /^(```|~~~)/ {
      ch = substr($0, 1, 1)
      if (fence == 0)      { fence = 1; fchar = ch }
      else if (ch == fchar){ fence = 0; fchar = "" }
    }
    !fence && $0 ~ pat { skip = 1; next }
    !fence && /^## /   { skip = 0 }
    !skip              { print }
  ' "$file"
}
