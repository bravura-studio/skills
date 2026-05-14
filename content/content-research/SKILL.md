---
name: content-research
description: |
  Research phase of the Scripta content pipeline. Searches qmd vaults (scripta,
  agent-knowledge) and the web to build a research brief for a given topic or
  theme. Use when starting a new article, when the Monday ritual surfaces themes,
  or when someone says "research this topic", "what do we have on X".
version: 1.0.0
category: content
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
  - "research this topic"
  - "what do we have on"
  - "content research"
  - "Monday ritual"
  - "find material on"
benefits-from: []
feeds-into:
  - content-draft
qmd:
  - collection: scripta
    query: "{topic} writing craft personal branding"
    limit: 10
  - collection: agent-knowledge
    query: "{topic} builder narrative patterns"
    limit: 5
reads-learnings: true
writes-learnings: true
---

# Content Research

## Context

Every Scripta article starts with research — not to write a well-researched blog post, but to surface raw material that the founder can react to. The vault has 400+ docs; the web has infinite takes. This skill distills both into a brief that makes the deep-dive interview (content-draft) productive.

Part of the Monday Content Ritual: n8n fires Monday 9am Lisbon → founder says "go" → this skill runs → themes surface → founder picks → content-draft takes over.

## Prerequisites

- A topic, theme, or direction (can be vague)
- Access to qmd vaults (scripta, agent-knowledge)

## Steps

### Step 1: Clarify the Direction

If the input is vague (e.g., "Monday ritual, go"), start by querying the vaults broadly:

```
qmd query: scripta — recent bookmarks, articles, themes
qmd query: agent-knowledge — builder narratives, lessons
```

Cluster results into 3-5 candidate themes. Present them:

> **CHECKPOINT:** "Here are 3-5 themes surfacing from the vaults this week. Which one resonates? Or do you have something else in mind?"

If the input is specific (e.g., "write about the skills architecture we just built"), skip clustering and go to Step 2.

### Step 2: Deep Vault Search

For the chosen topic, run targeted queries:

1. **Scripta vault** — Prior articles, brand voice examples, related topics already covered
2. **Agent-knowledge vault** — Technical patterns, architecture decisions, builder narratives
3. **Other vaults** (tmaker, striva, tycoon) — Cross-project perspectives if relevant

For each query, note:
- What we already wrote about this (avoid repetition)
- What raw material exists (bookmarks, stars, notes)
- What angles haven't been explored yet

### Step 3: Web Research

Search for external perspectives on the topic:
- What are others saying? (Find 3-5 notable takes)
- What's the contrarian view?
- Is there a timely hook? (Recent event, trend, discourse)

Don't over-research. 3-5 external sources max. The article is the founder's take, not a literature review.

### Step 4: Identify the Angle

From the vault + web research, identify:
- **The obvious take** — What most people would write about this topic
- **The founder's unique angle** — Based on BUILD.FUN.FREE context, portfolio experience, personal journey
- **The tension** — What makes this interesting? What's the conflict or surprise?

The best Scripta pieces have a tension: expected vs. reality, conventional wisdom vs. lived experience, what people say vs. what actually works.

### Step 5: Write the Research Brief

Save to a predictable location for `content-draft` to find.

**Output path:** `skills/_output/content-research-{date}-{slug}.md`

```markdown
# Research Brief: {Topic}

**Date:** {YYYY-MM-DD}
**Theme:** {one-line theme}
**Triggered by:** {Monday ritual / founder request / vault signal}

## Vault Material
{Key findings from vault search — quotes, references, patterns}
{Note what we've already published on adjacent topics}

## External Perspectives
{3-5 notable external takes with source links}

## Angle
- **Obvious take:** {what most people would write}
- **Founder's angle:** {what makes this uniquely ours}
- **Tension:** {the conflict or surprise that makes it interesting}

## Raw Questions for Deep-Dive
{3-5 questions to ask the founder in content-draft's interview step}
{These should surface stories, metaphors, and honest reactions — not opinions}

## Mode Suggestion
{Short punchy piece (1-3 min) or wisdom piece (longer, framework-driven)?}
{Why?}
```

> **CHECKPOINT:** Present the research brief. Ask: "Does this angle feel right? Anything I missed or got wrong?"

## Completion

Report status:
- **DONE** — Research brief written. State the file path. Suggest `content-draft` next.
- **DONE_WITH_CONCERNS** — Brief written but topic feels thin or too close to a prior article.
- **BLOCKED** — Vault search returned nothing useful and web research didn't help.
- **NEEDS_CONTEXT** — Can't determine the angle without founder input.

## Learnings Capture

After completion, evaluate:
1. Which vault queries worked well? (Note the phrasing for reuse.)
2. Did we discover a gap in the vaults? (Flag for ingestion pipeline.)
3. Did the founder reject our suggested angle? (Capture the taste preference.)
