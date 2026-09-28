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

---

# Capture Model

Strategy:

```
Capture everything.
Ignore unnecessary data.
```

Engine:

```
rsync
```

Preserved metadata:

- owner
- group
- permissions
- ACL
- extended attributes

---

# Privacy Model

Repository model:

```
Public repository + encrypted secrets
```

Pipeline:

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

Secrets:

```
age encrypted secrets
```

---

# Repository Architecture

Layered repository structure:

```
dotfiles/

├── bootstrap/
├── capture/
├── restore/
├── verify/
├── state/
├── policies/
│   ├── ignore/
│   └── privacy/
├── secrets/
└── README.md
```

---

# State Layout

Hybrid state model:

- system paths remain real
- user state is normalized
- restore remains portable

State format:

```
Filesystem + Metadata
```

Example:

```
state/

├── filesystem/
│   ├── etc/
│   ├── usr/
│   └── users/
│
└── metadata/
    ├── users
    ├── permissions
    ├── packages
    ├── services
    ├── hardware
    ├── kernel
    └── network
```

---

# Bootstrap

Model:

```
Layered bootstrap
```

Rules:

- starts from git clone
- idempotent execution
- critical failures stop execution
- non-critical failures are reported
- separate verify phase exists

Bootstrap flow:

```
git clone
    |
    v
bootstrap
    |
    v
restore
    |
    v
verify
```

---

# Restore

Restore engine:

```
rsync
```

Responsibilities:

- precheck
- user handling
- UID/GID restore
- ownership correction
- state restore
- secret decrypt
- post actions

---

# Tracking

Fedora native systemd:

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
No event watcher
Rsync detects changes
```

---

# Logging

Systemd journal is used.

No extra log files.

Examples:

```
journalctl -u capture.service
journalctl -u bootstrap.service
```

---

# Implementation

Language:

```
Bash
```

Native tools:

- rsync
- systemd
- journalctl
- age
- Fedora native tools

---

# Security Decisions

SSH:

- SSH config is normal state
- private keys are encrypted with age

Browser:

- browser state is not captured

Secrets:

- isolated from public repository state

---

# Git Workflow

Model:

```
main branch only
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

# Recovery

```
git clone repository
./bootstrap
```

Result:

A rebuilt Linux workstation matching the captured environment.

---

# Philosophy

This project does not replace Linux.

It uses native Linux mechanisms to capture, store and reproduce a working system state.

The operating system remains the source of truth.
