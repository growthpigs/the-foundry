#!/usr/bin/env bash
# foundry-dryrun.test.sh — smoke test for the ORCHESTRATOR itself (engine hardening).
# Until now CI only tested the constitution loader; the 47KB foundry.sh engine had
# zero execution coverage. This exercises the real planning path end-to-end:
# arg parsing → mode classification → stage-list build → command resolution →
# dry-run exit — in both a bare environment (must fail loudly, exit 1) and a
# stubbed one (must produce a full plan, exit 0).
#
# Hermetic: HOME is redirected to an empty temp dir so a developer's real
# ~/.claude/commands cannot make the bare case accidentally resolve.
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FOUNDRY="$REPO_ROOT/bin/foundry.sh"

PASS=0
FAIL=0
check() {
  local desc="$1" ; local ok="$2"
  if [ "$ok" = "0" ]; then echo "  ok  - $desc" ; PASS=$((PASS+1))
  else echo "  FAIL - $desc" ; FAIL=$((FAIL+1)); fi
}
contains()     { printf '%s' "$1" | grep -qF -- "$2"; }
not_contains() { ! printf '%s' "$1" | grep -qF -- "$2"; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/home" "$WORK/proj"
git -C "$WORK/proj" init -q .

run_dry() { # $1 = project dir; prints output, returns foundry's real exit code
  ( cd "$1" && HOME="$WORK/home" CLAUDECODE="" bash "$FOUNDRY" --mode GREENFIELD --dry-run "#1" 2>&1 )
}

echo "# bare environment: plan builds, missing commands fail LOUDLY"
set +e
OUT_BARE="$(run_dry "$WORK/proj")"
RC_BARE=$?
set -e 2>/dev/null || true
[ "$RC_BARE" -eq 1 ]; check "bare dry-run exits 1 (missing commands are an error, not a shrug)" $?
contains "$OUT_BARE" "The Foundry v";                 check "banner says The Foundry" $?
not_contains "$OUT_BARE" "Dark Foundry";              check "no Dark Foundry fossil in output" $?
contains "$OUT_BARE" "Mode: GREENFIELD";              check "classification ran (forced mode)" $?
contains "$OUT_BARE" "[PLAN]";                        check "stage plan was built" $?
contains "$OUT_BARE" "[AUTH] Skipped for dry-run";    check "dry-run skips auth preflight" $?
contains "$OUT_BARE" "ERROR: Required command files are missing"; check "missing commands reported" $?

echo "# stubbed commands: full plan resolves, dry-run exits 0, no side effects"
CMDS="$WORK/proj/.claude/commands"
mkdir -p "$CMDS"
for c in issue user-stories explore issue-review red-team red-team-quick red-team-spec \
         red-team-compliance compliance code validate validate-fast e2e pr pr-review \
         pr-restricted autoresearch follow-up fsd; do
  printf '# stub command for smoke test\nDo the %s stage for $ARGUMENTS.\n' "$c" > "$CMDS/$c.md"
done
set +e
OUT_STUB="$(run_dry "$WORK/proj")"
RC_STUB=$?
set -e 2>/dev/null || true
[ "$RC_STUB" -eq 0 ]; check "stubbed dry-run exits 0" $?
contains "$OUT_STUB" "[DRY RUN] No changes made.";    check "clean dry-run completion line" $?
not_contains "$OUT_STUB" "NOT FOUND";                 check "every stage command resolved" $?
not_contains "$OUT_STUB" "ERROR";                     check "no errors in stubbed plan" $?
[ ! -d "$WORK/proj/.foundry" ]; check "dry-run created no .foundry state (no side effects)" $?

echo ""
echo "foundry-dryrun: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
