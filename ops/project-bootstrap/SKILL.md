---
name: project-bootstrap
description: |
  Scaffolds a new BUILD.FUN.FREE project from scratch. Creates charter, agent
  personas, project-local commands, Paperclip registration, learnings file, qmd
  vault wiring, and repo setup. Use when starting a new project, when someone says
  "new project", "start a project", "bootstrap", or "let's kick off X".
version: 1.0.0
category: ops
interactive: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
  - Edit
  - WebSearch
  - AskUserQuestion
triggers:
  - "new project"
  - "start a project"
  - "bootstrap"
  - "kick off"
  - "set up a new project"
  - "project-bootstrap"
benefits-from: []
feeds-into:
  - sprint-plan
qmd:
  - collection: agent-knowledge
    query: "project setup patterns agent team configuration"
    limit: 3
reads-learnings: true
writes-learnings: true
---

# Project Bootstrap

## Context

Every BFF project needs the same infrastructure to work with our agent system. When we set up Tmaker, Scripta, and LocalKit, each time we assembled these pieces manually — charter, agents, commands, Paperclip, vault. This skill codifies that into a repeatable process.

The output is a project ready for Gate 0 — agents wired, commands installed, knowledge connected, founder can start ideating immediately.

## Prerequisites

- Access to VPS1 (Paperclip, qmd, container)
- Founder available for the interview (Steps 1-2 are interactive)
- `templates/agent-team-kickstart.md` for Paperclip registration reference

## Steps

### Step 1: Project Interview

Ask these questions to understand the project. Adapt based on answers — skip what's obvious, dig deeper where it's vague.

**B1: What is it?**
"What's the project? One sentence — what does it do and for whom?"

**B2: What type?**
"Is this a tool (like Tmaker), a content site (like Scripta), a service (like Striva), or something else? This determines the default agent team and command set."

| Type | Default agents | Default workflow |
|------|---------------|-----------------|
| **Tool** | CEO + Coder + QA | Sprint chain + launchkit |
| **Content** | Coder + QA | Content chain + sprint chain |
| **Service** | CEO + Coder + QA | Sprint chain + custom |
| **Experimental** | Coder + QA | Sprint chain (lean) |

**B3: Repo situation?**
"Does a repo already exist? If yes, where? If no, should we create one? Public or private? Under bravura-studio or another org?"

**B4: Stack?**
"What's the tech stack? Next.js from launchkit? Something else? Any external services or APIs?"

**B5: Priority?**
"Where does this sit in the portfolio? Active focus, parallel experiment, or future placeholder?"

**B6: Source material?**
"Is there existing research, bookmarks, or documents to ingest into a qmd vault? A GitHub stars list? Chrome bookmarks export?"

> **CHECKPOINT:** Summarize the project profile. Ask: "Is this right? Anything to adjust?"

### Step 2: Name the Agents

BFF agents are named after Portuguese cultural figures. Propose names based on the project's character.

**Naming conventions:**
- **Coder agents:** Named after architects, engineers, or builders (Siza, Camões, Rui)
- **QA agents:** Named after critics, poets, or detail-oriented figures (Florbela, Távora, Cruz)
- **CEO agents:** Named after strategists or explorers (Vasco)

Propose 2-3 names for each role. Let the founder pick.

> **CHECKPOINT:** "Here are my name suggestions. Which ones do you like?"

### Step 3: Create the Charter

Write `projects/{project-name}/CHARTER.md` based on the interview answers:

```markdown
# {Project Name} — Project Charter

> Designed collaboratively by {Founder} + Portfolio CEO.

## Mission
{B1 answer — expanded to 2-3 sentences}

## Current State
- **Site:** {URL or "not yet"}
- **Stack:** {B4 answer}
- **Repo:** {B3 answer}
- **Priority:** {B5 answer}

## Agent Team
{From Step 2 — names, roles, adapters}

## Success Metrics
{Propose 4-5 measurable metrics based on project type}

## Escalation Protocol (ALL agents)
When you hit ANY blocker — missing credentials, auth errors, build failures, missing files, dependency issues — you MUST:
1. **Escalate BEFORE setting status to blocked.** Silent blocks waste days.
2. Call the ferro-notify webhook:
   ```bash
   curl -s -X POST https://n8n.andochoa.com/webhook/ferro-escalation \
     -H "Content-Type: application/json" \
     -d '{"message": "BRAA-XXX blocked: <specific reason>", "agent": "<your name>", "priority": "high"}'
   ```
3. THEN set the issue status to blocked and add a comment explaining the blocker.
Never silently block. If the webhook fails, add "ESCALATION FAILED" to the issue comment.
```

### Step 4: Create Agent Personas

For each agent, create `projects/{project-name}/agents/{role}-persona.md`:

```markdown
# {Agent Name} — {Project} {Role}

> Agent config card. Full operational prompt lives in Paperclip.
> Named after {cultural figure} — {why this name fits}.

## Agent Configuration

| Field | Value |
|-------|-------|
| **Name** | {name} |
| **Paperclip ID** | `pending registration` |
| **Company** | Bravura Studio |
| **Role** | `{engineer|qa}` |
| **Adapter** | `claude_local` |
| **Default Model** | `claude-sonnet-4-6` |
| **Reports to** | Ferro (Portfolio CEO) |
| **Timeout** | 3600s |

## Model Selection Rules

| Tier | Model | When |
|------|-------|------|
| **Deep** | `claude-opus-4-6` | Architecture decisions, complex multi-file refactors |
| **Work** | `claude-sonnet-4-6` | Feature implementation, standard builds (DEFAULT) |
| **Fast** | `claude-haiku-4-5` | Bug fixes, small changes, status updates |

## Knowledge Architecture
- **qmd vault:** `{project-name}` ({doc count} docs)
- **CLAUDE.md:** project repo rules (HOT layer)

## Skills (AD-036)
Skills at `/paperclip/.claude/skills/`. Default workflow:
{sprint chain for coders, qa-check for QA, content chain for content projects}

## Key Operational Rules
- Never marks issues "done" — job ends at `in_review` for QA
- Escalates via `ferro-notify` webhook on any blocker
- Bases PRs on main only, never stacks branches

## Cross-references
- {Project} charter: `projects/{project-name}/CHARTER.md`
- Operations playbook: `references/agent-operations-playbook.md`
- Kickstart template: `templates/agent-team-kickstart.md`
- Skills standard: `references/skills-standard.md`
```

### Step 5: Set Up Project-Local Commands

Create `.claude/commands/` in the project repo with the ai-dev-tasks command set.

**For tool/service projects** (launchkit-based):
If scaffolded from launchkit, commands come pre-installed. Verify they exist:
```bash
ls {repo}/.claude/commands/
# Expected: create-prd.md, generate-tasks.md, process-tasks.md, review.md, workflows/compound.md
```

**For non-launchkit projects** (content sites, experimental):
Copy and adapt from an existing project:
```bash
mkdir -p {repo}/.claude/commands/workflows
# Copy from Scripta (most adaptable baseline)
cp /opt/bff/scripta/repos/.claude/commands/create-prd.md {repo}/.claude/commands/
cp /opt/bff/scripta/repos/.claude/commands/generate-tasks.md {repo}/.claude/commands/
cp /opt/bff/scripta/repos/.claude/commands/process-tasks.md {repo}/.claude/commands/
cp /opt/bff/scripta/repos/.claude/commands/review.md {repo}/.claude/commands/
cp /opt/bff/scripta/repos/.claude/commands/resolve-todos.md {repo}/.claude/commands/
cp -r /opt/bff/scripta/repos/.claude/commands/workflows/ {repo}/.claude/commands/workflows/
```

Then tailor: update project references, stack-specific rules, and directory paths.

### Step 6: Bootstrap Learnings File

Create the project's learnings file:

```bash
# In build-fun-free
touch skills/_learnings/{project-name}.jsonl
```

If the project has a known context (similar to an existing project), seed with relevant learnings:
```bash
# Example: new tool project gets tmaker learnings as starting point
grep -E '"type":"technical"' skills/_learnings/tmaker.jsonl >> skills/_learnings/{project-name}.jsonl
```

### Step 7: Wire qmd Vault

If the project has source material to ingest:

```bash
# Create vault directory
mkdir -p /knowledge/vault-{project-name}

# If source material exists, copy it
cp -r {source-material}/*.md /knowledge/vault-{project-name}/

# Register collection with qmd
qmd collection add {project-name} /knowledge/vault-{project-name} --pattern "**/*.md"

# Add context description
qmd context add {project-name} / "{One-paragraph description for search relevance}"

# Index
qmd update
```

If no source material yet, create the vault directory and register it — documents can be added later.

### Step 8: Register in Paperclip

Follow `templates/agent-team-kickstart.md` for the full API call sequence:

1. Create Paperclip project under Bravura Studio company
2. Register each agent with persona, adapter, model, timeout
3. Store secrets (GITHUB_TOKEN binding)
4. Create agent API keys
5. Smoke test each agent's heartbeat

**Important:** Use `status: "todo"` for test issues (not "backlog" — backlog is silently dropped).

Record the Paperclip IDs back into the agent persona files.

### Step 9: Update Portfolio Tracker

Add the project to `architecture/build-sequence.md`:

```markdown
| **{Project}** | [`projects/{name}/ROADMAP.md`](../projects/{name}/ROADMAP.md) | [ ] Charter written, agents registered, not yet started | {priority} |
```

### Step 10: Generate Visual Architecture Plan (optional)

If the project is non-trivial, generate a visual architecture diagram:

```bash
/visual-explainer:generate-web-diagram
```

This becomes the reference diagram for all downstream agents.

> **CHECKPOINT:** Present the full bootstrap summary. Ask: "Everything look right? Ready to start Gate 0?"

## Completion

Report status:
- **DONE** — Project fully bootstrapped. List what was created: charter, N agent personas, commands, vault, Paperclip registration, learnings file. Suggest `sprint-plan` as next step.
- **DONE_WITH_CONCERNS** — Bootstrapped but some steps deferred (e.g., vault empty, Paperclip registration pending).
- **BLOCKED** — Cannot proceed (e.g., repo access denied, Paperclip API down).
- **NEEDS_CONTEXT** — Need more detail from founder about the project.

## Learnings Capture

After completion, evaluate:
1. Were any bootstrap steps unnecessary for this project type? (Simplify for next time)
2. Did the agent naming convention need adaptation? (Cultural fit)
3. Were the default agent roles right or did we need a custom role?
4. How long did the full bootstrap take? (Benchmark for improvement)

## Appendix: Bootstrap Checklist

Quick reference — use this to verify completeness after running the skill:

```
[ ] Charter written (projects/{name}/CHARTER.md)
[ ] Agent personas created (projects/{name}/agents/*.md)
[ ] Project-local commands installed ({repo}/.claude/commands/)
[ ] Learnings file created (skills/_learnings/{name}.jsonl)
[ ] qmd vault wired (/knowledge/vault-{name}/)
[ ] Paperclip project + agents registered
[ ] Paperclip IDs written back to persona files
[ ] build-sequence.md updated
[ ] Repo exists with CLAUDE.md + .gitignore
[ ] Smoke test: agent heartbeat passed
```
