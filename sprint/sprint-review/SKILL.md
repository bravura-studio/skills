---
name: sprint-review
description: |
  PRD phase. Takes ONE feature from a roadmap and produces an atomic PRD with
  architecture, acceptance criteria, edge cases, and task breakdown. Use after
  roadmap or when someone says "review this feature", "write the PRD",
  "lock the architecture", "sprint review".
version: 4.0.0
category: sprint
interactive: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Edit
  - Write
  - WebSearch
  - AskUserQuestion
triggers:
  - "review this feature"
  - "write the PRD"
  - "lock the architecture"
  - "sprint review"
benefits-from:
  - roadmap
feeds-into:
  - build
qmd:
  - collection: agent-knowledge
    query: "architecture patterns and technical decisions"
    limit: 5
reads-learnings: true
writes-learnings: true
---

# Sprint Review

## Context

The last gate before coding starts. Takes ONE atomic feature from the roadmap and
produces everything a coder needs: architecture, acceptance criteria, edge cases,
test strategy, and task breakdown.

**Scope:** This skill handles ONE feature only. If you have a high-level plan that
needs decomposition into features, run `roadmap` first. CEO scope review lives in
`roadmap` — this skill assumes scope is already locked.

**Just-in-time PRDs:** This skill runs once per feature in the roadmap's execution
loop. Previous features' retros inform this PRD. Never batch-write PRDs.

## Required Outputs (do not skip)

This skill produces exactly 3 files. All 3 must exist before reporting DONE.

1. **PRD** → `product/prds/prd-{N}-{name}.md`
2. **Task file** → `product/tasks/tasks-prd-{N}-{name}.md` (follows generate-tasks format: PRD summary header, parent tasks mapped to ACs, subtasks with embedded PRD context, validation + dependencies per parent)
3. **Locked plan** → `product/sprint-reviews/sprint-review-{date}-{slug}.md` (links PRD + task file, architecture, test strategy)

Before writing the completion status, verify all 3 files exist.

## Prerequisites

- A roadmap with sequenced features (check `product/roadmap/` or `skills/_output/roadmap-*.md`)
- OR a sprint-plan for simple/single-feature work (check `product/sprint-plan/` or `skills/_output/sprint-plan-*.md`)
- If neither exists, suggest running `sprint-plan` → `roadmap` first
- For the second feature onward: the previous feature's retro should exist

## Steps

### Step 1: Load Context

```bash
# Find the roadmap
ls -t skills/_output/roadmap-*.md 2>/dev/null | head -1

# Find the sprint-plan (for reference)
ls -t skills/_output/sprint-plan-*.md 2>/dev/null | head -1

# Find previous retros (learnings from prior features)
ls -t skills/_output/retro-*.md 2>/dev/null | head -5

# Find project learnings
ls skills/_learnings/*.jsonl 2>/dev/null
```

Read the roadmap, identify which feature is `[ACTIVE]` or next `[PLANNED]`.
Read the sprint-plan for strategic context.
Read any previous retros — their learnings should shape this PRD.

Also read any referenced files (charters, existing code, prior art, vault docs).

### Step 2: Architecture Review

For the target feature, define:

**2a. Technical Approach**
- What stack/tools/patterns?
- Build vs. extend vs. integrate?
- Any existing code to reuse?
- How does this feature connect to already-shipped features?

**2b. Data Flow**
- What data goes in? What comes out?
- Where is state stored?
- What are the failure modes in data flow?

**2c. Edge Cases**
List at least 5 edge cases. For each:
- What triggers it?
- What's the expected behavior?
- What breaks if we ignore it?

**2d. Dependencies**
- External services or APIs?
- Other features that must be shipped first?
- Anything that could block implementation?

### Step 3: Test Strategy

Define what "done" looks like in testable terms:

- **Must-pass criteria:** What MUST work for this feature to ship?
- **Should-pass criteria:** What SHOULD work but won't block shipping?
- **Test approach:** Unit? Integration? Manual? E2E?
- **Verification method:** How does QA (qa-check skill) verify this?

### Step 4: PRD Deep-Dive Interview

Run 6 PRD-specific questions, adapted to THIS specific feature. Unlike sprint-plan's
strategic questions, these are **implementation-focused.** Don't read them like a script
— adapt to the feature.

**PQ1: User Journey**
"Walk me through exactly what happens when this feature runs — from trigger to output.
What goes in? What comes out? What does the user see at each step?"

*Why: Forces concrete thinking. Vague features → vague ACs.*

**PQ2: Success Moment**
"What's the ONE thing that proves this feature works? What's the artifact or output
that makes you say 'yes, this is right'?"

*Why: Defines the hero AC — the one that matters most.*

**PQ3: Data & State**
"What data does this feature need? Where does it come from? What happens if the
data source is empty, slow, or wrong?"

*Why: Surfaces integration complexity and error handling.*

**PQ4: Design Impact**
"How much does this change how the product looks and feels? Is it invisible backend
work (none), a small UI addition (minor), or a significant visual change (major)?
What existing patterns can we reuse?"

*Why: Sets the `design_impact` tag for QA.*

**PQ5: Scope Knife**
"Is there anything in this feature that could be cut without losing the core value?
Any edge cases we should explicitly defer?"

*Why: Last chance to cut before committing to ACs.*

**PQ6: Done-When**
"If you could only test 3 things to know this feature works, what would they be?"

*Why: These become your top 3 acceptance criteria.*

> **CHECKPOINT:** After all 6 answers, summarize. Ask: "Did I capture this right? Anything to add before I write the PRD?"

### Step 5: Write the PRD

Structure the PRD:

```markdown
# PRD-{N}: {Feature Name}

**Date:** {YYYY-MM-DD}
**Roadmap:** {link to roadmap output}
**Feature:** {N} of {total}
**Design impact:** {none | minor | major}

## User Journey
{PQ1 answer — step by step}

## Success Moment
{PQ2 answer — the hero artifact}

## Acceptance Criteria
- [ ] AC-1: {from PQ6 top 3 — the must-haves}
- [ ] AC-2: {second must-have}
- [ ] AC-3: {third must-have}
- [ ] AC-4: {additional from PQ1 journey steps}
- [ ] AC-5: {error handling from PQ3}

## Architecture
{2a — technical approach}

## Data Flow
{2b — data flow description}

## Edge Cases
{2c — numbered list}

## Design Requirements
{PQ4 answer — visual expectations, patterns to reuse}
design_impact: {none | minor | major}

## Technical Constraints
{PQ3 answer — data sources, APIs, performance targets}

## Out of Scope
{PQ5 answer — explicitly deferred items}

## Learnings from Prior Features
{Summary of relevant retro insights that shaped this PRD}

## Open Questions
{Anything unresolved}
```

**Output path:** `product/prds/prd-{N}-{name}.md` (launchkit) or `skills/_output/prd-{date}-{slug}.md` (non-launchkit)

> **CHECKPOINT:** Present the PRD. Ask: "Are these acceptance criteria right? Anything missing or too aggressive?"

### Step 6: Generate Task Breakdown

With the PRD approved, decompose into tasks.

**Output path:** `product/tasks/tasks-prd-{N}-{name}.md`

In launchkit projects, use `/generate-tasks`:
```bash
/generate-tasks product/prds/prd-{N}-{name}.md
```

For all projects (launchkit or not), the task file MUST follow this format:

```markdown
# Tasks: [Feature Name]

**PRD:** product/prds/prd-{N}-{name}.md
**Created:** [date]
**Status:** Planning

### PRD Summary
> **Problem:** [1-sentence]
> **Goal:** [Key goal]
> **Success:** [Primary metric / done-when]
> **Scope:** [What's explicitly out of scope]

---

## Parent Tasks

- [ ] 1. [Parent task 1] — AC-1, AC-2
- [ ] 2. [Parent task 2] — AC-3, AC-4
...

---

## Task 1: [Parent task name]

### PRD Context
> **AC-1**: [Exact acceptance criterion]
> **AC-2**: [Exact acceptance criterion]
> **Technical**: [Key implementation note, if task-relevant]

### Subtasks
- [ ] 1.1 [Specific implementation step]
- [ ] 1.2 [Specific implementation step]
- [ ] 1.3 [Specific implementation step]

### Validation
- Verify: AC-1, AC-2 [specific ACs this task must satisfy]

### Dependencies
- Requires: [prior tasks if any]
- Enables: [subsequent tasks if any]

## Task 2: [Next parent task]
...
```

**Task breakdown rules:**
- One parent task = one atomic commit = one heartbeat for the coder
- Each parent task maps to 1-5 acceptance criteria from the PRD
- Each parent task has embedded PRD context (3-10 lines — if >10, split the task)
- Subtasks within a parent are executed sequentially, not cherry-picked
- The first parent task should be scaffolding/setup; the last should be integration/cleanup
- Validation section references specific AC-N items from the PRD

### Step 7: Write the Locked Plan

**Output path:** `product/sprint-reviews/sprint-review-{date}-{slug}.md`

```markdown
---
skill: sprint-review
project: {project}
date: {YYYY-MM-DD}
feature: {feature N name}
roadmap: {path to roadmap}
prd: {path to PRD}
---

## Sprint Review: {Feature Name}

**Reviewed by:** {agent name}
**Date:** {YYYY-MM-DD}
**Feature:** {N} of {total} from roadmap

### Architecture
{2a — technical approach}

### Data Flow
{2b — data flow}

### Edge Cases
{2c — numbered list}

### Dependencies
{2d — list}

### Test Strategy
{Criteria + approach from Step 3}

### Task Breakdown
{Link to generated task file, or inline breakdown}

### Learnings Applied
{Which retro insights from prior features influenced this plan}

### Status: LOCKED
This plan is approved for implementation.
```

> **CHECKPOINT:** Present the locked plan. Ask: "Ready to build? Anything else before coding starts?"

### Step 8: Update Roadmap Status

Update the roadmap file to mark this feature as `[ACTIVE]`:
- Set the target feature status to `[ACTIVE]`
- Add a revision log entry

**Next steps for the execution loop:**
1. Code the feature (using tasks from Step 6)
2. `qa-check` to verify
3. `ship-pr` to merge
4. `retro` to extract learnings
5. Check if retro learnings change the roadmap
6. Run `sprint-review` on the next feature

## Completion

Report status:
- **DONE** — PRD written, plan locked, tasks generated. State file paths. Suggest starting implementation.
- **DONE_WITH_CONCERNS** — Plan locked but with noted risks. List them.
- **BLOCKED** — Architecture question that needs research or a decision from the founder.
- **NEEDS_CONTEXT** — Missing technical information.

## Learnings Capture

After completion, evaluate:
1. Did any retro learnings from prior features change how we approached this PRD?
2. Did we find edge cases that surprised us?
3. Did architecture search surface a better approach than our first instinct?
