---
name: content-edit
description: |
  QA phase of the Scripta content pipeline. Reviews a draft for factual accuracy,
  voice consistency (brand guide compliance), readability, and SEO basics. Does NOT
  rewrite — flags issues and suggests fixes. Use after content-draft or when someone
  says "edit this", "review the draft", "is this ready to publish".
version: 1.0.0
category: content
interactive: false
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - WebSearch
triggers:
  - "edit this"
  - "review the draft"
  - "is this ready to publish"
  - "content edit"
  - "proofread"
benefits-from:
  - content-draft
feeds-into:
  - content-publish
qmd:
  - collection: scripta
    query: "brand voice anti-patterns to avoid"
    limit: 3
reads-learnings: true
writes-learnings: true
---

# Content Edit

## Context

The quality gate before publishing. This is NOT a rewrite — the founder's voice was captured in content-draft. This pass checks for factual errors, voice drift (did any sentence start sounding like AI?), readability, and basic SEO.

The editor's job is to protect the voice, not improve the prose.

## Prerequisites

- A draft from `content-draft` (check `skills/_output/content-draft-*.md` or `content/drafts/journals/`)
- Brand guide: `projects/scripta/brand-guide.md`

## Steps

### Step 1: Load the Draft and Brand Guide

Read both fully. Note the intended mode (short punchy vs. wisdom piece).

Check if there's a research brief too — useful for fact-checking claims.

### Step 2: Fact Check

For every factual claim in the draft:
1. Is it verifiable? Check against vault, web, or code.
2. Is it accurate? Dates, names, numbers, technical details.
3. Is it attributed correctly?

**Common traps:**
- Mixing up timelines (when did X actually happen?)
- Overstating results (did we actually ship 4 tools, or was it 3?)
- Technical claims that were true when drafted but changed since

Mark each claim: VERIFIED, UNVERIFIABLE (opinion/feeling — fine), or INCORRECT (must fix).

### Step 3: Voice Audit

Read the draft out loud (mentally). For each paragraph, ask:

- Does this sound like the founder talking to a friend over wine?
- Or does it sound like an AI writing a blog post?

**Red flags (from brand guide):**
- Corporate speak or buzzwords
- Sentences that are too smooth, too balanced, too safe
- Humble bragging disguised as vulnerability
- Generic advice that could come from anyone
- Performative positivity
- Unnecessary jargon

**For each flagged passage:**
- Quote the problematic text
- Explain why it fails the voice test
- Suggest a fix OR note that the founder's interview quotes from content-draft should replace it

### Step 4: Readability Check

- **Flow:** Does each paragraph lead naturally to the next?
- **Hook:** Does the opening grab attention in 2 sentences?
- **Landing:** Does the ending feel earned, not abrupt?
- **Length:** Does the length match the mode? Short punchy = 1-3 min. Wisdom = longer but every sentence earns its place.
- **Sign-off:** Does it end with "Keep building. -Ochoa"?

### Step 5: SEO Basics

Light touch — Scripta is a personal site, not a content farm. But basics matter:
- **Title:** Clear, honest, not clickbait. Would you click this in an RSS feed?
- **Excerpt:** Does the frontmatter excerpt work as a social preview?
- **Tags:** Are they accurate and consistent with existing tags?
- **Meta:** Is the slug readable? (`building-with-ai-agents` not `post-2026-05-13`)

### Step 6: Report

```markdown
## Content Edit: {title}

**Date:** {YYYY-MM-DD}
**Draft:** {file path}
**Mode:** {short punchy | wisdom piece}

### Fact Check
| # | Claim | Status | Notes |
|---|-------|--------|-------|
| 1 | {claim} | VERIFIED/UNVERIFIABLE/INCORRECT | {detail} |

### Voice Audit
{Number of passages flagged}

{For each flag:}
> "{quoted text}"
Issue: {why it fails the voice test}
Suggestion: {fix or "use founder's words from interview"}

### Readability
- Hook: {strong / weak — why}
- Flow: {smooth / choppy — where}
- Landing: {earned / abrupt}
- Length: {right / too long / too short}
- Sign-off: {present / missing}

### SEO
- Title: {ok / suggestion}
- Excerpt: {ok / suggestion}
- Tags: {ok / suggestion}

### Verdict: {PUBLISH | REVISE | REWRITE}
```

**Verdict rules:**
- **PUBLISH:** No INCORRECT facts. No voice flags. Readability solid. Ship it.
- **REVISE:** Minor issues that can be fixed in place. List the fixes.
- **REWRITE:** Voice drift is systemic — the draft doesn't sound like the founder. Needs another content-draft pass with more interview material.

## Completion

Report status:
- **DONE** — Edit complete, verdict rendered. If PUBLISH, suggest `content-publish` next.
- **DONE_WITH_CONCERNS** — Edit complete but a judgment call on voice/tone. Needs founder's eye.
- **BLOCKED** — Can't fact-check (sources unavailable, claims too vague).
- **NEEDS_CONTEXT** — Draft is missing context that makes editing impossible (no research brief, unclear audience).

## Learnings Capture

After completion, evaluate:
1. Did we catch a factual error? (Note the pattern — where do errors come from?)
2. Did we flag voice drift? (Note which type of sentence triggers it — useful for content-draft.)
3. Was the SEO check useful or just noise for this project? (Calibrate intensity.)
