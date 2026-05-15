---
name: retro
description: |
  Reflect phase. Extracts learnings from a completed sprint and writes them to
  the project's learnings.jsonl. Reviews what worked, what didn't, and what to
  do differently. Use after a PR is merged, a sprint completes, or when someone
  says "retro", "what did we learn", "retrospective".
version: 2.0.0
category: sprint
interactive: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
  - AskUserQuestion
triggers:
  - "retro"
  - "retrospective"
  - "what did we learn"
  - "lessons learned"
  - "debrief"
benefits-from:
  - ship-pr
feeds-into:
  - roadmap
qmd: []
reads-learnings: true
writes-learnings: true
---

# Retro

## Context

The compound learning engine. Every sprint produces insights — about the codebase, the process, the tools, the domain. Most of these get lost when the session ends. This skill captures them so future sprints start smarter.

This is NOT a ceremony or a meeting format. It's a 5-minute extraction pass that compounds over time. Fast, specific, actionable.

## Required Outputs (do not skip)

This skill produces exactly 1 file (appended). It must be updated before reporting DONE.

1. **Learnings** → `skills/_learnings/{project-slug}.jsonl` (append new learning records)
2. **Roadmap update** → update feature status in `product/roadmap/roadmap-*.md` (if applicable)

## Prerequisites

- A completed sprint (PR merged, feature shipped, or work explicitly concluded)
- Access to sprint artifacts (design doc, review, QA results)

## Steps

### Step 1: Gather the Sprint Artifacts

Find and read the artifacts from this sprint:

```bash
# Design docs and reviews
ls -t skills/_output/sprint-*.md 2>/dev/null | head -5

# Recent commits
git log --oneline -20

# Any PR that was just merged
gh pr list --state merged --limit 3
```

### Step 2: Three-Question Review

Ask yourself (and the user if interactive):

**What worked?**
- What went faster than expected?
- What decision turned out to be right?
- What tool, pattern, or approach should we reuse?

**What didn't work?**
- What took longer than expected? Why?
- What assumption was wrong?
- What broke that we didn't anticipate?

**What would we do differently?**
- Knowing what we know now, what would we change?
- Is there a process improvement worth capturing?
- Should we update any existing skill based on this experience?

> **CHECKPOINT:** If interactive, ask the user: "Anything I missed? Any lessons from your perspective that I wouldn't see from the code?"

### Step 3: Extract Learnings

From the three-question review, identify reusable insights. Each learning must be:
- **Specific:** Not "tests are important" but "this project's API endpoints need integration tests against the real DB because mocks missed the Postgres-specific timestamp behavior"
- **Actionable:** Someone reading this learning should know what to DO differently
- **Durable:** Still relevant in a month, not just for today's session

Filter ruthlessly. A good sprint produces 1-3 learnings. Most produce 0-1. Don't manufacture learnings for the sake of it.

### Step 4: Write to learnings.jsonl

For each learning, append to `skills/_learnings/{project-slug}.jsonl`:

```json
{
  "ts": "{ISO 8601}",
  "skill": "retro",
  "type": "{operational | technical | process | taste}",
  "key": "{kebab-case-unique-key}",
  "insight": "{the learning — one sentence, specific, actionable}",
  "confidence": {0.0-1.0},
  "source": "{observed | corrected | validated}"
}
```

**Type guide:**
- `operational`: How we do things (e.g., "always run migrations before deploying")
- `technical`: Code/infra patterns (e.g., "this project uses Drizzle ORM, not Prisma")
- `process`: Workflow improvements (e.g., "sprint-plan Q3 consistently surfaces scope creep early")
- `taste`: Design/style preferences (e.g., "founder prefers minimal UI with lots of whitespace")

**Source guide:**
- `observed`: Agent noticed this during the sprint
- `corrected`: Founder corrected the agent's approach
- `validated`: Founder confirmed a non-obvious choice was right

### Step 5: Run Compound Engineering (ai-dev-tasks integration)

If this is a launchkit project, run the compound engineering workflow to extract learnings into the project's CLAUDE.md and qmd vault:

```bash
# Run compound learning extraction
/workflows:compound
```

This does two things that complement the retro's learnings.jsonl writes:
- **CLAUDE.md rules:** Technical patterns become HOT-layer rules (loaded every session, max 50)
- **qmd vault patterns:** Broader insights written to the project's vault (WARM layer, searchable)

The retro skill's learnings.jsonl (Step 4) captures process/operational insights. `/workflows:compound` captures technical/code patterns. Both are needed — they're complementary, not duplicative.

If NOT a launchkit project, skip this step. The learnings.jsonl from Step 4 is sufficient.

### Step 6: Roadmap Checkpoint

If this retro is part of a multi-feature roadmap execution loop:

1. Read the active roadmap (`skills/_output/roadmap-*.md`)
2. Mark the just-completed feature as `[DONE]`
3. Evaluate: **do any learnings from this retro change the roadmap?**
   - Should a planned feature be cut? (validated assumption was wrong)
   - Should a new feature be added? (discovered need during implementation)
   - Should features be reordered? (dependency changed, risk reassessed)
   - Should a feature's scope change? (learned something about the domain)
4. If YES: update the roadmap — change statuses, reorder, add/cut features, add revision log entry
5. If NO: advance the pointer to the next `[PLANNED]` feature
6. State what the next feature is and suggest running `sprint-review` on it

> **CHECKPOINT:** If roadmap changes are needed, present them. Ask: "Agree with these roadmap changes? Ready to move to Feature N?"

### Step 7: Evaluate Skill Updates

Check if any learning warrants updating a skill:
- Should `code-review` check for something it missed this sprint?
- Should `sprint-plan` ask a different forcing question for this project type?
- Should `qa-check` add a new verification step?

If yes, note the proposed skill update but don't make it — flag for the founder to approve.

### Step 8: Report

```markdown
## Retro: {sprint description}

**Date:** {YYYY-MM-DD}
**Sprint duration:** {start → end}
**Artifacts:** {list of design docs, PRs, reviews}

### What Worked
- {item}

### What Didn't Work
- {item}

### Learnings Captured
| Key | Type | Insight |
|-----|------|---------|
| {key} | {type} | {insight} |

### Proposed Skill Updates
- {skill}: {proposed change} (pending founder approval)

### Sprint Velocity Notes
- {any observations about speed, efficiency, blockers}
```

## Completion

Report status:
- **DONE** — Retro complete. State how many learnings were captured and where. Sprint chain complete.
- **DONE_WITH_CONCERNS** — Retro complete but a systemic issue was identified that needs attention beyond a learning. State what.
- **BLOCKED** — Can't assess the sprint (no artifacts found, unclear what was done).
- **NEEDS_CONTEXT** — Need user input to evaluate what worked/didn't.

## Learnings Capture

This skill IS the learnings capture mechanism. The learnings are written in Step 4 above. No additional capture needed — just ensure Step 4 actually executed.
