---
name: use-commando
enabled: true
event: bash
pattern: ssh\s+.*\b(akio-lab|akio-garage)\b.*pct\s+exec
action: block
---

**Use Commando MCP instead of SSH!**

You're trying to run a command via SSH on a machine that has the commando-agent installed. Use Commando MCP tools instead — they're ~58x faster and avoid shell escaping issues.

**Instead of SSH+pct exec:**
```
commando_exec(target="akio-lab/<hostname>", command="...")
commando_exec(target="akio-garage/<hostname>", command="...")
```

**Only use SSH for:**
- Proxmox host-level operations (`pct clone`, `pct set`, `pct start/stop`, `pct push`, `pct resize`)
- LXCs that don't have commando-agent installed yet
