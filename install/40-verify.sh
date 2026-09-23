#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${DOTFILES_ROOT:?}"
python3 -m pytest -q "$ROOT/tests"
