# Chezmoi + Git + GitHub — Kopyala/Çalıştır Komut Rehberi

> [Chezmoi komutları](chezmoi.md) · [Çalışma günlüğü](gunluk.md) · [Ana sayfa](../README.md)

**Ortam:** Fedora; chezmoi kaynak deposu `~/.local/share/chezmoi`; GitHub deposu `orioninsist/dotfiles`; dal `main`. Bunlar 20 Ekim 2026 terminal çıktılarıyla doğrulanan ortam bilgileridir.

**Kural:** Kod bloklarını sırayla çalıştır. Hata görürsen sonraki bloğa geçme. `git push` öncesi `git diff --cached` içeriğini incele. Parola, API anahtarı, SSH özel anahtarı, token veya özel metinleri herkese açık depoya gönderme.

## Senaryo 1 — Tek yapılandırma dosyası ekle

**Örnek hedef:** `~/.config/kitty/kitty.conf`. Yeni bir dosyada `HEDEF` satırını değiştir. Kitty zaten yönetiliyorsa aynı dosyayı tekrar eklemene gerek yok.

### A. Hedefi denetle

```bash
HEDEF="$HOME/.config/kitty/kitty.conf"
test -f "$HEDEF" || { echo "Dosya yok: $HEDEF"; exit 1; }
ls -l "$HEDEF"
file "$HEDEF"
```

### B. Chezmoi'ye al

```bash
chezmoi add "$HEDEF"
chezmoi source-path "$HEDEF"
chezmoi managed
chezmoi status
chezmoi diff
chezmoi apply --dry-run --verbose
```

Yeni eklemeden sonra `chezmoi diff` boş olabilir; **bu Git'e eklendiği anlamına gelmez.**

### C. Git'e hazırla — kaynağın gerçek adını doğrula

```bash
cd "$(chezmoi source-path)"
git status --short
```

Örnekte kaynak yolunun `dot_config/kitty/kitty.conf` olduğu doğrulanmışsa:

```bash
git add -- dot_config/kitty/kitty.conf
git diff --cached --check
git diff --cached
git status --short
```

`git diff --cached` beklenen dosyayı ve **güvenli içeriği** gösteriyorsa:

```bash
git commit -m "feat(chezmoi): manage kitty configuration"
git push origin main
```

### D. Uzak depo doğrulaması

```bash
git status --short
git log -1 --oneline
git rev-parse HEAD
git ls-remote --heads origin main
chezmoi status
chezmoi diff
```

Yerel HEAD ve uzak `main` SHA değerleri eşleşmeli; `git status --short` boş olmalı. Çalışma günlüğüne ve Sheets'e ancak bu çıktılarla doğruladığın sonucu kaydet.

## Senaryo 2 — Bir klasördeki yapılandırmaları ekle

**Örnek:** Atuin (`~/.config/atuin`).

### A. Önce hangi dosyalar var, gör

```bash
find "$HOME/.config/atuin" -type f -print
du -ah "$HOME/.config/atuin" | sort -h | tail -20
```

Veritabanı, geçmiş, kişisel veri veya başka sır içeren dosyalar varsa dizinin tamamını ekleme; seçilen dosyaları tek tek `chezmoi add DOSYA` ile ekle.

### B. Yalnızca içerik uygunsa topluca ekle

```bash
chezmoi add --recursive "$HOME/.config/atuin"
chezmoi managed | grep '/atuin/'
chezmoi status
chezmoi diff
git -C "$(chezmoi source-path)" status --short
```

### C. Git'e aktar

```bash
cd "$(chezmoi source-path)"
git add -- dot_config/atuin
git diff --cached --check
git diff --cached
git commit -m "feat(chezmoi): manage atuin configuration"
git push origin main
```

**Şart:** Commit ve push satırlarına yalnızca `git diff --cached` güvenli, beklenen dosyaları gösteriyorsa geç.

## Senaryo 3 — Klasör içinde ayrı bir .git deposu varsa

**Yaşanan gerçek örnek:** `~/.config/espanso/match/.git`. Bu iç Git deposunun nesnelerini, geçmişini ve yapılandırmasını dotfiles deposuna kopyalama.

### A. Tespit

```bash
find "$HOME/.config/espanso" -name .git -print
chezmoi managed | grep '/espanso/'
```

### B. Yanlışlıkla chezmoi'ye eklendiyse

Chezmoi kaynak adlandırmasında `.git` klasörü `dot_git` olabilir. Kaynak yolunu **doğrulamadan silme**:

```bash
chezmoi source-path "$HOME/.config/espanso/match/.git"
```

Yalnızca iç deponun `chezmoi` tarafından yönetildiğini gördüğünde:

```bash
chezmoi forget "$HOME/.config/espanso/match/.git"
test -d "$HOME/.config/espanso/match/.git" && echo "Gerçek Git deposu duruyor"
chezmoi managed | grep '/espanso/match/.git' || echo "Chezmoi yönetiminde değil"
```

`chezmoi forget` **chezmoi kaynak kopyasını kaldırır**; gerçek hedefteki `.git` deposunu silmez. Etkileşimli silme istemini kontrol et. Gerçek terminal çıktısında `forget` sonrası `.git` yönetim dışında kalmış ve hedef korunmuştur.

### C. Güvenli dosyaları aşamaya al

```bash
cd "$(chezmoi source-path)"
git add -- dot_config/espanso
git diff --cached --name-only
git diff --cached --check
git diff --cached
```

Listeye `dot_config/espanso/match/dot_git/` veya `.git/` girdiyse commit/push yapma; önce `git restore --staged -- İLGİLİ_YOL` ve `chezmoi forget` ile düzelt.

## Senaryo 4 — Yönetilen dosyayı düzenle

**Kaynak kopyayı düzenlemek için:**

```bash
HEDEF="$HOME/.config/atuin/config.toml"
chezmoi edit "$HEDEF"
chezmoi diff
chezmoi status
chezmoi apply --dry-run --verbose
```

İçeriği ve etkisini doğruladıktan sonra gerçek hedefe uygula:

```bash
chezmoi apply "$HEDEF"
chezmoi status
```

Sonra `git status`, hedefe özel `git add`, `git diff --cached`, commit/push ve SHA doğrulamasını **Senaryo 1** gibi uygula. `chezmoi apply` mevcut hedef dosyayı değiştirebilir.

## Senaryo 5 — Fedora'daki hedef dosyayı doğrudan değiştirdin

Hedef dosyadaki değişikliği kaynak depoya almak için **önce farkı gör**:

```bash
HEDEF="$HOME/.config/atuin/config.toml"
chezmoi diff "$HEDEF"
chezmoi status
chezmoi source-path "$HEDEF"
```

Değişikliği bilerek kaynağa geçirmek istiyorsan:

```bash
chezmoi re-add "$HEDEF"
chezmoi diff "$HEDEF"
git -C "$(chezmoi source-path)" status --short
```

`re-add` kaynak kopyayı günceller; beklenmeyen değişiklikte commit yapma.

## Senaryo 6 — GitHub push reddedildi (fetch first)

20 Ekim'de yerel `bcf044b` commit'inden sonra GitHub'da yeni belge commit'i `085d182` oluşmuştu. Çözüm hızlı ileri sarma oldu.

```bash
cd "$(chezmoi source-path)"
git fetch origin
git status
git log --oneline --graph --decorate --all -n 12
git pull --ff-only origin main
```

`--ff-only` başarısızsa **dur**; körlemesine `--force`, `reset --hard` veya `pull --rebase` uygulama. Durum çözülünce yeniden `git push origin main`.

## Senaryo 7 — Yanlışlıkla stage edilenleri geri al

Bu işlem dosyaları silmez; yalnızca Git'in **staging alanından çıkarır**:

```bash
cd "$(chezmoi source-path)"
git restore --staged -- dot_config/atuin dot_config/espanso
git status --short
```

Bundan sonra `git commit` çalıştırırsan “nothing added to commit” görebilirsin. Önce güvenli dosyaları tekrar `git add` ile seçmen gerekir.

## Senaryo 8 — GitHub'da docs/ dosyasını değiştirdik, Fedora'yı güncelle

`docs/` dosyaları **doğrudan Git ile** yönetilir; chezmoi'nin hedef uygulama listesine girmez.

```bash
cd "$(chezmoi source-path)"
git status --short
git fetch origin
git pull --ff-only origin main
git log -1 --oneline
```

`README.md` ve `docs/` için chezmoi uygulaması gerekmez.

## Senaryo 9 — Güvenlik ve eksik denetim

Sadece anahtar sözcük aramak **güvenli olduğunu kanıtlamaz**. İçeriği yerel terminalde gözden geçir:

```bash
cd "$(chezmoi source-path)"
git diff --cached --name-only
git diff --cached --check
git diff --cached
```

Özel depo geçmişi, token, parolalar, kişisel metinler, veritabanları, `.git` nesneleri ve uygulama önbelleklerini ekleme. `git add .` alışkanlığından kaçın. Yanlışlıkla sır push edildiğinde yalnızca dosyayı silmek yeterli olmaz; erişim bilgisinin iptal/yenilenmesi ve geçmiş temizliği gerekebilir.

## Her işlemden sonra kopyala/çalıştır

```bash
cd "$(chezmoi source-path)"
git status --short
git log -1 --oneline
git rev-parse HEAD
git ls-remote --heads origin main
chezmoi managed
chezmoi status
chezmoi diff
```

**Kayıt:** [docs/gunluk.md](gunluk.md) ve [Google Sheets](https://docs.google.com/spreadsheets/d/1sutPQH5P0kotlz__uTs7v_PY3LeRZcvSjgDekgImyRg/edit) — yalnızca gerçek terminal ve GitHub çıktısına göre.

**Başvuru:** [Chezmoi günlük işlemler](https://www.chezmoi.io/user-guide/daily-operations/) · [Komut referansı](https://www.chezmoi.io/reference/commands/) · [Git komut referansı](https://git-scm.com/docs)
