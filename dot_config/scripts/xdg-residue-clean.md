# XDG Residue Clean

Fedora Linux için boş XDG dizinlerini temizleyen Bash betiği.

## Amaç

`$XDG_CONFIG_HOME`, `$XDG_DATA_HOME` ve `$XDG_STATE_HOME`
altındaki boş birinci seviye dizinleri kaldırmak.

## Kullanım

    bash ~/.config/scripts/xdg-residue-clean.sh

Yardım:

    bash ~/.config/scripts/xdg-residue-clean.sh --help

## Güvenlik

- Yalnızca boş dizinleri `rmdir` ile kaldırır.
- Dosya ve dolu dizinleri silmez.
- Alt dizinlerde özyinelemeli temizlik yapmaz.
- Symlink takip etmez.
- `sudo` gerektirmez.
- SELinux bağlamlarını değiştirmez.

## Sınırlama

Kaldırılmış uygulamaların dolu yapılandırma ve veri dizinlerini
otomatik tespit etmez.
