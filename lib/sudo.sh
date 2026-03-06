#!/usr/bin/env bash
# Shared sudo helper — source this from install scripts.
# Sets SUDO="" when root, SUDO="sudo" otherwise.
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
elif command -v sudo &>/dev/null; then
  SUDO="sudo"
else
  SUDO=""
fi
