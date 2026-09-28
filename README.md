# Fedora Workstation State Reproduction System

## Project Purpose

This repository is the reproducible state definition of a Fedora Linux workstation.

The goal is not to create a disk image, clone a filesystem, or backup personal data.

The goal is:

> Take the current working Fedora system state, track it with native tools, store the reproducible definition in Git, and recreate the same working environment on another Fedora installation with one bootstrap command.

The starting point is a clean Fedora installation. After Fedora installation reaches a usable terminal environment, this repository becomes responsible for rebuilding the workstation state.

---

## Core Principle

The running system is the source of truth.

The workflow is:

```text
Running Fedora Workstation
          |
          |  Native state capture tools
          |
          v
Git Repository
          |
          |  git commit / git push
          |
          v
New Fedora Installation
          |
          |  bootstrap script
          |
          v
Same workstation state
```

The repository does not contain a manually designed copy of the operating system. It contains the state required to reproduce the operating system environment.

---

## Scope

Managed by this project:

- Fedora system packages
- installed applications
- user configuration
- desktop environment configuration
- Niri Wayland configuration
- Neovim and development environment configuration
- systemd services and user services
- required scripts and automation
- application credentials and machine secrets through secure storage

Not managed by this project:

- personal documents
- photos
- videos
- personal archives
- large user data
- cache files
- full disk images

Personal backup is a separate project.

---

## Native Tools

The project uses native tools that already solve each state management problem.

| Tool | Purpose | Reason |
|---|---|---|
| Git | Source of truth | Tracks every state change and provides version control |
| Ansible | System orchestration | Applies state in a repeatable and automated process |
| chezmoi | User configuration management | Tracks and applies home configuration files |
| systemd | Service management | Native Fedora service and daemon state management |
| Fedora DNF | Package management | Native Fedora package state management |
| Secret management tool | Protected credentials | Restores required tokens and keys securely |
| Verify scripts | Validation | Confirms the restored system matches expected state |

Links:

- Git: https://git-scm.com/
- Ansible: https://www.ansible.com/
- chezmoi: https://www.chezmoi.io/
- systemd: https://systemd.io/
- Fedora: https://fedoraproject.org/

---

## System Lifecycle

### 1. Capture Current System

The existing Fedora workstation is analyzed by native tools.

Examples:

```text
Packages      -> Fedora DNF state
Services      -> systemd state
User configs  -> chezmoi state
Secrets       -> encrypted secret state
```

The result becomes the repository state.

---

### 2. Daily Workflow

After making a system change:

```text
Change system
      |
Capture new state
      |
Review git diff
      |
git commit
      |
git push
```

GitHub always represents the latest desired workstation state.

---

### 3. New Machine Restore

After installing Fedora:

```bash
git clone https://github.com/orioninsist/dotfiles.git
cd dotfiles
./bootstrap.sh
```

The bootstrap process:

```text
Install required tools
          |
Apply package state
          |
Apply user configuration
          |
Restore services
          |
Restore protected secrets
          |
Run verification
          |
System ready
```

---

## Security Model

Secrets required by applications and development tools are not personal data backups.

Examples:

- SSH keys
- Git tokens
- API tokens
- application credentials
- machine configuration secrets

Secrets are stored separately and securely. The repository contains the process to restore them, not uncontrolled plain text credentials.

---

## Project Rules

1. The current Fedora system is the source of truth.
2. Native tools manage each state area.
3. No disk cloning is used.
4. No personal data backup is included.
5. No unnecessary history or archive state is maintained.
6. Git commit and push are the only manual maintenance steps.
7. The bootstrap process must recreate the workstation from a clean Fedora installation.

---

## Final Goal

A Fedora installation should be recoverable with:

```bash
git clone
./bootstrap.sh
```

The result should be the same working workstation environment that was previously captured.
