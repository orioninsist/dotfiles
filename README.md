# Linux Workstation State Reproduction

This repository is not a classic dotfiles collection.

It is a native Linux workstation state reproduction system.

The goal is simple:

```text
rebuild a clean Linux installation into the same working environment
```

The running Linux system is the source of truth, but the repository must not blindly copy the whole system. It must capture only the paths that are required for rebuild.

---

# Mission

```text
Detect the system state.
Classify paths.
Capture only approved rebuild data.
Store it in Git.
Restore it on a clean Linux system.
Verify the rebuilt workstation.
```

The project is designed around one rule:

```text
Do not capture too much.
Do not capture too little.
Capture the exact rebuild state.
```

---

# Core Architecture

```text
Running Linux System
        |
        v
Discovery
        |
        v
Registry / Path Policy
        |
        v
Capture Plan
        |
        v
State Repository
        |
        v
Restore
        |
        v
Verify
        |
        v
Rebuilt Workstation
```

The system is path-driven. Folder and file paths are the real contract.

---

# Registry Model

The registry is the central decision layer.

It answers these questions:

```text
Which paths are ignored forever?
Which paths are watched but not captured?
Which files are captured directly?
Which directories are captured fully?
Which directories are captured partially?
```

The registry is human-readable and Git-tracked.

Planned registry layout:

```text
capture/registry/
├── paths.rules
├── apply.sh
└── report.sh

state/registry/
├── watch.list
├── block.list
├── capture.files
└── unclassified.list
```

---

# Path Policy Actions

Every path belongs to one of these actions:

```text
BLOCK        ignore completely
WATCH        track changes, but do not capture automatically
TAKE_FILE    capture one file
TAKE_DIR     capture one directory completely
TAKE_PARTIAL capture selected files inside a directory
```

Example policy:

```text
# root watch
WATCH .

# blocked top-level paths
BLOCK Downloads
BLOCK Videos
BLOCK Music
BLOCK Pictures
BLOCK GoogleDrive
BLOCK .cache

# watched roots
WATCH .config
WATCH .local
WATCH .ssh

# direct files
TAKE_FILE .bashrc
TAKE_FILE .gitconfig
TAKE_FILE .ssh/config

# full directories
TAKE_DIR .local/bin
TAKE_DIR .config/nvim
TAKE_DIR .config/yazi

# single config file
TAKE_FILE .config/starship.toml

# partial directory capture
TAKE_PARTIAL .config/kitty
  INCLUDE kitty.conf
  INCLUDE current-theme.conf
  EXCLUDE sessions
  EXCLUDE cache
END
```

This keeps the system exact. A known directory can be watched without being captured completely.

---

# Discovery

Discovery scans known Linux user-state roots and produces candidate paths.

Important roots:

```text
$HOME
$HOME/.config
$HOME/.local
$HOME/.local/bin
$HOME/.ssh
```

Discovery does not decide what to capture. It only reports what exists.

Output:

```text
state/discovered/files.list
```

---

# Classification Flow

```text
discover.sh
    |
    v
state/discovered/files.list
    |
    v
registry/report.sh
    |
    v
state/registry/unclassified.list
    |
    v
human decision
    |
    v
capture/registry/paths.rules
    |
    v
registry/apply.sh
    |
    v
state/registry/capture.files
```

New paths must not be silently captured.

If a new path appears under a watched root, it becomes unclassified first.

Example:

```text
NEW UNCLASSIFIED PATH:
.config/ghostty

Decision:
BLOCK
WATCH
TAKE_DIR
TAKE_FILE
TAKE_PARTIAL
```

Once a path is blocked, it is not watched and it is not captured. Changes under that path are irrelevant to this repository.

---

# Capture Model

Capture uses `rsync`, but `rsync` receives an approved file list.

```text
rsync --files-from state/registry/capture.files
```

The capture engine does not decide. It only copies what the registry has approved.

Current principle:

```text
Registry decides.
Capture copies.
Git stores.
Restore rebuilds.
```

Preserved metadata:

```text
owner
group
permissions
ACL
extended attributes
```

---

# Restore Model

Restore is the reverse of capture.

```text
state/filesystem
        |
        v
$HOME
```

Restore responsibilities:

```text
precheck
optional dry-run
path restore
ownership correction
permission restore
secret decrypt
post actions
verification
```

Restore must use the same registry logic so that only approved rebuild state is restored.

---

# Tracking Model

The first implementation should use native Linux tools with low maintenance cost.

Recommended tool stack:

```text
bash
find
rsync
git
systemd user timer
```

The default tracking model is periodic scanning, not an always-running watcher.

```text
systemd user timer
        |
        v
find-based scan
        |
        v
registry report
        |
        v
unclassified path list
```

`inotifywait` may be added later for real-time events, but it is not required for the first stable implementation.

Reason:

```text
find + systemd timer is simpler, more stable, and easier to debug.
inotifywait is useful later if instant path events are needed.
```

---

# Privacy Model

Repository model:

```text
Public repository + encrypted secrets
```

Secrets are never stored as plain text.

Secrets model:

```text
age encrypted secrets
```

Browser profiles, cloud sync folders, downloads, media folders, caches, temporary files and machine-local runtime data are blocked by default.

---

# Repository Architecture

```text
dotfiles/
├── bootstrap/
├── capture/
│   ├── discover/
│   ├── registry/
│   ├── metadata/
│   └── capture.sh
├── restore/
├── verify/
├── state/
│   ├── discovered/
│   ├── registry/
│   ├── filesystem/
│   └── metadata/
├── secrets/
└── README.md
```

---

# State Layout

```text
state/
├── discovered/
│   └── files.list
├── registry/
│   ├── watch.list
│   ├── block.list
│   ├── capture.files
│   └── unclassified.list
├── filesystem/
└── metadata/
    ├── users.txt
    ├── permissions.txt
    ├── packages.txt
    ├── services.txt
    └── kernel.txt
```

Machine-specific metadata such as hardware, network and storage should be runtime data unless explicitly needed.

---

# Bootstrap

Bootstrap starts from a clean Linux installation.

```text
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

Rules:

```text
idempotent execution
critical failures stop execution
non-critical failures are reported
verify phase is separate
```

---

# Git Workflow

The repository stores decisions and approved state.

```text
scan
  |
  v
report unclassified paths
  |
  v
update registry decisions
  |
  v
apply registry
  |
  v
capture approved state
  |
  v
git diff
  |
  v
git commit
  |
  v
git push
```

Git is the history of rebuild decisions.

---

# Implementation Rules

```text
Bash first.
Linux native tools first.
No heavy framework.
No hidden magic.
No automatic capture of unknown paths.
```

Native tools:

```text
find
rsync
systemd
journalctl
git
age
```

Optional later:

```text
inotify-tools
```

---

# Security Decisions

SSH:

```text
SSH config is normal state.
Private keys are encrypted with age.
```

Browsers:

```text
Browser profiles are not captured.
```

Cloud folders:

```text
Cloud sync folders are blocked by default.
```

Caches:

```text
Caches are blocked by default.
```

---

# Recovery

```text
git clone repository
./bootstrap/bootstrap.sh
```

Expected result:

```text
A clean Linux installation becomes the same working workstation state.
```

---

# Philosophy

This project does not replace Linux.

It uses native Linux mechanisms to detect, classify, capture, store, restore and verify a working Linux workstation state.

The operating system remains the source of truth.

The registry is the contract.

The repository is the memory.
