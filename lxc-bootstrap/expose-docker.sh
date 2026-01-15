#!/bin/bash

# Enable Docker TCP on port 2375 for What's Up Docker
#
# Run with:
#   curl -fsSL https://raw.githubusercontent.com/icyrainz/.dotfiles/refs/heads/master/lxc-bootstrap/expose-docker.sh | bash

set -e

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

OVERRIDE_DIR="/etc/systemd/system/docker.service.d"
OVERRIDE_FILE="${OVERRIDE_DIR}/override.conf"

# Configure Docker TCP if not already done
if [[ -f "$OVERRIDE_FILE" ]] && grep -q "tcp://0.0.0.0:2375" "$OVERRIDE_FILE"; then
  echo "Docker TCP already configured."
else
  echo "Setting up Docker TCP on port 2375..."

  mkdir -p "$OVERRIDE_DIR"

  cat >"$OVERRIDE_FILE" <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock
EOF

  echo "Created $OVERRIDE_FILE"

  systemctl daemon-reload
  systemctl restart docker

  sleep 2
  if ss -tlnp | grep -q ":2375"; then
    echo "✓ Docker TCP enabled on port 2375"
  else
    echo "✗ Failed to enable Docker TCP"
    exit 1
  fi
fi
