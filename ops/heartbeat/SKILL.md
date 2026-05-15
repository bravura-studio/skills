---
name: heartbeat
description: |
  Portfolio-wide status heartbeat. Verifies REAL state across infra, projects,
  agents, and content — no assumptions from docs. Surfaces problems, progress,
  priorities, and blockers with live evidence. Use on session start, when founder
  asks "what's cooking", "status", "heartbeat", or on a schedule.
version: 1.0.0
category: ops
interactive: false
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
  - Agent
triggers:
  - "what's cooking"
  - "status"
  - "heartbeat"
  - "what's the status"
  - "how are we doing"
  - "progress check"
  - "checkpoint"
benefits-from:
  - infra-audit
feeds-into: []
qmd:
  - agent-knowledge
reads-learnings: true
writes-learnings: true
---

# Heartbeat

## Context

Portfolio-level operational heartbeat for BUILD.FUN.FREE. Unlike infra-audit (which checks server health) or deploy-check (which checks a single deployment), this skill verifies the REAL state of the entire portfolio: infrastructure, every active project, agent teams, content pipeline, and data freshness.

The key principle: **never trust docs — verify live**. Build-sequence.md, charters, and memory can all be stale. This skill runs live checks and reports what's actually true RIGHT NOW.

Takes ~2-3 minutes for a full pass.

## Prerequisites

- Running on VPS1 (or SSH access to it)
- gh CLI authenticated
- qmd, dinobase CLIs available

## Steps

### Step 1: Infrastructure Quick Check

Run all in parallel:

```bash
# System resources
uptime && free -h | grep Mem && df -h / | tail -1

# ferro.service
systemctl status ferro.service --no-pager 2>&1 | head -5
systemctl show ferro.service -p MemoryCurrent --value

# Docker containers
docker ps --format 'table {{.Names}}\t{{.Status}}' 2>/dev/null

# Service endpoints
for url in "https://paperclip.andochoa.com/api/health" "https://andochoa.com" "https://n8n.andochoa.com"; do
  code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 5 "$url" 2>/dev/null || echo "timeout")
  echo "$url: $code"
done

# qmd freshness
qmd status 2>&1 | grep -E "Total|Updated|Files"

# Dinobase freshness
dinobase info 2>&1 | grep -E "STALE|rows|last sync"

# n8n active workflows
docker exec n8n n8n list:workflow --active=true 2>/dev/null | grep -v "Error tracking"
```

Flag if:
- ferro.service RSS >500MB
- Any container down or restarting
- Any endpoint non-200
- qmd updated >3 days ago
- Dinobase sources stale >7 days
- Any expected n8n workflow missing or inactive

### Step 2: Project Status (verify each active project)

For EACH project in the portfolio, verify live state — don't just read the charter.

**Scripta (active priority):**
```bash
# Site live?
curl -sS -o /dev/null -w "andochoa.com: HTTP %{http_code}\n" https://andochoa.com

# Actual published content count (from live site, not docs)
curl -s "https://andochoa.com/posts" 2>/dev/null | grep -oP '(?<=href="/posts/)[^"]*' | sort -u

# Recent commits
gh api repos/bravura-studio/andochoa.com/commits --jq '.[0:5] | .[] | "\(.commit.committer.date[:10]) \(.commit.message | split("\n")[0])"'

# Open PRs
gh pr list --repo bravura-studio/andochoa.com --state open --json number,title --jq '.[] | "#\(.number) \(.title)"'

# Drafts in pipeline
gh api repos/bravura-studio/andochoa.com/contents/content/drafts --jq '[.[] | select(.type=="file")] | length | "\(.) drafts pending"' 2>/dev/null

# SEO basics
curl -s "https://andochoa.com/sitemap.xml" -o /dev/null -w "sitemap.xml: HTTP %{http_code}\n" 2>/dev/null
curl -s "https://andochoa.com/robots.txt" -o /dev/null -w "robots.txt: HTTP %{http_code}\n" 2>/dev/null
```

**build-fun-free (handbook):**
```bash
# Recent activity
git log --oneline --since="7 days ago" | wc -l
git log --oneline --since="7 days ago" | head -5

# Open PRs
gh pr list --repo bravura-studio/build-fun-free --state open --json number,title --jq '.[] | "#\(.number) \(.title)"'

# Skills count
find /root/code/build-fun-free/skills -name "SKILL.md" | wc -l
```

**Other projects (paused/not started):**
```bash
# Check each repo exists and last activity
for repo in localkit midday vinhais-hotel; do
  last=$(gh api repos/bravura-studio/$repo/commits --jq '.[0].commit.committer.date[:10]' 2>/dev/null || echo "not found")
  echo "$repo: last commit $last"
done
```

### Step 3: Agent Team Status

```bash
# Paperclip agents — try API first
curl -s https://paperclip.andochoa.com/api/agents \
  -H "Cookie: $(cat /root/.claude/projects/-root-code-build-fun-free/memory/paperclip_session_cookie.txt 2>/dev/null)" \
  2>/dev/null | jq -r '.[] | "\(.name) (\(.adapter)) — \(.status // "unknown")"' 2>/dev/null

# If auth fails, note it as a blocker
# Check last Paperclip heartbeat activity
curl -s "https://paperclip.andochoa.com/api/runs?limit=5" \
  -H "Cookie: $(cat /root/.claude/projects/-root-code-build-fun-free/memory/paperclip_session_cookie.txt 2>/dev/null)" \
  2>/dev/null | jq -r '.[] | "\(.createdAt[:10]) \(.agentName // .agentId) — \(.status)"' 2>/dev/null
```

If Paperclip auth fails, flag it as a blocker — can't verify agent state.

### Step 4: Data Freshness

```bash
# qmd vault ages
qmd status 2>&1 | grep -E "updated|Files"

# Dinobase source ages
dinobase info 2>&1 | grep -E "STALE|last sync"
```

Flag stale sources with specific staleness duration.

### Step 5: Cross-reference Docs vs Reality

Read `architecture/build-sequence.md` and compare its claims against what you just verified. Flag any discrepancies:
- Article counts that don't match live site
- Status markers ([x]) on items that aren't actually done
- "In progress" items with no recent activity
- "Not started" items that have actually been started

### Step 6: Report

Format the heartbeat as a structured report:

```
HEARTBEAT — {YYYY-MM-DD HH:MM UTC}

PROBLEMS (things that need attention NOW)
- {problem 1 with evidence}
- {problem 2 with evidence}

PROGRESS (what moved since last check)
- {verified progress with dates/evidence}

PRIORITIES (ordered by impact)
1. {priority 1 — why it matters}
2. {priority 2 — why it matters}

BLOCKERS (things only the founder can unblock)
- {blocker — what's needed}

DATA FRESHNESS
| Source | Last Updated | Status |
|--------|-------------|--------|
| qmd | {date} | {OK/STALE} |
| dinobase-github | {date} | {OK/STALE} |
| dinobase-vercel | {date} | {OK/STALE} |

DOC CORRECTIONS
- {any build-sequence.md or charter claims that don't match reality}
```

If running via Telegram, send the report via reply tool. Keep it concise — details available on request.

## Completion

- **HEALTHY** — All systems up, data fresh, projects on track, no blockers.
- **DEGRADED** — Running but with concerns (stale data, missing SEO basics, auth issues).
- **BLOCKED** — Critical systems down or can't verify state.
- **ACTION_NEEDED** — Founder needs to make a decision or take an action.

## Learnings Capture

After completion, evaluate:
1. Were there doc-vs-reality discrepancies? Update the docs immediately.
2. Was any data source stale enough to affect agent work? Flag for auto-refresh setup.
3. Did any infra metric change significantly since last heartbeat? Track the trend.
4. Did Paperclip auth work? If not, track the auth refresh pattern.
