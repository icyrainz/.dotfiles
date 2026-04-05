# Car Media Offline System — Design Spec

**Date:** 2026-04-05
**Status:** Approved

## Problem

Pixel 7 serves as a dedicated Android Auto car device running CarStream. No internet in the car. Need offline video playback of sitcom library (Friends, HIMYM, Big Bang Theory — 721 episodes) via CarStream's web UI capability.

## Architecture

```
┌─ Homelab ──────────────────────────────────────────────┐
│                                                        │
│  pool-syn (1080p x265 originals, ~414GB)               │
│       │                                                │
│       ▼                                                │
│  akio-fractal (RTX 5090, NVENC)                        │
│  Batch transcode: 1080p x265 → 360p h264 MP4           │
│       │                                                │
│       ▼                                                │
│  pool-terra/car-media/ (360p staging, ~32GB)            │
│  Canonical copy — 1:1 mirror of phone content          │
│                                                        │
└────────────────────┬───────────────────────────────────┘
                     │ adb push (USB)
                     ▼
┌─ Pixel 7 (Android 16) ────────────────────────────────┐
│                                                        │
│  /storage/emulated/0/CarMedia/                         │
│  ├── Friends/S01E01.mp4 ... S10E18.mp4                 │
│  ├── HIMYM/S01E01.mp4 ... S09E24.mp4                   │
│  └── BBT/S01E01.mp4 ... S12E24.mp4                     │
│                                                        │
│  Termux (via F-Droid / GitHub APK sideload)            │
│  ├── Caddy (port 8081) — static file server            │
│  ├── NodeCast TV (port 3000) — IPTV web UI             │
│  │   └── Source: local M3U → http://localhost:8081/... │
│  └── Termux:Boot — auto-start + wake-lock              │
│                                                        │
│  CarStream → http://localhost:3000                      │
│                                                        │
└────────────────────────────────────────────────────────┘
```

## Component 1: Transcoding Pipeline (akio-fractal)

### Source Content

| Show | Location | Original Size | Episodes |
|------|----------|---------------|----------|
| Friends (1994) | pool-syn/Shows/Friends (1994) {imdb-tt0108778}/ | 158GB | ~236 |
| How I Met Your Mother (2005) | pool-syn/Shows/How I Met Your Mother (2005) {imdb-tt0460649}/ | 97GB | ~208 |
| The Big Bang Theory (2007) | pool-syn/Shows/The Big Bang Theory (2007) {imdb-tt0898266}/ | 159GB | ~277 |
| **Total** | | **414GB** | **~721** |

Original format: 1080p WEBRip/Bluray, x265 (HEVC), EAC3/AC3 5.1 surround, MKV container.

### Transcode Settings

```bash
ffmpeg -hwaccel cuda -i input.mkv \
  -c:v h264_nvenc -preset p4 -vf "scale=640:360" -b:v 400k \
  -c:a aac -b:a 96k -ac 2 \
  -movflags +faststart \
  output.mp4
```

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Resolution | 640x360 | Car screen is small; 360p looks fine |
| Video codec | h264 (NVENC) | Universal HTML5 browser support |
| Video bitrate | 400 kbps | ~45MB/episode, ~32GB total for 721 episodes |
| Audio codec | AAC stereo | Downmix 5.1 → stereo for car speakers |
| Audio bitrate | 96 kbps | Adequate for speech-heavy sitcoms |
| Container | MP4 | HTML5 native, no remux needed |
| faststart | yes | Moov atom at front for instant playback |

Estimated output: **~32GB total** (leaves ~65GB free on 98GB-available Pixel 7).

### Output Structure

Transcoded to `pool-terra/car-media/` with simplified filenames:

```
pool-terra/car-media/
├── Friends/
│   ├── S01E01.mp4
│   ├── S01E02.mp4
│   └── ...
├── HIMYM/
│   ├── S01E01.mp4
│   └── ...
└── BBT/
    ├── S01E01.mp4
    └── ...
```

### Transcode Script

Bash script on akio-fractal that:
- Reads from pool-syn (must be NFS/CIFS mounted or accessible)
- Iterates all episodes across 3 shows
- Extracts season/episode number from filename (e.g., `S01E01`)
- Skips already-transcoded files (resume-safe)
- Writes to pool-terra/car-media/
- Logs progress

## Component 2: Android Setup (Termux + NodeCast + Caddy)

### Prerequisites

- Termux installed from F-Droid or GitHub APK sideload (NOT Play Store)
- Termux:Boot installed from same source
- Battery optimization disabled for Termux in Android settings

### Termux Packages

```bash
pkg install nodejs caddy
termux-setup-storage  # grants access to /storage/emulated/0/
```

### NodeCast TV Setup

- Copy NodeCast TV source to `~/nodecast-tv/`
- `npm install` (better-sqlite3 compiles natively on aarch64)
- Apply the same quick-login patch from akio-nodecast (JWT skip for CarStream)
- ffprobe available via `pkg install ffmpeg` if needed (optional — transcoding not needed locally)

### Caddy File Server

Serves the CarMedia directory over HTTP on port 8081:

```
caddy file-server --root /storage/emulated/0/CarMedia --listen :8081
```

NodeCast streams from `http://localhost:8081/{Show}/S01E01.mp4`.

### M3U Playlist Generation

A script scans `CarMedia/` and generates an M3U playlist for NodeCast:

- **Live channels:** One per show (continuous shuffle), plus one "Sitcom Shuffle" channel (all shows mixed)
- **VOD entries:** Each show as a series with season/episode structure for on-demand browsing

Regenerated on boot (always fresh) and after any content sync.

### Boot Script

`~/.termux/boot/start-carcast.sh`:

```bash
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
# Regenerate M3U from current content
~/nodecast-tv/scripts/generate-m3u.sh
# Start Caddy file server
caddy file-server --root /storage/emulated/0/CarMedia --listen :8081 &
# Start NodeCast TV
cd ~/nodecast-tv && node server/index.js &
```

Startup time: ~3-5 seconds from Termux:Boot trigger to services ready.

### Resilience

- `termux-wake-lock` prevents Android from killing Termux in background
- Battery optimization exemption for Termux
- Boot script handles frequent power-cycle scenario (phone dies → charges → boots → services auto-start)
- No state to corrupt — M3U is regenerated each boot, SQLite WAL handles unclean shutdowns

## Component 3: Content Sync

### Initial Load

1. Transcode on akio-fractal → pool-terra/car-media/
2. `adb push /path/to/pool-terra/car-media/ /storage/emulated/0/CarMedia/` over USB

### Future Incremental Sync

Deferred. Options when needed:
- **Manual:** Re-run transcode script (skips existing), `adb push` new files
- **Syncthing:** LXC with pool-terra mounted runs Syncthing, Android Syncthing app syncs on home WiFi

### Pool-terra as Canonical Copy

`pool-terra/car-media/` is the source of truth. Whatever is there should be 1:1 with the phone. This directory is already created:

```
/mnt/pool-terra/car-media/
├── Friends/
├── HIMYM/
└── BBT/
```

## Open Items (Deferred)

- **Syncthing setup** — add to a homelab LXC + Android app when incremental sync is needed
- **YouTube music content** — no homelab service for music management yet; add content source when available
- **Additional shows** — same pipeline applies; add show directory, re-run transcode, re-push
- **Fractal pool-syn mount** — verify akio-fractal can access pool-syn for transcoding; may need NFS/CIFS mount setup
