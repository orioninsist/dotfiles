# Linux System State Reproduction

## Purpose

This repository is not a dotfiles collection.

This project creates a reproducible Linux workstation state.

The running Linux system is the source of truth.

Mission:

```
Capture the machine.
Store the state.
Rebuild the machine.
Return to the same environment.
```

The project records the real working system instead of manually creating configuration files.

---

# Core Architecture

```
Running Linux System
        |
        v
Native capture
        |
        v
Git Repository
        |
        v
Clean Linux Installation
        |
        v
Bootstrap restore
        |
        v
Same workstation state
```

Principles:

- no symbolic link management
- no manually maintained dotfile list
- no application package manager replacement
- Linux/Fedora native tools remain responsible for applications

Example:

```
Neovim package
        -> Fedora package management

Neovim configuration
        -> captured workstation state
```

---

# Capture Model

Capture strategy:

```
Capture everything.
Ignore unnecessary data.
```

No manual file selection exists.

Capture engine:

```
rsync
```

Metadata:

- owner
- group
- permissions
- ACL
- extended attributes

are preserved where required.

---

# Ignore System

Ignore management is layered:

```
ignore/

├── default.conf
├── system.conf
└── local.conf
```

Purpose:

- default.conf: Linux standard exclusions
- system.conf: system level exclusions
- local.conf: machine/user specific exclusions

---

# Privacy Model

The repository uses a public repository model.

Security layers:

```
Capture
   |
   v
Ignore filtering
   |
   v
Privacy sanitize
   |
   v
Public state
```

Secrets are stored separately:

```
age encrypted secrets
```

---

# Repository Layout

State layout uses a hybrid model:

```
repository/

├── state/
│   ├── etc/
│   ├── usr/
│   └── users/
│       └── main/
│
├── secrets/
├── ignore/
├── privacy/
├── capture
└── bootstrap
```

System paths remain real.

User state is normalized for portability.

---

# Automatic Tracking

Tracking uses Fedora native systemd.

```
systemd timer
```

Frequency:

```
Every 6 hours
```

Capture model:

```
Full rsync run

No event based watcher.

Rsync detects changes.
```

---

# Git Workflow

Git history represents workstation state history.

Model:

```
main branch only
```

No branch workflow.

Commit messages:

```
system state update YYYY-MM-DD
```

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

---

# Restore / Bootstrap

Restore engine:

```
rsync
```

Bootstrap responsibilities:

- precheck
- user handling
- UID/GID restore
- ownership correction
- state restore
- secret decrypt
- post actions

User model:

- UID/GID captured
- users can be created when required
- multi-user support

---

# Testing

Dry-run mode is optional.

Normal:

```
capture
bootstrap
```

Testing:

```
capture --dry-run
bootstrap --dry-run
```

Uses native rsync dry-run support.

---

# Logging

Logging uses Fedora native systemd journal.

No separate log files.

Example:

```
journalctl -u capture.service
journalctl -u bootstrap.service
```

---

# Large Files

The repository is not an archive system.

Policy:

- no Git LFS
- unnecessary large files are ignored
- only reproducible workstation state is stored

---

# Recovery

Clean installation:

```
git clone repository
./bootstrap
```

Result:

A rebuilt Linux workstation matching the captured environment.

---

# Philosophy

This project does not replace Linux.

It does not create a new configuration framework.

It uses native Linux mechanisms to capture, store and reproduce a working system state.

The operating system remains the source of truth.
