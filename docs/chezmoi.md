# Chezmoi — Komut Cep Rehberi

> [Dosya ekleme ve senaryolar](dosya-ekleme.md) · [Çalışma günlüğü](gunluk.md)

## Doğrulanmış Fedora kurulumu — 20 Ekim 2026

```text
Fedora:      44 / x86_64
Chezmoi:     2.73.0 (Fedora RPM)
Kaynak depo: ~/.local/share/chezmoi
Git remote:  https://github.com/orioninsist/dotfiles.git
Dal:         main
```

Son doğrulanan yapılandırma commit'i: [`8b1e6c0`](https://github.com/orioninsist/dotfiles/commit/8b1e6c0b92f47441ca0af4b7423e954ad4d24f64) — Atuin ve Espanso eklendi; Fedora terminalinde Git çalışma ağacı temiz, yerel/uzak SHA aynı, chezmoi status boştu. Bu bilgi bir **anlık doğrulama**dır, şu anki Fedora durumunun garantisi değildir.

## 1. Günlük kontrol — değiştirmez

```bash
chezmoi --version
chezmoi doctor
chezmoi source-path
chezmoi managed
chezmoi status
chezmoi diff
chezmoi apply --dry-run --verbose
git -C "$(chezmoi source-path)" status --short
```

`doctor` ortam sorunlarını inceler. `managed` yönetilen **hedef yollarını** listeler; `status` ve `diff` kaynak–hedef uyuşmazlığını gösterir; `--dry-run` değişiklikleri uygulamadan önizler.

## 2. Chezmoi temel komutları ve parametreleri

| Komut | Amaç |
|---|---|
| `chezmoi init REPO` | Yeni kurulumda uzak depoyu kaynak olarak başlat |
| `chezmoi add DOSYA` | Hedef dosyayı chezmoi kaynağına ekle |
| `chezmoi add --recursive DIZIN` | Dizin ağacını ekle; önce tüm dosyaları incele |
| `chezmoi source-path DOSYA` | Hedefin kaynak karşılığını göster |
| `chezmoi edit DOSYA` | Kaynak kopyayı düzenle |
| `chezmoi re-add DOSYA` | Hedefteki mevcut içeriği kaynağa yeniden al |
| `chezmoi forget DOSYA` | Hedefi yönetimden çıkar; kaynak kopyayı siler, hedefi korur |
| `chezmoi diff` | Uygulanacak değişikliklerin farkı |
| `chezmoi status` | Kaynak–hedef durum kodları |
| `chezmoi apply --dry-run --verbose` | Güvenli önizleme |
| `chezmoi apply DOSYA` | Kaynağı hedefe uygula; hedefi değiştirebilir |
| `chezmoi update` | Uzak kaynak değişikliklerini çekip uygular; dikkatli kullan |
| `chezmoi doctor` | Kurulum tanılaması |

Bu referans gerçek `chezmoi 2.73.0` kurulumunda doğrulanan temel kullanım akışına odaklanır. Tüm seçenekler için `chezmoi help KOMUT` çalıştır:

```bash
chezmoi help add
chezmoi help apply
chezmoi help forget
chezmoi help update
```

## 3. Git komutları — chezmoi kaynak deposunda çalıştır

```bash
cd "$(chezmoi source-path)"
git status --short
git diff
git diff --cached
git diff --cached --check
git log --oneline -n 8
git remote -v
```

- `git diff`: aşamaya alınmamış, **izlenen** dosyalardaki fark; yeni (untracked) dosyaları içermez.
- `git diff --cached`: commit'e girecek aşamaya alınmış içerik; yeni dosyaları da gösterir.
- `git status --short`: `??` yeni/izlenmeyen, `A` eklenen, `M` değişen dosyalar.
- `git add -- YOL`: yalnızca belirtilen yolu stage et.
- `git restore --staged -- YOL`: stage'i geri al; dosya içeriğini silmez.
- `git commit -m "mesaj"`: stage edilmiş içeriği sürümle.
- `git push origin main`: commit'i GitHub'a gönder.
- `git fetch origin`: uzaktaki geçmişi al, yerel dosyaları uygulama.
- `git pull --ff-only origin main`: yalnızca güvenli fast-forward mümkünse yerel dalı ilerlet.

**Tam, uygulanabilir örnekler:** [dosya-ekleme.md](dosya-ekleme.md).

## 4. Şimdi yönetilen uygulamalar

```text
~/.bashrc                         → dot_bashrc
~/.config/kitty/kitty.conf        → dot_config/kitty/kitty.conf
~/.config/atuin/config.toml       → dot_config/atuin/config.toml
~/.config/espanso/config/default.yml → dot_config/espanso/config/default.yml
~/.config/espanso/match/*.yml     → dot_config/espanso/match/*.yml
```

Atuin/Espanso commit'inde toplam **40 yeni dosya** vardır: bir Atuin TOML, bir Espanso varsayılan YAML, 37 Espanso eşleşme YAML dosyası ve bir `.keep` dosyası. `~/.config/espanso/match/.git` iç Git deposu **hariçtir**; kaynakta chezmoi adlandırması `dot_git` olabilir.

## 5. Bilinen uyarılar

```text
doctor latest-version: Fedora RPM 2.73.0; o tarihte 2.73.2 mevcut
doctor hardlink: invalid cross-device link
```

İkinci uyarının gözlenen nedeni: chezmoi kaynak dizini `ext4`, `/tmp` ise ayrı `tmpfs` dosya sistemindedir. Bu nedenle `/tmp` değiştirilmemelidir. `~/.config/chezmoi/chezmoi.toml` yokken varsayılan kurulum çalışmıştır.

## 6. Neleri chezmoi apply etmemelisin?

`README.md` ve `docs/` doğrudan GitHub bilgi belgeleridir. Depodaki `.chezmoiignore` dosyası bu yolları chezmoi'nin hedef uygulamasından dışlar. GitHub'daki yeni belgeleri Fedora'ya almak için `git pull --ff-only origin main` yeterlidir; `chezmoi apply` çalıştırma.

## Referans

[Chezmoi](https://www.chezmoi.io/) · [Günlük işlemler](https://www.chezmoi.io/user-guide/daily-operations/) · [Komutlar](https://www.chezmoi.io/reference/commands/) · [Git](https://git-scm.com/docs)
