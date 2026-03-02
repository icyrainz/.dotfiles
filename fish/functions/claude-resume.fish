function claude-resume
    set -l pick_line (__claude_session_pick)
    if test -z "$pick_line"
        return 1
    end

    # ctrl-n: start new session
    if test "$pick_line" = __new__
        command claude $argv
        return
    end

    set -l session_id (string split \t $pick_line)[1]
    set -l session_name (string split \t $pick_line)[2]

    # Rename tmux window to match the resumed session
    if set -q TMUX; and test -n "$session_name"
        tmux rename-window "$session_name"
    end

    command claude --resume $session_id $argv
end

function __claude_session_pick
    set -l projects_dir "$HOME/.claude/projects"
    test -d "$projects_dir"; or return

    set -l proj_key (pwd | string replace -a '/' '-' | string replace -a '.' '-')
    set -l sessions_dir "$projects_dir/$proj_key"
    test -d "$sessions_dir"; or return

    set -l lines
    for f in (ls -t "$sessions_dir"/*.jsonl 2>/dev/null | head -30)
        set -l sid (basename "$f" .jsonl)
        string match -qr '^[0-9a-f]{8}-' "$sid"; or continue
        # Skip empty sessions (no user messages)
        grep -q '"type":"user"' "$f" 2>/dev/null; or continue

        set -l name ""
        set -l renamed (grep '"local_command"' "$f" 2>/dev/null | grep -o 'Session renamed to: [^<"\\]*' | tail -1 | sed 's/Session renamed to: //')
        if test -n "$renamed"
            set name "$renamed"
        else
            set name (head -20 "$f" 2>/dev/null | grep -o '"slug":"[^"]*"' | head -1 | cut -d'"' -f4)
        end
        test -z "$name"; and set name (string sub -l 8 "$sid")

        set -l ts (stat -f "%Sm" -t "%m/%d %H:%M" "$f" 2>/dev/null)
        set -l bytes (stat -f "%z" "$f" 2>/dev/null)
        set -l size ""
        if test -n "$bytes"
            set size (math --scale=0 "$bytes / 1024")" KB"
        end
        set -a lines (printf '%s\t%s %8s  %s\t%s' "$sid" "$ts" "$size" "$name" "$name")
    end

    printf '%s\n' $lines | fzf --no-sort --with-nth=2 --delimiter='\t' \
        --header='Select session to resume | ctrl+o new' \
        --bind='ctrl-o:become(echo __new__)' \
        --bind='ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up' \
        --preview="grep '\"type\":\"user\"' '$sessions_dir'/{1}.jsonl 2>/dev/null | python3 -c \"
import sys,json,re
msgs=[]
for l in sys.stdin:
    try:
        d=json.loads(l)
        c=d.get('message',{}).get('content','')
        if isinstance(c,list): c=c[0].get('text','') if c else ''
        cmd=re.search(r'<command-name>(/\w+)</command-name>',c)
        args=re.search(r'<command-args>([^<]*)</command-args>',c)
        if cmd:
            msgs.append('\033[36m' + cmd.group(1)+((' '+args.group(1)) if args else '') + '\033[0m')
            continue
        c=re.sub(r'<(local-command|system-reminder)[^>]*>.*?</\\1>','',c,flags=re.S)
        c=re.sub(r'<[^>]+>','',c).strip()
        if c: msgs.append(re.sub(r'(\[[^\]]+\])','\033[2;31m'+r'\1'+'\033[0m',c))
    except: pass
for c in msgs:
    print('---')
    print(c)
\" | bat --style=plain --color=always -l md" \
        --preview-window=down:60%:wrap:follow | cut -f1,3
end
