#!/usr/bin/env bash

# Fedora 44 / DNF5 / Flatpak paket envanteri
# Kullanım: analyze | update | install | summary | read [dnf|flatpak|repos|all]

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
    log "=== ANALİZ ==="

    for category in dnf flatpak repos; do
        saved="$DATA/$category.txt"

        if ! capture "$category" > "$tmp/$category"; then
            log "$category: okunamadı"
            result=1
            continue
        fi

        sort -u "$tmp/$category" -o "$tmp/$category"

        if [[ -f "$saved" ]]; then
            log "$category: kayıtlı $(count "$saved"), mevcut $(count "$tmp/$category"), eksik $(missing_count "$saved" "$tmp/$category")"
        else
            log "$category: mevcut $(count "$tmp/$category"), kayıt henüz yok"
        fi
    done

    rm -r "$tmp"
    return "$result"
}

update() {
    local tmp category saved added removed result=0

    tmp="$(mktemp -d)" || return 1
    log "=== ENVANTER GÜNCELLEME ==="

    for category in dnf flatpak repos; do
        saved="$DATA/$category.txt"

        if ! capture "$category" > "$tmp/$category"; then
            log "$category: HATA, eski kayıt korundu"
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
            log "$category: değişmedi ($(count "$saved"))"
        else
            cp "$tmp/$category" "$saved"
            log "$category: toplam $(count "$saved"), yeni $added, çıkarılan $removed"
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
            log "Geçersiz kategori: $category" >&2
            return 2
            ;;
    esac
}


install_local_rpm() {
    local package="$1"
    local name version url checksum extra
    local file tmp identity actual

    [[ -f "$DATA/rpm-sources.txt" ]] || {
        log "HATA: RPM kaynak listesi bulunamadı." >&2
        return 1
    }

    while IFS='|' read -r name version url checksum extra; do
        [[ "$name" == "$package" ]] || continue

        if [[ -n "$extra" ||
              ! "$version" =~ ^[A-Za-z0-9._+-]+$ ||
              ! "$url" =~ ^https://github\.com/[^/]+/[^/]+/releases/download/[^/]+/[^/]+\.rpm$ ||
              ! "$checksum" =~ ^[a-fA-F0-9]{64}$ ]]; then
            log "HATA: Geçersiz RPM kaydı: $package" >&2
            return 1
        fi

        tmp="$(mktemp -d)" || return 1
        file="$tmp/${url##*/}"

        if ! curl -fL --retry 3 -- "$url" -o "$file"; then
            log "HATA: RPM indirilemedi: $package" >&2
            rm -r "$tmp"
            return 1
        fi

        actual="$(sha256sum "$file")"
        actual="${actual%% *}"

        if [[ "$actual" != "$checksum" ]]; then
            log "HATA: SHA-256 uyuşmuyor: $package" >&2
            rm -r "$tmp"
            return 1
        fi

        identity="$(rpm -qp --queryformat '%{NAME}|%{VERSION}-%{RELEASE}|%{ARCH}' "$file")" || {
            rm -r "$tmp"
            return 1
        }

        if [[ "$identity" != "$name|$version|x86_64" ]]; then
            log "HATA: RPM kimliği uyuşmuyor: $package" >&2
            rm -r "$tmp"
            return 1
        fi

        log "Doğrulandı: $package $version"

        if sudo dnf5 install -y "$file" &&
           rpm -q "$package" >/dev/null 2>&1; then
            rm -r "$tmp"
            return 0
        fi

        rm -r "$tmp"
        return 1
    done < "$DATA/rpm-sources.txt"

    log "HATA: RPM kaynak kaydı bulunamadı: $package" >&2
    return 1
}

install_missing() {
    local tmp package scope app remote
    local success=0 failed=0 skipped=0

    for package in dnf flatpak repos; do
        if [[ ! -f "$DATA/$package.txt" ]]; then
            log "Eksik envanter: $package" >&2
            return 1
        fi
    done

    tmp="$(mktemp -d)" || return 1

    if ! capture_dnf > "$tmp/dnf" ||
       ! capture_flatpak > "$tmp/flatpak" ||
       ! capture_repos > "$tmp/repos"; then
        log "Sistem durumu okunamadı; kurulum durduruldu." >&2
        rm -r "$tmp"
        return 1
    fi

    sort -u "$tmp/dnf" -o "$tmp/dnf"
    sort -u "$tmp/flatpak" -o "$tmp/flatpak"
    sort -u "$tmp/repos" -o "$tmp/repos"

    # Eksik depoların kurulum adresleri envanterden çıkarılamaz.
    # Yanlış kaynaktan paket kurulmasını önlemek için önce durdur.
    if [[ -n "$(comm -23 "$DATA/repos.txt" "$tmp/repos")" ]]; then
        log "HATA: Kayıtlı bazı DNF depoları etkin değil."
        log "Eksik depolar:"
        comm -23 "$DATA/repos.txt" "$tmp/repos"
        log "Depo yapılandırmaları doğrulanmadan paket kurulmadı."
        rm -r "$tmp"
        return 1
    fi

    log "=== EKSİK PAKET KURULUMU ==="

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
                log "BAŞARISIZ: $package"
            fi
            continue
        fi

        if sudo dnf5 install -y "$package" &&
           rpm -q "$package" >/dev/null 2>&1; then
            success=$((success + 1))
        else
            failed=$((failed + 1))
            log "BAŞARISIZ: $package"
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
            log "BAŞARISIZ: $app"
        fi
    done < "$DATA/flatpak.txt"

    log "Başarılı: $success | Zaten mevcut: $skipped | Hatalı: $failed"

    rm -r "$tmp"
    (( failed == 0 ))
}

summary() {
    log "=== ENVANTER ÖZETİ ==="
    log "DNF: $(count "$DATA/dnf.txt")"
    log "Flatpak: $(count "$DATA/flatpak.txt")"
    log "Depolar: $(count "$DATA/repos.txt")"

    if [[ -f "$LAST" ]]; then
        log ""
        log "=== SON İŞLEM ==="
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

analyze : Salt okunur karşılaştırma
update  : Envanteri mevcut kurulumla eşitle
install : Eksik paketleri kur; mevcutları atla
summary : Envanter ve son işlem özeti
read    : Kayıtları görüntüle
HELP
}


# Harici depo dosyalarını kontrol et; hiçbir sistem dosyasını değiştirme.
check_repositories() {
    local file name missing=0 found=0
    local current_fedora
    current_fedora="$(rpm -E '%fedora')" || return 1

    printf 'Fedora sürümü: %s\n' "$current_fedora"

    for file in "$ROOT"/repos/*.repo; do
        [[ -f "$file" && ! -L "$file" ]] || {
            echo "HATA: Geçersiz depo yedeği: $file" >&2
            return 1
        }

        name="${file##*/}"

        if grep -Eq '(^|[^0-9])fedora[-_/ ]?(4[0-9]|[5-9][0-9])([^0-9]|$)' "$file"; then
            if grep -Eiq 'fedora[-_/ ]?44([^0-9]|$)' "$file" &&
               [[ "$current_fedora" != 44 ]]; then
                echo "HATA: Fedora 44 için sabitlenmiş depo: $name" >&2
                return 1
            fi
        fi

        if [[ -e "/etc/yum.repos.d/$name" || -L "/etc/yum.repos.d/$name" ]]; then
            found=$((found + 1))
        else
            missing=$((missing + 1))
            printf 'Eksik: %s\n' "$name"
        fi
    done

    printf 'Mevcut: %s | Eksik: %s\n' "$found" "$missing"
}

# Yalnızca açık komutla çalışır. Mevcut dosyaları değiştirmez.
restore_repositories() {
    local file name answer
    local current_fedora

    current_fedora="$(rpm -E '%fedora')" || return 1

    if [[ "$current_fedora" != 44 ]]; then
        echo "HATA: Yedekler Fedora 44 üzerinde alındı."
        echo "Farklı Fedora sürümünde depo uyumluluğu ayrıca doğrulanmalı."
        return 1
    fi

    check_repositories || return 1

    printf 'Eksik depo dosyalarını /etc/yum.repos.d/ içine eklemek istiyor musun? [e/H] '
    read -r answer
    [[ "$answer" == e || "$answer" == E ]] || {
        echo "İptal edildi."
        return 0
    }

    for file in "$ROOT"/repos/*.repo; do
        name="${file##*/}"

        if [[ -e "/etc/yum.repos.d/$name" || -L "/etc/yum.repos.d/$name" ]]; then
            continue
        fi

        # Hedef varsa üzerine yazmayı reddet.
        if ! sudo cp --no-clobber -- "$file" "/etc/yum.repos.d/$name"; then
            echo "HATA: $name kopyalanamadı." >&2
            return 1
        fi

        if ! sudo cmp -s -- "$file" "/etc/yum.repos.d/$name"; then
            echo "HATA: $name doğrulanamadı." >&2
            return 1
        fi

        sudo chmod 644 "/etc/yum.repos.d/$name" || return 1
        echo "Eklendi: $name"
    done

    echo "Depo dosyaları kontrol edildi."
    echo "Paket kurulumundan önce DNF depo erişimini ayrıca doğrula."
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
                log "İşlem: $action"
                log "Tarih: $(date '+%Y-%m-%d %H:%M:%S')"
                log "Süre: $((ended - started)) saniye"
                log "Çıkış kodu: $status"
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
