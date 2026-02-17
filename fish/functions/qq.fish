function qq --description "Generate shell commands with LLM"
    set -l cwd (pwd)
    set -l files (ls -1 2>/dev/null | head -30 | string join ", ")
    set -l context "CWD: $cwd
Contents: $files
Task: $argv"
    set -l result (llm -t cmd "$context" 2>&1)
    if test $status -ne 0
        echo $result
        return 1
    end
    echo $result
    echo $result | pbcopy
    echo ""
    read -l -P "Run? [y/N] " confirm
    if test "$confirm" = y -o "$confirm" = Y
        eval $result
    end
end
