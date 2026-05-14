---
name: vault-hygiene
description: |
  Nightly vault maintenance cycle. Runs lint, backlink check, entity extraction,
  embedding refresh, and orphan detection across all qmd vaults. Adapted from
  gbrain's Dream Cycle pattern. Use on a schedule (nightly via n8n) or manually
  when vault health degrades.
version: 1.0.0
category: knowledge
interactive: false
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
  - Edit
triggers:
  - "vault hygiene"
  - "clean up vaults"
  - "dream cycle"
  - "vault maintenance"
  - "knowledge hygiene"
benefits-from: []
feeds-into:
  - stale-detector
  - compiled-truth
qmd: []
reads-learnings: true
writes-learnings: true
---

# Vault Hygiene

## Context

Knowledge vaults degrade without maintenance. Documents get stale, links break, new content arrives without embeddings, and orphaned pages accumulate. This skill runs a 5-step maintenance cycle that keeps all qmd vaults healthy.

Inspired by gbrain's "Dream Cycle" — a nightly process that consolidates, indexes, and cleans knowledge while agents sleep.

Run this nightly via n8n, or manually when search quality drops or after bulk ingestion.

## Prerequisites

- `qmd` CLI available (installed on VPS1 at `/root/.local/bin/qmd`)
- Vault directories accessible at `/knowledge/vault-*`
- Sufficient disk space for embedding model (~1.3GB cached at `~/.cache/qmd/models/`)

## Steps

### Step 1: Health Check

Run `qmd status` to get baseline metrics. Record:
- Total docs indexed per collection
- Last update timestamp per collection
- Vector embedding count
- Any warnings or errors

```bash
qmd status
```

If any collection shows "updated: never" or error state, flag it and skip to Step 5 (report).

### Step 2: Lint Markdown

Scan vault directories for common markdown issues:

```bash
# Find files with broken frontmatter (missing closing ---)
for vault in /knowledge/vault-*/; do
  name=$(basename "$vault")
  # Check for files with unclosed frontmatter
  find "$vault" -name "*.md" -exec grep -l '^---$' {} \; | while read f; do
    count=$(grep -c '^---$' "$f" 2>/dev/null || echo 0)
    if [ "$count" -eq 1 ]; then
      echo "LINT: $name — unclosed frontmatter: $f"
    fi
  done
  # Check for empty files
  find "$vault" -name "*.md" -empty -exec echo "LINT: $name — empty file: {}" \;
  # Check for very large files (>100KB — likely not atomic knowledge)
  find "$vault" -name "*.md" -size +100k -exec echo "LINT: $name — oversized (>100KB): {}" \;
done
```

Record lint findings. These are advisory — don't auto-fix, just report.

### Step 3: Backlink & Orphan Check

Find documents that link to non-existent files (broken links) and documents that nothing links to (orphans):

```bash
for vault in /knowledge/vault-*/; do
  name=$(basename "$vault")
  # Count total docs
  total=$(find "$vault" -name "*.md" | wc -l)
  # Find wikilinks [[...]] and check targets exist
  grep -roh '\[\[[^]]*\]\]' "$vault" --include="*.md" 2>/dev/null | \
    sort -u | sed 's/\[\[//;s/\]\]//' | while read link; do
      # Check if target exists (with or without .md extension)
      if [ ! -f "$vault/$link" ] && [ ! -f "$vault/$link.md" ]; then
        echo "BROKEN_LINK: $name — [[${link}]] target not found"
      fi
    done
  echo "STATS: $name — $total total docs"
done
```

### Step 4: Re-index & Embed

Update the qmd index and refresh embeddings for any new or changed documents:

```bash
# Re-index all collections (picks up new/changed/deleted files)
qmd update

# Refresh embeddings (only processes new/changed docs, skips existing)
qmd embed
```

Record the output — how many docs were re-indexed, how many embeddings were generated.

### Step 5: Report

Generate a summary report with:
- **Health:** overall vault status (healthy / degraded / broken)
- **Lint findings:** count per vault, top issues
- **Broken links:** count and list
- **Orphan candidates:** count per vault
- **Index stats:** docs added/removed since last run, embedding coverage
- **Action items:** anything that needs human attention

Format as a structured summary. If running via n8n, this becomes the notification payload.

## Completion

Report status:
- **DONE** — All vaults processed, no critical issues found.
- **DONE_WITH_CONCERNS** — Vaults processed but lint/link issues found that need attention.
- **BLOCKED** — qmd CLI unavailable or vault directories inaccessible.

## Learnings Capture

After completion, evaluate:
1. Were there recurring lint patterns across vaults?
2. Did any vault have significantly more broken links than others?
3. Did embedding refresh take unusually long (possible model or disk issue)?
