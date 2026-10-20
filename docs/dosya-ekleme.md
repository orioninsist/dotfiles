# Chezmoi — Dosya ve Dizin Ekleme Rehberi

> [Ana sayfa](../README.md) · [Chezmoi notları](chezmoi.md) · [Çalışma günlüğü](gunluk.md)

Bu sayfa **kopyala–çalıştır** komutları içerir. Önce Fedora'daki gerçek dosyayı doğrula, sonra chezmoi'ye ekle. GitHub deposu herkese açıktır: **gizli bilgi içeren dosyaları ekleme.**

## 1. Kitty — Tek yapılandırma dosyası

Önce dosyanın varlığını kontrol et:

```bash
ls -l ~/.config/kitty/kitty.conf
```

Dosya varsa chezmoi'ye ekle:

```bash
chezmoi add ~/.config/kitty/kitty.conf
```

Eklenen dosyanın kaynak konumunu ve Git değişikliklerini kontrol et:

```bash
chezmoi source-path ~/.config/kitty/kitty.conf
chezmoi managed
git -C "$(chezmoi source-path)" status --short
```

> **Dikkat:** `chezmoi diff` yalnızca chezmoi kaynağı ile hedef arasındaki farkı gösterir. Yeni eklenen dosya hedefle aynıysa çıktı boş olabilir. Git'e eklenmemiş dosyaları görmek için `git status --short` kullan.

## 2. Kitty — Tüm yapılandırma dizini (isteğe bağlı)

**Önce içerikleri kontrol et.** Dizindeki tüm dosyaların yönetilmesi gerçekten isteniyorsa:

```bash
find ~/.config/kitty -maxdepth 2 -type f -print
```

```bash
chezmoi add --recursive ~/.config/kitty
```

Tek dosya yönetimi daha az risklidir. Dizin içinde makineye özel dosyalar veya gizli bilgiler varsa tüm dizini ekleme.

## 3. Herhangi bir dosyayı ekleme

Aşağıdaki `HEDEF_DOSYA` ifadesini gerçek yol ile değiştir:

```bash
chezmoi add "$HOME/.config/UYGULAMA/AYAR_DOSYASI"
```

Örnek (dosya varsa):

```bash
chezmoi add ~/.config/kitty/kitty.conf
```

## 4. Ekledikten sonra kontrol

```bash
chezmoi managed
chezmoi status
chezmoi diff
git -C "$(chezmoi source-path)" status --short
```

Yeni dosyanın içeriğini Git'e göndermeden önce incele:

```bash
cd "$(chezmoi source-path)"
git status --short
git diff --check
```

> `git diff`, henüz izlenmeyen (untracked) dosyaların içeriğini göstermez. Yeni dosyayı önce `git add` ile aşamaya alıp ardından `git diff --cached` ile incele.

## 5. Kitty için Git commit ve push

**Yalnızca `kitty.conf` eklendiyse** ve içerik gizli bilgi açısından incelendiyse:

```bash
cd "$(chezmoi source-path)"
git add -- dot_config/kitty/kitty.conf
git diff --cached --check
git diff --cached
```

Diff'i onayladıktan sonra:

```bash
git commit -m "feat(chezmoi): manage kitty configuration"
git push origin main
```

Kaynak dosyanın adı farklıysa `chezmoi source-path ~/.config/kitty/kitty.conf` çıktısına göre `git add` yolunu düzenle. **İçeriği incelemeden push yapma.**

## 6. Mevcut yapılandırmayı düzenleme

```bash
chezmoi edit ~/.config/kitty/kitty.conf
chezmoi diff
chezmoi apply --dry-run --verbose
```

`chezmoi apply` gerçek hedef dosyayı değiştirebilir; yalnızca önizleme ve onaydan sonra kullan.

## 7. Belgeler neden ev dizinine uygulanmıyor?

Depo kökündeki [`.chezmoiignore`](../.chezmoiignore) dosyası `README.md` ve `docs/` dosyalarını yönetim dışında tutar. Bu belgeler GitHub bilgi merkezi içindir.

## Resmî kaynaklar

- [Chezmoi hızlı başlangıç](https://www.chezmoi.io/quick-start/)
- [Chezmoi kullanıcı kılavuzu](https://www.chezmoi.io/user-guide/)
- [Chezmoi komut referansı](https://www.chezmoi.io/reference/commands/)
- [Chezmoi resmî sitesi](https://www.chezmoi.io/)
