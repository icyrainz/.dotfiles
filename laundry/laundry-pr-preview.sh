#!/usr/bin/env bash
# laundry-pr-preview.sh — Show PR + CI status for all PRs linked to a laundry task
# Used as a TV preview pane command.
set -euo pipefail

TASK_ID="${1:?Usage: laundry-pr-preview.sh <task-id>}"

# Colors
G='\033[32m'  # green
Y='\033[33m'  # yellow
R='\033[31m'  # red
B='\033[34m'  # blue
D='\033[2m'   # dim
N='\033[0m'   # reset
BOLD='\033[1m'

# Get linked PRs from task JSON
PRS=$(python3 -c "
import json
from pathlib import Path
with open(Path.home() / '.local/share/laundry/tasks.json') as f:
    data = json.load(f)
for t in data['tasks']:
    if t['id'] == '$TASK_ID':
        for pr in t.get('links', {}).get('prs', []):
            print(pr)
        break
")

if [ -z "$PRS" ]; then
    echo -e "${D}No PRs linked to this task.${N}"
    echo ""
    echo -e "Link a PR: ${BOLD}laundry link $TASK_ID --pr owner/repo#N${N}"
    exit 0
fi

while IFS= read -r pr_ref; do
    [ -z "$pr_ref" ] && continue

    # Parse owner/repo#number
    repo="${pr_ref%#*}"
    number="${pr_ref#*#}"

    echo -e "${BOLD}${pr_ref}${N}"
    echo -e "${D}$(printf '%.0s─' {1..60})${N}"

    # Fetch PR details
    pr_json=$(gh pr view "$number" -R "$repo" --json title,state,reviewDecision,headRefName,isDraft,mergeable,additions,deletions,url 2>/dev/null) || {
        echo -e "  ${R}Failed to fetch PR${N}"
        echo ""
        continue
    }

    title=$(echo "$pr_json" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('title',''))")
    state=$(echo "$pr_json" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('state',''))")
    review=$(echo "$pr_json" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('reviewDecision',''))")
    branch=$(echo "$pr_json" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('headRefName',''))")
    draft=$(echo "$pr_json" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('isDraft',False))")
    adds=$(echo "$pr_json" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('additions',0))")
    dels=$(echo "$pr_json" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('deletions',0))")
    url=$(echo "$pr_json" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('url',''))")

    # State indicator
    case "$state" in
        MERGED)  state_str="${B}MERGED${N}" ;;
        CLOSED)  state_str="${D}CLOSED${N}" ;;
        OPEN)
            if [ "$draft" = "True" ]; then
                state_str="${D}DRAFT${N}"
            else
                state_str="${G}OPEN${N}"
            fi
            ;;
        *)       state_str="$state" ;;
    esac

    # Review indicator
    case "$review" in
        APPROVED)          review_str="${G}✓ Approved${N}" ;;
        CHANGES_REQUESTED) review_str="${R}✗ Changes requested${N}" ;;
        REVIEW_REQUIRED)   review_str="${Y}○ Review required${N}" ;;
        *)                 review_str="${D}No reviews${N}" ;;
    esac

    echo -e "  ${title}"
    echo -e "  ${state_str}  ${review_str}  ${G}+${adds}${N} ${R}-${dels}${N}"
    echo -e "  ${D}${branch}${N}"
    echo ""

    # CI checks (only for open PRs)
    if [ "$state" = "OPEN" ]; then
        checks_json=$(gh pr checks "$number" -R "$repo" --json name,state,bucket 2>/dev/null) || {
            echo -e "  ${D}No CI checks${N}"
            echo ""
            continue
        }

        # Parse and display checks
        python3 -c "
import json, sys

checks = json.loads('''$checks_json''')
if not checks:
    print('  \033[2mNo CI checks\033[0m')
    sys.exit(0)

pass_count = sum(1 for c in checks if c.get('bucket') == 'pass')
fail_count = sum(1 for c in checks if c.get('bucket') == 'fail')
pending_count = sum(1 for c in checks if c.get('bucket') == 'pending')
skip_count = sum(1 for c in checks if c.get('bucket') in ('skipping', 'cancel'))

# Summary line
parts = []
if pass_count: parts.append(f'\033[32m{pass_count} passed\033[0m')
if fail_count: parts.append(f'\033[31m{fail_count} failed\033[0m')
if pending_count: parts.append(f'\033[33m{pending_count} pending\033[0m')
if skip_count: parts.append(f'\033[2m{skip_count} skipped\033[0m')
print(f'  CI: {\"  \".join(parts)}')

# Show failed checks in detail
for c in checks:
    if c.get('bucket') == 'fail':
        print(f'    \033[31m✗ {c[\"name\"]}\033[0m')
    elif c.get('bucket') == 'pending':
        print(f'    \033[33m⟳ {c[\"name\"]}\033[0m')
" 2>/dev/null || echo -e "  ${D}Could not parse checks${N}"
        echo ""
    fi
done <<< "$PRS"
