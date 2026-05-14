---
name: compiled-truth
description: |
  Synthesizes multiple vault pages on a topic into a single authoritative page
  with a timeline of how the understanding evolved. Adapted from gbrain's
  "compiled truth" pattern. Use when a topic has 5+ scattered references across
  vault docs, or when agents keep finding conflicting information.
version: 1.0.0
category: knowledge
interactive: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
  - Edit
  - WebSearch
  - AskUserQuestion
triggers:
  - "compile truth"
  - "compiled truth"
  - "consolidate knowledge"
  - "synthesize topic"
  - "knowledge consolidation"
benefits-from:
  - vault-hygiene
feeds-into: []
qmd:
  - collection: agent-knowledge
    query: "knowledge management compilation patterns"
    limit: 3
reads-learnings: true
writes-learnings: true
---

# Compiled Truth

## Context

Knowledge vaults accumulate multiple perspectives on the same topic over time — bookmarks from different dates, notes from different contexts, articles with conflicting advice. When an agent searches for "Next.js deployment patterns," they might get 8 documents with 3 different (possibly contradictory) approaches, no way to know which is current.

Compiled truth solves this: take N scattered sources, synthesize them into one authoritative page that captures:
- **The current best understanding** (what we know now)
- **The timeline** (how we got here — key shifts in thinking)
- **The conflicts** (where sources disagree and why)
- **The gaps** (what we still don't know)

This is NOT a summary. It's a synthesis with provenance. Every claim traces back to a source. Every conflict is surfaced, not hidden.

## Prerequisites

- Topic identified (either by user or by vault-hygiene orphan analysis)
- qmd CLI available for vault search
- Target vault collection known

## Steps

### Step 1: Gather Sources

Search the target vault for all documents related to the topic:

```bash
qmd query --collection {collection} --query "{topic}" --limit 20
```

Read each result. For each source document, extract:
- **Key claims** (specific, factual statements)
- **Date** (from frontmatter, file path, or content)
- **Context** (why this was saved — bookmark, article, note, agent output)
- **Confidence** (how authoritative is this source?)

### Step 2: Build the Timeline

Sort claims chronologically. Identify:
- **Evolution points:** where the understanding changed
- **Conflicts:** where two sources disagree
- **Superseded claims:** older information replaced by newer

> **CHECKPOINT:** Present the timeline to the user. Ask: "Is this timeline accurate? Any sources missing? Any claims you'd flag as outdated?"

### Step 3: Synthesize the Truth

Write the compiled truth document in this format:

```markdown
---
title: "Compiled Truth: {Topic}"
compiled: {date}
sources: {count}
collection: {vault}
---

# {Topic}

## Current Understanding

{The authoritative synthesis. Present tense. Specific and actionable.
Every claim should be supportable by at least one source.}

## Timeline

| Date | Shift | Source |
|------|-------|--------|
| {date} | {what changed} | {source doc} |
| ... | ... | ... |

## Open Conflicts

{Where sources still disagree. Don't resolve — surface.}
- **{Conflict}:** Source A says X, Source B says Y. {Why they might differ.}

## Gaps

{What we don't know. Specific questions, not vague uncertainty.}
- {Gap 1}
- {Gap 2}

## Sources

{Full list of source documents with paths}
```

### Step 4: Write to Vault

Save the compiled truth to the vault:

```bash
qmd add -c {collection} {output-path}
```

Place compiled truth pages at the vault root or in a `_compiled/` directory for discoverability.

### Step 5: Update Backlinks

If any source documents should link to the compiled truth (because they contain partial or outdated information), add a note at the top:

```markdown
> **See also:** [Compiled Truth: {Topic}]({path}) — authoritative synthesis of this topic.
```

## Completion

Report status:
- **DONE** — Compiled truth written and added to vault. State source count and path.
- **DONE_WITH_CONCERNS** — Written, but unresolved conflicts or low-confidence claims flagged.
- **NEEDS_CONTEXT** — Topic too broad or sources too sparse. Ask user to narrow scope.

## Learnings Capture

After completion, evaluate:
1. Were there surprising conflicts between sources?
2. Did the timeline reveal a pattern (e.g., best practices shifting every 6 months)?
3. Were any sources consistently outdated and candidates for stale-detector flagging?
