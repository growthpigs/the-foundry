# The Foundry — Anti-Regression Baseline Capture

**Purpose:** Snapshot the system state BEFORE making changes so we can verify AFTER that nothing broke.

## When It Runs

| Mode | Runs? | Rigor |
|------|-------|-------|
| FULL | ✅ | Standard |
| FIX | ✅ | Standard |
| HOTFIX | ⏭ Skip | — (speed over safety) |
| REFACTOR | ✅✅ | Critical (comprehensive) |
| SECURE | ✅ | Standard |

## What Gets Captured

### Standard Baseline (FULL, FIX, SECURE)

```bash
capture_baseline() {
  local project_dir="$1"
  local baseline_file="$2"

  cd "$project_dir"

  echo "## Anti-Regression Baseline" > "$baseline_file"
  echo "Captured: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$baseline_file"
  echo "" >> "$baseline_file"

  # 1. Test count
  echo "### Test Count" >> "$baseline_file"
  local test_count
  test_count=$(npx jest --listTests 2>/dev/null | wc -l || echo "0")
  echo "Total test files: $test_count" >> "$baseline_file"
  echo "" >> "$baseline_file"

  # 2. Test results summary
  echo "### Test Results" >> "$baseline_file"
  npx jest --passWithNoTests --no-coverage 2>&1 | tail -5 >> "$baseline_file"
  echo "" >> "$baseline_file"

  # 3. TypeScript compilation
  echo "### TypeScript" >> "$baseline_file"
  npx tsc --noEmit 2>&1 | tail -3 >> "$baseline_file"
  echo "" >> "$baseline_file"

  # 4. Build status
  echo "### Build" >> "$baseline_file"
  npm run build 2>&1 | tail -3 >> "$baseline_file"
  echo "" >> "$baseline_file"
}
```

### Critical Baseline (REFACTOR Mode — Additional Captures)

Refactoring must preserve behavior exactly. Additional captures:

```bash
capture_critical_baseline() {
  local project_dir="$1"
  local baseline_file="$2"

  # Run standard baseline first
  capture_baseline "$project_dir" "$baseline_file"

  cd "$project_dir"

  # 5. Test names (detect removed/renamed tests)
  echo "### Test Names" >> "$baseline_file"
  npx jest --listTests 2>/dev/null | sort >> "$baseline_file"
  echo "" >> "$baseline_file"

  # 6. API response shapes (if health endpoint exists)
  echo "### API Health Response" >> "$baseline_file"
  if [ -n "$HEALTH_URL" ]; then
    curl -s "$HEALTH_URL" | python3 -c "
import sys, json
data = json.load(sys.stdin)
def shape(obj, prefix=''):
    if isinstance(obj, dict):
        for k in sorted(obj.keys()):
            shape(obj[k], f'{prefix}.{k}')
    elif isinstance(obj, list):
        print(f'{prefix}[]: {type(obj[0]).__name__ if obj else \"empty\"}')
    else:
        print(f'{prefix}: {type(obj).__name__}')
shape(data)
" >> "$baseline_file" 2>/dev/null
  fi
  echo "" >> "$baseline_file"

  # 7. Key file checksums (detect unintended changes)
  echo "### File Checksums (Key Files)" >> "$baseline_file"
  for f in shared/schema.ts server/routes.ts client/src/App.tsx netlify.toml; do
    if [ -f "$f" ]; then
      echo "$(md5 -q "$f" 2>/dev/null || md5sum "$f" | cut -d' ' -f1) $f" >> "$baseline_file"
    fi
  done
  echo "" >> "$baseline_file"
}
```

## Baseline File Location

```
.foundry/
├── baseline-{issue-number}.md    ← Captured BEFORE changes
├── postcheck-{issue-number}.md   ← Captured AFTER changes
└── comparison-{issue-number}.md  ← Diff report
```

This directory is gitignored. Baselines are ephemeral — they exist only for the duration of the pipeline run.

## Comparison (Post-Code)

After the Code stage completes, run the same captures and compare:

```bash
compare_baseline() {
  local baseline="$1"
  local postcheck="$2"
  local comparison="$3"

  echo "## Anti-Regression Comparison" > "$comparison"

  # Test count delta
  local before_tests after_tests
  before_tests=$(grep "Total test files:" "$baseline" | grep -o '[0-9]*')
  after_tests=$(grep "Total test files:" "$postcheck" | grep -o '[0-9]*')

  if [ "$before_tests" -gt "$after_tests" ]; then
    echo "❌ REGRESSION: Test count decreased ($before_tests → $after_tests)" >> "$comparison"
  elif [ "$before_tests" -lt "$after_tests" ]; then
    echo "✅ Test count increased ($before_tests → $after_tests)" >> "$comparison"
  else
    echo "✅ Test count unchanged ($before_tests)" >> "$comparison"
  fi

  # Test pass/fail delta
  # TypeScript delta
  # Build delta
  # (For REFACTOR: test names delta, API shape delta, checksum delta)
}
```

## Failure Modes

| Finding | Severity | Action |
|---------|----------|--------|
| Test count decreased | ❌ BLOCK | Do not proceed to PR. Fix first. |
| Tests that passed now fail | ❌ BLOCK | Regression introduced. Fix first. |
| TypeScript errors increased | ❌ BLOCK | New type errors. Fix first. |
| Build broken | ❌ BLOCK | Cannot deploy. Fix first. |
| API response shape changed (REFACTOR) | ⚠️ WARNING | Behavior change in refactor. Likely wrong. |
| File checksum changed for non-target file (REFACTOR) | ⚠️ WARNING | Unintended side effect. Review. |
| Test count increased | ✅ GOOD | More coverage. Proceed. |

## Integration with progress.txt

Anti-regression findings are appended to progress.txt:

```
[ANTI-REGRESSION] Baseline: 142 tests passing, 0 TS errors
[ANTI-REGRESSION] Post-code: 148 tests passing, 0 TS errors (+6 tests)
[ANTI-REGRESSION] ✅ No regressions detected
```

Or on failure:
```
[ANTI-REGRESSION] ❌ REGRESSION: 3 tests now failing
[ANTI-REGRESSION] Failing: swotRadarPositioning.test.ts, chatFormatting.test.ts, adminAuth.test.ts
[ANTI-REGRESSION] Pipeline BLOCKED until regressions fixed
```
