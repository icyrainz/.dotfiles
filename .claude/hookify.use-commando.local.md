---
name: use-commando
enabled: true
event: bash
pattern: ssh\s+.*\b(akio-lab|akio-garage|akio-fractal)\b
action: block
---

**Use Commando MCP instead of SSH!**

You're trying to SSH to a machine that has the commando-agent installed. Use Commando MCP tools instead — they're ~58x faster and avoid shell escaping issues.

**For Proxmox host commands** (e.g., `pvesm status`, `free -h`, `uptime`, `smartctl`, `lvs`):
```
commando_exec(target="akio-lab", command="...")
commando_exec(target="akio-garage", command="...")
```

**For LXC container commands:**
```
commando_exec(target="akio-lab/<hostname>", command="...")
commando_exec(target="akio-garage/<hostname>", command="...")
```

**For akio-fractal:**
```
commando_exec(target="akio-fractal", command="bash -c '...'")
```

**Only use SSH for operations Commando cannot do:**
- `pct push`, `pct resize`, `pct clone`, `pct set`, `pct start/stop`
- `qm` VM management commands (`qm start`, `qm stop`, `qm guest exec`)
- LXCs that don't have commando-agent installed yet
- Interactive/TTY operations
