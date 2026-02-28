---
name: youtube
description: "Use when the user passes a YouTube link and wants to understand or discuss the video content. Invoke via /youtube <url>. Extracts the full transcript using yt-dlp (with whisper.cpp fallback for uncaptioned videos), loads it into context, and enables deep conversation about the video. Use this skill whenever a user shares a YouTube URL and wants to analyze, summarize, question, or discuss what was said in the video."
---

# YouTube Video Conversation

Extract a YouTube video's transcript and enable deep, informed conversation about its content.

## Step 1: Run the extraction script

```bash
python3 ~/.claude/skills/youtube/scripts/fetch_transcript.py "URL"
```

The script handles everything: metadata fetching, subtitle extraction, whisper.cpp fallback, SRT/VTT cleaning, and deduplication. It outputs paths to the result files.

Parse its stdout for these fields:
- `VIDEO_ID` — the video identifier
- `TRANSCRIPT_SOURCE` — `subtitles`, `whisper`, or `none`
- `META_FILE` — path to cleaned metadata text
- `TRANSCRIPT_FILE` — path to cleaned transcript text
- `TRANSCRIPT_LENGTH` — character count

If the script exits with an error, check stderr for:
- `ERROR: Failed to fetch metadata` — video is private, deleted, or region-locked. Tell the user.
- `WHISPER_NOT_INSTALLED` — no captions and no whisper.cpp. Suggest `brew install whisper-cpp`.
- `WHISPER_MODEL_MISSING` — whisper.cpp installed but model missing. Suggest running:
  ```
  mkdir -p ~/.local/share/whisper-cpp/models
  curl -L "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin" -o ~/.local/share/whisper-cpp/models/ggml-base.en.bin
  ```

## Step 2: Load and present

Read both `META_FILE` and `TRANSCRIPT_FILE`. Present to the user:

---

**Video:** [title]
**Channel:** [channel] | **Duration:** [duration] | **Uploaded:** [date]

**Chapters:** (if available, list them with timestamps)

**Summary:**
[Write 3-5 bullet points capturing the main ideas from the transcript content, not assumptions from the title.]

---

I've loaded the full transcript of this video. Ask me anything about what was discussed — I can reference specific timestamps and quotes.

---

If `TRANSCRIPT_SOURCE=none`, note that only metadata is available and conversation will be limited.

## Conversation Guidelines

When answering questions about the video:

- **Cite timestamps** when referencing specific points (e.g., "At [14:32], the speaker argues that...")
- **Quote directly** when the user asks what someone said — use the actual words from the transcript
- **Distinguish clearly** between what was explicitly stated and your own interpretation or inference
- **Acknowledge gaps** — if auto-captions garbled a section, say so rather than guessing
- **Use chapter context** when available to help orient answers
- **Handle multi-speaker content** by noting speaker changes when detectable from context

## Dependencies

**Required:** `yt-dlp` (`brew install yt-dlp`)
**Optional:** `whisper-cpp` (`brew install whisper-cpp`) — for uncaptioned videos
