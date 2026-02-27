function voice-listen -d "Toggle voice recording with Space, send transcription to tmux pane"
    set -l target ""
    set -l model "base"
    set -l model_dir ~/.local/share/whisper

    # Parse args
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --target -t
                set i (math $i + 1)
                set target $argv[$i]
            case --model -m
                set i (math $i + 1)
                set model $argv[$i]
            case --help -h
                echo "Usage: voice-listen [--target <tmux-pane>] [--model <base|medium>]"
                echo ""
                echo "Press Space to start recording, Space again to stop."
                echo "Transcription is sent to the target tmux pane automatically."
                echo ""
                echo "Auto-detects the target pane if not specified."
                echo ""
                echo "Options:"
                echo "  -t, --target   Tmux pane. Auto-detected if omitted."
                echo "  -m, --model    Whisper model: base (fast) or medium (accurate). Default: base."
                echo ""
                echo "Examples:"
                echo "  voice-listen                    # auto-detect, base model"
                echo "  voice-listen -m medium          # use medium model"
                echo "  voice-listen -t %0              # explicit target"
                return 0
        end
        set i (math $i + 1)
    end

    set -l model_path $model_dir/ggml-$model.en.bin

    for cmd in rec whisper-cli
        if not command -q $cmd
            echo "Missing: $cmd (brew install sox whisper-cpp)" >&2
            return 1
        end
    end

    if not set -q TMUX
        echo "Error: not inside a tmux session." >&2
        return 1
    end

    # Auto-detect target pane if not specified
    if test -z "$target"
        set -l current (tmux display-message -p '#{pane_id}')
        set -l panes (tmux list-panes -F '#{pane_id}' | string match -v $current)

        if test (count $panes) -eq 1
            set target $panes[1]
        else if test (count $panes) -gt 1
            set target (tmux display-message -p -t '{last}' '#{pane_id}' 2>/dev/null)
        end

        if test -z "$target"
            echo "Error: could not detect target pane. Use --target <pane-id>." >&2
            return 1
        end
    end

    # Auto-download model
    if not test -f $model_path
        echo "Downloading whisper $model.en model..."
        mkdir -p $model_dir
        curl -L --progress-bar -o $model_path \
            "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-$model.en.bin"
        or begin
            echo "Model download failed." >&2
            return 1
        end
    end

    echo "Voice listener active"
    echo "  Target: $target"
    echo "  Model:  $model.en"
    echo ""
    echo "  [Space] = start/stop recording"
    echo "  [q/Esc] = quit"
    echo ""

    while true
        # Wait for Space to start recording
        echo -n (set_color brblack)"Press Space to record..."(set_color normal)
        while true
            read -n 1 -P "" -l key
            # Quit on q, Esc (\e), Ctrl+C (\x03), Ctrl+D (\x04)
            if contains -- "$key" q \e \x03 \x04
                echo ""
                echo "Stopped."
                return 0
            end
            if test "$key" = " "
                break
            end
        end

        set -l tmpfile (mktemp /tmp/voice-XXXXXX).wav

        # Start recording in background
        rec -q $tmpfile rate 16k channels 1 2>/dev/null &
        set -l rec_pid $last_pid
        echo -e \r(set_color red)"Recording... Space to stop."(set_color normal)"   "

        # Wait for Space to stop recording
        while true
            read -n 1 -P "" -l key
            # Quit while recording: stop rec first, then exit
            if contains -- "$key" q \e \x03 \x04
                kill $rec_pid 2>/dev/null
                wait $rec_pid 2>/dev/null
                rm -f $tmpfile
                echo ""
                echo "Stopped."
                return 0
            end
            if test "$key" = " "
                break
            end
        end

        kill $rec_pid 2>/dev/null
        wait $rec_pid 2>/dev/null

        if not test -s $tmpfile
            rm -f $tmpfile
            echo (set_color yellow)"No audio captured."(set_color normal)
            continue
        end

        echo (set_color brblack)"Transcribing..."(set_color normal)

        # Transcribe
        set -l raw (whisper-cli --no-prints -m $model_path -f $tmpfile --no-timestamps -l en 2>/dev/null)
        rm -f $tmpfile

        # Clean up whisper output
        set -l text (printf '%s\n' $raw | string trim | string match -rv '^\[.*\]$' | string join ' ' | string trim)

        if test -z "$text"
            echo (set_color yellow)"No speech detected."(set_color normal)
            continue
        end

        echo (set_color green)">> $text"(set_color normal)
        tmux send-keys -t $target -l -- "$text"
        tmux send-keys -t $target Enter
    end
end
