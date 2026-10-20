# Fedora Dotfiles — Chezmoi Yönetim Merkezi

Fedora Linux kullanıcı yapılandırmalarının **chezmoi** ile yönetildiği, **GitHub** üzerinde sürümlendiği ve **Google Sheets** ile takip edildiği kişisel depo.

## Başlangıç durumu · 20 Ekim 2026

| Alan | Doğrulanan durum |
| --- | --- |
| Sistem | Fedora Linux 44 (x86_64) |
| Chezmoi | v2.73.0 (Fedora RPM) |
| Kaynak dizini | `~/.local/share/chezmoi` |
| GitHub | [orioninsist/dotfiles](https://github.com/orioninsist/dotfiles) |
| İlk yönetilen dosya | `~/.bashrc` → `dot_bashrc` |
| İlk dosya commit'i | [`49b9b24`](https://github.com/orioninsist/dotfiles/commit/49b9b24) |
| Son kontrol | Git temiz; `chezmoi diff` boş |

## Bilgi merkezi

GitHub'ın desteklediği **GitHub Flavored Markdown (GFM)** kullanılır. GitHub README içinde `[[Sayfa]]` sözdizimi otomatik wiki bağlantısı oluşturmadığından, wiki benzeri gezinme için **göreli Markdown bağlantıları** kullanılır.

- 📖 [Chezmoi — Kullanım Notları](docs/chezmoi.md)
- 🗓️ [Çalışma Günlüğü](docs/gunluk.md)
- 📊 [Google Sheets — Yönetim Merkezi](https://docs.google.com/spreadsheets/d/1sutPQH5P0kotlz__uTs7v_PY3LeRZcvSjgDekgImyRg/edit)
- 📚 [Chezmoi resmî dokümantasyonu](https://www.chezmoi.io/)
- 🛠️ [Chezmoi resmî GitHub deposu](https://github.com/twpayne/chezmoi)

## Günlük kullanım

```bash
chezmoi managed
chezmoi status
chezmoi diff
git -C "$(chezmoi source-path)" status --short
```

Değişiklikleri uygulamadan önce `chezmoi diff` ve `chezmoi apply --dry-run --verbose` ile önizle. Mevcut dosyaları körlemesine değiştirme.

## Çalışma ilkeleri

1. Fedora'da gerçek durumu doğrula.
2. Kullanıcı yapılandırmalarını chezmoi ile yönet.
3. GitHub'da küçük ve açıklayıcı commit'lerle sürümle.
4. Sonuçları Google Sheets'e kaydet.
5. Parolaları, token'ları ve özel anahtarları herkese açık depoya gönderme.

Detaylar için [Chezmoi notlarına](docs/chezmoi.md), tarihsel işlemler için [günlüğe](docs/gunluk.md) bak.
