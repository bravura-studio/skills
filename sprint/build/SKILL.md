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

## Handoff Status Rules (enforced — not optional)

These rules govern ALL issue status changes made by this skill. Violations cause agents to go idle and break the chain.

- **Agent-to-agent handoffs: always `status: "todo"`.** Never `in_review`. Agents filter for `todo,in_progress,blocked` — they SKIP `in_review` issues. Setting `in_review` on a QA handoff = Távora never wakes up.
- **Next task after QA: always `status: "blocked"` with `blockedByIssueIds`.** Paperclip enforces the gate — the issue stays blocked until QA resolves it. Never use self-wake.
- **`in_review` is for human/founder review only.** Never between agents.
- **Reassignment is the wake signal.** Always PATCH `assigneeAgentId` before posting a comment. Comments alone don't wake agents.

## Required Outputs (do not skip)

This skill produces these outputs. All must exist before reporting DONE.

1. **Feature branch** → pushed to origin with all implementation commits. Branch name: `{agent-name}/{feature-slug}` (e.g., `siza/f2-task3-lead-adapter`).
2. **Task file updated** → mark completed parent task and subtasks `[x]` in `product/tasks/tasks-prd-{N}-{name}.md`. Update Status from "Planning" to "In Progress" (or "Complete" if all tasks done).
3. **Completion comment** → posted on the Paperclip issue with: what was built, which files changed, branch name, which parent task was completed, and how many tasks remain.
4. **QA issue created** → assigned to the project's QA agent with `status: "todo"` (NEVER `in_review`).

## Steps

### Step 1: Setup workspace

Before writing any code, verify the workspace is ready.

```bash
# 1. Pull latest main
git checkout main
git pull origin main

# 2. Set git identity (required for Vercel deploys — must be a team member)
git config user.name "Andre Ochoa"
git config user.email "a.ochoa.g21@gmail.com"

# 3. Create feature branch
git checkout -b {agent-name}/{feature-slug}

# 4. Install dependencies (if package.json exists)
if [ -f package.json ]; then npm install; fi

# 5. Verify prerequisites from issue description
# Check for required files, env vars, tools mentioned in the task
```

**Prerequisite checklist** — read the issue description and verify:
- [ ] Required files exist (data files, config files, scripts referenced)
- [ ] Required env vars are set (check `.env` at project root)
- [ ] Required tools are installed (CLI tools, binaries)
- [ ] Required dependencies are installed (`node_modules/`, Go binaries, etc.)

If ANY prerequisite is missing: **STOP. Do not start coding.** Go to the Escalation section.

### Step 1b: Load Task File

If the project has a task file (`product/tasks/tasks-prd-{N}-{name}.md`), read it to determine WHAT to implement.

```bash
# Find task files
ls product/tasks/tasks-*.md 2>/dev/null

# Read the active task file
cat product/tasks/tasks-prd-{N}-{name}.md
```

**Task file protocol:**
1. Read the Parent Tasks checklist at the top of the file
2. Find the first parent task marked `[ ]` (not yet started)
3. Read that parent task's section: PRD Context, Subtasks, Validation, Dependencies
4. Check Dependencies → Requires: ensure all prerequisite tasks are `[x]`
5. This parent task is your scope for THIS heartbeat — do NOT work on other tasks

If no task file exists, fall back to the Paperclip issue description as the task spec.

If ALL parent tasks are `[x]`, the task file is complete. Update Status to "Complete", run retro, and exit.

### Step 2: Implement

Work through the task subtasks in order (from the task file's parent task section). After completing each meaningful unit of work:

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

### Step 4: Update Task File

If working from a task file, mark the completed parent task and its subtasks as done:

```bash
# Mark subtasks [x] in the task file
# Mark the parent task [x] in the Parent Tasks checklist
# Update Status: "Planning" → "In Progress" (or "Complete" if all tasks done)
```

Commit the task file update:
```bash
git add product/tasks/tasks-*.md
git commit -m "chore: mark task {N} complete in task file"
git push
```

### Step 5: Handoff

```bash
# Final push (safety)
git push

# Report what was done
```

Post a comment on the Paperclip issue with:
- What was implemented (list of changes)
- Branch name
- Files changed (`git diff --stat main...HEAD`)
- Which parent task was completed (e.g., "Task 2 of 4")
- How many tasks remain in the task file
- Any issues encountered or decisions made

**Create QA issue for the completed parent task:**

Use curl with the REST API to create the QA issue (do NOT rely on MCP tools alone — they may silently drop assigneeAgentId):

```bash
curl -sS -X POST "$PAPERCLIP_API_URL/api/companies/$PAPERCLIP_COMPANY_ID/issues" \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-Paperclip-Run-Id: $PAPERCLIP_RUN_ID" \
  -d '{
    "title": "QA: Task {N} — {description}",
    "description": "## Acceptance Criteria to verify\n{ACs from task file Validation section}\n\n## Branch\n{branch-name}\n\n## Task file\nproduct/tasks/tasks-prd-{N}-{name}.md — Task {N}",
    "assigneeAgentId": "{QA-agent-id}",
    "projectId": "{project-id}",
    "status": "todo"
  }'
```

The QA agent ID and project ID should be in your workspace CLAUDE.md or .env.paperclip.

### Step 6: Chain Next Task (blocked by QA)

**Do NOT self-wake for the next task.** Self-wake races ahead of QA — the agent picks up the next task before QA passes on the current one. Instead, use Paperclip's `blockedByIssueIds` to enforce sequencing.

If more parent tasks remain in the task file, create the next task issue **blocked by the QA issue** you just created in Step 5:

```bash
# Check if more tasks remain
if grep -qE '^\- \[ \] [0-9]+\.' product/tasks/tasks-*.md 2>/dev/null; then
  # Get the next parent task number and description from the task file
  NEXT_TASK=$(grep -E '^\- \[ \] [0-9]+\.' product/tasks/tasks-*.md | head -1)

  # Create next task issue, BLOCKED by the QA issue
  curl -sS -X POST "$PAPERCLIP_API_URL/api/companies/$PAPERCLIP_COMPANY_ID/issues" \
    -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
    -H "Content-Type: application/json" \
    -H "X-Paperclip-Run-Id: $PAPERCLIP_RUN_ID" \
    -d '{
      "title": "Task {N+1}: {next task description}",
      "description": "Read task file: product/tasks/tasks-prd-{N}-{name}.md — Task {N+1}\nRun /build to execute.",
      "assigneeAgentId": "'$PAPERCLIP_AGENT_ID'",
      "projectId": "{project-id}",
      "status": "blocked",
      "blockedByIssueIds": ["{QA-issue-UUID-from-step-5}"]
    }'
else
  echo "All tasks complete — task file done. Run /retro."
fi
```

**Why blockedByIssueIds instead of self-wake:**
- `blockedByIssueIds` is enforced by Paperclip — the issue stays blocked until QA marks the blocker done
- Paperclip auto-wakes the agent when all blockers resolve (`issue_blockers_resolved` event)
- No race condition: the agent literally cannot start the next task until QA passes
- If QA fails, the blocker stays open → next task stays blocked → agent picks up the fix issue instead

**When all tasks are done:** Don't create another task issue. Instead, create a retro issue or let the agent exit and report "task file complete."

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
   curl -s -X POST https://n8n.andochoa.com/webhook/ferro-notify \
     -H "Content-Type: application/json" \
     -d '{"text": "🚨 BRAA-XXX blocked: <specific reason> (agent: <your name>)", "url": "https://paperclip.andochoa.com"}'
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
