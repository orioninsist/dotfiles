#!/usr/bin/env bash

# Fedora 44 / DNF5 / Flatpak package inventory
# Usage: analyze | update | install | summary | read [dnf|flatpak|repos|all]

set -u
export LC_ALL=C

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DATA="$ROOT/data"
REPORT="$ROOT/reports"
LAST="$REPORT/last.txt"

mkdir -p "$DATA" "$REPORT"

log() {
    printf '%s\n' "$*"
}

count() {
    if [[ -f "$1" ]]; then
        awk 'NF {n++} END {print n+0}' "$1"
    else
        printf '0\n'
    fi
}

capture_dnf() {
    dnf5 repoquery --userinstalled --queryformat '%{name}\n' 2>/dev/null |
        grep -E '^[A-Za-z0-9_+.-]+$' |
        sort -u
    return "${PIPESTATUS[0]}"
}

capture_repos() {
    dnf5 repolist --enabled 2>/dev/null |
        awk 'NR > 1 && NF {print $1}' |
        sort -u
    return "${PIPESTATUS[0]}"
}

capture_flatpak() {
    local scope output status=0

    for scope in user system; do
        if output="$(flatpak list "--$scope" --app \
            --columns=application,origin 2>/dev/null)"; then
            printf '%s\n' "$output" |
                awk -v scope="$scope" '
                    NF >= 2 && $1 ~ /^[A-Za-z0-9_.-]+$/ {
                        print scope "\t" $1 "\t" $2
                    }
                '
        else
            status=1
        fi
    done | sort -u

    return "$status"
}

capture() {
    case "$1" in
        dnf) capture_dnf ;;
        flatpak) capture_flatpak ;;
        repos) capture_repos ;;
        *) return 2 ;;
    esac
}

missing_count() {
    comm -23 "$1" "$2" | awk 'END {print NR+0}'
}

analyze() {
    local tmp category saved result=0

    tmp="$(mktemp -d)" || return 1
    log "=== ANALYSIS ==="

    for category in dnf flatpak repos; do
        saved="$DATA/$category.txt"

        if ! capture "$category" > "$tmp/$category"; then
            log "$category: could not be read"
            result=1
            continue
        fi

        sort -u "$tmp/$category" -o "$tmp/$category"

        if [[ -f "$saved" ]]; then
            log "$category: saved $(count "$saved"), present $(count "$tmp/$category"), missing $(missing_count "$saved" "$tmp/$category")"
        else
            log "$category: present $(count "$tmp/$category"), no saved inventory"
        fi
    done

    rm -r "$tmp"
    return "$result"
}

update() {
    local tmp category saved added removed result=0

    tmp="$(mktemp -d)" || return 1
    log "=== INVENTORY UPDATE ==="

    for category in dnf flatpak repos; do
        saved="$DATA/$category.txt"

        if ! capture "$category" > "$tmp/$category"; then
            log "$category: ERROR, previous inventory preserved"
            result=1
            continue
        fi

        sort -u "$tmp/$category" -o "$tmp/$category"

        if [[ -f "$saved" ]]; then
            added="$(comm -13 "$saved" "$tmp/$category" | wc -l)"
            removed="$(comm -23 "$saved" "$tmp/$category" | wc -l)"
        else
            added="$(count "$tmp/$category")"
            removed=0
        fi

        if [[ -f "$saved" ]] && cmp -s "$saved" "$tmp/$category"; then
            log "$category: unchanged ($(count "$saved"))"
        else
            cp "$tmp/$category" "$saved"
            log "$category: total $(count "$saved"), added $added, removed $removed"
        fi
    done

    rm -r "$tmp"
    return "$result"
}

read_inventory() {
    local category="${1:-all}" item

    case "$category" in
        all)
            for item in dnf flatpak repos; do
                log "=== $item ==="
                [[ ! -f "$DATA/$item.txt" ]] || cat "$DATA/$item.txt"
            done
            ;;
        dnf|flatpak|repos)
            [[ ! -f "$DATA/$category.txt" ]] || cat "$DATA/$category.txt"
            ;;
        *)
            log "Invalid category: $category" >&2
            return 2
            ;;
    esac
}


install_local_rpm() {
    local package="$1"
    local name version url checksum extra
    local file tmp identity actual

    [[ -f "$DATA/rpm-sources.txt" ]] || {
        log "ERROR: RPM source list not found." >&2
        return 1
    }

    while IFS='|' read -r name version url checksum extra; do
        [[ "$name" == "$package" ]] || continue

        if [[ -n "$extra" ||
              ! "$version" =~ ^[A-Za-z0-9._+-]+$ ||
              ! "$url" =~ ^https://github\.com/[^/]+/[^/]+/releases/download/[^/]+/[^/]+\.rpm$ ||
              ! "$checksum" =~ ^[a-fA-F0-9]{64}$ ]]; then
            log "ERROR: Invalid RPM record: $package" >&2
            return 1
        fi

        tmp="$(mktemp -d)" || return 1
        file="$tmp/${url##*/}"

        if ! curl -fL --retry 3 -- "$url" -o "$file"; then
            log "ERROR: RPM download failed: $package" >&2
            rm -r "$tmp"
            return 1
        fi

        actual="$(sha256sum "$file")"
        actual="${actual%% *}"

        if [[ "$actual" != "$checksum" ]]; then
            log "ERROR: SHA-256 mismatch: $package" >&2
            rm -r "$tmp"
            return 1
        fi

        identity="$(rpm -qp --queryformat '%{NAME}|%{VERSION}-%{RELEASE}|%{ARCH}' "$file")" || {
            rm -r "$tmp"
            return 1
        }

        if [[ "$identity" != "$name|$version|x86_64" ]]; then
            log "ERROR: RPM identity mismatch: $package" >&2
            rm -r "$tmp"
            return 1
        fi

        log "Verified: $package $version"

        if sudo dnf5 install -y "$file" &&
           rpm -q "$package" >/dev/null 2>&1; then
            rm -r "$tmp"
            return 0
        fi

        rm -r "$tmp"
        return 1
    done < "$DATA/rpm-sources.txt"

    log "ERROR: RPM source record not found: $package" >&2
    return 1
}

install_missing() {
    local tmp package scope app remote
    local success=0 failed=0 skipped=0

    for package in dnf flatpak repos; do
        if [[ ! -f "$DATA/$package.txt" ]]; then
            log "Missing inventory: $package" >&2
            return 1
        fi
    done

    tmp="$(mktemp -d)" || return 1

    if ! capture_dnf > "$tmp/dnf" ||
       ! capture_flatpak > "$tmp/flatpak" ||
       ! capture_repos > "$tmp/repos"; then
        log "Could not read system state; installation stopped." >&2
        rm -r "$tmp"
        return 1
    fi

    sort -u "$tmp/dnf" -o "$tmp/dnf"
    sort -u "$tmp/flatpak" -o "$tmp/flatpak"
    sort -u "$tmp/repos" -o "$tmp/repos"

    # Repository installation URLs cannot be determined from inventory.
    # Stop first to prevent installation from an incorrect source.
    if [[ -n "$(comm -23 "$DATA/repos.txt" "$tmp/repos")" ]]; then
        log "ERROR: Some saved DNF repositories are not enabled."
        log "Missing repositories:"
        comm -23 "$DATA/repos.txt" "$tmp/repos"
        log "Starting restoration of missing repositories."

        if ! restore_repositories; then
            log "Repository restoration incomplete; no packages installed."
            rm -r "$tmp"
            return 1
        fi

        if ! capture_repos > "$tmp/repos"; then
            log "Could not read repositories again."
            rm -r "$tmp"
            return 1
        fi

        sort -u "$tmp/repos" -o "$tmp/repos"

        if [[ -n "$(comm -23 "$DATA/repos.txt" "$tmp/repos")" ]]; then
            log "Some repositories are still disabled; no packages installed."
            rm -r "$tmp"
            return 1
        fi
    fi

    log "=== MISSING PACKAGE INSTALLATION ==="

    while IFS= read -r package; do
        [[ -n "$package" ]] || continue

        if grep -Fxq "$package" "$tmp/dnf"; then
            skipped=$((skipped + 1))
            continue
        fi

        log "DNF: $package"

        if grep -q "^${package}|" "$DATA/rpm-sources.txt" 2>/dev/null; then
            if install_local_rpm "$package"; then
                success=$((success + 1))
            else
                failed=$((failed + 1))
                log "FAILED: $package"
            fi
            continue
        fi

        if sudo dnf5 install -y "$package" &&
           rpm -q "$package" >/dev/null 2>&1; then
            success=$((success + 1))
        else
            failed=$((failed + 1))
            log "FAILED: $package"
        fi
    done < "$DATA/dnf.txt"

    while IFS=$'\t' read -r scope app remote; do
        [[ -n "$scope" && -n "$app" && -n "$remote" ]] || continue

        if grep -Fxq "$(printf '%s\t%s\t%s' "$scope" "$app" "$remote")" "$tmp/flatpak"; then
            skipped=$((skipped + 1))
            continue
        fi

        log "Flatpak ($scope/$remote): $app"

        if flatpak install "--$scope" -y "$remote" "$app" &&
           flatpak info "--$scope" "$app" >/dev/null 2>&1; then
            success=$((success + 1))
        else
            failed=$((failed + 1))
            log "FAILED: $app"
        fi
    done < "$DATA/flatpak.txt"

    log "Installed: $success | Already present: $skipped | Failed: $failed"

    rm -r "$tmp"
    (( failed == 0 ))
}

summary() {
    log "=== INVENTORY SUMMARY ==="
    log "DNF: $(count "$DATA/dnf.txt")"
    log "Flatpak: $(count "$DATA/flatpak.txt")"
    log "Repositories: $(count "$DATA/repos.txt")"

    if [[ -f "$LAST" ]]; then
        log ""
        log "=== LAST OPERATION ==="
        cat "$LAST"
    fi
}

usage() {
    cat <<'HELP'
./install.sh analyze
./install.sh update
./install.sh install
./install.sh summary
./install.sh read dnf|flatpak|repos|all

analyze : Read-only inventory comparison
update  : Synchronize inventory with installed packages
install : Install missing packages; skip existing ones
summary : Inventory and last operation summary
read    : Display inventory records
HELP
}


# Check external repository files without modifying system files.
check_repositories() {
    local file name missing=0 found=0
    local current_fedora
    current_fedora="$(rpm -E '%fedora')" || return 1

    printf 'Fedora version: %s\n' "$current_fedora"

    for file in "$ROOT"/repos/*.repo; do
        [[ -f "$file" && ! -L "$file" ]] || {
            echo "ERROR: Invalid repository backup: $file" >&2
            return 1
        }

        name="${file##*/}"

        if grep -Eq '(^|[^0-9])fedora[-_/ ]?(4[0-9]|[5-9][0-9])([^0-9]|$)' "$file"; then
            if grep -Eiq 'fedora[-_/ ]?44([^0-9]|$)' "$file" &&
               [[ "$current_fedora" != 44 ]]; then
                echo "ERROR: Repository pinned to Fedora 44: $name" >&2
                return 1
            fi
        fi

        if [[ -e "/etc/yum.repos.d/$name" || -L "/etc/yum.repos.d/$name" ]]; then
            found=$((found + 1))
        else
            missing=$((missing + 1))
            printf 'Missing: %s\n' "$name"
        fi
    done

    printf 'Present: %s | Missing: %s\n' "$found" "$missing"
}

# Runs only when explicitly requested. Does not overwrite existing files.
restore_repositories() {
    local file name answer
    local current_fedora

    current_fedora="$(rpm -E '%fedora')" || return 1

    if [[ "$current_fedora" != 44 ]]; then
        echo "ERROR: Backups were created on Fedora 44."
        echo "Repository compatibility must be checked on other Fedora versions."
        return 1
    fi

    check_repositories || return 1

    printf 'Restore missing repository files to /etc/yum.repos.d/? [e/H] '
    read -r answer
    [[ "$answer" == e || "$answer" == E ]] || {
        echo "Cancelled."
        return 1
    }

    for file in "$ROOT"/repos/*.repo; do
        name="${file##*/}"

        if [[ -e "/etc/yum.repos.d/$name" || -L "/etc/yum.repos.d/$name" ]]; then
            continue
        fi

        # Refuse to overwrite an existing destination.
        if ! sudo cp --no-clobber -- "$file" "/etc/yum.repos.d/$name"; then
            echo "ERROR: $name could not be copied." >&2
            return 1
        fi

        if ! sudo cmp -s -- "$file" "/etc/yum.repos.d/$name"; then
            echo "ERROR: $name could not be verified." >&2
            return 1
        fi

        sudo chmod 644 "/etc/yum.repos.d/$name" || return 1
        echo "Added: $name"
    done

    echo "Repository files checked."
    echo "Verify DNF repository access before installing packages."
}

main() {
    local action="${1:-help}"
    local started ended status

    case "$action" in
        analyze)
            analyze
            ;;
        update|install)
            started="$(date +%s)"

            if [[ "$action" == update ]]; then
                update
            else
                install_missing
            fi
            status=$?

            ended="$(date +%s)"

            {
                log "Operation: $action"
                log "Date: $(date '+%Y-%m-%d %H:%M:%S')"
                log "Duration: $((ended - started)) seconds"
                log "Exit code: $status"
            } > "$LAST"

            return "$status"
            ;;
        repos-check) check_repositories ;;
        repos-restore) restore_repositories ;;
        summary) summary ;;
        read) read_inventory "${2:-all}" ;;
        help|-h|--help) usage ;;
        *) usage; return 2 ;;
    esac
}

main "$@"
