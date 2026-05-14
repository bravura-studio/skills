---
name: agent-debug
description: |
  Diagnose and unstick a Paperclip agent that's not responding, stuck in a loop,
  or producing errors. Checks heartbeat status, run history, container health,
  and common failure modes. Use when an agent stops working, heartbeats fail,
  or someone says "agent is stuck", "why isn't X responding", "debug the agent".
version: 1.0.0
category: ops
interactive: true
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
  - AskUserQuestion
triggers:
  - "agent is stuck"
  - "why isn't it responding"
  - "debug the agent"
  - "heartbeat failed"
  - "agent not working"
  - "unstick"
benefits-from: []
feeds-into: []
qmd:
  - collection: agent-knowledge
    query: "agent debugging common failures paperclip"
    limit: 3
reads-learnings: true
writes-learnings: true
---

# Agent Debug

## Context

Agents get stuck. Common causes from operational history (PCB-007 through PCB-012):
- Container process died (bun crash, OOM kill)
- Auth expired (Max subscription credential refresh)
- Heartbeat coalesce race (self-wake landed during active run)
- Wrong assignee (PATCH-reassign not called, agent never woke)
- Tool missing or broken (binary lost on container rebuild)
- Rate limit hit (Google AI Studio 5 RPM, API quotas)
- Context too large (maxTurnsPerRun exhausted without completing)

This skill walks through diagnosis systematically instead of guessing.

## Prerequisites

- Access to VPS1 (where Paperclip runs)
- Agent name or ID known
- Symptom described (not responding, error output, loop behavior)

## Steps

### Step 1: Identify the Agent

```bash
# Known agent IDs (Bravura Studio)
# Ferro: CEO (runs as ferro.service, NOT in Paperclip container)
# Vasco: 278ca58e-4b55-4f7a-8fce-43c18e8de8fb (Tmaker CEO)
# Rui: 1ac9bed3-2698-4aa8-8d38-b3d968280fba (Tmaker Coder)
# Cruz: 6e6a5dd9-dd14-4bbc-879c-b37a0df6eacf (Tmaker QA)
# Camões: 477c637f-b6b3-4da2-9d18-e94c92956c21 (Scripta Coder)
# Florbela: 0fa7af86-b3f8-4fe1-b348-c7f9cd06012e (Scripta QA)

# Check agent status via Paperclip API
curl -sS "$PAPERCLIP_API_URL/api/agents/{agentId}" \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" | jq '.name, .status, .lastHeartbeat'
```

### Step 2: Check Recent Runs

```bash
# Get last 5 runs
curl -sS "$PAPERCLIP_API_URL/api/agents/{agentId}/runs?limit=5" \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" | jq '.[].{id, status, startedAt, completedAt, error}'
```

Look for:
- **Status "failed"** — check error field
- **Status "running" for >30min** — likely stuck
- **No recent runs** — agent not being woken

### Step 3: Check Container Health

```bash
# Is the container running?
docker ps --filter name=paperclip-server-1 --format '{{.Status}}'

# Container resource usage
docker stats paperclip-server-1 --no-stream --format '{{.MemUsage}} | {{.CPUPerc}}'

# Check for OOM kills
docker inspect paperclip-server-1 --format '{{.State.OOMKilled}}'

# Check claude processes inside container
docker exec paperclip-server-1 ps aux | grep claude
```

### Step 4: Check Auth & Credentials

```bash
# Is Max subscription auth valid?
docker exec paperclip-server-1 cat /paperclip/.claude/.credentials.json 2>/dev/null | jq '.expiresAt'

# Are secrets bound?
docker exec paperclip-server-1 env | grep -E "GITHUB_TOKEN|PAPERCLIP_API" | sed 's/=.*/=<set>/'
```

### Step 5: Check Common Failure Modes

Run through the known failure checklist:

| Failure Mode | Check | Fix |
|---|---|---|
| Process dead | `docker exec paperclip ps aux \| grep claude` | Restart container or re-trigger heartbeat |
| Auth expired | Check `.credentials.json` expiry | Re-login: `docker exec -it paperclip claude /login` |
| Coalesce race | Last run status "completed" but no output | Delayed self-wake with 3s sleep |
| Wrong assignee | Check issue's `assigneeAgentId` | PATCH correct assignee |
| Tool missing | `docker exec paperclip which {tool}` | Re-install per playbook 09 |
| Rate limited | Check run logs for 429 errors | Wait or switch model per AD-031 |
| maxTurns exhausted | Run completed with truncated output | Increase maxTurnsPerRun via SQL |
| Orphan processes | `docker exec paperclip ps aux \| wc -l` | Kill orphans: `pkill -f "pnpm\|next"` |

> **CHECKPOINT:** Present findings. Ask: "Want me to apply the fix, or do you want to handle it?"

### Step 6: Report

```markdown
## Agent Debug: {agent name}

**Date:** {YYYY-MM-DD}
**Symptom:** {description}
**Root cause:** {identified cause}
**Fix applied:** {what was done, or "pending approval"}

### Diagnosis Steps
1. {what was checked} → {result}
2. ...

### Recommendation
{What to do to prevent recurrence}
```

## Completion

- **DONE** — Root cause found and fixed. Agent is responsive.
- **DONE_WITH_CONCERNS** — Fixed but underlying issue may recur (e.g., OOM from memory leak).
- **BLOCKED** — Can't diagnose without container access or API credentials.
- **NEEDS_CONTEXT** — Need more symptom detail from the user.

## Learnings Capture

After completion, evaluate:
1. Was this a new failure mode? Add to the checklist above.
2. Was this a recurring pattern? Consider a preventive measure (monitoring, alert).
3. Should any agent persona be updated to avoid this failure?
