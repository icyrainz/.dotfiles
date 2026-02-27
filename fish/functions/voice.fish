function voice -d "Record voice and transcribe locally with whisper.cpp"
    set -l model_path ~/.local/share/whisper/ggml-base.en.bin

    # Check dependencies
    if not command -q rec
        echo "sox not installed: brew install sox" >&2
        return 1
    end
    if not command -q whisper-cli
        echo "whisper-cpp not installed: brew install whisper-cpp" >&2
        return 1
    end

    # Auto-download model on first use
    if not test -f $model_path
        echo "Downloading whisper base.en model (~142MB)..." >&2
        mkdir -p ~/.local/share/whisper
        curl -L --progress-bar -o $model_path \
            "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"
        or begin
            echo "Failed to download model." >&2
            return 1
        end
    end

    set -l tmpfile (mktemp /tmp/voice-XXXXXX).wav

    # Record until user presses Enter
    echo "Recording... (press Enter to stop)" >&2
    rec -q $tmpfile rate 16k channels 1 2>/dev/null &
    set -l rec_pid $last_pid

    read -P ""
    kill $rec_pid 2>/dev/null
    wait $rec_pid 2>/dev/null

    # Check file has content
    if not test -s $tmpfile
        rm -f $tmpfile
        echo "No audio recorded." >&2
        return 1
    end

    echo "Transcribing..." >&2
    set -l text (whisper-cli --no-prints -m $model_path -f $tmpfile --no-timestamps -l en 2>/dev/null \
        | string trim \
        | string match -rv '^\[.*\]$')

    rm -f $tmpfile

    if test -z "$text"
        echo "No speech detected." >&2
        return 1
    end

    # Output clean text to stdout
    echo $text
end
