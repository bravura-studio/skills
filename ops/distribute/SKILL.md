---
name: distribute
description: |
  Post-ship distribution workflow. Creates launch assets for X, Reddit, HN,
  Product Hunt, directories, and Scripta blog. Structures the distribution step
  that follows quality pipeline completion. Use after a tool ships, after QA passes,
  or when someone says "launch this", "distribute", "post about it", "get the word out".
version: 1.0.0
category: ops
interactive: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
  - WebSearch
  - AskUserQuestion
triggers:
  - "launch this"
  - "distribute"
  - "post about it"
  - "get the word out"
  - "write the launch posts"
  - "X thread"
  - "submit to HN"
benefits-from:
  - deploy-check
feeds-into:
  - retro
qmd:
  - collection: tmaker
    query: "distribution launch viral growth strategies"
    limit: 5
  - collection: scripta
    query: "content distribution social media posting"
    limit: 3
reads-learnings: true
writes-learnings: true
---

# Distribute

## Context

Shipping is 50% of the work. Distribution is the other 50%. A tool that nobody knows about generates zero value. This skill structures the launch playbook so distribution isn't ad-hoc.

The distribution step runs AFTER the quality pipeline (AD-019: pretty → fast → viral) confirms the tool is ready. By this point: QA passed, design polished, performance verified, OG images working, share flow tested.

## Prerequisites

- Tool is live and deploy-check passed
- Quality pipeline complete (design polish, performance, viral readiness)
- OG image and meta tags verified
- Tool URL and key screenshots available

## Steps

### Step 1: Gather Launch Assets

Collect everything needed for distribution:

```bash
# Tool info
echo "Tool: {name}"
echo "URL: {production url}"
echo "Repo: {github url}"
echo "One-liner: {what it does in one sentence}"

# Screenshots (should exist from QA)
ls product/screenshots/ 2>/dev/null || ls qa-*.png 2>/dev/null
```

Read the tool's PRD for the value proposition and target audience. Read the taste doc for brand voice.

### Step 2: Draft X/Twitter Post

Write a launch post optimized for engagement:

**Format options (pick the best fit):**

**A. Show & Tell** (best for visual tools):
```
I built {tool} — {one-line value prop}

{screenshot or demo GIF}

{2-3 bullet points of what it does}

Try it free: {url}
```

**B. Problem → Solution** (best for utility tools):
```
{Problem statement that resonates}

So I built {tool}.

{How it works in 2 sentences}

{url}
```

**C. Data Hook** (best for data-driven tools):
```
I analyzed {impressive data point} and found {insight}.

Built {tool} to make this accessible to everyone.

{url}
```

**Rules:**
- No hashtags (they reduce reach on X)
- No "🚀 Excited to announce" (cringe)
- Lead with value or curiosity, not self-promotion
- Include the URL as the last line
- Keep under 280 chars for the main tweet (thread for details)

### Step 3: Draft Reddit Post

Identify 2-3 relevant subreddits. Write a post for each.

**Reddit rules:**
- Title: descriptive, not clickbait. "[Tool] Tool Name — what it does"
- Body: genuine, helpful, not salesy
- Always disclose you built it: "I built this because..."
- Engage with comments (plan to check back in 2h, 6h, 24h)
- r/SideProject, r/webdev, r/InternetIsBeautiful are good defaults for tools

### Step 4: Draft Hacker News Title

HN is title-only (no body for Show HN posts):

```
Show HN: {Tool Name} – {what it does in 8 words or fewer}
```

**HN rules:**
- "Show HN:" prefix required for projects
- No superlatives ("best", "fastest", "revolutionary")
- Technical audience — emphasize the interesting technical choice
- Submit at ~9am ET for best visibility

### Step 5: Directory Submissions

List the top 10 directories for this tool type:

| Directory | URL | Status |
|-----------|-----|--------|
| Product Hunt | producthunt.com | [ ] Scheduled |
| BetaList | betalist.com | [ ] Submitted |
| AlternativeTo | alternativeto.net | [ ] Listed as alt to {X} |
| ToolFinder | toolfinder.co | [ ] Submitted |
| SaaSHub | saashub.com | [ ] Submitted |
| Indie Hackers | indiehackers.com | [ ] Posted in products |
| Hacker News | news.ycombinator.com | [ ] Show HN submitted |
| Reddit | reddit.com | [ ] Posted to {subreddits} |
| X/Twitter | x.com | [ ] Posted |
| Scripta Blog | andochoa.com | [ ] Article drafted |

### Step 6: Scripta Blog Brief (optional)

If the tool has a story worth telling, draft a brief for the Scripta content pipeline:

```markdown
## Scripta Brief: {tool name}

**Angle:** {why this is interesting beyond "I built a tool"}
**Hook:** {opening line that creates curiosity}
**Key points:**
- {the problem and who has it}
- {the interesting technical or market insight}
- {the result / traction}
**CTA:** {where to try it}
```

This becomes input for `content-research` → `content-draft` if approved.

> **CHECKPOINT:** Present all launch assets. Ask: "Ready to post? Any changes to voice/angle? Which channels first?"

### Step 7: Write Launch Checklist

Save the distribution plan:

**Output path:** `product/distribution/launch-{tool-name}.md`

```markdown
## Distribution Plan: {tool name}

**Ship date:** {YYYY-MM-DD}
**URL:** {production url}

### Launch Assets
- X post: {copy}
- Reddit: {subreddits + copy}
- HN: {title}
- Directories: {list with submission status}
- Scripta brief: {yes/no}

### Schedule
- Day 0: X post + Reddit + HN
- Day 1: Check engagement, respond to comments
- Day 2-3: Directory submissions (spread out to avoid spam signals)
- Week 1: Scripta article if traction warrants

### Metrics to Track
- X impressions + link clicks
- Reddit upvotes + comments
- HN points + comments
- Directory referral traffic (via PostHog UTM params)
```

## Completion

- **DONE** — All launch assets created, distribution plan written. State the output path.
- **DONE_WITH_CONCERNS** — Assets created but OG image or share flow has issues. Fix before posting.
- **BLOCKED** — Tool not ready for distribution (deploy-check failed, quality pipeline incomplete).
- **NEEDS_CONTEXT** — Need founder input on angle, target audience, or channel priority.

## Learnings Capture

After completion, evaluate:
1. Which channel drove the most traffic for similar tools? (Track over time)
2. Did the launch angle resonate? (Check engagement metrics in retro)
3. Were there directories missed that would be relevant?
