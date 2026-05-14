---
name: deploy-check
description: |
  Post-ship health check. Verifies a deployment is live, healthy, and performing
  correctly after merge/deploy. Checks DNS, HTTP status, key pages, console errors,
  and Vercel deployment status. Use after merging a PR, after a Vercel deploy, or
  when someone says "is it live", "check the deploy", "post-ship check".
version: 1.0.0
category: ops
interactive: false
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
triggers:
  - "is it live"
  - "check the deploy"
  - "post-ship check"
  - "deploy check"
  - "is it working"
benefits-from:
  - ship-pr
feeds-into:
  - retro
qmd: []
reads-learnings: true
writes-learnings: true
---

# Deploy Check

## Context

The gap between "PR merged" and "confirmed working in production." Vercel deploys are usually instant, but things break: environment variables missing in production, edge functions failing, DNS propagation issues, build-time vs runtime behavior differences.

This is a 2-minute verification pass, not a full QA cycle. The goal is to catch deploy-specific failures that wouldn't show up in preview.

## Prerequisites

- A URL to check (production or preview)
- The deployment should have completed (Vercel typically deploys in <60s after merge)

## Steps

### Step 1: Identify the Target

Determine what was deployed and where:

```bash
# Check latest deployment via gh
gh pr list --state merged --limit 1 --json number,title,mergedAt,url

# If checking a specific PR
gh pr view {N} --json mergeCommit,mergedAt,url
```

Identify the production URL. For Tmaker tools: `{tool-name}.vercel.app`. For Scripta: `andochoa.com`.

### Step 2: HTTP Health Check

```bash
# Basic reachability
curl -sS -o /dev/null -w "HTTP %{http_code} | %{time_total}s | %{size_download} bytes\n" {url}

# Check key pages (home + one inner page)
for page in "" "/about" "/api/health"; do
  code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 10 "{url}${page}" 2>/dev/null)
  echo "${page:-/}: $code"
done
```

Any non-2xx response on expected pages = immediate flag.

### Step 3: SSL & Headers Check

```bash
# SSL expiry
echo | openssl s_client -connect {domain}:443 -servername {domain} 2>/dev/null | openssl x509 -noout -dates 2>/dev/null

# Security headers
curl -sS -I {url} 2>/dev/null | grep -iE "strict-transport|x-frame|x-content-type|content-security"
```

### Step 4: Console & Runtime Errors

If `agent-browser` is available:
```bash
agent-browser batch \
  "open '{url}'" \
  "wait 3000" \
  "get console"
```

Check for JavaScript errors, failed network requests, hydration mismatches.

### Step 5: Vercel Deployment Status

```bash
# Check deployment status via GitHub checks
gh pr checks {N} --repo {owner}/{repo}
```

Verify: Vercel deployment status is "Ready", not "Error" or "Building".

### Step 6: Report

```markdown
## Deploy Check: {url}

**Date:** {YYYY-MM-DD HH:MM UTC}
**Trigger:** PR #{N} merged
**Duration:** {time from merge to check}

| Check | Status | Detail |
|-------|--------|--------|
| HTTP 200 | ✅/❌ | {response time} |
| SSL valid | ✅/❌ | expires {date} |
| Console clean | ✅/❌ | {error count} |
| Vercel status | ✅/❌ | {Ready/Error} |
| Key pages | ✅/❌ | {pages checked} |

**Verdict:** {HEALTHY / DEGRADED / DOWN}
```

## Completion

- **DONE** — All checks pass. Deployment is healthy.
- **DONE_WITH_CONCERNS** — Site is up but with warnings (slow response, console warnings, missing headers).
- **BLOCKED** — Can't reach the site or determine deployment status.

## Learnings Capture

After completion, evaluate:
1. Did deployment take longer than expected? (Vercel build cache issue?)
2. Did any environment variable fail to propagate? (Common pattern worth tracking)
3. Did console errors appear that weren't in preview? (Runtime vs build-time gap)
