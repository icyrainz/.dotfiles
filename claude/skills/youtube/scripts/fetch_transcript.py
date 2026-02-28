#!/usr/bin/env python3
"""Fetch YouTube video metadata and transcript, output clean text files."""

import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

OUTPUT_DIR = Path("/tmp/youtube-transcripts")
WHISPER_MODEL = Path.home() / ".local/share/whisper-cpp/models/ggml-base.en.bin"


def extract_video_id(url: str) -> str | None:
    patterns = [
        r"(?:youtube\.com/watch\?.*v=|youtu\.be/|youtube\.com/live/)([a-zA-Z0-9_-]{11})",
    ]
    for p in patterns:
        m = re.search(p, url)
        if m:
            return m.group(1)
    return None


def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True, **kwargs)


def fetch_metadata(url: str, video_id: str) -> dict | None:
    meta_path = OUTPUT_DIR / f"{video_id}_meta.json"
    result = run(["yt-dlp", "--dump-json", "--no-download", url])
    if result.returncode != 0:
        print(f"ERROR: Failed to fetch metadata: {result.stderr.strip()}", file=sys.stderr)
        return None
    meta_path.write_text(result.stdout)
    return json.loads(result.stdout)


def fetch_subtitles(url: str, video_id: str) -> Path | None:
    run([
        "yt-dlp", "--write-subs", "--write-auto-subs",
        "--sub-langs", "en", "--sub-format", "srt/vtt/best",
        "--skip-download", "-o", str(OUTPUT_DIR / video_id), url,
    ])
    # Find any subtitle file that was created
    for ext in [".en.srt", ".en.vtt", ".en.srv3", ".en.json3"]:
        p = OUTPUT_DIR / f"{video_id}{ext}"
        if p.exists() and p.stat().st_size > 0:
            return p
    return None


def transcribe_with_whisper(url: str, video_id: str) -> Path | None:
    whisper_bin = shutil.which("whisper-cli")
    if not whisper_bin:
        print("WHISPER_NOT_INSTALLED", file=sys.stderr)
        return None
    if not WHISPER_MODEL.exists():
        print(f"WHISPER_MODEL_MISSING:{WHISPER_MODEL}", file=sys.stderr)
        return None

    wav_path = OUTPUT_DIR / f"{video_id}.wav"
    if not wav_path.exists():
        result = run(["yt-dlp", "-x", "--audio-format", "wav",
                       "-o", str(OUTPUT_DIR / f"{video_id}.%(ext)s"), url])
        if result.returncode != 0:
            print(f"ERROR: Audio download failed: {result.stderr.strip()}", file=sys.stderr)
            return None

    txt_out = OUTPUT_DIR / video_id
    result = run([whisper_bin, "-m", str(WHISPER_MODEL),
                  "-f", str(wav_path), "-otxt", "-of", str(txt_out)])
    if result.returncode != 0:
        print(f"ERROR: Whisper failed: {result.stderr.strip()}", file=sys.stderr)
        return None

    txt_path = OUTPUT_DIR / f"{video_id}.txt"
    return txt_path if txt_path.exists() else None


def parse_srt(content: str) -> list[tuple[int, str]]:
    blocks = re.split(r"\n\n+", content.strip())
    entries = []
    for block in blocks:
        lines = block.strip().split("\n")
        if len(lines) < 3:
            continue
        time_match = re.match(r"(\d{2}):(\d{2}):(\d{2})", lines[1])
        if not time_match:
            continue
        text = " ".join(lines[2:])
        text = re.sub(r"<[^>]+>", "", text).strip()
        if not text:
            continue
        h, m, s = int(time_match.group(1)), int(time_match.group(2)), int(time_match.group(3))
        entries.append((h * 3600 + m * 60 + s, text))
    return entries


def parse_vtt(content: str) -> list[tuple[int, str]]:
    # Strip VTT header
    content = re.sub(r"^WEBVTT.*?\n\n", "", content, flags=re.DOTALL)
    content = re.sub(r"^Kind:.*\n", "", content, flags=re.MULTILINE)
    content = re.sub(r"^Language:.*\n", "", content, flags=re.MULTILINE)
    return parse_srt(content)  # VTT body is similar enough to SRT


def clean_transcript(entries: list[tuple[int, str]]) -> str:
    # Deduplicate overlapping lines
    seen = set()
    deduped = []
    for ts, text in entries:
        normalized = text.lower().strip()
        if normalized not in seen:
            seen.add(normalized)
            deduped.append((ts, text))

    # Build transcript with timestamps every ~30s
    lines = []
    last_marker = -30
    for ts, text in deduped:
        if ts - last_marker >= 30:
            mins, secs = divmod(ts, 60)
            lines.append(f"\n[{mins:02d}:{secs:02d}]")
            last_marker = ts
        lines.append(text)

    return "\n".join(lines).strip()


def format_metadata(meta: dict) -> str:
    parts = []
    parts.append(f"Title: {meta.get('title', 'Unknown')}")
    parts.append(f"Channel: {meta.get('channel', 'Unknown')}")
    parts.append(f"Duration: {meta.get('duration_string', 'Unknown')}")
    upload = meta.get("upload_date", "")
    if upload and len(upload) == 8:
        upload = f"{upload[:4]}-{upload[4:6]}-{upload[6:8]}"
    parts.append(f"Uploaded: {upload}")

    desc = meta.get("description", "")
    if desc:
        parts.append(f"Description: {desc[:500]}")

    chapters = meta.get("chapters") or []
    if chapters:
        parts.append(f"Chapters ({len(chapters)}):")
        for ch in chapters:
            m, s = divmod(int(ch["start_time"]), 60)
            parts.append(f"  [{m:02d}:{s:02d}] {ch['title']}")

    return "\n".join(parts)


def main():
    if len(sys.argv) < 2:
        print("Usage: fetch_transcript.py <youtube-url>", file=sys.stderr)
        sys.exit(1)

    url = sys.argv[1]
    video_id = extract_video_id(url)
    if not video_id:
        print(f"ERROR: Could not extract video ID from: {url}", file=sys.stderr)
        sys.exit(1)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Fetch metadata
    meta = fetch_metadata(url, video_id)
    if not meta:
        sys.exit(1)

    meta_text = format_metadata(meta)
    meta_out = OUTPUT_DIR / f"{video_id}_meta.txt"
    meta_out.write_text(meta_text)

    # Try subtitles first
    sub_path = fetch_subtitles(url, video_id)
    transcript_source = "subtitles"

    if sub_path:
        content = sub_path.read_text()
        if sub_path.suffix == ".vtt":
            entries = parse_vtt(content)
        else:
            entries = parse_srt(content)
        transcript = clean_transcript(entries)
    else:
        # Whisper fallback
        print("No subtitles found, trying whisper.cpp...", file=sys.stderr)
        whisper_out = transcribe_with_whisper(url, video_id)
        if whisper_out and whisper_out.exists():
            transcript = whisper_out.read_text().strip()
            transcript_source = "whisper"
        else:
            transcript = ""
            transcript_source = "none"

    transcript_out = OUTPUT_DIR / f"{video_id}_transcript.txt"
    transcript_out.write_text(transcript)

    # Print summary to stdout for Claude to read
    print(f"VIDEO_ID={video_id}")
    print(f"TRANSCRIPT_SOURCE={transcript_source}")
    print(f"META_FILE={meta_out}")
    print(f"TRANSCRIPT_FILE={transcript_out}")
    print(f"TRANSCRIPT_LENGTH={len(transcript)}")


if __name__ == "__main__":
    main()
