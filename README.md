# Linux System State Reproduction

## Purpose

This repository is not a dotfiles collection.

This project creates a reproducible Linux workstation state.

The running Linux system is the source of truth.

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

# Architecture Decisions

## Project Identity

This project is not an application repository.

It is a **workstation state repository**.

Applications are managed by the Linux distribution.

This project records how the user environment and system state are configured.

Examples:

- Neovim application -> Fedora package management
- Neovim configuration -> captured workstation state
- Git application -> Fedora package management
- Git user configuration -> captured workstation state

---

## Capture Model

The system uses a blacklist approach.

The rule is:

```
Capture everything required for workstation reproduction.
Exclude only unnecessary paths.
```

No manual file selection exists.

The capture system does not maintain a list like:

```
copy this file
ignore this file
```

Instead it uses:

- Linux standard exclusions
- user defined ignore rules

---

## Repository State Layout

Captured filesystem state is stored under `state/`.

Example:

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

The real filesystem structure is preserved.

Example:

```
/home/user/.config/nvim
```

becomes:

```
state/home/user/.config/nvim
```

---

## Capture Engine

The capture engine uses native Linux tools.

Main filesystem capture:

```
rsync
```

Filtering:

```
Linux standard rules
+
ignore.conf
```

Automatic tracking is provided by systemd timer.

Capture frequency:

```
Every 6 hours
```

---

## Git Workflow

Capture is automatic.

Commit and push are manual.

Workflow:

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

# Philosophy

This project does not create a new configuration system.

It does not replace Linux.

It uses Linux native mechanisms to record, reproduce and rebuild the working environment.

The operating system remains the source of truth.
