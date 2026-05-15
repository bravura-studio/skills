---
name: sprint-plan
description: |
  Think phase. Takes a raw idea, problem, or feature request and produces a
  structured design doc through 6 forcing questions. Use when someone says
  "I have an idea", "let's build X", "we need to solve Y", or at the start
  of any non-trivial work.
version: 1.0.0
category: sprint
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
  - "I have an idea"
  - "let's build"
  - "we need to"
  - "new feature"
  - "sprint plan"
  - "think through"
benefits-from: []
feeds-into:
  - roadmap
qmd:
  - collection: agent-knowledge
    query: "architecture patterns relevant to this problem"
    limit: 5
reads-learnings: true
writes-learnings: true
---

# Sprint Plan

## Context

Every non-trivial piece of work starts here. The goal is to go from a vague idea to a concrete design doc that a coder can execute against. The forcing questions prevent premature building — the most expensive bugs are the ones you code before thinking.

Adapted from gstack's /office-hours (Garry Tan) and the BUILD.FUN.FREE ai-dev-tasks pipeline (vision → roadmap → PRDs → tasks).

## Prerequisites

- A problem, idea, or feature request (can be vague — that's the point)
- Access to qmd vaults for prior art search

## Steps

### Step 1: Understand the Raw Input

Read or listen to what the user wants. Don't interpret yet — just capture.

If the input references existing code, read the relevant files. If it references a project, check its charter (`projects/{project}/CHARTER.md`).

### Step 2: Search for Prior Art

Before thinking from scratch, check:
1. **qmd vaults** — Has this problem been solved before? Are there patterns?
2. **Project learnings** — Did we learn something relevant last time?
3. **Existing code** — Is there something we can extend rather than build new?

Spend 2-3 queries on this. Don't skip it even if the idea seems novel.

### Step 3: Run the 6 Forcing Questions

Ask these one at a time. Wait for an answer before moving to the next. Each question should be adapted to the specific idea — don't read them verbatim like a script.

**Q1: What's the pain?**
What specific problem does this solve? Who feels it? How often? Get concrete examples, not abstractions.

**Q2: How does the status quo fail?**
What do people do today? Why is that insufficient? What's the cost of doing nothing?

**Q3: What's the narrowest wedge?**
What's the smallest version that delivers value? Strip features until you can't strip more without losing the point.

**Q4: What's the observation?**
What did you notice that others missed? This is the insight that makes this worth doing now rather than later.

**Q5: What does 10x look like?**
If this worked perfectly beyond all expectations, what would that look like? Don't constrain — dream. Then we'll scope back.

**Q6: What's the risk?**
What could go wrong? What assumptions might be wrong? What's the worst-case failure mode?

> **CHECKPOINT:** Confirm with user that the answers capture the intent before proceeding to the design doc.

### Step 4: Draft the Design Doc

Write a structured design doc based on the answers. Save to a predictable location so `sprint-review` can find it.

**Output path:** `skills/_output/sprint-plan-{date}-{slug}.md`

**Design doc format:**

```markdown
# {Title}

**Date:** {YYYY-MM-DD}
**Author:** {who initiated} + Ferro
**Status:** Draft — pending sprint-review
**Project:** {project name}

## Problem

{Q1 + Q2 synthesis — what's broken and why it matters}

## Insight

{Q4 — the observation that makes this worth doing}

## Proposal

{What we're going to build. Concrete, specific.}

## Scope

### In Scope
{Narrowest wedge from Q3}

### Out of Scope
{What we're explicitly NOT doing — from the gap between Q3 and Q5}

### 10x Vision
{Q5 — where this could go if it works. Not committed, just noted.}

## Risks

{Q6 — what could go wrong, mitigations}

## Open Questions

{Anything unresolved from the forcing questions}

## Prior Art

{What the vault/code search found — patterns to reuse, mistakes to avoid}
```

### Step 5: Confirm the Design Doc

> **CHECKPOINT:** Present the design doc to the user. Ask: "Does this capture what you want to build? Anything to add, cut, or change before we lock scope in sprint-review?"

Iterate on feedback. The design doc should feel RIGHT to the user before moving on.

## Completion

Report status:
- **DONE** — Design doc written, user confirmed. State the file path. Suggest invoking `sprint-review` next.
- **DONE_WITH_CONCERNS** — Design doc written but user had unresolved reservations. List them.
- **BLOCKED** — Cannot proceed (e.g., need input from someone else, missing critical context).
- **NEEDS_CONTEXT** — User couldn't answer a forcing question. State which one and what's needed.

## Learnings Capture

After completion, evaluate:
1. Did the forcing questions surface something non-obvious?
2. Did the vault search find useful prior art? (If not, is there a gap in our vaults?)
3. Did the user push back on scope? (Capture the taste preference.)
4. Any patterns worth noting for this project type?

If a reusable insight emerged, append to `skills/_learnings/{project-slug}.jsonl`.
