---
name: content-draft
description: |
  Write phase of the Scripta content pipeline. Conducts a deep-dive interview
  with the founder to extract their authentic voice, then drafts the article
  following the brand guide. Drafts go to content/drafts/, NEVER directly to
  content/published/. Use after content-research or when someone says "let's
  write this", "draft the article", "deep dive on this topic".
version: 1.0.0
category: content
interactive: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
  - AskUserQuestion
triggers:
  - "let's write this"
  - "draft the article"
  - "deep dive"
  - "write about"
  - "start drafting"
benefits-from:
  - content-research
feeds-into:
  - content-edit
qmd:
  - collection: scripta
    query: "brand voice writing style examples"
    limit: 5
reads-learnings: true
writes-learnings: true
---

# Content Draft

## Context

The most critical skill in the content pipeline. The difference between a generic blog post and a Scripta piece is the founder's authentic voice. That voice doesn't come from prompting — it comes from a deep-dive interview where the founder thinks out loud.

**Rule #1: Always deep-dive before drafting.** Never skip the interview. The draft should sound like the founder talking to a friend over wine, not a well-researched article.

**Rule #2: Drafts go to content/drafts/ first.** Never put anything in content/published/ — it goes live immediately regardless of frontmatter status (the code uses directory as fallback). Separate PR to move to published when approved.

## Prerequisites

- Research brief from `content-research` (check `skills/_output/content-research-*.md`)
- Brand guide internalized (read `projects/scripta/brand-guide.md` every time — don't rely on memory)

## Steps

### Step 1: Load Context

1. Read the research brief (most recent for this topic)
2. Read the brand guide: `projects/scripta/brand-guide.md`
3. Read 1-2 recent published articles for voice calibration
4. Load any learnings tagged `content-draft` from the project

### Step 2: Deep-Dive Interview

This is the core of the skill. Ask 3-5 questions one at a time. Wait for the answer before asking the next.

**Source:** Use the "Raw Questions for Deep-Dive" from the research brief as starting points, but adapt based on the conversation.

**Question design principles:**
- Ask for **stories**, not opinions. "Tell me about a time when..." > "What do you think about..."
- Ask for **feelings**, not analysis. "How did that feel?" > "What was the impact?"
- Ask for **metaphors**. "What does this remind you of?" "If you had to explain this to your kids..."
- Follow the energy. If the founder lights up about something, go deeper there.
- Don't lead. "What surprised you?" not "Were you surprised by X?"

**Capture:** Note the founder's exact phrases, metaphors, and stories. These go directly into the draft.

> **CHECKPOINT:** After 3-5 questions, summarize what you heard. Ask: "Did I capture the core of what you're saying? Anything else that needs to be in this piece?"

### Step 3: Determine the Mode

Based on the interview + research brief:

**Short punchy piece** (default, 1-3 min read):
- One idea, well told
- Story-driven hook → insight → clean landing
- Think Shaan Puri's One Minute Blog

**Wisdom piece** (occasional, longer):
- Topic demands depth
- Framework or hard-won lesson
- Think Jason Cohen at Smart Bear

State which mode and why before drafting.

### Step 4: Write the Draft

**Writing rules (from brand guide):**

Voice: Like talking to a close friend over wine on a Friday night. No jargon. Think out loud. Not performing wisdom — processing reality.

Formula:
- Interesting > Profound
- Raw > Polished
- Hard stuff > Easy wins

Never sounds like:
- Corporate speak
- Humble bragging disguised as vulnerability
- Generic startup advice
- AI-sounding prose — smooth, safe, soulless

Structure:
- No named series, no rigid format
- Use the founder's actual phrases from the interview
- Images/screenshots only when they clarify, not decorate
- End with: **Keep building. -Ochoa**

**Draft format (frontmatter for andochoa.com):**

```markdown
---
title: "{title}"
date: "{YYYY-MM-DD}"
excerpt: "{1-2 sentence hook}"
status: "draft"
tags: ["{tag1}", "{tag2}"]
---

{article body}

Keep building. -Ochoa
```

### Step 5: Save the Draft

**Output path:** `content/drafts/journals/{slug}.mdx` (in the andochoa.com repo)

If working in build-fun-free (not the andochoa.com repo), save to:
`skills/_output/content-draft-{date}-{slug}.md`

with a note that it needs to be moved to the andochoa.com repo.

> **CHECKPOINT:** Present the draft to the founder. Ask: "Does this sound like you? What feels off? What needs to change?"

### Step 6: Iterate

The first draft is rarely the final draft. Common feedback loops:
- "This doesn't sound like me" → Identify which sentences feel AI-generated, rewrite using interview quotes
- "The hook is weak" → Try a different story or opening line
- "Too long / too short" → Adjust scope, don't pad or cut arbitrarily
- "Missing the point" → Go back to Step 2, ask one more question

Iterate until the founder says "this is close" or "let's move to edit."

## Completion

Report status:
- **DONE** — Draft written, founder approved direction. State the file path. Suggest `content-edit` next.
- **DONE_WITH_CONCERNS** — Draft written but founder had reservations. List them.
- **BLOCKED** — Can't capture the founder's voice (e.g., topic doesn't resonate, interview didn't surface stories).
- **NEEDS_CONTEXT** — Need more interview time. State what's missing.

## Learnings Capture

After completion, evaluate:
1. Which interview questions worked best? (Capture the phrasing.)
2. Did the founder reject any phrasing as "not sounding like me"? (Capture the anti-pattern.)
3. What mode was chosen and why? (Build a sense of which topics → which mode.)
4. How many iterations before approval? (Track improvement over time.)
