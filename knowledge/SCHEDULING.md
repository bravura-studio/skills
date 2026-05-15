# Knowledge Hygiene Scheduling

> How to run knowledge skills on a schedule via n8n.
> Part of Phase 5: Knowledge Hygiene (AD-036).

---

## Architecture

```
n8n (cron trigger) → SSH to VPS1 → run skill via Claude Code CLI → Telegram notification
```

The n8n workflow triggers nightly, SSHes into VPS1, invokes the vault-hygiene skill via `claude -p`, captures the output, and sends a summary to Telegram.

---

## n8n Workflow: Vault Hygiene Nightly

### Trigger
- **Type:** Cron
- **Schedule:** `0 3 * * *` (03:00 UTC daily — low-traffic window)
- **Timezone:** Europe/Lisbon

### Nodes

#### 1. SSH Execute — Run vault-hygiene
```json
{
  "type": "n8n-nodes-base.ssh",
  "parameters": {
    "command": "cd /root/code/build-fun-free && claude -p 'Run the vault-hygiene skill. Output the report as structured markdown. No interactive checkpoints.' --output-format text --max-turns 30 2>&1 | tail -100",
    "host": "localhost",
    "port": 22
  }
}
```

**Why localhost SSH?** n8n runs in Docker on VPS1. SSH to localhost reaches the host where `claude`, `qmd`, and the vaults live. This avoids Docker-in-Docker complexity.

**Alternative (simpler, no Claude Code):** Run the hygiene steps directly via bash:
```bash
#!/bin/bash
# Direct execution — no Claude Code needed for the mechanical steps
set -euo pipefail

echo "## Vault Hygiene Report — $(date -I)"
echo ""

# Step 1: Health check
echo "### Health"
qmd status 2>&1

# Step 2: Re-index
echo ""
echo "### Re-index"
qmd update 2>&1

# Step 3: Embed
echo ""
echo "### Embed"
qmd embed 2>&1

# Step 4: Lint (empty files, oversized files)
echo ""
echo "### Lint"
for vault in /knowledge/vault-*/; do
  name=$(basename "$vault")
  empty=$(find "$vault" -name "*.md" -empty | wc -l)
  oversized=$(find "$vault" -name "*.md" -size +100k | wc -l)
  total=$(find "$vault" -name "*.md" | wc -l)
  echo "- $name: $total docs, $empty empty, $oversized oversized"
done

# Step 5: Stale count
echo ""
echo "### Staleness"
for vault in /knowledge/vault-*/; do
  name=$(basename "$vault")
  stale90=$(find "$vault" -name "*.md" -mtime +90 | wc -l)
  stale180=$(find "$vault" -name "*.md" -mtime +180 | wc -l)
  echo "- $name: $stale90 >90d, $stale180 >180d"
done
```

#### 2. IF — Check for issues
```json
{
  "type": "n8n-nodes-base.if",
  "parameters": {
    "conditions": {
      "string": [
        { "value1": "={{ $json.stderr }}", "operation": "isNotEmpty" }
      ]
    }
  }
}
```

#### 3. Telegram — Send report
```json
{
  "type": "n8n-nodes-base.telegram",
  "parameters": {
    "chatId": "8707887211",
    "text": "🧹 Vault Hygiene Report\n\n{{ $json.stdout.substring(0, 3000) }}",
    "additionalFields": {
      "appendAttribution": false
    }
  }
}
```

---

## Deployment

### Option A: n8n GUI
1. Open `https://n8n.andochoa.com`
2. Create new workflow "Vault Hygiene Nightly"
3. Add nodes per the spec above
4. Activate the workflow

### Option B: n8n CLI import
```bash
# Export the workflow JSON (when created via GUI)
docker exec n8n n8n export:workflow --id={id} --output=/tmp/vault-hygiene.json
```

---

## Monitoring

- **Success:** Telegram notification arrives daily ~03:05 UTC with vault stats
- **Failure:** n8n execution fails → check n8n execution log at `https://n8n.andochoa.com`
- **Drift:** If no notification for 2+ days, check n8n workflow activation status

---

## Future: Stale Detector + Compiled Truth

The nightly cycle currently runs vault-hygiene only. Later phases can chain:

```
vault-hygiene (nightly) → stale-detector (weekly, Sundays) → compiled-truth (on-demand, when stale-detector finds compile candidates)
```

Stale-detector is heavier (URL checks, content analysis) — run weekly, not nightly.
Compiled-truth is interactive — run on-demand when the stale report surfaces compile candidates.
