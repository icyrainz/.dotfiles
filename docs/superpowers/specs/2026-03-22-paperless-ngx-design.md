# Paperless-ngx LXC Setup Design

## Purpose

Deploy Paperless-ngx as a personal document archive (bills, receipts, tax docs, mail) in a new LXC on akio-lab. Documents stored on pool-terra (NFS from akio-omv) for durability and backup.

## Infrastructure

| Setting | Value |
|---------|-------|
| VMID | 136 |
| Hostname | `akio-paperless` |
| Template | 1000 (akio-lxc-template) |
| Memory | 4096 MB |
| Swap | 512 MB |
| Cores | 2 |
| Root disk | 8 GB (default — OS + Docker only) |
| Bind mount | host `/mnt/pool-terra/paperless` → LXC `/mnt/pool-terra` |
| Node | akio-lab |

The template includes Docker, nesting, and AppArmor unconfined. No GPU passthrough or Tailscale needed.

## Docker Stack

Three containers following the `~/docker-app/docker-compose.yml` convention:

### paperless-ngx (webserver)

- Image: `ghcr.io/paperless-ngx/paperless-ngx:latest`
- Port: 8000
- OCR: built-in Tesseract (English)
- No Tika/Gotenberg sidecars (not needed for basic personal docs)

### PostgreSQL

- Image: `postgres:16-alpine`
- PGDATA set explicitly to `/var/lib/postgresql/data/pgdata` (per pitfalls — avoids anonymous volume conflicts)
- Data stored on local LXC disk (`./data/db`)

### Redis

- Image: `redis:7-alpine`
- Used as task broker for scheduled jobs (mail fetching, index optimization)
- Data stored on local LXC disk (`./data/redis`)

## Volume Layout

| Container path | Host path | Storage | Purpose |
|---------------|-----------|---------|---------|
| Postgres PGDATA | `./data/db` | Local LXC | Database |
| Redis `/data` | `./data/redis` | Local LXC | Task broker AOF |
| `/usr/src/paperless/consume` | `/mnt/pool-terra/consume` | NFS (pool-terra) | Drop documents here for ingestion |
| `/usr/src/paperless/media` | `/mnt/pool-terra/media` | NFS (pool-terra) | Archived originals + thumbnails |
| `/usr/src/paperless/data` | `/mnt/pool-terra/data` | NFS (pool-terra) | Search index + classification model |
| `/usr/src/paperless/export` | `/mnt/pool-terra/export` | NFS (pool-terra) | Backup exports |

## Networking

- **Reverse proxy:** NPM (LXC 101) proxies `paperless.lan` → `<LXC_IP>:8000`
- **DNS:** Pi-hole (LXC 107) local DNS record `akio-paperless` → `<LXC_IP>`
- **LAN wildcard:** `*.lan` already routes to NPM via Pi-hole wildcard `address=/lan/192.168.0.52`

## Post-Setup

1. Create admin superuser via `docker compose exec webserver createsuperuser`
2. Install commando-agent + rtk, register in gateway (LXC 134)
3. User to reserve DHCP lease for the LXC MAC → IP

## Decisions Made

- **Paperless-ngx over alternatives** (Papra, Papermerge, Docspell): best OCR, auto-tagging, community, and maturity for personal doc archiving
- **pool-terra for documents**: consistent with other media services (pinchflat, stash) already using this NFS share
- **No Tika/Gotenberg**: user's use case is personal documents (scanned PDFs, images), not Office files
- **8 GB root disk**: only OS + Docker layers; all document data lives on pool-terra
- **postgres:16-alpine**: follows existing convention (nocodb, litellm use postgres:16/18-alpine)
