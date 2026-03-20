# Unified Observability Stack — akio-obs

**Date:** 2026-03-20
**Status:** Draft
**Motivation:** No centralized logging exists across the homelab. Errors like NFS stale file handles go unnoticed for days. Need unified logs, metrics, and dashboards across all LXCs, GPU nodes, and Proxmox hosts.

## Stack

| Component | Role | Image |
|-----------|------|-------|
| VictoriaMetrics | Metrics storage + query (PromQL-compatible) | `victoriametrics/victoria-metrics` |
| VictoriaLogs | Log storage + query (LogsQL) | `victoriametrics/victoria-logs` |
| Grafana | Dashboards + visualization | `grafana/grafana-oss` |
| Grafana Alloy | Collection agent (per-LXC) | Native Debian package via Grafana APT repo |

**Why Victoria over Prometheus/Loki:** Significantly lower resource usage (~200MB RAM each vs 1-2GB), single binaries, PromQL-compatible. VictoriaMetrics is API-compatible with Prometheus — Grafana registers it as a Prometheus-type datasource. Escape hatch: swap to Prometheus/Loki by changing one URL in Alloy config.

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                   akio-obs (LXC 136)                     │
│                                                          │
│  ┌──────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │ Grafana      │  │ VictoriaMetrics │  │ VictoriaLogs│ │
│  │ :3000        │  │ :8428           │  │ :9428       │ │
│  └──────────────┘  └────────▲────────┘  └──────▲──────┘ │
│                             │                   │        │
└─────────────────────────────┼───────────────────┼────────┘
                              │                   │
         ┌────────────────────┴───────────────────┘
         │
    ┌────┴──────────────────────────────────┐
    │  Grafana Alloy (on every LXC)         │
    │  - Docker logs (discovery.docker)     │
    │  - systemd journal                    │
    │  - node metrics (built-in exporter)   │
    │  - remote_write → akio-obs:8428       │
    │  - log push → akio-obs:9428           │
    └───────────────────────────────────────┘
```

## akio-obs LXC Spec

- **VMID:** 136
- **Hostname:** akio-obs
- **Node:** akio-lab
- **Disk:** 16GB OS (storage: `local-lvm-2`)
- **RAM:** 2GB (swap: 1GB)
- **CPU:** 2 cores
- **NFS mount:** `/mnt/pool-terra/observability/` for metrics + log data
- **Network:** Static IP on 192.168.0.0/24

### Pre-Setup
```bash
# Create NFS directories on pool-terra (from any LXC with the mount)
mkdir -p /mnt/pool-terra/observability/{vm-data,vl-data}
```

## Docker Compose (akio-obs)

Three services following the `~/docker-app/docker-compose.yml` convention:

### VictoriaMetrics
- Image: `victoriametrics/victoria-metrics`
- Port: 8428
- Volume: `/mnt/pool-terra/observability/vm-data:/data`
- Flags: `-retentionPeriod=30d -storageDataPath=/data`

### VictoriaLogs
- Image: `victoriametrics/victoria-logs`
- Port: 9428
- Volume: `/mnt/pool-terra/observability/vl-data:/data`
- Flags: `-retentionPeriod=30d -storageDataPath=/data`

### Grafana
- Image: `grafana/grafana-oss`
- Port: 3000
- Volume: `./grafana-data:/var/lib/grafana` (local, SQLite DB is small)
- Environment: `GF_INSTALL_PLUGINS=victoriametrics-logs-datasource`
- Datasources provisioned via `./provisioning/datasources/`:
  - VictoriaMetrics as Prometheus-type datasource (`http://victoriametrics:8428`)
  - VictoriaLogs via `victoriametrics-logs-datasource` plugin (`http://victorialogs:9428`)

All services: `restart: unless-stopped`.

## Alloy Agent (Per-LXC)

### Installation
Native Debian package from Grafana APT repo. Runs as systemd service.
Config: `/etc/alloy/config.alloy`

**Docker LXCs:** Alloy user must be in `docker` group (for Docker socket) and `systemd-journal` group (for journal access).

**Non-Docker hosts** (GPU LXCs, Proxmox hosts): Alloy only needs `systemd-journal` group. Config omits `discovery.docker` and `loki.source.docker` components — journal + node metrics only.

Two Alloy config variants:
- `config-docker.alloy` — Docker LXCs (docker logs + journal + metrics)
- `config-host.alloy` — Non-Docker hosts (journal + metrics only)

### What it collects

| Source | Alloy Component | Shipped to |
|--------|----------------|------------|
| Docker container stdout/stderr | `discovery.docker` + `loki.source.docker` | VictoriaLogs :9428 |
| Systemd journal | `loki.source.journal` | VictoriaLogs :9428 |
| Node metrics (CPU, RAM, disk, net) | `prometheus.exporter.unix` | VictoriaMetrics :8428 |

### Labels (kept under 10)
- `host` — LXC hostname (e.g., `akio-pinchflat`)
- `job` — source type (`docker`, `journal`, `node`)
- For Docker logs: `container_name`, `compose_service`

### Endpoints
- Metrics: `http://akio-obs:8428/api/v1/write` (Prometheus remote_write)
- Logs: `http://akio-obs:9428/insert/loki/api/v1/push` (VictoriaLogs Loki-compatible endpoint)

Uses `akio-obs` hostname (not `grafana.lan`) to avoid routing through NPM.

## Rollout Order

1. **akio-obs itself** — dogfood, monitor the monitoring stack
2. **High-value LXCs:** akio-pinchflat, akio-arr, akio-ntfy, akio-torrent
3. **Remaining Docker LXCs** in batches (~20 containers)
4. **GPU node LXCs:** akio-plex, akio-ollama, akio-openwebui (journal + metrics only, no Docker)
5. **Proxmox hosts:** akio-lab, akio-garage (journal + node metrics, uses `config-host.alloy`). Alloy installs via the same Grafana APT repo (Proxmox is Debian-based). Low resource overhead — should not interfere with Proxmox services.

## Network & Access

- **NPM proxy:** `grafana.lan` → `akio-obs:3000`
- **Pi-hole DNS:** `akio-obs` → LXC IP
- **No auth** — LAN only, consistent with other homelab services

## Dashboards (Initial)

| Dashboard | Purpose |
|-----------|---------|
| Cluster Overview | All LXCs: CPU, RAM, disk, network at a glance |
| Docker Containers | Container status, restart counts, resource usage per LXC |
| Log Explorer | Searchable logs across all services, filterable by host/container/severity |

Import community dashboards (e.g., Grafana ID 1860 for node metrics) and customize. VictoriaMetrics is PromQL-compatible so community dashboards work.

## Deferred (Future Phases)

- **Alerting:** Grafana webhook contact point → ntfy `homelab-alerts` topic. Alert rules for stale NFS mounts, crash loops, disk usage, service down.
- **akio-omv monitoring:** Scrape OMV web API remotely from Alloy on akio-obs for disk health and NFS server metrics.
- **LXC template:** Bake Alloy installation into akio-lxc-template (VMID 1000) for new containers.
- **Existing InfluxDB consolidation:** Evaluate whether PeaNUT and Scrutiny InfluxDB instances should feed into VictoriaMetrics.

## Out of Scope

- **akio-nas (VMID 102):** FreeBSD, no apt package manager
- **akio-haos (VMID 117):** Immutable OS, no package installation

## Escape Hatches

- **VictoriaLogs → Loki:** If VictoriaLogs' Grafana plugin is too rough, swap to Loki. Alloy config change only (switch `loki.write` endpoint).
- **VictoriaMetrics → Prometheus:** Register as Prometheus-type datasource already. Swap backend by changing Alloy's remote_write URL.
- **Alloy collects everything** — the storage backend is interchangeable without touching agents.

## Retention & Storage Estimates

- Retention: 30 days for both metrics and logs
- Metrics: ~1-3 GB for 30 days (VictoriaMetrics compression)
- Logs: Depends on volume, estimate 10-50 GB for 30 days across ~30 LXCs
- Storage location: pool-terra (17 TB free) — not a constraint
