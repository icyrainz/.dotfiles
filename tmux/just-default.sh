#!/usr/bin/env bash
if ! just --summary &>/dev/null; then
  echo "No justfile found"
  read -n1 -rsp "Press any key to close..."
  exit 0
fi

just
read -n1 -rsp "Press any key to close..."
