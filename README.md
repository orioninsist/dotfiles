# Linux System State Reproduction

## Purpose

This repository is not a dotfiles collection.

This project creates a reproducible Linux workstation state.

The running Linux system is the source of truth.

The mission is simple:

```
Capture the machine.
Store the state.
Rebuild the machine.
Return to the same environment.
```

The goal is:

- analyze the current working Linux system
- capture required system state using native Linux tools
- store the reproducible state in Git
- rebuild the same workstation on a clean installation

The repository does not manually design configuration files.

It records the real state of the running system.

---

## Core Principle

```
Running Linux System
          |
          |
          | Native state capture
          |
          v
     Git Repository
          |
          |
          | git commit / git push
          |
          v
 Clean Linux Installation
          |
          |
          | bootstrap
          |
          v
 Same workstation state
```

The Linux installation itself is the source of truth.

No symbolic link management.

No manually maintained dotfiles structure.

No manually selected configuration list.

---

# Project Identity

This project is not an application repository.

It is a **workstation state repository**.

Applications are managed by Fedora/Linux native tools.

This project records how the working environment is configured.

Examples:

```
Neovim application
        -> Fedora package management

Neovim configuration
        -> captured workstation state

Git application
        -> Fedora package management

Git user configuration
        -> captured workstation state
```

---

# Capture Model

The system uses a blacklist approach.

Rule:

```
Capture everything required for workstation reproduction.
Exclude only unnecessary paths.
```

No manual file selection exists.

The system uses:

- Linux standard exclusions
- user defined ignore rules

---

# Repository Layout

Captured filesystem state is stored under `state/`.

```
repository/

├── state/
│   ├── etc/
│   ├── home/
│   └── usr/
│
├── ignore.conf
├── capture
└── bootstrap
```

Real paths are preserved:

```
/home/user/.config/nvim
```

becomes:

```
state/home/user/.config/nvim
```

---

# Capture Engine

The capture engine uses native Linux tools.

Filesystem capture:

```
rsync
```

Filtering:

```
Linux standard rules
+
ignore.conf
```

Automatic tracking:

```
systemd timer
```

Capture frequency:

```
Every 6 hours
```

---

# Git Workflow

Capture is automatic.

Commit and push are manual.

```
systemd timer
        |
        v
capture
        |
        v
state updated
        |
        v
git diff
        |
        v
manual commit
        |
        v
manual push
```

This keeps Git history controlled and intentional.

---

# Daily Workflow

Normal Linux usage continues.

Examples:

- install applications
- remove applications
- modify configurations
- change system settings
- modify services

The user does not manually synchronize files.

The system captures the current workstation state.

---

# Recovery

A clean Linux installation should become the previous workstation state with:

```
git clone repository
./bootstrap
```

The final result is a rebuilt Linux environment matching the captured workstation state.

---

# Philosophy

This project does not create a new configuration system.

It does not replace Linux.

It uses Linux native mechanisms to record, reproduce and rebuild the working environment.

The operating system remains the source of truth.
