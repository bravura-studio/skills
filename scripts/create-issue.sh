#!/usr/bin/env bash
# create-issue.sh — Create a Paperclip issue with guaranteed agent assignment
#
# The Paperclip MCP tools do not reliably pass assigneeAgentId when agents
# create issues for other agents. This script uses the REST API directly
# to guarantee assignment works. Use this instead of MCP tools for
# cross-agent issue creation (e.g., dev → QA handoff).
#
# Usage:
#   create-issue.sh --title "QA: Review X" \
#     --assignee <agent-id> \
#     --description "## Task\n..." \
#     [--project <project-id>] \
#     [--status todo] \
#     [--priority medium]
#
# Requires: PAPERCLIP_TOKEN and PAPERCLIP_COMPANY_ID env vars
# Optional: PAPERCLIP_DOMAIN (defaults to paperclip.andochoa.com)
#           PAPERCLIP_PROJECT_ID (default project for issues)
#
# Example (from agent CLAUDE.md or issue description):
#   export PAPERCLIP_TOKEN="$PAPERCLIP_API_KEY"
#   export PAPERCLIP_COMPANY_ID="bd17a271-fe16-43b3-8b1f-4496d2169b1e"
#   export PAPERCLIP_PROJECT_ID="bc392ff0-803b-4ae9-9f56-83642a19870c"
#   bash skills/scripts/create-issue.sh \
#     --title "QA: Review deployed sites" \
#     --assignee "82517a6b-db9e-4656-89f1-369d1bd7f3d1" \
#     --description "Verify AC-5, AC-6..." \
#     --status todo \
#     --priority high

set -euo pipefail

PAPERCLIP_DOMAIN="${PAPERCLIP_DOMAIN:-paperclip.andochoa.com}"
PAPERCLIP_TOKEN="${PAPERCLIP_TOKEN:-}"
PAPERCLIP_COMPANY_ID="${PAPERCLIP_COMPANY_ID:-}"
PAPERCLIP_PROJECT_ID="${PAPERCLIP_PROJECT_ID:-}"

# Parse arguments
TITLE=""
ASSIGNEE=""
DESCRIPTION=""
PROJECT_ID="$PAPERCLIP_PROJECT_ID"
STATUS="todo"
PRIORITY="medium"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title) TITLE="$2"; shift 2 ;;
    --assignee) ASSIGNEE="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --project) PROJECT_ID="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    --priority) PRIORITY="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# Validate required fields
if [[ -z "$PAPERCLIP_TOKEN" ]]; then
  echo "Error: PAPERCLIP_TOKEN not set." >&2
  echo "Set it from your agent API key or session." >&2
  exit 1
fi

if [[ -z "$PAPERCLIP_COMPANY_ID" ]]; then
  echo "Error: PAPERCLIP_COMPANY_ID not set." >&2
  exit 1
fi

if [[ -z "$TITLE" ]]; then
  echo "Error: --title is required." >&2
  exit 1
fi

if [[ -z "$ASSIGNEE" ]]; then
  echo "Error: --assignee is required. Pass the target agent's ID." >&2
  exit 1
fi

# Build JSON payload
PAYLOAD=$(cat <<ENDJSON
{
  "title": $(echo "$TITLE" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read().strip()))'),
  "description": $(echo "$DESCRIPTION" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read().strip()))'),
  "status": "$STATUS",
  "priority": "$PRIORITY",
  "assigneeAgentId": "$ASSIGNEE"
  ${PROJECT_ID:+,"projectId": "$PROJECT_ID"}
}
ENDJSON
)

# Create issue
RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $PAPERCLIP_TOKEN" \
  -H "Content-Type: application/json" \
  "https://${PAPERCLIP_DOMAIN}/api/companies/${PAPERCLIP_COMPANY_ID}/issues" \
  -d "$PAYLOAD")

# Parse response
IDENTIFIER=$(echo "$RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('identifier','ERROR'))" 2>/dev/null || echo "ERROR")
ASSIGNED=$(echo "$RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('assigneeAgentId','null'))" 2>/dev/null || echo "null")

if [[ "$IDENTIFIER" == "ERROR" ]]; then
  echo "Error creating issue:" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

if [[ "$ASSIGNED" == "null" ]]; then
  echo "Warning: Issue $IDENTIFIER created but assignee is null. Assignment may have failed." >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "$IDENTIFIER created, assigned to $ASSIGNEE, status: $STATUS"
