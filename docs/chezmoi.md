# Chezmoi — Kullanım Notları

> [Ana sayfa](../README.md) · [Çalışma günlüğü](gunluk.md)

## Amaç

Fedora kullanıcı yapılandırmalarını chezmoi ile yönetmek, GitHub'da sürümlemek ve Google Sheets'te takip etmek.

## Doğrulanan kurulum (20 Ekim 2026)

- Fedora Linux 44, x86_64
- Fedora RPM paketi: chezmoi v2.73.0
- Kaynak dizini: `~/.local/share/chezmoi`
- Git remote: `https://github.com/orioninsist/dotfiles.git`
- Yönetilen ilk dosya: `~/.bashrc` (kaynak: `dot_bashrc`)
- Son doğrulanan commit: [`49b9b24`](https://github.com/orioninsist/dotfiles/commit/49b9b24)
- `chezmoi diff` boş; Git çalışma ağacı temiz.

## Temel komutlar

```bash
chezmoi doctor                 # Kurulum tanılama
chezmoi managed                # Yönetilen hedefleri listele
chezmoi status                 # Kaynak ve hedef durumunu karşılaştır
chezmoi diff                   # Uygulanacak içerik farkını incele
chezmoi add ~/.bashrc          # Hedef dosyayı kaynak depoya al
chezmoi edit ~/.bashrc         # Kaynak dosyayı düzenle
chezmoi apply --dry-run --verbose  # Uygulamadan önce önizle
```

`chezmoi apply` mevcut kullanıcı dosyalarını değiştirebilir. Önce `status`, `diff` ve dry-run çıktıları incelenmelidir. `chezmoi add` öncesi gizli bilgileri kontrol et.

## Bilinen doctor uyarıları

- `latest-version`: Fedora paket sürümü 2.73.0 iken doctor 2.73.2 bildiriyor. Tek başına kurulum hatası değildir.
- `hardlink: invalid cross-device link`: kaynak dizini ile `/tmp` arasında hardlink testi başarısız. Farklı dosya sistemleri olası açıklamadır; kök neden henüz ayrıca doğrulanmadı.
- `chezmoi.toml` bulunmuyor: mevcut kurulum varsayılan ayarlarla çalışıyor.

## Resmî belgeler

- [Chezmoi resmî belgeleri](https://www.chezmoi.io/)
- [Hızlı başlangıç](https://www.chezmoi.io/quick-start/)
- [Kullanıcı kılavuzu](https://www.chezmoi.io/user-guide/)
- [Komut referansı](https://www.chezmoi.io/reference/commands/)
- [Chezmoi kaynak kodu](https://github.com/twpayne/chezmoi)

## Konu dizini

Yeni uygulama yapılandırmaları yönetilmeye başladığında bu dizine ayrı GFM belgeleri eklenebilir. Ana README'de bunlara göreli Markdown bağlantıları verilir.
