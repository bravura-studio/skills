# Context Injection Protocol

> How agents load vault context and learnings before executing a skill.
> Part of Phase 3: Compound Learning Infrastructure (AD-036).

---

## Overview

Skills declare their context needs in YAML frontmatter (`qmd:` and `reads-learnings:`). Before executing a skill's steps, the agent loads this context. This protocol specifies **how**.

---

## Two Paths

### Path A: Inside Claude Code (MCP — preferred)

When running inside Claude Code with the qmd MCP server connected:

1. **Read the SKILL.md** — parse the `qmd:` frontmatter entries.
2. **For each qmd entry**, call `mcp__qmd__query`:
   ```
   collection: <from frontmatter>
   query: <from frontmatter>
   limit: <from frontmatter, default 5>
   ```
3. **Prepend results** as a `## Vault Context` section before executing steps.
4. **Load learnings** — if `reads-learnings: true` (default), read `skills/_learnings/{project}.jsonl`:
   - Filter by `skill` field matching the current skill name AND any `benefits-from` skills.
   - Prepend as `## Prior Learnings` section.

### Path B: CLI (scripts)

When running outside Claude Code or in automation:

```bash
# Full context injection (qmd + learnings)
skills/scripts/inject-context.sh skills/{category}/{name}/SKILL.md {project-slug}

# Learnings only (fast, no model loading)
skills/scripts/load-learnings.sh {skill-name} {project-slug} [benefits-from-csv]
```

**Note:** CLI qmd queries use `qmd query` which loads the embedding model on each invocation. First run downloads ~1.3GB model. Subsequent runs use cache but still load into memory. MCP path (Path A) is significantly faster since the model stays loaded.

---

## Injection Order

Context is prepended to the skill execution in this order:

```
## Vault Context          ← qmd query results (if qmd: declared)
### {collection}: {query}
...results...

## Prior Learnings        ← filtered learnings.jsonl (if reads-learnings: true)
- **key** (confidence, source): insight
...

## Steps                  ← skill execution begins here
```

---

## Agent Instructions

When you (the agent) are about to execute a skill:

1. Read the SKILL.md frontmatter.
2. If `qmd:` entries exist, run the queries and hold results in working memory.
3. If `reads-learnings: true` (or absent — it defaults to true), load the project's learnings file.
4. Use loaded context to inform your execution of the skill's steps.
5. After completion, if `writes-learnings: true`, evaluate whether to append a new learning.

**Do not skip context injection.** A skill without its context is like a function without its arguments.

---

## Writing Learnings After Execution

After completing a skill, evaluate:

1. Did anything unexpected happen during execution?
2. Is there a reusable lesson that would change behavior next time?
3. If yes, append one JSONL line to `skills/_learnings/{project}.jsonl`:

```json
{"ts":"2026-05-13T15:00:00Z","skill":"skill-name","type":"operational","key":"kebab-key","insight":"Specific actionable lesson.","confidence":0.9,"source":"observed"}
```

**Types:** `operational` (how-to), `technical` (code/infra), `process` (workflow), `taste` (design/style)
**Sources:** `observed` (agent noticed), `corrected` (founder fixed), `validated` (founder confirmed)

**Don't write trivial learnings.** "The build succeeded" is not a learning. "This project's Turbopack config breaks with dynamic imports in API routes" is.

---

## Agent Operating Rules

These rules are injected into every skill execution alongside vault context and learnings. They apply regardless of which skill is running.

### Escalation Protocol

When you hit ANY blocker — missing credentials, auth errors, build failures, missing files, dependency issues — you MUST:

1. **Escalate BEFORE setting status to blocked.** Silent blocks waste days.
2. Call the ferro-notify webhook:
   ```bash
   curl -s -X POST https://n8n.andochoa.com/webhook/ferro-notify \
     -H "Content-Type: application/json" \
     -d '{"text": "🚨 BRAA-XXX blocked: <specific reason> (agent: <your name>)", "url": "https://paperclip.andochoa.com"}'
   ```
3. THEN set the issue status to blocked and add a comment explaining the blocker.

Never silently block. If the webhook fails, add "ESCALATION FAILED" to the issue comment so it's visible on next heartbeat review.

### Cross-Agent Issue Creation

Do NOT use Paperclip MCP tools to create issues assigned to other agents — they silently drop `assigneeAgentId`, leaving the issue unassigned and the target agent unaware.

Use the `create-issue.sh` script instead:

```bash
bash skills/scripts/create-issue.sh \
  --title "QA: Review <what>" \
  --assignee "<target-agent-id>" \
  --description "## Task\n..." \
  --status todo \
  --priority high
```

Requires env vars: `PAPERCLIP_TOKEN`, `PAPERCLIP_COMPANY_ID`, `PAPERCLIP_PROJECT_ID`.
