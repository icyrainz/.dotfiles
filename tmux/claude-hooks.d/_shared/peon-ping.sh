#!/bin/bash
# Wrapper for peon-ping — stdin JSON is piped in by the shim
exec "$HOME/.claude/hooks/peon-ping/peon.sh"
