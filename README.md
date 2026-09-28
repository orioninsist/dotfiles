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

# Architecture

The system consists of three main layers.

---

## 1. Native State Capture

The capture process analyzes the running Linux system.

The system captures real native locations:

Examples:

```
/etc
/usr
/home/user/.config
/home/user/.local
systemd state
package state
user state
```

The repository represents the captured state.

The user does not decide every individual file manually.

The capture system determines the current state and records changes.

---

## 2. Git Repository

Git is the history and synchronization layer.

Git stores:

- system state
- package state
- service state
- user configuration
- rebuild information
- encrypted secrets

Daily workflow:

```
Use Linux normally

        |

System changes

        |

Capture current state

        |

Review git diff

        |

git commit

        |

git push
```

GitHub always represents the latest reproducible workstation state.

---

## 3. Rebuild System

A clean Linux installation starts the recovery process.

Example:

```
Install Linux

        |

git clone repository

        |

bootstrap

        |

apply system state

        |

machine restored
```

The rebuild process recreates:

- installed packages
- applications
- configurations
- services
- user environment
- required system settings

---

# Native Tools

The project uses native Linux tools whenever possible.

## Git

Purpose:

- version control
- history
- synchronization

---

## Linux Native Tools

Purpose:

Capture the real system state.

Examples:

- package manager tools
- filesystem tools
- systemd tools
- user management tools
- permission tools

---

## Ansible

Purpose:

System rebuild and orchestration.

Ansible applies the captured state to a clean installation.

---

## Secret Management

Purpose:

Secure restoration of private information.

Examples:

- SSH keys
- API tokens
- application credentials

Secrets are restored securely.

They are not stored as plain text.

---

# Project Rules

1. The running Linux system is always the source of truth.

2. Native filesystem paths remain native.

3. No symbolic links.

4. No classic dotfiles manager workflow.

5. No manually maintained configuration selection.

6. Only unnecessary paths are excluded.

7. Excluded paths are documented in an ignore list.

8. Removing something from the real system removes it from future captures.

9. Git commit and push are the only daily maintenance actions.

---

# Daily Usage

Normal Linux usage continues.

Install applications.

Remove applications.

Change configurations.

Modify services.

After changes:

```bash
capture
git diff
git add .
git commit
git push
```

No manual file copying.

No manual synchronization.

No remembering which file changed.

---

# Recovery

A clean Linux installation should become the previous workstation state with:

```bash
git clone repository
./bootstrap
```

The final result is a rebuilt Linux environment matching the captured system state.

---

# Philosophy

This project does not create a new configuration system.

It does not replace Linux.

It uses Linux native mechanisms to record, reproduce and rebuild the working system.

The operating system remains the source of truth.