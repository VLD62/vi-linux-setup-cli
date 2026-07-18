#!/usr/bin/env bash

set -euo pipefail

ACTION="${1:-plan}"

log() {
  echo "[INFO] $*"
}

warn() {
  echo "[WARN] $*"
}

error() {
  echo "[ERROR] $*" >&2
}

require_ubuntu() {
  if ! command -v apt-get >/dev/null 2>&1; then
    error "This setup currently supports Debian/Ubuntu-based systems only."
    exit 1
  fi
}

is_installed() {
  command -v "$1" >/dev/null 2>&1
}

run_step() {
  local description="$1"
  shift

  if [[ "$ACTION" == "plan" ]]; then
    echo "[PLAN] $description"
  elif [[ "$ACTION" == "apply" ]]; then
    log "$description"
    "$@"
  else
    error "Unknown action: $ACTION"
    echo "Usage: $0 [plan|apply]"
    exit 1
  fi
}

install_apt_packages() {
  sudo apt-get update

  sudo apt-get install -y \
    curl \
    wget \
    git \
    vim \
    tree \
    jq \
    htop \
    ncdu \
    ripgrep \
    fd-find \
    fzf \
    tmux \
    meld \
    ca-certificates \
    apt-transport-https \
    gnupg \
    software-properties-common
}

configure_shell_aliases() {
  local bashrc="$HOME/.bashrc"

  if ! grep -q "alias k='kubectl'" "$bashrc"; then
    cat >> "$bashrc" <<'EOF'

# Kubernetes aliases
alias k='kubectl'

# Editor aliases
alias vi='vim'
alias v='vim'
alias svi='sudo vim'
EOF
  else
    log "Shell aliases already configured."
  fi
}

configure_vim() {
  local vimrc="$HOME/.vimrc"

  if [[ -f "$vimrc" ]]; then
    warn "$vimrc already exists. Skipping Vim configuration."
    return
  fi

  cat > "$vimrc" <<'EOF'
set nocompatible
set encoding=utf-8

set number
set relativenumber
set ruler
set showcmd
set cursorline
set hidden
set mouse=a

set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set autoindent

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yml  setlocal ts=2 sts=2 sw=2 expandtab

set ignorecase
set smartcase
set incsearch
set hlsearch
nnoremap <leader>h :nohlsearch<CR>

syntax on
set background=dark
set showmatch
set wildmenu
set wildmode=longest:full,full

set clipboard=unnamedplus

set splitbelow
set splitright

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

set wrap
set linebreak
EOF
}

install_yq() {
  if is_installed yq; then
    log "yq already installed."
    return
  fi

  sudo wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
  sudo chmod +x /usr/local/bin/yq
}

main() {
  require_ubuntu

  echo "vi-linux-setup-cli"
  echo "Action: $ACTION"
  echo

  run_step "Install base developer packages" install_apt_packages
  run_step "Configure shell aliases" configure_shell_aliases
  run_step "Configure Vim" configure_vim
  run_step "Install yq" install_yq

  echo
  if [[ "$ACTION" == "plan" ]]; then
    log "Plan completed. No changes were made."
    log "Run './scripts/setup.sh apply' to apply the setup."
  else
    log "Setup completed."
    log "Restart the terminal or run: source ~/.bashrc"
  fi
}

main "$@"
