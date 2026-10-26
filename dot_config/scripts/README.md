# cache-clean

Fedora Linux için XDG önbellek temizleme betiği.

## Amaç

`~/.cache` dizinindeki gereksiz uygulama önbelleklerini
temizlemek ve HOME dizinini düzenli tutmak.

Betik yalnızca önceden belirlenmiş dizinleri hedefler.
Tüm `~/.cache` dizinini silmez.

## Dosya konumu

`~/.config/scripts/cache-clean`

ChezMoi tarafından yönetilir.

## Kullanım

```bash
~/.config/scripts/cache-clean


Yardım:
~/.config/scripts/cache-clean --help


Temizlenen önbellekler
Uygulama	İçerik
pip	HTTP indirme önbelleği ve selfcheck
Codex	Çalışma ortamları ve önbellekleri
Puppeteer	İndirilen tarayıcı bileşenleri
Camoufox	İndirilen tarayıcı bileşenleri
Playwright	İndirilen tarayıcılar
Whisper	İndirilen model dosyaları
Go	Derleme önbelleği
Tracker3	Arama indeksleri
libdnf5	Kullanıcı önbelleği
Firefox	Önbellek
Tor Browser	Önbellek
Yandex Browser	Önbellek
Chromium	Önbellek
Microsoft Edge	Önbellek
Calibre	Önbellek
Hugo	Derleme önbelleği

Özel işlemler
uv: uv cache prune

Kullanılmayan önbellek girdilerini temizler.

npm: npm cache verify

Önbelleği doğrular ve bakım yapar.
Tamamen boşaltmaz.

Bu araçlar sistemde yoksa ilgili işlem atlanır.
Google Chrome
Google Chrome önbelleği özellikle korunur.

Betikteki google-chrome satırı yorum durumundadır.

Chrome açıkken betik çalıştırılabilir; ancak diğer
uygulamaların kapalı olması önerilir.
Güvenlik ve sınırlamalar
- Silinen önbellekler geri alınamaz.
- İndirilen modeller ve tarayıcı bileşenleri tekrar indirilebilir.
- Tracker3 arama indekslerini yeniden oluşturabilir.
- Kurulu Python ve sistem paketleri hedeflenmez.
- ~/.config, ~/.local/share ve ~/.local/state temizlenmez.
- Çalışan uygulamalar için genel bir kilit kontrolü yapılmaz.
- Yalnızca betikte listelenen önbellekler temizlenir.
- Betik rm -rf kullandığından çalıştırmadan önce içeriği gözden geçirilmelidir.
XDG uyumluluğu
Önbellek kökü:

${XDG_CACHE_HOME:-$HOME/.cache}

Betik konumu:

~/.config/scripts/cache-clean

Bu konum kişisel yapılandırma betikleri için seçilmiştir;
standart bir XDG çalıştırılabilir dosya dizini değildir.
ChezMoi
Dosyaları kaydetmek:
chezmoi add ~/.config/scripts/cache-clean
chezmoi add ~/.config/scripts/README.md


Değişiklikleri kontrol etmek:
chezmoi diff


Doğrulama
bash -n ~/.config/scripts/cache-clean
~/.config/scripts/cache-clean --help
du -sh ~/.cache


