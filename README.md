# vi-linux-setup-cli

A practical Linux workstation setup automation project focused on DevOps and development workflows.

The project started as a repeatable setup script for configuring a personal Ubuntu-based workstation. The long-term goal is to evolve it into a small CLI tool with clear `plan`, `apply`, and `validate` commands.

## Purpose

This repository collects setup automation, validation checks, and workstation configuration notes for building a consistent Linux development environment.

The current focus is on:

- base developer tooling
- shell aliases
- Vim configuration
- terminal utilities
- YAML and JSON tools
- future Kubernetes and DevOps tooling setup

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
└── scripts/
    ├── setup.sh
    └── validate.sh
```

## Included in the Initial Setup

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

It also configures basic shell aliases and creates a Vim configuration when one does not already exist.

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
- evolve toward a CLI only after the automation is useful

## Future Direction

Planned additions:

- Kubernetes tooling setup
- Helm installation
- Docker tooling checks
- GNOME desktop preferences
- Markdown tooling
- optional launcher creation
- improved validation output
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
