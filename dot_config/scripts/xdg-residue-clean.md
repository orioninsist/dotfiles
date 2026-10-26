# XDG Residue Clean

`xdg-residue-clean.sh`, XDG dizinlerinin doğrudan altındaki boş
klasörleri temizleyen küçük bir Bash betiğidir.

## Amaç

`~/.config` ve `~/.local` dizinlerinde gereksiz boş klasör
kalmasını önlemek.

## Kapsam

| Dizin | İşlem |
|---|---|
| `$XDG_CONFIG_HOME` | Boş birinci seviye klasörleri kaldırır |
| `$XDG_DATA_HOME` | Boş birinci seviye klasörleri kaldırır |
| `$XDG_STATE_HOME` | Boş birinci seviye klasörleri kaldırır |

Varsayılan konumlar sırasıyla `~/.config`, `~/.local/share`
ve `~/.local/state` dizinleridir.

## Kullanım

```bash
bash ~/.config/scripts/xdg-residue-clean.sh


Yardım:
bash ~/.config/scripts/xdg-residue-clean.sh --help


Güvenlik
- Yalnızca boş dizinleri rmdir ile kaldırır.
- Dosya veya dolu dizin silmez.
- Alt klasörleri özyinelemeli temizlemez.
- Symlink takip etmez.
- sudo gerektirmez.
- SELinux bağlamlarını değiştirmez.
- Tekrar çalıştırılabilir.
Sınırlama
Bu betik kullanılmayan uygulamaları veya onların dolu
yapılandırma ve veri dizinlerini tespit etmez.

Bir dizinin boş olması, uygulamanın kaldırıldığı anlamına gelmez.
Gerekli boş dizinler uygulamalar tarafından yeniden oluşturulabilir.
