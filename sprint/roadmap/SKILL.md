---
name: roadmap
description: |
  Decompose phase. Takes a design doc from sprint-plan and breaks it into
  sequenced, atomic features — each one becoming its own PRD via sprint-review.
  Includes CEO scope review. Use after sprint-plan or when someone says
  "break this down", "what are the features", "decompose this", "roadmap".
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
  - "break this down"
  - "decompose"
  - "feature map"
  - "roadmap"
  - "what are the features"
benefits-from:
  - sprint-plan
feeds-into:
  - sprint-review
qmd:
  - collection: agent-knowledge
    query: "architecture patterns and feature decomposition"
    limit: 5
reads-learnings: true
writes-learnings: false
---

# Roadmap

## Context

The bridge between strategy and execution. sprint-plan produces the WHAT and WHY.
This skill produces the SEQUENCE — which atomic features to build, in what order,
with what dependencies. Each feature becomes input to its own sprint-review cycle.

**Why this exists:** Jumping from a high-level plan to a monolithic PRD forces all
decisions at once and prevents learnings from earlier features from shaping later ones.
This skill decomposes the plan so features are built one at a time, with retros between
them. Just-in-time PRDs.

## Prerequisites

- A design doc from `sprint-plan` (check `skills/_output/sprint-plan-*.md`)
- If no design doc exists, suggest running `sprint-plan` first

## Steps

### Step 1: Load the Design Doc

Find the design doc:
```
ls -t skills/_output/sprint-plan-*.md | head -5
```

Read it fully. Also read:
- Project charter (`projects/{project}/CHARTER.md`) if it exists
- Build sequence (`architecture/build-sequence.md`) for portfolio context
- Any existing roadmap for this project (to update rather than create fresh)
- Relevant vault references mentioned in the design doc

### Step 2: CEO Scope Review

Evaluate the overall scope against four modes (pick one and state which):

| Mode | When | Action |
|------|------|--------|
| **Expand** | Scope is too small, missing obvious value | Propose additions |
| **Selective Expand** | Scope is right but 1-2 cheap wins are sitting on the table | Cherry-pick expansions |
| **Hold** | Scope is right | Confirm and move to decomposition |
| **Reduce** | Scope is too ambitious for current constraints | Propose cuts |

Check against:
- Portfolio strategy and priorities
- Time/resource constraints
- Dependencies on other projects
- Whether this is a wedge or a monolith
- Cost constraints (EUR 200/mo portfolio cap)

> **CHECKPOINT:** State your scope recommendation and rationale. Ask: "Agree with this scope call? Any adjustments before I decompose?"

### Step 3: Identify Atomic Features

Break the locked scope into atomic features. Each feature must be:

- **Independently valuable:** Produces a working, testable artifact on its own
- **Small enough for one sprint-review → code → qa → ship cycle**
- **Clear inputs and outputs:** What does this feature need? What does it produce?
- **Demoable:** You can show the founder something working after shipping it

**How to decompose:**
1. Trace the data flow end-to-end (from the design doc)
2. Find natural seams — where does one component's output become another's input?
3. Each seam is a feature boundary
4. The first feature should be the one that validates the riskiest assumption
5. The last feature should be integration/glue

**Anti-patterns to avoid:**
- Features that are just "setup" with no visible output (fold into the first real feature)
- Features so small they're just tasks (if it's < 2 hours of work, merge it into an adjacent feature)
- Features that can't be tested without another feature existing (reorder or merge)

### Step 4: Sequence and Dependencies

For each feature, define:
- **Depends on:** Which features must ship first?
- **Enables:** Which features can start after this ships?
- **Risk level:** How uncertain is this feature? (High-risk features go first)
- **Estimated effort:** S/M/L (relative, not hours)

Order by: risk first (validate assumptions early), then dependencies (unblock downstream), then effort (quick wins build momentum).

### Step 5: Define the Execution Loop

State the execution protocol explicitly in the output:

```
For each feature (in sequence):
  1. sprint-review → atomic PRD + task breakdown
  2. code → implement
  3. qa-check → verify
  4. ship-pr → merge
  5. retro → extract learnings
  6. CHECKPOINT: do learnings change the roadmap?
     YES → update roadmap (reorder/add/cut features), note what changed and why
     NO → advance pointer to next feature
```

Rules:
- Never write more than 1 PRD ahead
- retro MUST happen before next sprint-review
- Roadmap is a living doc — retro can change it
- If a feature is cut mid-execution, mark it `[CUT]` with reason, don't delete

> **CHECKPOINT:** Present the feature list and sequence. Ask: "Does this sequence make sense? Should anything move earlier or later? Any features missing or too granular?"

### Step 6: Write the Roadmap

**Output path:** `skills/_output/roadmap-{date}-{slug}.md`

```markdown
---
skill: roadmap
project: {project}
date: {YYYY-MM-DD}
status: active
slug: {slug}
sprint-plan: {path to sprint-plan output}
---

# Roadmap: {Project Name}

**Scope mode:** {Expand | Selective Expand | Hold | Reduce}
**Scope rationale:** {1-2 sentences}

## Execution Protocol

One feature at a time. sprint-review → code → qa → ship → retro → checkpoint.
Never write more than 1 PRD ahead. Retro learnings may change this roadmap.

## Features

### Feature 1: {Name} [{STATUS}]
{1-2 sentence description}
- **Depends on:** {none | feature N}
- **Enables:** {feature N}
- **Risk:** {high | medium | low} — {why}
- **Effort:** {S | M | L}
- **Done when:** {1-sentence acceptance summary}

### Feature 2: {Name} [{STATUS}]
...

## Status Legend
- `[PLANNED]` — not yet started
- `[ACTIVE]` — currently in sprint-review → code → qa → ship loop
- `[DONE]` — shipped + retro'd
- `[CUT]` — removed from scope (with reason)
- `[CHANGED]` — modified after a retro (with reason)

## Revision Log
| Date | Change | Trigger |
|------|--------|---------|
| {date} | Initial roadmap | sprint-plan |
```

> **CHECKPOINT:** Present the roadmap. Ask: "Ready to start Feature 1? I'll run sprint-review on it."

## Completion

Report status:
- **DONE** — Roadmap written with {N} features sequenced. State the file path. Suggest starting sprint-review on Feature 1.
- **DONE_WITH_CONCERNS** — Roadmap written but with noted risks. List them.
- **BLOCKED** — Can't decompose without more information. State what's missing.
- **NEEDS_CONTEXT** — Need user input to determine feature boundaries.

## Updating the Roadmap

This skill can be re-invoked to update an existing roadmap. When updating:
1. Read the current roadmap (`skills/_output/roadmap-*-{slug}.md`)
2. Read the retro that triggered the update (`skills/_output/retro-*.md` or `skills/_learnings/`)
3. Present what changed and why
4. Update feature statuses, reorder if needed, add/cut features
5. Add entry to Revision Log
6. Advance the pointer to the next `[PLANNED]` feature
