---
name: stale-detector
description: |
  Finds vault documents that are likely stale — not updated in N days, referencing
  deprecated tools/patterns, or containing time-sensitive claims past their shelf
  life. Flags for review, update, or archival. Use after vault-hygiene or when
  search results feel outdated.
version: 1.0.0
category: knowledge
interactive: false
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
triggers:
  - "stale detection"
  - "find stale docs"
  - "knowledge expiry"
  - "outdated docs"
  - "vault cleanup"
benefits-from:
  - vault-hygiene
feeds-into:
  - compiled-truth
qmd: []
reads-learnings: true
writes-learnings: true
---

# Stale Detector

## Context

Knowledge has a shelf life. A "best deployment strategy" article from 6 months ago might recommend patterns that are now anti-patterns. Agent bookmarks pile up without curation. Vault docs reference tools that have been deprecated, APIs that have changed, or practices that the team has moved past.

This skill scans vaults for staleness signals and produces a triage list: what to update, what to archive, what to leave alone.

## Prerequisites

- Vault directories accessible at `/knowledge/vault-*`
- `qmd` CLI available for listing and querying

## Steps

### Step 1: Age Scan

Find documents by last-modified time. Flag anything older than the threshold (default: 90 days).

```bash
for vault in /knowledge/vault-*/; do
  name=$(basename "$vault")
  echo "=== $name ==="
  # Files not modified in 90+ days
  find "$vault" -name "*.md" -mtime +90 | wc -l
  echo "  files older than 90 days"
  # Files not modified in 180+ days
  find "$vault" -name "*.md" -mtime +180 | wc -l
  echo "  files older than 180 days"
done
```

Age alone isn't sufficient for staleness — a reference doc from 2024 might still be perfectly valid. Use age as a filter, then apply content signals.

### Step 2: Content Staleness Signals

Scan flagged documents for signals that indicate the content is outdated:

**Deprecated technology references:**
```bash
# Search for known deprecated patterns across vaults
grep -rl "pages router\|getServerSideProps\|getStaticProps" /knowledge/vault-*/  --include="*.md" 2>/dev/null
grep -rl "node 16\|node 18\|react 17\|next 12\|next 13" /knowledge/vault-*/ --include="*.md" 2>/dev/null
grep -rl "openai.*gpt-3\|gpt-3.5\|davinci\|text-ada" /knowledge/vault-*/ --include="*.md" 2>/dev/null
```

**Time-sensitive language:**
```bash
# Find docs with temporal claims that may have expired
grep -rl "as of 202[0-4]\|currently\|right now\|just launched\|beta\|early access" /knowledge/vault-*/ --include="*.md" 2>/dev/null
```

**Broken URLs** (sample check — don't crawl everything):
```bash
# Extract a sample of URLs and check for 404s
grep -roh 'https://[^ )*"]*' /knowledge/vault-*/ --include="*.md" 2>/dev/null | \
  sort -u | shuf | head -20 | while read url; do
    code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 5 "$url" 2>/dev/null || echo "timeout")
    if [ "$code" = "404" ] || [ "$code" = "410" ]; then
      echo "DEAD_URL: $url ($code)"
    fi
  done
```

### Step 3: Classify and Triage

For each flagged document, classify:

| Category | Action | Criteria |
|----------|--------|----------|
| **Archive** | Move to `vault-discarded/` | Content fully superseded, no unique value |
| **Update** | Flag for revision | Core insight still valid but details outdated |
| **Compile** | Feed to compiled-truth | 3+ docs on same topic, need synthesis |
| **Keep** | No action | Evergreen content, still accurate |

### Step 4: Generate Report

Produce a structured report:

```markdown
## Stale Knowledge Report — {date}

### Summary
- Total docs scanned: {N}
- Flagged as potentially stale: {N}
- Recommended archive: {N}
- Recommended update: {N}
- Compile candidates: {N}

### Archive Candidates
| Vault | File | Reason |
|-------|------|--------|
| ... | ... | ... |

### Update Candidates
| Vault | File | Signal |
|-------|------|--------|
| ... | ... | ... |

### Compile Candidates
| Topic | Doc Count | Vaults |
|-------|-----------|--------|
| ... | ... | ... |
```

Write the report to `skills/_output/stale-report-{date}.md`.

### Step 5: Execute Archival (optional)

If running autonomously (nightly cycle), move archive candidates:

```bash
# Only if confidence is high and doc is clearly superseded
mv /knowledge/vault-{name}/{file} /knowledge/vault-discarded/{name}/{file}
qmd update  # Re-index after moves
```

For update and compile candidates, create Paperclip issues or flag in the report for human review.

## Completion

Report status:
- **DONE** — Scan complete, report generated. State: {N} flagged, {N} archived, {N} need review.
- **DONE_WITH_CONCERNS** — High number of stale docs detected. Vault may need bulk cleanup.
- **BLOCKED** — Vault directories inaccessible or qmd index corrupted.

## Learnings Capture

After completion, evaluate:
1. Which vault had the highest stale ratio? (Signal about ingestion quality)
2. Were there patterns in what goes stale? (e.g., "how-to" articles stale faster than "concept" articles)
3. Did any deprecated tech signals need updating in the detector itself?
