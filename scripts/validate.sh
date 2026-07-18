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

check_docker_compose() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "[MISSING] docker compose"
    return
  fi

  if docker compose version >/dev/null 2>&1; then
    echo "[OK] docker compose -> $(docker compose version)"
  else
    echo "[MISSING] docker compose"
  fi
}

echo "Validating Linux workstation setup..."
echo

echo "Base tools:"
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
echo "DevOps tools:"
check_command kubectl
check_command helm
check_command kubectx
check_command kubens
check_command k9s
check_command stern
check_command glow

echo
echo "Docker tooling:"
check_command docker
check_docker_compose
check_command lazydocker
check_command dive

echo
echo "Validation completed."
