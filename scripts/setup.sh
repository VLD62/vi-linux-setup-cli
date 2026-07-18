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

configure_bash_workflow() {
  local bashrc="$HOME/.bashrc"

  if grep -q "vi-linux-setup bash workflow" "$bashrc"; then
    log "Bash workflow already configured."
    return
  fi

  cat >> "$bashrc" <<'EOF'

# vi-linux-setup bash workflow
# Adds:
# - colored prompt
# - current Git branch in the prompt
# - command duration indicator for commands taking 3+ seconds

__vi_git_branch() {
  git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
}

__vi_timer_prompt() {
  local now
  local duration

  now=$(date +%s)

  if [[ ${__vi_last_prompt_time:-0} -ne 0 ]]; then
    duration=$((now - __vi_last_prompt_time))

    if [[ $duration -ge 3 ]]; then
      echo -e "\e[1;35m⏱ ${duration}s\e[0m"
    fi
  fi

  __vi_last_prompt_time=$now
}

__vi_set_prompt() {
  local branch
  branch="$(__vi_git_branch)"

  if [[ -n "$branch" ]]; then
    PS1='\[\e[1;32m\]\u@\h\[\e[0m\] \[\e[1;34m\]\w\[\e[0m\] \[\e[1;33m\]'"${branch}"'\[\e[0m\]\n\$ '
  else
    PS1='\[\e[1;32m\]\u@\h\[\e[0m\] \[\e[1;34m\]\w\[\e[0m\]\n\$ '
  fi
}

__vi_prompt_command() {
  __vi_timer_prompt
  __vi_set_prompt
}

if [[ "${PROMPT_COMMAND:-}" != *"__vi_prompt_command"* ]]; then
  if [[ -n "${PROMPT_COMMAND:-}" ]]; then
    PROMPT_COMMAND="__vi_prompt_command; ${PROMPT_COMMAND}"
  else
    PROMPT_COMMAND="__vi_prompt_command"
  fi
fi
EOF
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
  run_step "Configure Bash workflow" configure_bash_workflow
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
