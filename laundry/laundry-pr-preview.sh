#!/usr/bin/env bash
# laundry-pr-preview.sh — Show PR + CI status for all PRs linked to a laundry task
# Used as a TV preview pane command.
set -euo pipefail

TASK_ID="${1:?Usage: laundry-pr-preview.sh <task-id>}"

# Get linked PRs from task JSON
PRS=$(python3 -c "
import sys; sys.path.insert(0, '$(dirname "$0")')
from laundry import _load, _find_task
task = _find_task(_load(), sys.argv[1])
if task:
    for pr in task.get('links', {}).get('prs', []):
        print(pr)
" "$TASK_ID")

if [ -z "$PRS" ]; then
    echo -e '\033[2mNo PRs linked to this task.\033[0m'
    echo ""
    echo -e "Link a PR: \033[1mlaundry link $TASK_ID --pr owner/repo#N\033[0m"
    exit 0
fi

# Fetch all PRs in parallel (single gh call per PR with statusCheckRollup)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

i=0
while IFS= read -r pr_ref; do
    [ -z "$pr_ref" ] && continue
    repo="${pr_ref%#*}"
    number="${pr_ref#*#}"
    (
        gh pr view "$number" -R "$repo" \
            --json title,state,reviewDecision,headRefName,isDraft,additions,deletions,statusCheckRollup \
            > "$WORK/$i.json" 2>/dev/null || echo '{"_error":true}' > "$WORK/$i.json"
    ) &
    echo "$pr_ref" > "$WORK/$i.ref"
    i=$((i + 1))
done <<< "$PRS"
wait

# Render all results
python3 - "$WORK" "$i" <<'PYEOF'
import json, sys, os

work, count = sys.argv[1], int(sys.argv[2])

G  = '\033[32m'
Y  = '\033[33m'
R  = '\033[31m'
B  = '\033[34m'
D  = '\033[2m'
N  = '\033[0m'
BD = '\033[1m'

ICONS = {'pass': f'{G}+', 'fail': f'{R}x', 'pending': f'{Y}~', 'skip': f'{D}-'}

def bucket(c):
    # CheckRun uses conclusion/status; StatusContext uses state
    conclusion = (c.get('conclusion') or '').upper()
    status = (c.get('status') or c.get('state') or '').upper()
    if conclusion in ('SUCCESS', 'NEUTRAL') or status == 'SUCCESS': return 'pass'
    if conclusion in ('FAILURE', 'ERROR', 'TIMED_OUT', 'ACTION_REQUIRED') or status in ('FAILURE', 'ERROR'): return 'fail'
    if conclusion == 'SKIPPED':               return 'skip'
    if status in ('QUEUED', 'IN_PROGRESS', 'PENDING', 'WAITING', 'REQUESTED', 'EXPECTED'): return 'pending'
    if conclusion: return 'pass'
    return 'pending'

for j in range(count):
    ref = open(f'{work}/{j}.ref').read().strip()
    with open(f'{work}/{j}.json') as f:
        d = json.load(f)

    print(f'{BD}{ref}{N}')
    print(f'{D}{"─" * 60}{N}')

    if d.get('_error'):
        print(f'  {R}Failed to fetch PR{N}\n')
        continue

    title   = d.get('title', '')
    state   = d.get('state', '')
    review  = d.get('reviewDecision', '')
    branch  = d.get('headRefName', '')
    draft   = d.get('isDraft', False)
    adds    = d.get('additions', 0)
    dels    = d.get('deletions', 0)

    # State
    if state == 'MERGED':     state_s = f'{B}MERGED{N}'
    elif state == 'CLOSED':   state_s = f'{D}CLOSED{N}'
    elif draft:               state_s = f'{D}DRAFT{N}'
    elif state == 'OPEN':     state_s = f'{G}OPEN{N}'
    else:                     state_s = state

    # Review
    review_map = {
        'APPROVED': f'{G}+ Approved{N}',
        'CHANGES_REQUESTED': f'{R}x Changes requested{N}',
        'REVIEW_REQUIRED': f'{Y}~ Review required{N}',
    }
    review_s = review_map.get(review, f'{D}No reviews{N}')

    print(f'  {title}')
    print(f'  {state_s}  {review_s}  {G}+{adds}{N} {R}-{dels}{N}')
    print(f'  {D}{branch}{N}')
    print()

    # CI checks
    checks = d.get('statusCheckRollup', [])
    if state != 'OPEN' or not checks:
        continue

    buckets = [bucket(c) for c in checks]
    counts = {k: buckets.count(k) for k in ('pass', 'fail', 'pending', 'skip')}

    parts = []
    if counts['pass']:    parts.append(f'{G}{counts["pass"]} passed{N}')
    if counts['fail']:    parts.append(f'{R}{counts["fail"]} failed{N}')
    if counts['pending']: parts.append(f'{Y}{counts["pending"]} pending{N}')
    if counts['skip']:    parts.append(f'{D}{counts["skip"]} skipped{N}')
    print(f'  CI: {"  ".join(parts)}')

    for c, b in zip(checks, buckets):
        name = c.get('name') or c.get('context') or '?'
        icon = ICONS.get(b, ' ')
        print(f'    {icon} {name}{N}')
    print()
PYEOF
