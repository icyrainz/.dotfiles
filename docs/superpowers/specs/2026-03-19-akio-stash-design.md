# akio-stash: Stash LXC Setup

## Overview

New LXC container on akio-lab running [Stash](https://stashapp.cc) — a self-hosted web application for organizing and streaming a video collection with metadata scraping via community plugins.

## Decision Log

- **Node**: akio-lab (pool-terra NFS already mounted on host)
- **Image**: Official `stashapp/stash` over community alternatives. The `feederbox826/stash-s6` image adds VAAPI/NVENC support and PUID/PGID, but hardware acceleration isn't needed for this use case — Stash is primarily an organizer, not a heavy transcoder.
- **GPU**: None. Preview generation runs on CPU (acceptable for non-massive libraries). Live transcoding rarely needed since modern browsers handle H.264/H.265 natively.
- **Storage split**: SQLite DB and cache on local disk (SQLite must not be on NFS — corruption risk). Media, metadata, generated content, and blobs on pool-terra NFS.

## LXC Container

| Setting | Value |
|---------|-------|
| VMID | 135 |
| Hostname | `akio-stash` |
| Node | akio-lab |
| Template | Clone from 1000 (Docker template, full copy) |
| Storage | `local-lvm-2` |
| Disk | 8GB |
| Memory | 2048 MB |
| Swap | 1024 MB |
| Cores | 4 |
| Onboot | Yes |
| GPU | None |
| Mount | `mp0: /mnt/pool-terra/,mp=/mnt/pool-terra` |

The template (1000) includes Docker, nesting, and AppArmor unconfined.

## Docker Compose

Location: `/root/docker-app/docker-compose.yml`

```yaml
services:
  stash:
    image: stashapp/stash:latest
    container_name: stash
    restart: unless-stopped
    ports:
      - "9999:9999"
    environment:
      - STASH_STASH=/data/
      - STASH_GENERATED=/generated/
      - STASH_METADATA=/metadata/
      - STASH_CACHE=/cache/
      - STASH_PORT=9999
    volumes:
      - ./config:/root/.stash
      - /mnt/pool-terra/stash/data:/data
      - /mnt/pool-terra/stash/metadata:/metadata
      - /mnt/pool-terra/stash/generated:/generated
      - /mnt/pool-terra/stash/blobs:/blobs
      - ./cache:/cache
      - /etc/localtime:/etc/localtime:ro
    logging:
      driver: json-file
      options:
        max-file: "10"
        max-size: "2m"
```

## Storage Layout

| Path (container) | Host path | Storage | Purpose |
|-------------------|-----------|---------|---------|
| `/root/.stash` | `./config` | Local 8GB disk | SQLite DB, scrapers, plugins, config |
| `/cache` | `./cache` | Local 8GB disk | Live transcode temp files |
| `/data` | `/mnt/pool-terra/stash/data` | pool-terra NFS (22TB) | Media collection |
| `/metadata` | `/mnt/pool-terra/stash/metadata` | pool-terra NFS | Database metadata exports |
| `/generated` | `/mnt/pool-terra/stash/generated` | pool-terra NFS | Previews, thumbnails, sprites, transcodes |
| `/blobs` | `/mnt/pool-terra/stash/blobs` | pool-terra NFS | Covers, images |

## Networking

| Component | Config |
|-----------|--------|
| Stash port | 9999 |
| NPM proxy | `stash.lan` -> `<akio-stash IP>:9999` (websocket upgrade enabled) |
| Pi-hole DNS | `akio-stash` -> LXC IP |
| DHCP | User reserves static lease on router for LXC MAC -> IP |

## Post-Setup

1. Access Stash at `stash.lan` to complete first-run setup wizard
2. Configure media library path (`/data`) in Stash settings
3. Run initial scan to index the collection
4. Optionally enable preview/thumbnail generation (CPU-based, may take time for large libraries)

## Future Upgrades

If CPU-based transcoding becomes a bottleneck:
- Switch to `feederbox826/stash-s6:hwaccel` image
- Add GPU passthrough: `pct set 135 --dev0 /dev/dri/renderD128` + cgroup `c 226:* rwm`
- AMD Radeon PRO WX 3100 on akio-lab supports VAAPI decode (encode support is limited in Stash)
