#!/usr/bin/env bash
# constitution-tiering.test.sh — unit tests for bin/lib/constitution-loader.sh (#73).
# Runs against the REAL CONSTITUTION.md so boundary regressions (an awk strip
# eating an adjacent CORE article) are caught against the live document, not a toy.
# Fails-before/passes-after: with the pre-#73 loader (plain cat), the internal-mode
# assertions below fail.
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONSTITUTION="$REPO_ROOT/CONSTITUTION.md"
# shellcheck source=../lib/constitution-loader.sh
. "$REPO_ROOT/bin/lib/constitution-loader.sh"

PASS=0
FAIL=0

check() {
  local desc="$1" ; local ok="$2"
  if [ "$ok" = "0" ]; then
    echo "  ok  - $desc" ; PASS=$((PASS+1))
  else
    echo "  FAIL - $desc" ; FAIL=$((FAIL+1))
  fi
}

contains()     { printf '%s' "$1" | grep -qF -- "$2"; }
not_contains() { ! printf '%s' "$1" | grep -qF -- "$2"; }

echo "# internal project: CLIENT-tier articles stripped, CORE intact"
INTERNAL="$(load_constitution "$CONSTITUTION" internal)"
not_contains "$INTERNAL" "## Article 14:"; check "Article 14 (18 Documents) stripped" $?
not_contains "$INTERNAL" "## Article 16:"; check "Article 16 (Slack Console) stripped" $?
not_contains "$INTERNAL" "## Article 19:"; check "Article 19 (Admin Quality Gate) stripped" $?
not_contains "$INTERNAL" "## Article 23:"; check "Article 23 (Service Billing) stripped" $?
not_contains "$INTERNAL" "## Article 33:"; check "Article 33 (Agreement) stripped" $?
not_contains "$INTERNAL" "## Article 34:"; check "Article 34 (Work Ledger) stripped" $?
not_contains "$INTERNAL" "Development Units (DUs)"; check "DU-ledger body text gone" $?

echo "# tail-leak canaries: one LATE-body string per stripped article (fence-blind"
echo "# unskip leaked Article 34's tail past an embedded '## ' line — never again)"
not_contains "$INTERNAL" "all 18 substantially complete"; check "Article 14 tail gone" $?
not_contains "$INTERNAL" "Fob and Circles are phone-native"; check "Article 16 tail gone" $?
not_contains "$INTERNAL" "Never leave a corrupted issue"; check "Article 19 tail gone" $?
not_contains "$INTERNAL" 'quota exceeded'; check "Article 23 body gone" $?
not_contains "$INTERNAL" "combined SOW + MOU"; check "Article 33 body gone" $?
not_contains "$INTERNAL" "Six-Hat DU Rates"; check "Article 34 tail (DU rate card) gone" $?
not_contains "$INTERNAL" "## Work Ledger"; check "Article 34 embedded fake-H2 gone" $?

echo "# structural integrity: stripping must not unbalance markdown fences"
INT_FENCES="$(printf '%s\n' "$INTERNAL" | grep -c '^```')"
[ $((INT_FENCES % 2)) -eq 0 ]; check "internal output has even fence count ($INT_FENCES)" $?

echo "# boundary correctness: articles adjacent to stripped ones survive"
contains "$INTERNAL" "## Article 13:"; check "Article 13 (before 14) intact" $?
contains "$INTERNAL" "## Article 15:"; check "Article 15 (after 14) intact" $?
contains "$INTERNAL" "## Article 17:"; check "Article 17 (after 16) intact" $?
contains "$INTERNAL" "## Article 20:"; check "Article 20 (after 19) intact" $?
contains "$INTERNAL" "## Article 24:"; check "Article 24 (after 23) intact" $?
contains "$INTERNAL" "## Article 32:"; check "Article 32 (before 33) intact" $?
contains "$INTERNAL" "## Article 35:"; check "Article 35 (after 34) intact" $?
contains "$INTERNAL" "## Article 36:"; check "Article 36 intact" $?
contains "$INTERNAL" "## Article 1:";  check "Article 1 intact" $?
contains "$INTERNAL" "## Article 8b:"; check "Article 8b (letter suffix) intact" $?
contains "$INTERNAL" "## Loading Map"; check "Loading Map section intact" $?
contains "$INTERNAL" "## Amendments";  check "Amendments section intact" $?
contains "$INTERNAL" "## Article 22:"; check "Article 22 (borderline, ruled CORE) intact" $?
contains "$INTERNAL" "## Article 31:"; check "Article 31 (borderline, ruled CORE) intact" $?

echo "# client project: nothing stripped"
CLIENT="$(load_constitution "$CONSTITUTION" client)"
contains "$CLIENT" "## Article 14:"; check "Article 14 present for client" $?
contains "$CLIENT" "## Article 34:"; check "Article 34 present for client" $?
[ "$CLIENT" = "$(cat "$CONSTITUTION")" ]; check "client output matches file content (modulo trailing newline)" $?

echo "# project-type resolution"
TMPDIR_T="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_T"' EXIT

T="$(FOUNDRY_PROJECT_TYPE="" foundry_project_type "$TMPDIR_T")"
[ "$T" = "client" ]; check "no config anywhere → client (fail-safe default)" $?

printf 'internal\n' > "$TMPDIR_T/project-type"
T="$(FOUNDRY_PROJECT_TYPE="" foundry_project_type "$TMPDIR_T")"
[ "$T" = "internal" ]; check "project-type file 'internal' honored" $?

printf ' Internal \n' > "$TMPDIR_T/project-type"
T="$(FOUNDRY_PROJECT_TYPE="" foundry_project_type "$TMPDIR_T")"
[ "$T" = "internal" ]; check "whitespace + case normalized" $?

T="$(FOUNDRY_PROJECT_TYPE=client foundry_project_type "$TMPDIR_T")"
[ "$T" = "client" ]; check "env var overrides file" $?

printf 'banana\n' > "$TMPDIR_T/project-type"
T="$(FOUNDRY_PROJECT_TYPE="" foundry_project_type "$TMPDIR_T" 2>/dev/null)"
[ "$T" = "client" ]; check "unknown value → client (fail-safe)" $?

echo "# context savings are real (floor set near true savings so partial-strip"
echo "# regressions — e.g. a tail leak — drag it below the bar)"
INT_BYTES="$(printf '%s' "$INTERNAL" | wc -c)"
CLI_BYTES="$(printf '%s' "$CLIENT" | wc -c)"
SAVED=$((CLI_BYTES - INT_BYTES))
[ "$SAVED" -gt 17000 ]; check "internal strip saves >17KB (actual: ${SAVED} bytes)" $?

echo "# defensive source: a MISSING loader lib must NOT brick foundry.sh"
echo "# (it runs under 'set -euo pipefail'; a bare failed source aborts at startup)"
# Reproduce the exact guard block from bin/foundry.sh against a missing path.
MISS_OUT="$(bash -c '
  set -euo pipefail
  SCRIPT_DIR="/tmp/does-not-exist-$$"
  if [ -f "$SCRIPT_DIR/bin/lib/constitution-loader.sh" ] && . "$SCRIPT_DIR/bin/lib/constitution-loader.sh"; then :; else
    foundry_project_type() { printf "client"; }
    load_constitution() { cat "$1"; }
  fi
  printf "continued:%s" "$(foundry_project_type /x)"
' 2>/dev/null)"; MISS_RC=$?
[ "$MISS_RC" -eq 0 ]; check "missing lib does not abort under set -e (rc=$MISS_RC)" $?
[ "$MISS_OUT" = "continued:client" ]; check "missing lib falls back to client (loads full constitution)" $?
# And prove foundry.sh actually contains the defensive guard, not a bare source.
FOUNDRY_SH="$REPO_ROOT/bin/foundry.sh"
grep -q 'if \[ -f "\$SCRIPT_DIR/bin/lib/constitution-loader.sh" \]' "$FOUNDRY_SH"; check "foundry.sh guards the source (not a bare '. lib')" $?
! grep -qE '^\. "\$SCRIPT_DIR/bin/lib/constitution-loader.sh"' "$FOUNDRY_SH"; check "no unguarded top-level source remains" $?

echo "# synthetic fence adversarial cases (#75): tilde fences + nested syntaxes"
echo "# must not let a fake '## ' heading inside a code block reopen the strip"
SAVED_ARTS="$FOUNDRY_CLIENT_TIER_ARTICLES"
FOUNDRY_CLIENT_TIER_ARTICLES="14"
FIX="$TMPDIR_T/fixture.md"

# Case A — a ~~~ fenced block inside a stripped article, wrapping a fake H2.
# Backtick-only fence tracking (pre-#75) would miss the ~~~, see the fake H2 as a
# real heading, unskip, and leak the article tail + the CORE article's identity.
printf '%s\n' \
  '## Article 14: Client' '> banner' 'body A' \
  '~~~' '## Fake tilde heading' 'x' '~~~' \
  'tail-of-14-CANARY' \
  '## Article 15: Core' 'kept-body-A' > "$FIX"
OUT_A="$(load_constitution "$FIX" internal)"
not_contains "$OUT_A" "Fake tilde heading"; check "A: fake H2 inside ~~~ fence not leaked" $?
not_contains "$OUT_A" "tail-of-14-CANARY";  check "A: stripped article tail not leaked" $?
contains     "$OUT_A" "## Article 15: Core"; check "A: following CORE article survives" $?
contains     "$OUT_A" "kept-body-A";         check "A: CORE body survives" $?

# Case B — a ``` block whose CONTENT includes a ~~~ line and a fake H2. A naive
# both-toggle tracker (flip on ``` OR ~~~) would treat the inner ~~~ as a close,
# fall outside the fence, and leak the fake H2. Char-tracking keeps the ``` open.
printf '%s\n' \
  '## Article 14: Client' '> banner' \
  '```' '~~~ inner tilde is content' '## Fake heading in backtick block' '```' \
  'tail-of-14-CANARY-B' \
  '## Article 15: Core' 'kept-body-B' > "$FIX"
OUT_B="$(load_constitution "$FIX" internal)"
not_contains "$OUT_B" "Fake heading in backtick block"; check "B: fake H2 in \`\`\` (w/ inner ~~~) not leaked" $?
not_contains "$OUT_B" "tail-of-14-CANARY-B"; check "B: article tail not leaked past nested syntax" $?
contains     "$OUT_B" "kept-body-B";         check "B: CORE body survives" $?

FOUNDRY_CLIENT_TIER_ARTICLES="$SAVED_ARTS"

echo ""
echo "constitution-tiering: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
