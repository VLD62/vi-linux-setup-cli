#!/usr/bin/env bash

set -euo pipefail

ACTION="${1:-plan}"
KUBERNETES_MINOR_VERSION="${KUBERNETES_MINOR_VERSION:-v1.34}"

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

ensure_kubernetes_apt_repo() {
  if [[ -f /etc/apt/sources.list.d/kubernetes.list ]]; then
    log "Kubernetes APT repository already configured."
    return
  fi

  log "Configuring Kubernetes APT repository ${KUBERNETES_MINOR_VERSION}..."

  sudo mkdir -p /etc/apt/keyrings

  curl -fsSL "https://pkgs.k8s.io/core:/stable:/${KUBERNETES_MINOR_VERSION}/deb/Release.key" \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBERNETES_MINOR_VERSION}/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
}

ensure_helm_apt_repo() {
  if [[ -f /etc/apt/sources.list.d/helm-stable-debian.list ]]; then
    log "Helm APT repository already configured."
    return
  fi

  log "Configuring Helm APT repository..."

  sudo mkdir -p /etc/apt/keyrings

  curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey \
    | sudo gpg --dearmor -o /etc/apt/keyrings/helm.gpg

  echo "deb [signed-by=/etc/apt/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" \
    | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null
}

ensure_charm_apt_repo() {
  if [[ -f /etc/apt/sources.list.d/charm.list ]]; then
    log "Charm APT repository already configured."
    return
  fi

  log "Configuring Charm APT repository for glow..."

  sudo mkdir -p /etc/apt/keyrings

  curl -fsSL https://repo.charm.sh/apt/gpg.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg

  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
    | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
}

install_kubectl() {
  if is_installed kubectl; then
    log "kubectl already installed."
    return
  fi

  ensure_kubernetes_apt_repo
  sudo apt-get update
  sudo apt-get install -y kubectl
}

install_helm() {
  if is_installed helm; then
    log "helm already installed."
    return
  fi

  ensure_helm_apt_repo
  sudo apt-get update
  sudo apt-get install -y helm
}

install_kubectx_kubens() {
  if is_installed kubectx && is_installed kubens; then
    log "kubectx and kubens already installed."
    return
  fi

  sudo apt-get update
  sudo apt-get install -y kubectx

  if ! is_installed kubens; then
    warn "kubens was not found as a separate command. On some systems it is installed together with kubectx."
  fi
}

install_k9s() {
  if is_installed k9s; then
    log "k9s already installed."
    return
  fi

  local tmp_dir
  local download_url

  tmp_dir="$(mktemp -d)"
  log "Installing k9s from latest GitHub release..."

  download_url="$(
    curl -fsSL https://api.github.com/repos/derailed/k9s/releases/latest \
      | jq -r '.assets[] | select(.name | test("Linux_amd64.tar.gz$")) | .browser_download_url' \
      | head -n 1
  )"

  if [[ -z "$download_url" || "$download_url" == "null" ]]; then
    rm -rf "$tmp_dir"
    error "Could not find k9s Linux amd64 release asset."
    exit 1
  fi

  curl -L "$download_url" -o "$tmp_dir/k9s.tar.gz"
  tar -xzf "$tmp_dir/k9s.tar.gz" -C "$tmp_dir"
  sudo install -m 0755 "$tmp_dir/k9s" /usr/local/bin/k9s

  rm -rf "$tmp_dir"
}

install_stern() {
  if is_installed stern; then
    log "stern already installed."
    return
  fi

  local tmp_dir
  local download_url

  tmp_dir="$(mktemp -d)"
  log "Installing stern from latest GitHub release..."

  download_url="$(
    curl -fsSL https://api.github.com/repos/stern/stern/releases/latest \
      | jq -r '.assets[] | select(.name | test("linux_amd64.tar.gz$")) | .browser_download_url' \
      | head -n 1
  )"

  if [[ -z "$download_url" || "$download_url" == "null" ]]; then
    rm -rf "$tmp_dir"
    error "Could not find stern linux amd64 release asset."
    exit 1
  fi

  curl -L "$download_url" -o "$tmp_dir/stern.tar.gz"
  tar -xzf "$tmp_dir/stern.tar.gz" -C "$tmp_dir"
  sudo install -m 0755 "$tmp_dir/stern" /usr/local/bin/stern

  rm -rf "$tmp_dir"
}

install_glow() {
  if is_installed glow; then
    log "glow already installed."
    return
  fi

  ensure_charm_apt_repo
  sudo apt-get update
  sudo apt-get install -y glow
}

install_devops_tools() {
  install_kubectl
  install_helm
  install_kubectx_kubens
  install_k9s
  install_stern
  install_glow
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
  run_step "Install DevOps tools" install_devops_tools

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
