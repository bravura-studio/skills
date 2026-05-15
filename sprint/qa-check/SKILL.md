---
name: qa-check
description: |
  Test phase. Verification checklist that confirms the implementation matches
  the plan and works correctly. Runs tests, checks acceptance criteria, verifies
  edge cases. Use when someone says "does this work", "test it", "verify",
  "QA check", or after code-review passes.
version: 1.0.0
category: sprint
interactive: false
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
triggers:
  - "does this work"
  - "test it"
  - "verify"
  - "QA check"
  - "is it ready"
benefits-from:
  - code-review
feeds-into:
  - ship-pr
qmd: []
reads-learnings: true
writes-learnings: true
---

# QA Check

## Context

This is the quality gate before shipping. Code review checked the code; QA check confirms the behavior. The distinction matters — code can look correct and still not work.

Three tiers of thoroughness:
- **Quick:** Critical + high priority checks only. For small changes.
- **Standard:** + medium priority. Default tier.
- **Exhaustive:** + cosmetic + edge cases. For releases or high-risk changes.

Default to **Standard** unless the change is trivial (Quick) or high-risk (Exhaustive).

## Required Outputs (do not skip)

This skill produces exactly 1 output. It must be delivered before reporting DONE.

1. **QA verdict** → reported inline (SHIP, FIX_AND_RECHECK, or BLOCK) with structured markdown checklist. No file written — the verdict is communicated to the user/agent directly.

## Prerequisites

- Code changes implemented and code-review completed (or explicitly skipped)
- If a sprint-review doc exists, use its test strategy and edge cases as the checklist

## Steps

### Step 1: Determine Tier and Load Context

Read the sprint-review doc if one exists:
```bash
ls -t skills/_output/sprint-review-*.md 2>/dev/null | head -1
```

From it, extract:
- Must-pass criteria
- Should-pass criteria
- Edge cases list
- Verification method

If no sprint-review doc exists, derive criteria from the code changes themselves.

### Step 2: Run Existing Tests

Execute the project's test suite:
```bash
# Detect and run the appropriate test command
# Node: npm test / yarn test / bun test
# Python: pytest / python -m pytest
# Go: go test ./...
# Other: check package.json scripts, Makefile, etc.
```

Record: pass count, fail count, coverage if available.

### Step 3: Verify Acceptance Criteria

For each must-pass criterion from the sprint-review:
1. Describe how to verify it
2. Execute the verification (run command, read file, check output)
3. Record: PASS or FAIL with evidence

For each should-pass criterion:
1. Same process, but failures don't block shipping

### Step 4: Check Edge Cases

For each edge case from the sprint-review (or derived from the code):
1. Describe the scenario
2. Attempt to trigger it
3. Record: HANDLED, NOT_HANDLED, or NOT_TESTABLE

### Step 5: Smoke Test

If the project has a running instance or build step:
1. Build the project (verify no build errors)
2. Start it (verify no startup crashes)
3. Exercise the happy path manually (1-2 scenarios)

### Step 6: Report Results

**Output format:**

```markdown
## QA Check: {description}

**Date:** {YYYY-MM-DD}
**Tier:** {Quick | Standard | Exhaustive}
**Against plan:** {sprint-review doc path or "no plan"}

### Test Suite
- Passed: {n}
- Failed: {n}
- Skipped: {n}
- Coverage: {n}% (if available)

### Acceptance Criteria
| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | {criterion} | PASS/FAIL | {what was checked} |

### Edge Cases
| # | Scenario | Status | Notes |
|---|----------|--------|-------|
| 1 | {scenario} | HANDLED/NOT_HANDLED/NOT_TESTABLE | {detail} |

### Smoke Test
- Build: PASS/FAIL
- Startup: PASS/FAIL
- Happy path: PASS/FAIL

### Verdict: {SHIP | FIX_AND_RECHECK | BLOCK}
```

**Verdict rules:**
- **SHIP:** All must-pass criteria pass. Test suite green. No critical edge case failures.
- **FIX_AND_RECHECK:** Fixable failures found. List what needs fixing. Re-run qa-check after.
- **BLOCK:** Fundamental issue that requires rethinking the approach. Escalate.

## Completion

Report status:
- **DONE** — QA complete, verdict rendered. State the verdict. If SHIP, suggest `ship-pr` next.
- **DONE_WITH_CONCERNS** — Tests pass but something feels off. List the concerns.
- **BLOCKED** — Can't test (e.g., build fails, missing dependencies, environment not set up).
- **NEEDS_CONTEXT** — No acceptance criteria and can't derive them from the code. Ask what "working" means.

## Learnings Capture

After completion, evaluate:
1. Did we find a bug that code-review missed? (Note the gap — should we add a check?)
2. Did an edge case fail that we expected to pass? (Capture the pattern.)
3. Was the test suite insufficient? (Note what's missing for the retro.)
4. Did the smoke test reveal something the unit tests didn't? (Capture the scenario.)
