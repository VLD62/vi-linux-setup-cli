# VI Linux Setup CLI

A configuration-driven command-line tool for repeatable Linux workstation setup and provisioning.

`vi-linux-setup-cli` is intended to simplify the configuration of fresh Linux installations by automating package installation, developer tooling, DevOps utilities, and common workstation setup tasks.

> **Status:** Initial development.

## Features

* Linux distribution detection
* System package installation and updates
* Reusable YAML configuration profiles
* Developer and DevOps tool installation
* Git and shell configuration
* Dry-run mode
* Installation validation
* Structured execution logs
* Safe and repeatable operations

## Planned CLI

```bash
linux-setup init
linux-setup plan
linux-setup apply
linux-setup status
linux-setup validate
```

Apply a predefined profile:

```bash
linux-setup apply --profile minimal
linux-setup apply --profile developer
linux-setup apply --profile devops
```

Preview changes without modifying the system:

```bash
linux-setup apply --profile devops --dry-run
```

Use a custom configuration:

```bash
linux-setup apply --config workstation.yaml
```

## Configuration Example

```yaml
profile: devops

system:
  update_packages: true

packages:
  - git
  - curl
  - wget
  - jq
  - build-essential

tools:
  docker: true
  kubectl: true
  helm: true
  k9s: true
  terraform: true
  ansible: true

development:
  python: true
  vscode: true

shell:
  aliases: true
  bash_completion: true
```

## Initial Platform Support

* Ubuntu
* Debian-based Linux distributions
* Bash

## Technology Stack

* Python
* Typer
* Rich
* PyYAML
* pytest
* Ruff
* GitHub Actions

## Repository Structure

```text
vi-linux-setup-cli/
├── src/
│   └── vi_linux_setup/
│       ├── cli.py
│       ├── config.py
│       ├── system.py
│       ├── packages.py
│       └── validation.py
├── profiles/
│   ├── minimal.yaml
│   ├── developer.yaml
│   └── devops.yaml
├── tests/
├── examples/
├── pyproject.toml
├── LICENSE
└── README.md
```

## Development Setup

```bash
git clone https://github.com/VLD62/vi-linux-setup-cli.git
cd vi-linux-setup-cli

python3 -m venv .venv
source .venv/bin/activate

pip install -e ".[dev]"
pytest
```

## Security

The tool does not store passwords, access tokens, private keys, or other credentials.

Privileged operations use the operating system's standard `sudo` mechanism and are displayed before execution.

## License

This project is licensed under the [MIT License](LICENSE).
