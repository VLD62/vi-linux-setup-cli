# Workstation Setup Notes

This document describes the current Linux workstation setup approach used by `vi-linux-setup-cli`.

The goal is to keep the setup repeatable, understandable, and easy to extend.

## Current MVP Scope

The first version focuses on a small but useful baseline:

- install common developer tools
- configure basic shell aliases
- configure Vim when no existing `.vimrc` is present
- install `yq` from the official release binary
- validate that expected tools are available

The setup is currently implemented as Bash scripts.

## Commands

Preview planned setup actions:

```bash
./scripts/setup.sh plan
```

Apply the setup:

```bash
./scripts/setup.sh apply
```

Validate installed tools:

```bash
./scripts/validate.sh
```

## Installed Base Tools

The current setup installs the following packages through `apt`:

```text
curl
wget
git
vim
tree
jq
htop
ncdu
ripgrep
fd-find
fzf
tmux
meld
ca-certificates
apt-transport-https
gnupg
software-properties-common
```

The setup also installs `yq` as a standalone binary into:

```text
/usr/local/bin/yq
```

## Shell Configuration

The setup appends a small alias block to `~/.bashrc` when the Kubernetes alias is not already present.

Current aliases:

```bash
alias k='kubectl'
alias vi='vim'
alias v='vim'
alias svi='sudo vim'
```

The script avoids duplicating the alias block when it has already been configured.

## Vim Configuration

The setup creates `~/.vimrc` only when the file does not already exist.

If `~/.vimrc` already exists, the script skips Vim configuration and prints a warning.

This avoids overwriting existing user configuration.

## Validation

The validation script checks for the following commands:

```text
git
vim
curl
wget
jq
yq
tree
htop
ncdu
rg
fzf
tmux
meld
```

Example output:

```text
[OK] git -> /usr/bin/git
[OK] yq -> /usr/local/bin/yq
[MISSING] some-tool
```

## Known Notes

### External APT repositories

A broken third-party APT repository can block the setup because the script runs:

```bash
sudo apt-get update
```

For example, an unsigned or missing-key repository can stop the process before packages are installed.

In that case, fix or disable the broken repository first, then re-run:

```bash
./scripts/setup.sh apply
```

### Existing user configuration

The script should not blindly overwrite existing files.

Current behavior:

- existing `.vimrc` is skipped
- existing shell aliases are not duplicated

This pattern should be preserved for future setup steps.

## Next Planned Additions

The next logical setup area is Kubernetes tooling:

- `kubectl`
- `helm`
- `kubectx`
- `kubens`
- `k9s`
- `stern`

After that, possible additions include:

- Docker tooling validation
- Markdown preview tools
- GNOME desktop preferences
- terminal workflow helpers
- optional app launchers
