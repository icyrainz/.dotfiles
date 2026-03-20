# akio-stash LXC Setup — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deploy Stash in a new Docker-based LXC (VMID 135) on akio-lab with media storage on pool-terra NFS.

**Architecture:** Clone LXC template 1000 (Docker-ready Debian), mount pool-terra NFS, deploy `stashapp/stash` via Docker Compose, configure NPM reverse proxy and Pi-hole DNS.

**Tech Stack:** Proxmox (pct), Docker Compose, NPM API, Pi-hole v6 API

**Spec:** `docs/superpowers/specs/2026-03-19-akio-stash-design.md`

**Credentials needed:** NPM creds (`NGINX_USERNAME` / `NGINX_PASSWORD`) and Pi-hole password (`PIHOLE_PASSWORD`) from fish extra (`~/.config/fish/include/ignore/extra.fish`).

---

### Task 1: Clone LXC Template and Configure Resources

- [ ] **Step 1: Clone template 1000**

```bash
ssh root@akio-lab "pct clone 1000 135 --storage local-lvm-2 --hostname akio-stash --full"
```

Expected: Clone completes, no errors.

- [ ] **Step 2: Resize disk to 16GB**

Template default is 8GB. Resize to 16GB for Docker layers + cache headroom.

```bash
ssh root@akio-lab "pct resize 135 rootfs +8G"
```

Expected: Output confirms resize.

- [ ] **Step 3: Configure resources**

```bash
ssh root@akio-lab "pct set 135 --memory 2048 --swap 1024 --cores 4 --onboot 1"
```

Expected: No errors.

- [ ] **Step 4: Add pool-terra NFS mount passthrough**

```bash
ssh root@akio-lab "pct set 135 --mp0 /mnt/pool-terra/,mp=/mnt/pool-terra"
```

Expected: No errors. This bind-mounts the host's NFS mount into the LXC.

- [ ] **Step 5: Start the LXC**

```bash
ssh root@akio-lab "pct start 135"
```

Expected: LXC starts without errors.

- [ ] **Step 6: Verify LXC is running and get IP**

```bash
ssh root@akio-lab "pct exec 135 -- hostname -I"
```

Expected: Returns an IP address (e.g., `192.168.0.X`). Save this IP — needed for NPM and Pi-hole steps.

- [ ] **Step 7: Verify pool-terra is accessible inside LXC**

```bash
ssh root@akio-lab "pct exec 135 -- ls /mnt/pool-terra/"
```

Expected: Shows contents of pool-terra NFS share.

---

### Task 2: Create NFS Directories and Deploy Docker Compose

- [ ] **Step 1: Create stash directories on pool-terra**

```bash
ssh root@akio-lab "pct exec 135 -- mkdir -p /mnt/pool-terra/stash/{data,metadata,generated,blobs}"
```

Expected: No errors. Directories created on NFS share.

- [ ] **Step 2: Create docker-compose.yml**

```bash
ssh root@akio-lab "pct exec 135 -- mkdir -p /root/docker-app"
ssh root@akio-lab "pct exec 135 -- tee /root/docker-app/docker-compose.yml" << 'EOF'
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
EOF
```

Expected: File contents echoed back, no errors. If heredoc through `pct exec` fails (empty file or hang), write the file locally and use `pct push 135 /tmp/docker-compose.yml /root/docker-app/docker-compose.yml` instead.

- [ ] **Step 3: Pull image and start the container**

```bash
ssh root@akio-lab "pct exec 135 -- bash -c 'cd /root/docker-app && docker compose up -d'"
```

Expected: Image pulls, container starts. Output ends with container name.

- [ ] **Step 4: Verify container is running**

```bash
ssh root@akio-lab "pct exec 135 -- docker ps"
```

Expected: `stash` container is `Up` on port `9999`.

- [ ] **Step 5: Verify Stash responds**

```bash
ssh root@akio-lab "pct exec 135 -- curl -s -o /dev/null -w '%{http_code}' http://localhost:9999"
```

Expected: `200` (or `302` redirect to setup wizard).

---

### Task 3: Configure NPM Reverse Proxy

Requires: NPM creds from fish extra (`~/.config/fish/include/ignore/extra.fish`): `NGINX_USERNAME` and `NGINX_PASSWORD`.

**Important:** Steps 1 and 2 must run in the same shell session so `$TOKEN` persists.

- [ ] **Step 1: Get NPM auth token and create proxy host**

Replace `<NGINX_USERNAME>`, `<NGINX_PASSWORD>`, and `<LXC_IP>` (from Task 1 Step 6) with actual values.

```bash
# Get token
TOKEN=$(ssh root@akio-lab "pct exec 101 -- bash -c 'curl -s http://localhost:81/api/tokens -X POST \
  -H \"Content-Type: application/json\" \
  -d \"{\\\"identity\\\":\\\"<NGINX_USERNAME>\\\",\\\"secret\\\":\\\"<NGINX_PASSWORD>\\\"}\"'" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])") && \
# Create proxy host
ssh root@akio-lab "pct exec 101 -- bash -c 'curl -s http://localhost:81/api/nginx/proxy-hosts -X POST \
  -H \"Content-Type: application/json\" \
  -H \"Authorization: Bearer $TOKEN\" \
  -d \"{\\\"domain_names\\\":[\\\"stash.lan\\\"],\\\"forward_scheme\\\":\\\"http\\\",\\\"forward_host\\\":\\\"<LXC_IP>\\\",\\\"forward_port\\\":9999,\\\"allow_websocket_upgrade\\\":true,\\\"block_exploits\\\":false,\\\"access_list_id\\\":0,\\\"certificate_id\\\":0,\\\"meta\\\":{\\\"letsencrypt_agree\\\":false,\\\"dns_challenge\\\":false},\\\"advanced_config\\\":\\\"\\\",\\\"locations\\\":[],\\\"http2_support\\\":false,\\\"hsts_enabled\\\":false,\\\"hsts_subdomains\\\":false,\\\"ssl_forced\\\":false,\\\"caching_enabled\\\":false}\"'"
```

Expected: First command prints a JWT token. Second command returns JSON with the new proxy host ID, no error key.

- [ ] **Step 3: Verify stash.lan resolves and proxies**

```bash
curl -s -o /dev/null -w '%{http_code}' http://stash.lan
```

Expected: `200` or `302`. Pi-hole wildcard `*.lan` already routes to NPM (192.168.0.52), so DNS is handled.

---

### Task 4: Add Pi-hole DNS Record

Adds `akio-stash` hostname for direct LXC IP resolution (internal service-to-service communication).

Requires: `PIHOLE_PASSWORD` from fish extra.

- [ ] **Step 1: Add DNS record**

Replace `<LXC_IP>` with the IP from Task 1 Step 6, and `<PIHOLE_PASSWORD>` with actual value.

```bash
ssh root@akio-lab "pct exec 107 -- docker exec pihole bash -c '
API_URL=\"http://localhost/api/\"
AUTH_RESP=\$(curl -skS -X POST \"\${API_URL}auth\" -H \"Content-Type: application/json\" -d \"{\\\"password\\\":\\\"<PIHOLE_PASSWORD>\\\"}\" 2>/dev/null)
SID=\$(echo \"\$AUTH_RESP\" | grep -o \"\\\"sid\\\":\\\"[^\\\"]*\\\"\" | cut -d\\\" -f4)
curl -skS -X PUT \"\${API_URL}config/dns/hosts/<LXC_IP>%20akio-stash\" -H \"Accept: application/json\" -H \"sid: \$SID\"
curl -skS -o /dev/null -X DELETE \"\${API_URL}auth\" -H \"sid: \$SID\"
'"
```

Expected: `{"took": ...}` response, no errors.

- [ ] **Step 2: Verify DNS resolution**

```bash
dig +short akio-stash @192.168.0.198
```

Expected: Returns the LXC IP.

---

### Task 5: Install Commando Agent

Install the commando-agent on akio-stash so it can be managed via Commando MCP.

Agent binary: `/usr/local/bin/commando-agent` (static ELF x86-64, v0.5.10)
Config: `/etc/commando/agent.toml`
Service: systemd unit `commando-agent.service`
Gateway config: `/etc/commando/gateway.toml` on LXC 134 (akio-commando)

- [ ] **Step 1: Copy commando-agent binary from an existing LXC**

```bash
ssh root@akio-lab "pct pull 126 /usr/local/bin/commando-agent /tmp/commando-agent && pct push 135 /tmp/commando-agent /usr/local/bin/commando-agent --perms 755 && rm /tmp/commando-agent"
```

Expected: Binary copied successfully.

- [ ] **Step 2: Generate PSK and create agent config**

Replace `<LXC_IP>` with the IP from Task 1 Step 6.

```bash
PSK=$(openssl rand -hex 32) && echo "PSK: $PSK"
ssh root@akio-lab "pct exec 135 -- mkdir -p /etc/commando"
ssh root@akio-lab "pct exec 135 -- tee /etc/commando/agent.toml" << EOF
bind = "<LXC_IP>"
port = 9876
shell = "sh"
psk = "$PSK"
max_output_bytes = 131072
max_concurrent = 8
rtk = true
EOF
```

Expected: Config file created. Save the `$PSK` value — needed for gateway config in Step 4.

- [ ] **Step 3: Create systemd service and start agent**

```bash
ssh root@akio-lab "pct exec 135 -- tee /etc/systemd/system/commando-agent.service" << 'EOF'
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
EOF
ssh root@akio-lab "pct exec 135 -- bash -c 'systemctl daemon-reload && systemctl enable --now commando-agent'"
```

Expected: Service starts, no errors.

- [ ] **Step 4: Register target in commando gateway**

Add the PSK and target entry to `/etc/commando/gateway.toml` on LXC 134. Replace `<LXC_IP>` and `<PSK>` with actual values.

```bash
# Add PSK entry (append to [agent.psk] section)
ssh root@akio-lab "pct exec 134 -- sed -i '/^# akio-garage LXCs/i \"akio-lab/akio-stash\" = \"<PSK>\"' /etc/commando/gateway.toml"

# Add target entry (append before akio-garage targets section)
ssh root@akio-lab "pct exec 134 -- sed -i '/^# akio-garage targets/i \\
[[targets]]\\
name = \"akio-lab/akio-stash\"\\
host = \"<LXC_IP>\"\\
shell = \"sh\"\\
tags = [\"media\"]\\
' /etc/commando/gateway.toml"

# Restart gateway to pick up new config
ssh root@akio-lab "pct exec 134 -- bash -c 'cd /root/docker-app && docker compose restart'"
```

Expected: Gateway restarts, no errors.

- [ ] **Step 5: Verify commando connectivity**

Use the Commando MCP `commando_ping` tool:

```
commando_ping(target="akio-lab/akio-stash")
```

Expected: Returns hostname, uptime, shell info. Status: Reachable.

---

### Task 6: Update Homelab Documentation

- [ ] **Step 1: Add akio-stash to LXC inventory in homelab skill**

Edit `/Users/tuephan/.claude/skills/homelab/SKILL.md` and add to the "akio-lab LXC containers" table (after VMID 134):

```
| 135 | akio-stash | Video organizer | stash |
```

- [ ] **Step 2: Commit documentation update**

```bash
git add ~/.claude/skills/homelab/SKILL.md
git commit -m "homelab: add akio-stash (VMID 135) to LXC inventory"
```

---

### Task 7: Post-Setup (Manual / First-Run)

These steps require user interaction via the Stash web UI.

- [ ] **Step 1: Access Stash setup wizard**

Open `http://stash.lan` in browser. Complete the first-run wizard.

- [ ] **Step 2: Configure blobs storage**

In Stash settings (or via config file), set blobs to filesystem:

```yaml
# /root/.stash/config.yml (inside the config volume)
blobs_path: /blobs
blobs_storage: FILESYSTEM
```

Alternatively, set this in the Stash web UI under Settings > System.

- [ ] **Step 3: Add media library**

Add `/data` as a library path in Stash settings.

- [ ] **Step 4: Reserve DHCP lease**

Go to router admin and add a DHCP reservation for the LXC MAC → IP. Get the MAC from:

```bash
ssh root@akio-lab "grep hwaddr /etc/pve/lxc/135.conf"
```

- [ ] **Step 5: Run initial scan**

Trigger a library scan from the Stash UI to index media.
