#!/bin/bash

# Enable Docker TCP on port 2375 and configure firewall for What's Up Docker
#
# Run with:
#   curl -fsSL https://raw.githubusercontent.com/icyrainz/.dotfiles/refs/heads/master/lxc-bootstrap/expose-docker.sh | bash

set -e

# What's Up Docker LXC IP - only this host can access Docker API
MANAGER_IP="192.168.0.177"

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

OVERRIDE_DIR="/etc/systemd/system/docker.service.d"
OVERRIDE_FILE="${OVERRIDE_DIR}/override.conf"

# Configure Docker TCP if not already done
if [[ -f "$OVERRIDE_FILE" ]] && grep -q "tcp://0.0.0.0:2375" "$OVERRIDE_FILE"; then
  echo "Docker TCP already configured, skipping."
else
  echo "Setting up Docker TCP on port 2375..."

  # Create override directory if it doesn't exist
  mkdir -p "$OVERRIDE_DIR"

  # Create override file
  cat >"$OVERRIDE_FILE" <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock
EOF

  echo "Created $OVERRIDE_FILE"

  # Reload and restart
  systemctl daemon-reload
  systemctl restart docker

  # Verify
  sleep 2
  if ss -tlnp | grep -q ":2375"; then
    echo "✓ Docker TCP enabled successfully on port 2375"
    docker ps >/dev/null 2>&1 && echo "✓ Docker socket still working"
  else
    echo "✗ Failed to enable Docker TCP"
    exit 1
  fi
fi

# Set up firewall to only allow manager IP
if ufw status | grep -q "2375/tcp.*ALLOW.*$MANAGER_IP"; then
  echo "Firewall already configured for $MANAGER_IP, skipping."
else
  echo "Configuring firewall to allow only $MANAGER_IP..."

  # Delete existing rules for port 2375 (idempotent)
  ufw --force delete allow from "$MANAGER_IP" to any port 2375 proto tcp 2>/dev/null || true
  ufw --force delete deny 2375/tcp 2>/dev/null || true

  # Add rules: deny first, then insert allow at position 1 (processed first)
  ufw deny 2375/tcp
  ufw insert 1 allow from "$MANAGER_IP" to any port 2375 proto tcp

  # Ensure ufw is enabled
  if ! ufw status | grep -q "Status: active"; then
    echo "Enabling ufw..."
    ufw --force enable
  fi

  echo "✓ Firewall configured: only $MANAGER_IP can access port 2375"
fi
