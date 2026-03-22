# Paperless-ngx LXC Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deploy Paperless-ngx in a new LXC (VMID 137) on akio-lab with documents stored on pool-terra NFS.

**Architecture:** Clone LXC from template 1000, bind-mount pool-terra NFS, run Paperless-ngx + PostgreSQL + Redis via Docker Compose. NPM reverse proxy at `paperless.lan`, Pi-hole DNS for `akio-paperless`.

**Tech Stack:** Proxmox LXC, Docker Compose, Paperless-ngx, PostgreSQL 16, Redis 7

**Spec:** `docs/superpowers/specs/2026-03-22-paperless-ngx-design.md`

**Tooling:** All commands on Proxmox hosts use `commando exec akio-lab '<command>'`. Commands inside the LXC use `commando exec akio-lab 'pct exec 137 -- <command>'`. File creation uses `scp` to Proxmox host + `pct push` into LXC.

**Credentials:** NPM creds (`NGINX_USERNAME`, `NGINX_PASSWORD`) and Pi-hole password (`PIHOLE_PASSWORD`) are in fish extra (`~/.config/fish/include/ignore/extra.fish`). Use `$NGINX_USERNAME`, `$NGINX_PASSWORD`, `$PIHOLE_PASSWORD` in commands.

---

### Task 1: Clone and Configure LXC

- [ ] **Step 1: Clone template**

```bash
commando exec akio-lab 'pct clone 1000 137 --storage local-lvm-2 --hostname akio-paperless --full'
```

Expected: no output (success)

- [ ] **Step 2: Set resources**

```bash
commando exec akio-lab 'pct set 137 --memory 4096 --swap 512 --cores 2 --onboot 1'
```

Expected: no output (success)

- [ ] **Step 3: Resize root disk to 16 GB**

Template disk is 8 GB. Add 8 GB more:

```bash
commando exec akio-lab 'pct resize 137 rootfs +8G'
```

Expected: no output (success)

- [ ] **Step 4: Add bind mount for pool-terra**

```bash
commando exec akio-lab 'pct set 137 --mp0 /mnt/pool-terra/paperless,mp=/mnt/pool-terra'
```

Expected: no output (success)

- [ ] **Step 5: Create NFS directories on pool-terra**

```bash
commando exec akio-lab 'mkdir -p /mnt/pool-terra/paperless/{consume,media,export} && chown -R 1000:1000 /mnt/pool-terra/paperless'
```

Expected: no output (success)

- [ ] **Step 6: Start LXC and get IP**

```bash
commando exec akio-lab 'pct start 137'
```

Wait a few seconds for DHCP, then:

```bash
commando exec akio-lab 'pct exec 137 -- hostname -I'
```

Expected: an IP address like `192.168.0.XXX`. **Record this IP — needed for all subsequent tasks.**

- [ ] **Step 7: Verify bind mount is accessible**

```bash
commando exec akio-lab 'pct exec 137 -- ls /mnt/pool-terra/'
```

Expected: `consume  export  media`

---

### Task 2: Create Docker Compose and Start Services

- [ ] **Step 1: Create docker-app directory**

```bash
commando exec akio-lab 'pct exec 137 -- mkdir -p /root/docker-app/data/{db,redis,paperless}'
```

- [ ] **Step 2: Generate PAPERLESS_SECRET_KEY**

Run locally:

```bash
openssl rand -hex 32
```

Record the output — this is the `PAPERLESS_SECRET_KEY`.

- [ ] **Step 3: Write docker-compose.yml into LXC**

Create the file locally at `/tmp/paperless-compose.yml` with the content below, substituting `<PAPERLESS_SECRET_KEY>` with the value from step 2 and `<ADMIN_PASSWORD>` with a chosen password:

```yaml
services:
  broker:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - ./data/redis:/data

  db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: paperless
      POSTGRES_USER: paperless
      POSTGRES_PASSWORD: paperless
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - ./data/db:/var/lib/postgresql/data

  webserver:
    image: ghcr.io/paperless-ngx/paperless-ngx:latest
    restart: unless-stopped
    depends_on:
      - broker
      - db
    ports:
      - "8000:8000"
    environment:
      PAPERLESS_REDIS: redis://broker:6379
      PAPERLESS_DBHOST: db
      PAPERLESS_DBNAME: paperless
      PAPERLESS_DBUSER: paperless
      PAPERLESS_DBPASS: paperless
      PAPERLESS_URL: http://paperless.lan
      PAPERLESS_SECRET_KEY: "<PAPERLESS_SECRET_KEY>"
      PAPERLESS_OCR_LANGUAGE: eng
      PAPERLESS_ADMIN_USER: admin
      PAPERLESS_ADMIN_PASSWORD: "<ADMIN_PASSWORD>"
      USERMAP_UID: 1000
      USERMAP_GID: 1000
    volumes:
      - ./data/paperless:/usr/src/paperless/data
      - /mnt/pool-terra/consume:/usr/src/paperless/consume
      - /mnt/pool-terra/media:/usr/src/paperless/media
      - /mnt/pool-terra/export:/usr/src/paperless/export
```

Push the file to the Proxmox host, then into the LXC:

```bash
scp /tmp/paperless-compose.yml root@akio-lab:/tmp/paperless-compose.yml
```

```bash
commando exec akio-lab 'pct push 137 /tmp/paperless-compose.yml /root/docker-app/docker-compose.yml && rm /tmp/paperless-compose.yml'
```

- [ ] **Step 4: Pull images and start services**

```bash
commando exec akio-lab 'pct exec 137 -- bash -c "cd /root/docker-app && docker compose pull"'
```

Then:

```bash
commando exec akio-lab 'pct exec 137 -- bash -c "cd /root/docker-app && docker compose up -d"'
```

- [ ] **Step 5: Verify all containers are running**

Wait ~30 seconds for initial startup, then:

```bash
commando exec akio-lab 'pct exec 137 -- bash -c "cd /root/docker-app && docker compose ps"'
```

Expected: 3 containers (`broker`, `db`, `webserver`) all with status `Up`.

- [ ] **Step 6: Verify admin superuser was created**

The `PAPERLESS_ADMIN_USER` / `PAPERLESS_ADMIN_PASSWORD` env vars auto-create the superuser on first start. Check the logs:

```bash
commando exec akio-lab 'pct exec 137 -- bash -c "cd /root/docker-app && docker compose logs webserver 2>&1 | grep -i superuser"'
```

Expected: log line confirming superuser was created.

**Important:** After confirming the superuser exists, remove `PAPERLESS_ADMIN_USER` and `PAPERLESS_ADMIN_PASSWORD` from docker-compose.yml (they are only needed on first boot, and leaving them in means the password resets on every container recreation).

---

### Task 3: Configure NPM Reverse Proxy

`paperless.lan` resolves immediately via the existing Pi-hole wildcard (`address=/lan/192.168.0.52`) — no DNS step needed for the `.lan` domain.

- [ ] **Step 1: Get NPM API token**

Use `$NGINX_USERNAME` and `$NGINX_PASSWORD` from fish extra:

```bash
commando exec akio-lab/akio-nginx "curl -s http://localhost:81/api/tokens -X POST -H 'Content-Type: application/json' -d '{\"identity\":\"$NGINX_USERNAME\",\"secret\":\"$NGINX_PASSWORD\"}'"
```

Expected: JSON with a `token` field. Record the token value.

- [ ] **Step 2: Add proxy host for paperless.lan**

Replace `<TOKEN>` with the token from step 1, and `<LXC_IP>` with the IP from Task 1 Step 6:

```bash
commando exec akio-lab/akio-nginx 'curl -s http://localhost:81/api/nginx/proxy-hosts -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <TOKEN>" -d "{\"domain_names\":[\"paperless.lan\"],\"forward_scheme\":\"http\",\"forward_host\":\"<LXC_IP>\",\"forward_port\":8000,\"allow_websocket_upgrade\":true,\"block_exploits\":false,\"access_list_id\":0,\"certificate_id\":0,\"meta\":{\"letsencrypt_agree\":false,\"dns_challenge\":false},\"advanced_config\":\"\",\"locations\":[],\"http2_support\":false,\"hsts_enabled\":false,\"hsts_subdomains\":false,\"ssl_forced\":false,\"caching_enabled\":false}"'
```

Expected: JSON response with `"id": <number>` confirming the proxy host was created.

- [ ] **Step 3: Verify proxy works**

```bash
curl -s -o /dev/null -w "%{http_code}" http://paperless.lan
```

Expected: `200` or `302` (redirect to login page).

---

### Task 4: Add Pi-hole DNS Record

This adds the `akio-paperless` hostname (for direct IP resolution). The `paperless.lan` domain already works via the `*.lan` wildcard.

- [ ] **Step 1: Add local DNS entry**

Replace `<LXC_IP>` with the IP from Task 1 Step 6. Use `$PIHOLE_PASSWORD` from fish extra:

```bash
commando exec akio-lab/akio-pihole "docker exec pihole bash -c 'API_URL=\"http://localhost/api/\"; AUTH_RESP=\$(curl -skS -X POST \"\${API_URL}auth\" -H \"Content-Type: application/json\" -d \"{\\\"password\\\":\\\"$PIHOLE_PASSWORD\\\"}\" 2>/dev/null); SID=\$(echo \"\$AUTH_RESP\" | grep -o \"\\\"sid\\\":\\\"[^\\\"]*\\\"\" | cut -d\\\" -f4); curl -skS -X PUT \"\${API_URL}config/dns/hosts/<LXC_IP>%20akio-paperless\" -H \"Accept: application/json\" -H \"sid: \$SID\"; curl -skS -o /dev/null -X DELETE \"\${API_URL}auth\" -H \"sid: \$SID\"'"
```

Expected: `{"took": ...}` response (no error key).

- [ ] **Step 2: Verify DNS resolution**

```bash
dig akio-paperless @192.168.0.198 +short
```

Expected: `<LXC_IP>`

---

### Task 5: Install Commando Agent

- [ ] **Step 1: Copy binaries from existing LXC**

```bash
commando exec akio-lab 'pct pull 126 /usr/local/bin/commando-agent /tmp/commando-agent && pct push 137 /tmp/commando-agent /usr/local/bin/commando-agent --perms 755 && rm /tmp/commando-agent'
```

```bash
commando exec akio-lab 'pct pull 126 /usr/local/bin/rtk /tmp/rtk && pct push 137 /tmp/rtk /usr/local/bin/rtk --perms 755 && rm /tmp/rtk'
```

- [ ] **Step 2: Create rtk symlink**

```bash
commando exec akio-lab 'pct exec 137 -- ln -s /usr/local/bin/rtk /usr/bin/rtk'
```

- [ ] **Step 3: Generate PSK**

Run locally:

```bash
openssl rand -hex 32
```

Record the output — this is the agent PSK.

- [ ] **Step 4: Write agent.toml**

Create `/tmp/agent.toml` locally with this content, substituting `<LXC_IP>` and `<PSK>`:

```toml
bind = "<LXC_IP>"
port = 9876
shell = "sh"
psk = "<PSK>"
max_output_bytes = 131072
max_concurrent = 8
rtk = true
```

Push to the LXC:

```bash
scp /tmp/agent.toml root@akio-lab:/tmp/agent.toml
```

```bash
commando exec akio-lab 'pct exec 137 -- mkdir -p /etc/commando && pct push 137 /tmp/agent.toml /etc/commando/agent.toml && rm /tmp/agent.toml'
```

- [ ] **Step 5: Write systemd service file**

Create `/tmp/commando-agent.service` locally:

```ini
[Unit]
Description=Commando Agent
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/commando-agent --config /etc/commando/agent.toml
Restart=always
RestartSec=5
NoNewPrivileges=yes
ProtectSystem=true
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
```

Push and enable:

```bash
scp /tmp/commando-agent.service root@akio-lab:/tmp/commando-agent.service
```

```bash
commando exec akio-lab 'pct push 137 /tmp/commando-agent.service /etc/systemd/system/commando-agent.service && rm /tmp/commando-agent.service'
```

```bash
commando exec akio-lab 'pct exec 137 -- bash -c "systemctl daemon-reload && systemctl enable --now commando-agent"'
```

- [ ] **Step 6: Register in Commando gateway**

Add the PSK and target entry to `/etc/commando/gateway.toml` on LXC 134.

PSK line — add under `[agent.psk]` after the last `akio-lab/akio-stash` entry:

```
"akio-lab/akio-paperless" = "<PSK>"
```

Target block — add after the last akio-lab `[[targets]]` entry (before `# akio-garage targets`):

```toml
[[targets]]
name = "akio-lab/akio-paperless"
host = "<LXC_IP>"
port = 9876
shell = "sh"
tags = ["documents"]
```

Read the current gateway config, insert the entries at the correct positions, and write back:

```bash
commando exec akio-lab/akio-commando 'cat /etc/commando/gateway.toml'
```

Then use `sed` or full file rewrite via `commando exec akio-lab/akio-commando` to insert the new entries.

- [ ] **Step 7: Restart Commando gateway**

```bash
commando exec akio-lab/akio-commando 'cd /root/docker-app && docker compose restart'
```

Expected: brief 502 while gateway restarts, then recovers.

- [ ] **Step 8: Verify Commando agent**

Wait ~10 seconds, then:

```bash
commando ping akio-lab/akio-paperless
```

Expected: hostname, uptime, shell, and version info.

---

### Task 6: Final Verification and Cleanup

- [ ] **Step 1: Verify all services healthy**

```bash
commando exec akio-lab/akio-paperless 'cd /root/docker-app && docker compose ps'
```

Expected: 3 containers all `Up`.

- [ ] **Step 2: Verify web UI accessible**

```bash
curl -s -o /dev/null -w "%{http_code}" http://paperless.lan
```

Expected: `200` or `302`

- [ ] **Step 3: Get LXC MAC address for DHCP reservation**

```bash
commando exec akio-lab 'grep hwaddr /etc/pve/lxc/137.conf'
```

Record the MAC address. **User action required:** Go to router admin and add a DHCP reservation mapping this MAC to `<LXC_IP>`.

- [ ] **Step 4: Update homelab inventory**

Add the new LXC to the homelab skill inventory file at the appropriate location in the akio-lab LXC table:

```
| 137 | akio-paperless | Document archive | paperless-ngx, postgres:16-alpine, redis:7-alpine |
```

- [ ] **Step 5: Remove admin credentials from docker-compose.yml**

If not already done in Task 2 Step 6, remove `PAPERLESS_ADMIN_USER` and `PAPERLESS_ADMIN_PASSWORD` from the compose file and recreate the webserver:

```bash
commando exec akio-lab/akio-paperless 'cd /root/docker-app && docker compose up -d'
```
