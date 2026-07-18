# vi-linux-setup-cli

A practical Linux workstation setup automation project focused on DevOps and development workflows.

The project started as a repeatable setup script for configuring a personal Ubuntu-based workstation. The long-term goal is to evolve it into a small CLI tool with clear `plan`, `apply`, and `validate` commands.

## Purpose

This repository collects setup automation, validation checks, and workstation configuration notes for building a consistent Linux development environment.

The current focus is on:

- base developer tooling
- shell aliases
- Bash prompt and terminal workflow
- Vim configuration
- terminal utilities
- YAML and JSON tools
- Kubernetes and DevOps tooling
- Markdown preview tooling
- workstation customization assets

## Current Status

This is an early MVP version.

Currently available:

```bash
./scripts/setup.sh plan
./scripts/setup.sh apply
./scripts/validate.sh
```

The setup script supports two actions:

- `plan` — shows what would be configured without making changes
- `apply` — installs and configures the selected tools

The validation script checks whether the expected tools are available on the system.

## Repository Structure

```text
vi-linux-setup-cli/
├── README.md
├── docs/
│   └── workstation-setup-notes.md
├── scripts/
│   ├── setup.sh
│   └── validate.sh
└── wallpapers/
    ├── README.md
    ├── desktop-01.jpg
    ├── desktop-02.jpg
    └── ...
```

## Included Setup Areas

### Base Developer Tools

The initial setup installs and validates common workstation tools such as:

- `git`
- `vim`
- `curl`
- `wget`
- `jq`
- `yq`
- `tree`
- `htop`
- `ncdu`
- `ripgrep`
- `fzf`
- `tmux`
- `meld`

### Shell and Terminal Workflow

The setup configures basic shell aliases and Bash workflow helpers.

Included shell aliases:

```bash
alias k='kubectl'
alias vi='vim'
alias v='vim'
alias svi='sudo vim'
```

The Bash workflow configuration adds:

- colored prompt
- current Git branch in the prompt
- `$` prompt on a new line
- command duration indicator for commands taking 3+ seconds

### Vim Configuration

The setup creates a default `~/.vimrc` only when one does not already exist.

If an existing Vim configuration is found, the script skips it to avoid overwriting user settings.

### DevOps Tooling

The setup includes DevOps workstation tools such as:

- `kubectl`
- `helm`
- `kubectx`
- `kubens`
- `k9s`
- `stern`
- `glow`

Docker-related tools are validated but not automatically installed by default:

- `docker`
- `docker compose`
- `lazydocker`
- `dive`

This keeps the setup safer for corporate or custom Linux environments where Docker installation may depend on internal repositories, proxy settings, or existing system policies.

## Usage

Preview the planned setup:

```bash
./scripts/setup.sh plan
```

Apply the setup:

```bash
./scripts/setup.sh apply
```

Validate the workstation state:

```bash
./scripts/validate.sh
```

Reload shell configuration after applying changes:

```bash
source ~/.bashrc
```

## Design Principles

The project follows a few simple principles:

- keep the first version simple
- prefer small, readable Bash functions
- make setup steps safe to re-run
- avoid overwriting existing user configuration without warning
- validate installed tools after setup
- avoid hardcoding corporate or machine-specific configuration
- evolve toward a CLI only after the automation is useful

## Assets

Wallpaper assets are included for workstation customization purposes.

Code in this repository is covered by the project license. Image assets may have separate usage rights.

## Future Direction

Planned additions:

- tmux configuration
- Docker tooling setup or optional installer
- GNOME desktop preferences
- wallpaper setup automation
- optional launcher creation
- improved validation output
- optional configuration file support
- eventual CLI wrapper

Potential future command shape:

```bash
vi-setup plan
vi-setup apply
vi-setup validate
```

## Notes

This project currently targets Ubuntu-based systems.

It is intentionally built from real workstation setup tasks instead of being a generic dotfiles repository.
