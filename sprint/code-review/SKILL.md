---
name: code-review
description: |
  Review phase. Pre-merge code audit — reads the diff, checks for bugs, security
  issues, style violations, and missing tests. Auto-fixes obvious issues, flags
  judgment calls. Use when someone says "review my code", "check my changes",
  "pre-merge check", or before any PR creation.
version: 1.0.0
category: sprint
interactive: false
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Edit
triggers:
  - "review my code"
  - "check my changes"
  - "pre-merge check"
  - "look at the diff"
  - "code review"
benefits-from:
  - sprint-review
feeds-into:
  - qa-check
qmd:
  - collection: agent-knowledge
    query: "code review patterns and common mistakes"
    limit: 3
reads-learnings: true
writes-learnings: true
---

# Code Review

## Context

This runs after implementation, before QA and PR creation. The goal is to catch bugs, security issues, and style problems while the code is fresh. Auto-fix what's obvious; flag what needs human judgment.

Not a nitpick pass. Focus on things that would break in production or confuse the next reader.

## Prerequisites

- Code changes exist (staged, unstaged, or committed on a branch)
- Ideally a locked plan from `sprint-review` to review against (check `skills/_output/sprint-review-*.md`)

## Steps

### Step 1: Understand the Scope

Determine what changed:
```bash
# If on a feature branch
git diff main...HEAD --stat
git diff main...HEAD

# If uncommitted changes
git diff --stat
git diff
```

If a sprint-review doc exists, read it to understand what the code SHOULD be doing.

### Step 2: Review for Correctness

For each changed file, check:

- **Logic errors:** Off-by-one, wrong conditionals, missing null checks at system boundaries
- **Data flow:** Does data flow correctly between functions/components? Are types consistent?
- **Error handling:** Are external calls (APIs, DB, file I/O) handled? Are errors propagated correctly?
- **Concurrency:** Race conditions, deadlocks, shared mutable state?
- **Edge cases:** Does the code handle the edge cases listed in sprint-review?

### Step 3: Review for Security

Check OWASP Top 10 for the relevant stack:

- **Injection:** SQL, command, XSS — is user input sanitized?
- **Auth:** Are endpoints protected? Are tokens validated?
- **Secrets:** Are secrets hardcoded? Are .env files committed?
- **Dependencies:** Any known-vulnerable packages? (`npm audit`, `pip audit`)

### Step 4: Review for Quality

- **Dead code:** Anything added but never called?
- **Duplication:** Same logic in multiple places? (Only flag if 3+ occurrences)
- **Naming:** Are names clear enough that comments aren't needed?
- **Tests:** Are new code paths tested? Are edge cases covered?
- **Performance:** Any obvious N+1 queries, unbounded loops, or missing indexes?

### Step 5: Auto-Fix Obvious Issues

Fix directly (no need to ask):
- Typos in variable names or strings
- Missing semicolons / formatting issues
- Unused imports
- Console.log / debug statements left in

### Step 6: Report Findings

Write a structured review. Categorize each finding:

| Severity | Meaning | Action |
|----------|---------|--------|
| **MUST FIX** | Will break in production or is a security risk | Fix before proceeding |
| **SHOULD FIX** | Code smell or missing test, low risk | Fix if time allows |
| **NOTE** | Style preference or suggestion | Informational only |

**Output format:**

```markdown
## Code Review: {description}

**Date:** {YYYY-MM-DD}
**Files reviewed:** {count}
**Against plan:** {sprint-review doc path or "no plan"}

### Auto-Fixed
- {what was fixed and why}

### Findings

#### MUST FIX
1. **{file}:{line}** — {description}
   Why: {impact if not fixed}

#### SHOULD FIX
1. **{file}:{line}** — {description}

#### NOTES
1. {observation}

### Verdict: {PASS | PASS_WITH_FIXES | FAIL}
```

**Verdict rules:**
- **PASS:** No MUST FIX items. Ship it.
- **PASS_WITH_FIXES:** MUST FIX items found and auto-fixed. Verify the fixes.
- **FAIL:** MUST FIX items that require human judgment. List what needs to change.

## Completion

Report status:
- **DONE** — Review complete, verdict rendered. State the verdict and any auto-fixes applied. Suggest `qa-check` next.
- **DONE_WITH_CONCERNS** — Review complete but uncertain about some findings. List the uncertain items.
- **BLOCKED** — Can't review (e.g., no changes found, merge conflicts prevent diff).
- **NEEDS_CONTEXT** — Missing context to evaluate correctness (e.g., no sprint-review doc and unclear intent).

## Learnings Capture

After completion, evaluate:
1. Did we find a bug pattern specific to this project? (e.g., "this codebase always forgets to handle the empty array case")
2. Did we auto-fix something that keeps recurring? (Suggest a lint rule instead.)
3. Did the review catch something the tests missed? (Note the gap for qa-check.)
