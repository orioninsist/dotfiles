#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT="$SCRIPT_DIR/media-backup.rules"
TMP="${OUTPUT}.tmp"

cat > "$TMP" <<'RULES'
# ============================================================
# ORION MEDIA BACKUP FILTER
# ============================================================
#
# Source root:
#   ~/Media
#
# Destination:
#   gdrive:Media
#
# Managed by:
#   install/rclone/generate-media-backup-rules.sh
#
# Reference templates:
#   https://github.com/github/gitignore
#
# IMPORTANT:
#   This is an rclone filter file, NOT a .gitignore file.
#   Rules are processed top-to-bottom; first match wins.
#
# Policy:
#   - exclude only reproducible dependency/build/cache artifacts
#   - preserve source code and project configuration
#   - preserve .gitignore files themselves
#   - do NOT automatically exclude secrets/local data/databases
#   - include everything not explicitly excluded below
# ============================================================


# ------------------------------------------------------------
# Git repository internals
# ------------------------------------------------------------

- **/.git/**


# ------------------------------------------------------------
# JavaScript / TypeScript / Node / frontend
# ------------------------------------------------------------

- **/node_modules/**
- **/.npm/**
- **/.pnpm-store/**
- **/.yarn/cache/**
- **/.yarn/unplugged/**
- **/.next/**
- **/.nuxt/**
- **/.svelte-kit/**
- **/.vite/**
- **/.turbo/**
- **/.parcel-cache/**
- **/coverage/**


# ------------------------------------------------------------
# Rust
# ------------------------------------------------------------

- **/target/**


# ------------------------------------------------------------
# Python
# ------------------------------------------------------------

- **/__pycache__/**
- **/.pytest_cache/**
- **/.mypy_cache/**
- **/.ruff_cache/**
- **/.tox/**
- **/.nox/**
- **/.venv/**
- **/venv/**
- **/*.py[cod]


# ------------------------------------------------------------
# Go
# ------------------------------------------------------------

- **/vendor/**


# ------------------------------------------------------------
# Java / Gradle / Maven
# ------------------------------------------------------------

- **/.gradle/**
- **/.m2/repository/**


# ------------------------------------------------------------
# C / C++ / CMake
# ------------------------------------------------------------

- **/CMakeFiles/**
- **/CMakeCache.txt
- **/cmake-build-*/**


# ------------------------------------------------------------
# Android
# ------------------------------------------------------------

- **/.cxx/**
- **/.externalNativeBuild/**


# ------------------------------------------------------------
# Generic generated build/cache output
# ------------------------------------------------------------

- **/.cache/**
- **/.tmp/**
- **/.temp/**
- **/*.tmp


# ------------------------------------------------------------
# Editor / OS generated state
# ------------------------------------------------------------

- **/.idea/**
- **/.DS_Store
- **/Thumbs.db


# ------------------------------------------------------------
# EVERYTHING ELSE IS BACKED UP
# ------------------------------------------------------------

+ /**
RULES

mv -f "$TMP" "$OUTPUT"

echo "Generated: $OUTPUT"
