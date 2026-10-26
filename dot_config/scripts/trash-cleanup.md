# trash-cleanup.sh

Fedora Linux ve Niri Wayland ortamında XDG çöp kutusunu
güvenli ve kullanıcı onaylı olarak temizleyen Bash betiği.

## Gereksinimler

- Bash
- trash-cli
- GNU coreutils

Kurulum:

```bash
sudo dnf install trash-cli


Kullanım
Yardım:
~/.config/scripts/trash-cleanup.sh --help


Temizlik:
~/.config/scripts/trash-cleanup.sh


Çalışma şekli
1. XDG çöp kutusunun varlığını kontrol eder.
2. Mevcut disk kullanımını gösterir.
3. Kalıcı silme için kullanıcı onayı ister.
4. trash-empty aracını çalıştırır.
5. Temizlik sonrasında kalan boyutu gösterir.
Güvenlik
- Varsayılan olarak otomatik silme yapmaz.
- sudo kullanmaz.
- Dosya izinlerini veya SELinux bağlamlarını değiştirmez.
- Çöp kutusu dışındaki uygulama verilerini temizlemez.
- Silinen dosyalar geri alınamaz.
- İzin veya dosya sistemi hatalarında işlem başarısız olabilir.
Standart
FreeDesktop.org Trash Specification.

https://specifications.freedesktop.org/trash-spec/latest/

## Kapsam uyarısı

`trash-empty` yalnızca `$XDG_DATA_HOME/Trash` dizinini değil,
erişilebilir diğer bağlı dosya sistemlerinin çöp kutularını da
boşaltabilir.

Betikte gösterilen boyut yalnızca HOME çöp kutusuna aittir;
silinecek toplam veri miktarını temsil etmeyebilir.

İşlem kalıcıdır ve silinen dosyalar geri alınamaz.
