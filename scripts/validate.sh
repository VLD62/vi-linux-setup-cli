#!/usr/bin/env bash

set -euo pipefail

check_command() {
  local cmd="$1"

  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[OK] $cmd -> $(command -v "$cmd")"
  else
    echo "[MISSING] $cmd"
  fi
}

echo "Validating Linux workstation setup..."
echo

check_command git
check_command vim
check_command curl
check_command wget
check_command jq
check_command yq
check_command tree
check_command htop
check_command ncdu
check_command rg
check_command fzf
check_command tmux
check_command meld

echo
echo "Validation completed."
