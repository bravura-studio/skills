---
name: ship-pr
description: |
  Ship phase. Creates a pull request with proper formatting, links to design doc
  and review artifacts, and ensures the branch is clean. Use when someone says
  "ship it", "create a PR", "push this", or after qa-check passes.
version: 1.0.0
category: sprint
interactive: false
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
triggers:
  - "ship it"
  - "create a PR"
  - "push this"
  - "open a PR"
  - "ready to merge"
benefits-from:
  - qa-check
feeds-into:
  - retro
qmd: []
reads-learnings: true
writes-learnings: true
---

# Ship PR

## Context

The final mechanical step before human review. Everything has been thought through (sprint-plan), planned (sprint-review), built, reviewed (code-review), and verified (qa-check). This skill packages the work into a clean PR.

**Important constraints (from CLAUDE.md):**
- Never push to `main`. Always push to `ferro/{kind}-{slug}-{date}` branches.
- Never use `git push --no-verify`. The pre-push hook is a safety gate.
- Never skip hooks or bypass signing.

## Prerequisites

- Code changes committed on a feature branch
- qa-check verdict: SHIP (or explicit founder override)
- Branch naming: `ferro/{kind}-{slug}-{YYYY-MM-DD}`

## Steps

### Step 1: Verify Branch State

```bash
# Confirm we're not on main
git branch --show-current

# Check for uncommitted changes
git status

# Verify branch is ahead of main
git log --oneline main..HEAD
```

If on `main`, STOP. Create a branch first.
If uncommitted changes exist, commit them with a descriptive message.

### Step 2: Gather Artifacts

Collect references to link in the PR:
- Design doc: `skills/_output/sprint-plan-*.md` (most recent for this work)
- Sprint review: `skills/_output/sprint-review-*.md`
- Code review verdict
- QA check verdict

### Step 3: Push Branch

```bash
git push -u origin $(git branch --show-current)
```

If push fails, diagnose (don't force-push). Common issues:
- Pre-push hook rejection → read the error, fix the cause
- Remote ahead → fetch and rebase (if safe) or ask the user

### Step 4: Create PR

Use `gh pr create` with proper formatting:

```bash
gh pr create --title "{concise title under 70 chars}" --body "$(cat <<'EOF'
## Summary
{1-3 bullet points — what changed and why}

## Design
{Link to design doc if exists, or brief description}

## Test Plan
{What was verified — from qa-check results}

## Artifacts
- Design doc: `{path}`
- Sprint review: `{path}`
- Code review: {verdict}
- QA check: {verdict}

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Title rules:**
- Under 70 characters
- Start with category: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- Describe the WHAT, not the HOW

### Step 5: Report

State:
- PR URL
- Branch name
- What's included (file count, line count)
- Any artifacts linked

## Completion

Report status:
- **DONE** — PR created. State the URL. Suggest `retro` after the PR is merged.
- **DONE_WITH_CONCERNS** — PR created but with notes (e.g., force-push was needed, some tests flaky).
- **BLOCKED** — Can't push or create PR (auth issue, hook rejection, merge conflict).
- **NEEDS_CONTEXT** — Unclear what branch name or PR title to use. Ask.

## Learnings Capture

After completion, evaluate:
1. Did the PR process hit any friction? (e.g., hook rejections, naming issues)
2. Was the PR description sufficient? (If reviewer asks obvious questions, the description was lacking.)
3. Did we link all relevant artifacts? (If not, note what was missing.)
