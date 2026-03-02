function claude --wraps claude
    # If --resume or -r passed without a session ID, launch fzf picker
    set -l needs_picker 0
    set -l flag_idx 0
    for i in (seq (count $argv))
        switch "$argv[$i]"
            case --resume -r --continue -c
                set flag_idx $i
                set -l next_idx (math $i + 1)
                if test $next_idx -gt (count $argv); or string match -qr '^-' "$argv[$next_idx]"
                    set needs_picker 1
                end
        end
    end

    if test $needs_picker = 1
        set -l pick (__claude_session_pick)
        if test -z "$pick"
            return 1
        end
        # Insert the picked session ID after the flag
        set -l new_argv
        for i in (seq (count $argv))
            set -a new_argv $argv[$i]
            if test $i = $flag_idx
                set -a new_argv $pick
            end
        end
        set argv $new_argv
    end

    command claude $argv
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

        set -l name ""
        set -l renamed (grep '"local_command"' "$f" 2>/dev/null | grep -o 'Session renamed to: [^<"\\]*' | tail -1 | sed 's/Session renamed to: //')
        if test -n "$renamed"
            set name "$renamed"
        else
            set name (head -20 "$f" 2>/dev/null | grep -o '"slug":"[^"]*"' | head -1 | cut -d'"' -f4)
        end
        test -z "$name"; and set name (string sub -l 8 "$sid")

        set -l ts (stat -f "%Sm" -t "%m/%d %H:%M" "$f" 2>/dev/null)
        set -a lines (printf '%s\t%s  %s' "$sid" "$ts" "$name")
    end

    printf '%s\n' $lines | fzf --no-sort --with-nth=2.. --delimiter='\t' \
        --header='Select session to resume' \
        --preview="grep '\"type\":\"user\"' '$sessions_dir'/{1}.jsonl 2>/dev/null | tail -20 | python3 -c \"
import sys,json,re
DIM=chr(27)+'[2m'
CYAN=chr(27)+'[36m'
RED=chr(27)+'[2;31m'
R=chr(27)+'[0m'
lines=[]
for l in sys.stdin:
    try:
        d=json.loads(l)
        c=d.get('message',{}).get('content','')
        if isinstance(c,list): c=c[0].get('text','') if c else ''
        # extract /commands
        cmd=re.search(r'<command-name>(/\w+)</command-name>',c)
        args=re.search(r'<command-args>([^<]*)</command-args>',c)
        if cmd:
            txt=CYAN+cmd.group(1)+((' '+args.group(1)) if args else '')+R
            lines.append(txt)
            continue
        # strip noise tags, keep text
        c=re.sub(r'<(local-command|system-reminder)[^>]*>.*?</\\1>','',c,flags=re.S)
        c=re.sub(r'<[^>]+>','',c).strip()
        c=c.split(chr(10))[0][:120]
        if c:
            c=re.sub(r'(\[[^\]]+\])',RED+r'\\1'+R,c)
            lines.append(c)
    except: pass
for c in lines[-8:]: print(DIM+'>'+R+' '+c)
\"" \
        --preview-window=down:8:wrap | cut -f1
end
