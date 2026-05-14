---
name: sprint-review
description: |
  Plan phase. Takes a design doc from sprint-plan and locks scope, architecture,
  data flow, edge cases, and test strategy. Combines CEO-level scope review with
  eng-manager-level technical review in one pass. Use after sprint-plan or when
  someone says "review my plan", "lock the scope", "what's the architecture".
version: 3.0.0
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
  - "review my plan"
  - "lock the scope"
  - "architecture review"
  - "what's the approach"
  - "sprint review"
benefits-from:
  - sprint-plan
feeds-into:
  - code-review
qmd:
  - collection: agent-knowledge
    query: "architecture patterns and technical decisions"
    limit: 5
reads-learnings: true
writes-learnings: true
---

# Sprint Review

## Context

This is the last gate before coding starts. The design doc from `sprint-plan` has the WHAT and WHY. This skill locks the HOW — architecture, data flow, edge cases, test strategy. After this, the coder has everything they need.

Two review lenses in one pass:
1. **CEO lens:** Is the scope right? Too big? Too small? Does it match the portfolio strategy?
2. **Eng lens:** Is the architecture sound? What are the edge cases? What's the test plan?

## Prerequisites

- A design doc from `sprint-plan` (check `skills/_output/sprint-plan-*.md`)
- If no design doc exists, suggest running `sprint-plan` first

## Steps

### Step 1: Load the Design Doc

Find the most recent design doc:
```
ls -t skills/_output/sprint-plan-*.md | head -1
```

Read it fully. Also read any referenced files (charters, existing code, prior art).

### Step 2: CEO Scope Review

Evaluate the scope against four modes (pick one and state which):

| Mode | When | Action |
|------|------|--------|
| **Expand** | Scope is too small, missing obvious value | Propose additions |
| **Selective Expand** | Scope is right but 1-2 cheap wins are sitting on the table | Cherry-pick expansions |
| **Hold** | Scope is right | Confirm and move to eng review |
| **Reduce** | Scope is too ambitious for current constraints | Propose cuts |

Check against:
- Portfolio strategy (read `architecture/build-sequence.md` if needed)
- Time/resource constraints
- Dependencies on other projects
- Whether this is a wedge or a monolith

> **CHECKPOINT:** State your scope recommendation and rationale. Ask: "Agree with this scope call? Any adjustments?"

### Step 3: Architecture Review

For the locked scope, define:

**3a. Technical Approach**
- What stack/tools/patterns?
- Build vs. extend vs. integrate?
- Any existing code to reuse?

**3b. Data Flow**
- What data goes in? What comes out?
- Where is state stored?
- What are the failure modes in data flow?

**3c. Edge Cases**
List at least 5 edge cases. For each:
- What triggers it?
- What's the expected behavior?
- What breaks if we ignore it?

**3d. Dependencies**
- External services or APIs?
- Other projects or shared infrastructure?
- Anything that could block implementation?

### Step 4: Test Strategy

Define what "done" looks like in testable terms:

- **Must-pass criteria:** What MUST work for this to ship?
- **Should-pass criteria:** What SHOULD work but won't block shipping?
- **Test approach:** Unit? Integration? Manual? E2E?
- **Verification method:** How does QA (qa-check skill) verify this?

### Step 5: PRD Deep-Dive Interview

The design doc has the WHAT and WHY. Now we need the HOW and DONE-WHEN — concrete enough that a coder can build it and QA can verify it.

Run 6 PRD-specific questions. Unlike sprint-plan's strategic questions, these are **implementation-focused and reference the design doc directly.** Adapt each question to the specific feature — don't read them like a script.

**PQ1: User Journey**
"The design doc says the narrowest wedge is {Q3 answer from design doc}. Walk me through exactly what the user sees — from landing on the page to getting the result. What do they click? What loads? What appears?"

*Why: Forces concrete UI thinking. Vague scope → vague ACs. A step-by-step journey exposes missing steps.*

**PQ2: Success Moment**
"The insight is {Q4 answer}. What's the ONE thing the user must see or feel that proves this insight is real? What's the screenshot that makes someone share this?"

*Why: Defines the hero AC — the one that matters most. If you nail this, the feature works even if edges are rough.*

**PQ3: Data & State**
"What data does this need? Where does it come from — user input, API, database, scraping? What happens if the data source is empty, slow, or wrong?"

*Why: Surfaces integration complexity and error handling before coding starts.*

**PQ4: Design Impact**
"How much does this change how the product looks and feels? Is it invisible backend work (none), a small UI addition (minor), or a significant visual change (major)? What existing patterns can we reuse?"

*Why: Sets the `design_impact` tag that controls whether the design iterator runs during QA. Avoids both over-polishing and shipping ugly.*

**PQ5: Scope Knife**
"You mentioned {risk from Q6} as a risk. Should we handle that in v1 or explicitly defer it? Is there anything else in the wedge that could be cut without losing the core value?"

*Why: Last chance to cut scope before committing to ACs. Easier to cut here than after tasks are generated.*

**PQ6: Done-When**
"If you could only test 3 things to know this works, what would they be?"

*Why: These become your top 3 acceptance criteria. Everything else is secondary. Keeps the AC list focused.*

> **CHECKPOINT:** After all 6 answers, summarize the findings. Ask: "Did I capture this right? Anything to add before I write the PRD?"

### Step 5b: Write the PRD

Using the deep-dive answers, create the formal PRD. In launchkit projects, use `/create-prd` as the starting point:

```bash
/create-prd
```

Structure the PRD (whether from `/create-prd` or written manually):

```markdown
# PRD-{N}: {Feature Name}

**Date:** {YYYY-MM-DD}
**Design doc:** {link to sprint-plan output}
**Design impact:** {none | minor | major}

## User Journey
{PQ1 answer — step by step}

## Success Moment
{PQ2 answer — the hero screenshot}

## Acceptance Criteria
- [ ] AC-1: {from PQ6 top 3 — the must-haves}
- [ ] AC-2: {second must-have}
- [ ] AC-3: {third must-have}
- [ ] AC-4: {additional from PQ1 journey steps}
- [ ] AC-5: {error handling from PQ3}

## Design Requirements
{PQ4 answer — visual expectations, patterns to reuse}
design_impact: {none | minor | major}

## Technical Constraints
{PQ3 answer — data sources, APIs, performance targets}

## Out of Scope
{PQ5 answer — explicitly deferred items}

## Open Questions
{Anything unresolved from the deep-dive}
```

**Output path:** `product/prds/prd-{N}-{name}.md` (launchkit) or `skills/_output/prd-{date}-{slug}.md` (non-launchkit)

> **CHECKPOINT:** Present the PRD. Ask: "Are these acceptance criteria right? Anything missing or too aggressive?"

### Step 6: Generate Task Breakdown (ai-dev-tasks integration)

With the PRD approved, decompose it into tasks using `/generate-tasks`:

```bash
/generate-tasks product/prds/prd-{N}-{name}.md
# Output: product/tasks/tasks-{N}-prd-{name}.md
```

If no launchkit (non-tool project), write the task breakdown manually.

**Task breakdown rules:**
- One parent task = one atomic commit = one heartbeat for the coder
- Each parent task has clear acceptance criteria
- Subtasks within a parent are executed sequentially, not cherry-picked
- The first parent task should be scaffolding/setup; the last should be integration/cleanup

### Step 7: Write the Locked Plan

**Output path:** `skills/_output/sprint-review-{date}-{slug}.md`

Write the locked plan:

```markdown
## Sprint Review

**Reviewed by:** {agent name}
**Date:** {YYYY-MM-DD}
**Scope mode:** {Expand | Selective Expand | Hold | Reduce}

### Architecture
{3a — technical approach}

### Data Flow
{3b — data flow description}

### Edge Cases
{3c — numbered list}

### Dependencies
{3d — list}

### Test Strategy
{Criteria + approach from Step 4}

### Task Breakdown
{Link to generated task file, or inline breakdown if no /generate-tasks}

### Status: LOCKED
This plan is approved for implementation.
```

> **CHECKPOINT:** Present the locked plan. Ask: "Ready to build? Anything else before we start coding?"

**Next step for coders:** Execute tasks using `/process-tasks` — one parent task per heartbeat, atomic commits, post-commit `/review`.

## Completion

Report status:
- **DONE** — Plan locked, architecture defined, test strategy set. State the file path. Suggest starting implementation.
- **DONE_WITH_CONCERNS** — Plan locked but with noted risks. List them.
- **BLOCKED** — Architecture question that needs research or a decision from the founder.
- **NEEDS_CONTEXT** — Missing technical information (e.g., don't know the API shape, unclear data model).

## Learnings Capture

After completion, evaluate:
1. Did the scope change during review? Why? (Capture the pattern.)
2. Did we find edge cases that surprised us? (Capture for similar projects.)
3. Did architecture search surface a better approach than our first instinct?
4. Any reusable test strategy patterns?
