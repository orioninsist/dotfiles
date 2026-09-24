#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${DOTFILES_ROOT:?}"

mapfile -t pkgs < <(awk -F '\t' '$1=="dnf"{print $2}' "$ROOT/install/manifest.tsv")
(("${#pkgs[@]}" > 0)) || { echo "No Fedora packages found in install/manifest.tsv" >&2; exit 1; }

echo "Checking installed Fedora packages..."
missing=()
installed=0

for pkg in "${pkgs[@]}"; do
  if rpm -q "$pkg" >/dev/null 2>&1; then
    ((installed += 1))
  else
    missing+=("$pkg")
  fi
done

echo "Installed: $installed/${#pkgs[@]}"

if (("${#missing[@]}" == 0)); then
  echo "All required Fedora packages are already installed."
  echo "No DNF transaction needed."
  exit 0
fi

echo "Missing: ${#missing[@]}"
printf '  %s\n' "${missing[@]}"

echo
echo "Verifying only missing packages in Fedora repositories..."
unavailable=()
for pkg in "${missing[@]}"; do
  echo "  checking: $pkg"
  dnf -q repoquery --available "$pkg" >/dev/null 2>&1 || unavailable+=("$pkg")
done

if (("${#unavailable[@]}" > 0)); then
  printf 'Unavailable Fedora package: %s\n' "${unavailable[@]}" >&2
  exit 1
fi

dnf_retry() {
  local attempt=1
  local max_attempts=3
  while true; do
    echo "DNF attempt $attempt/$max_attempts"
    if sudo dnf -y install "$@"; then
      return 0
    fi
    if ((attempt >= max_attempts)); then
      echo "DNF failed after $max_attempts attempts." >&2
      return 1
    fi
    echo "DNF failed; retrying in 5 seconds..."
    sleep 5
    ((attempt += 1))
  done
}

echo
echo "Installing only missing Fedora packages..."
dnf_retry "${missing[@]}"

echo
echo "Verifying installed package set..."
still_missing=()
for pkg in "${pkgs[@]}"; do
  rpm -q "$pkg" >/dev/null 2>&1 || still_missing+=("$pkg")
done

if (("${#still_missing[@]}" > 0)); then
  printf 'Package still missing after installation: %s\n' "${still_missing[@]}" >&2
  exit 1
fi

echo "All required Fedora packages are installed."
