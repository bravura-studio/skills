---
name: infra-audit
description: |
  Infrastructure health check across VPS1 services. Checks systemd units, Docker
  containers, disk space, memory, qmd index, n8n workflows, and Paperclip API.
  Use on a schedule, after incidents, or when someone says "how's the server",
  "infra check", "is everything running".
version: 1.0.0
category: ops
interactive: false
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
triggers:
  - "infra check"
  - "how's the server"
  - "is everything running"
  - "system status"
  - "health check"
  - "infra audit"
benefits-from: []
feeds-into: []
qmd: []
reads-learnings: true
writes-learnings: true
---

# Infra Audit

## Context

VPS1 (Hetzner CPX42, 16GB) runs everything: Paperclip, n8n, qmd, Silverbullet, Caddy, ferro.service. This skill gives a single-pass health check across all services. Takes ~60 seconds.

Run this:
- Weekly as a routine check
- After any infrastructure change (container rebuild, service restart, package update)
- When something feels slow or broken
- After VPS1 reboots (to verify all services came back)

## Prerequisites

- SSH access to VPS1 (or running directly on VPS1)

## Steps

### Step 1: System Resources

```bash
# CPU + Memory overview
echo "=== System ==="
uptime
free -h | grep Mem
df -h / | tail -1

# Top memory consumers
echo ""
echo "=== Top Memory ==="
ps aux --sort=-%mem | head -6
```

Flag if: memory >80%, disk >85%, load > 2x CPU cores.

### Step 2: Systemd Services

```bash
echo "=== Services ==="
for svc in ferro caddy; do
  status=$(systemctl is-active $svc.service 2>/dev/null || echo "not-found")
  mem=$(systemctl show $svc.service -p MemoryCurrent 2>/dev/null | cut -d= -f2)
  echo "$svc: $status (${mem:-unknown})"
done
```

Flag if: ferro.service RSS >500MB (memory bloat, consider restart).

### Step 3: Docker Containers

```bash
echo "=== Containers ==="
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null

# Container resource usage
echo ""
docker stats --no-stream --format 'table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}' 2>/dev/null
```

Expected containers: paperclip-server-1, paperclip-db-1, n8n, silverbullet, caddy (if containerized).

Flag if: any container "Restarting", unhealthy, or missing.

### Step 4: Service Endpoints

```bash
echo "=== Endpoints ==="
for url in "https://paperclip.andochoa.com/api/health" "https://n8n.andochoa.com" "https://sb.andochoa.com"; do
  code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 5 "$url" 2>/dev/null || echo "timeout")
  echo "$url: $code"
done
```

### Step 5: qmd Index Health

```bash
echo "=== qmd ==="
qmd status 2>&1 | head -10
```

Flag if: index not updated in >7 days, or collection count is wrong.

### Step 6: Disk & Logs

```bash
# Large files / directories
echo "=== Disk Hogs ==="
du -sh /root/.cache/qmd/ /knowledge/ /var/lib/docker/ 2>/dev/null

# Recent errors in key logs
echo ""
echo "=== Recent Errors ==="
journalctl -u ferro.service --since "1 hour ago" --priority err --no-pager 2>/dev/null | tail -5
journalctl -u caddy.service --since "1 hour ago" --priority err --no-pager 2>/dev/null | tail -5
```

### Step 7: Report

```markdown
## Infra Audit: VPS1

**Date:** {YYYY-MM-DD HH:MM UTC}
**Uptime:** {days}

### System
| Metric | Value | Status |
|--------|-------|--------|
| Memory | {used}/{total} | ✅/⚠️/❌ |
| Disk | {used}/{total} | ✅/⚠️/❌ |
| Load | {1m avg} | ✅/⚠️/❌ |

### Services
| Service | Status | Memory |
|---------|--------|--------|
| ferro | {active/dead} | {RSS} |
| caddy | {active/dead} | {RSS} |

### Containers
| Container | Status | Memory |
|-----------|--------|--------|
| paperclip-server-1 | {Up Xh} | {usage} |
| paperclip-db-1 | {Up Xh} | {usage} |
| n8n | {Up Xh} | {usage} |
| silverbullet | {Up Xh} | {usage} |

### Endpoints
| URL | Status |
|-----|--------|
| paperclip.andochoa.com | {HTTP code} |
| n8n.andochoa.com | {HTTP code} |
| sb.andochoa.com | {HTTP code} |

### qmd
- Index: {size}, {doc count} docs, last updated {when}

### Alerts
- {Any flags from the checks above}

**Overall:** {HEALTHY / DEGRADED / CRITICAL}
```

## Completion

- **DONE** — All checks pass. Infrastructure healthy.
- **DONE_WITH_CONCERNS** — Running but with warnings (high memory, stale index, slow endpoints).
- **BLOCKED** — Can't reach VPS1 or critical services are down.

## Learnings Capture

After completion, evaluate:
1. Did any service's memory usage grow significantly since last audit?
2. Did any container restart unexpectedly? (Check restart count)
3. Is disk growing faster than expected? (Knowledge vaults, Docker images, logs)
