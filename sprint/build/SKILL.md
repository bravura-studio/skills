---
name: build
description: |
  Implementation phase. Takes a task from sprint-review and executes it with
  proper git discipline — branch creation, incremental commits, frequent pushes,
  and work preservation on blockers. Use after sprint-review produces a PRD/task
  breakdown, or when an agent picks up a Paperclip issue to implement.
version: 1.0.0
category: sprint
interactive: false
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Edit
  - Write
triggers:
  - "implement this"
  - "build this"
  - "start coding"
  - "execute the task"
  - "pick up this issue"
benefits-from:
  - sprint-review
feeds-into:
  - code-review
qmd:
  - collection: agent-knowledge
    query: "implementation patterns and development workflow"
    limit: 3
reads-learnings: true
writes-learnings: true
---

# Build

## Context

This is the implementation phase — where code gets written. Everything before this was planning (sprint-plan, roadmap, sprint-review). Everything after is verification (code-review, qa-check, ship-pr). This skill governs HOW agents execute implementation tasks with proper git discipline and work preservation.

**The cardinal rule: never lose work.** Every meaningful change gets committed. Every commit gets pushed. If you hit a blocker, push first, escalate second.

## Required Outputs (do not skip)

This skill produces exactly 2 outputs. Both must exist before reporting DONE.

1. **Feature branch** → pushed to origin with all implementation commits. Branch name: `{agent-name}/{feature-slug}` (e.g., `siza/f2-task3-lead-adapter`).
2. **Completion comment** → posted on the Paperclip issue with: what was built, which files changed, branch name, and any issues encountered.

## Steps

### Step 1: Setup workspace

Before writing any code, verify the workspace is ready.

```bash
# 1. Pull latest main
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b {agent-name}/{feature-slug}

# 3. Install dependencies (if package.json exists)
if [ -f package.json ]; then npm install; fi

# 4. Verify prerequisites from issue description
# Check for required files, env vars, tools mentioned in the task
```

**Prerequisite checklist** — read the issue description and verify:
- [ ] Required files exist (data files, config files, scripts referenced)
- [ ] Required env vars are set (check `.env` at project root)
- [ ] Required tools are installed (CLI tools, binaries)
- [ ] Required dependencies are installed (`node_modules/`, Go binaries, etc.)

If ANY prerequisite is missing: **STOP. Do not start coding.** Go to the Escalation section.

### Step 2: Implement

Work through the task subtasks in order. After completing each meaningful unit of work:

```bash
# Stage and commit
git add <changed-files>
git commit -m "{type}: {what changed and why}"

# Push to remote (preserves work)
git push -u origin $(git branch --show-current)
```

**Commit discipline:**
- Commit after each subtask or logical unit (not one giant commit at the end)
- Use conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`
- Each commit message describes WHAT changed and WHY
- Push after every commit — the remote branch is your safety net

**Implementation rules:**
- Follow the project's CLAUDE.md for code style, architecture, and conventions
- Read existing code before modifying — understand the patterns in use
- Don't add features beyond what the task specifies
- Don't refactor code outside the task scope
- Test your changes before committing (run the script, check the output, verify the build)

### Step 3: Verify

Before declaring done, verify your implementation:

```bash
# Build passes (if applicable)
npm run build  # or equivalent

# Your changes work as described in the task
# Run the scripts/commands specified in the acceptance criteria

# All new files are committed
git status  # should be clean

# Branch is pushed
git log --oneline origin/{branch}..HEAD  # should be empty
```

### Step 4: Handoff

```bash
# Final push (safety)
git push

# Report what was done
```

Post a comment on the Paperclip issue with:
- What was implemented (list of changes)
- Branch name
- Files changed (`git diff --stat main...HEAD`)
- Any issues encountered or decisions made
- Next step (typically: code-review or QA)

## Escalation

If you hit ANY blocker during setup or implementation:

1. **Push your current work first** — even if incomplete, push the branch so nothing is lost:
   ```bash
   git add -A
   git commit -m "wip: saving progress before escalation"
   git push -u origin $(git branch --show-current)
   ```

2. **Call the ferro-notify webhook:**
   ```bash
   curl -s -X POST https://n8n.andochoa.com/webhook/ferro-escalation \
     -H "Content-Type: application/json" \
     -d '{"message": "BRAA-XXX blocked: <specific reason>", "agent": "<your name>", "priority": "high"}'
   ```

3. **Then** set the issue status to blocked and add a comment explaining the blocker.

Never silently block. Never lose work. Push first, escalate second.

## Completion

Report status:
- **DONE** — Implementation complete, branch pushed, all acceptance criteria met. Suggest `code-review` as next step.
- **DONE_WITH_CONCERNS** — Implementation complete but with noted issues (edge cases, performance concerns, tech debt). List them.
- **BLOCKED** — Cannot proceed. Work pushed to branch, escalation sent, blocker documented.

## Learnings Capture

After completion, evaluate:
1. Did the setup phase catch all prerequisites? (If you hit a missing dep mid-build, that's a learning.)
2. Did the task description have enough context? (If you had to guess, note what was missing.)
3. Did you discover any patterns worth reusing? (New utility, clever approach, gotcha to avoid.)
