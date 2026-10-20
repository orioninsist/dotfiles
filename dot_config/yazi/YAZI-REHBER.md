# Yazi Kullanım Rehberim — Fedora Linux

> **Sürüm:** Yazi 26.9.1 (13 Eylül 2026 derlemesi)
> **Yapılandırma:** `~/.config/yazi/`
> **Hazırlanma:** 17 Ekim 2026
> Bu rehber, paylaştığın `init.lua`, `keymap.toml`, `package.toml`, `theme.toml`, `yazi.toml` ve eklenti dosya listesini temel alır. Sistemindeki dosyaları değiştirmez.

## 1. Hızlı başvuru

| Tuş | İşlem | Kaynak |
|---|---|---|
| `h` | Üst klasöre dön | Yazi varsayılanı |
| `j` / `k` | Aşağı / yukarı hareket | Yazi varsayılanı |
| `l` | Akıllı giriş: klasöre gir veya dosyayı aç | **Senin özel ayarın** (`smart-enter`) |
| `Enter` | Seçili dosyayı aç | Yazi varsayılanı; sürüme göre yardım ekranından kontrol et |
| `Space` | Dosyayı seç / seçimi kaldır | Yazi varsayılanı |
| `v` | Görsel seçim modu | Yazi varsayılanı |
| `V` | Görsel seçimi kaldırma modu | Yazi varsayılanı |
| `y` | Yazi'de kopyala ve Wayland panosuna dosya URI'lerini aktar | **Senin özel ayarın** |
| `x` | Kes / taşımak için işaretle | Yazi varsayılanı |
| `p` | Yapıştır, ardından görev ekranını göster | **Senin özel ayarın** |
| `w` | Görev yöneticisini göster | Yazi varsayılanı |
| `f` | Karaktere hızlı atla | **Senin özel ayarın** (`jump-to-char`) |
| `T` | Önizleme panelini büyüt / geri al | **Senin özel ayarın** (`toggle-pane`) |
| `b` ardından `p` | Önizleme panelini küçült / geri al | **Senin özel ayarın** |
| `m` ardından `m` | Disk/USB bağlama menüsü | **Senin özel ayarın** (`mount`) |
| `c` ardından `m` | Dosya izinlerini değiştir | **Senin özel ayarın** (`chmod`) |
| `g` ardından `r` | Git deposunun kök dizinine git | **Senin özel ayarın** |
| `!` | Bulunulan dizinde kabuk aç | **Senin özel ayarın** |
| `Ctrl+n` | Dragon ile sürükle-bırak penceresi aç | **Senin özel ayarın** |
| `K` / `J` | Önizlemeyi 5 birim yukarı / aşağı kaydır | **Senin özel ayarın** |
| `?` / `~` | Yardım ekranı (sürüm ve tuş haritasına göre) | Yazi içinden doğrula |
| `q` | Yazi'den çık | Yazi varsayılanı |

**Önemli:** `c` sonra `m`, `b` sonra `p` gibi ifadeler iki tuşa *sırayla* basmak demektir; aynı anda değil. `Ctrl+n` ise birlikte basılır.

## 2. Kopyalama, kesme ve çoklu seçim

### Tek dosya kopyalama

1. Dosyanın üzerine gel.
2. `y` tuşuna bas.
3. Hedef klasöre git.
4. `p` tuşuna bas. `paste` çalışır ve ardından `tasks:show` görev ekranını açar.

`y` için özel komutun önce seçili yolları `wl-copy -t text/uri-list` ile sistem panosuna aktarmaya, ardından Yazi'nin `yank` komutunu çalıştırmaya çalışır. Wayland panosuna aktarım için `wl-copy` kurulu ve kullanılabilir olmalıdır.

### Tek dosya kesme/taşıma

1. Dosyanın üzerine gel.
2. `x` tuşuna bas.
3. Hedef klasöre git.
4. `p` tuşuna bas. Kesilen dosya taşınır; görev ekranı açılır.

### Çoklu dosya

1. `Space` ile birden fazla dosyayı işaretle; istersen `v` ile görsel seçim yap.
2. Kopyalamak için `y`, taşımak için `x` kullan.
3. Hedefe gidip `p` tuşuna bas.

`p` kısayolun hem kesme hem kopyalama için aynıdır. Büyük işlemlerde görev ekranı açılır; ancak çok hızlı tamamlanan işlemlerde ilerleme çubuğunu görmeye zaman kalmayabilir. Bu ekran kalıcı, her an açık duran bir panel değildir.

### Faydalı notlar

- `y` tuşun **özelleştirilmiş**: standart Yazi `yank` işlevine ek olarak Wayland panosuna da yazmaya çalışıyor.
- Birden fazla dosya seçtiğinde panoya aktarılan dosya URI'lerini başka uygulamaların kabul etmesi, uygulamaya ve masaüstü ortamına bağlıdır.
- Kesilen dosyalar için `x` kullan; yalnızca `y` ile kopyalamak taşıma yapmaz.
- İşlem sırasında hata görürsen `w` ile görev ekranını incele.

## 3. Fare ve sürükle-bırak

Yazi terminal içinde fare ile gezinmeyi destekleyebilir; kullanılabilen hareketler terminal emülatörüne ve Yazi ayarlarına bağlıdır. **Dolphin/Nautilus tarzı, Yazi içinde bir dosyayı tutup klasöre sürükleyerek taşıma** işlevini varsayma.

### Dragon entegrasyonun

`Ctrl+n` şu komutu çalıştırır:

```sh
shell -- dragon -x -i -T %h
```

Bu kısayol Dragon aracını açarak seçili dosyayı dışarıdaki grafik uygulamalara sürüklemek için tasarlanmış. Dragon'ın davranışı kurulu sürüme, Wayland/X11 oturumuna ve hedef uygulamaya bağlıdır. Bu kısayol Yazi'nin kendi içindeki klasörler arasında sürükle-bırak ile taşıma garantisi vermez.

Dragon kurulu mu kontrol et:

```sh
command -v dragon
```

**En güvenilir Yazi içi taşıma yöntemi:** `x` → hedef klasöre git → `p`.

## 4. Özel tuşlarının ayrıntıları (`keymap.toml`)

| Kısayol | Çalıştırdığı komut | Açıklama |
|---|---|---|
| `l` | `plugin smart-enter` | Klasörde içeri girer, dosyada açma davranışı sağlar |
| `c m` | `plugin chmod` | İzin düzenleme arayüzü |
| `!` | `shell "$SHELL" --block` | Geçerli klasörde etkileşimli kabuk |
| `g r` | `shell -- ya emit cd "$(git rev-parse --show-toplevel)"` | Git köküne geçiş; Git deposu dışında hata verebilir |
| `y` | `shell -- ... wl-copy -t text/uri-list` ve `yank` | Hem sistem panosu hem Yazi kopyalama |
| `Ctrl+n` | `shell -- dragon -x -i -T %h` | Dragon sürükle-bırak aracı |
| `K` | `seek -5` | Önizlemede yukarı |
| `J` | `seek 5` | Önizlemede aşağı |
| `f` | `plugin jump-to-char` | Dosya adına göre hızlı atlama |
| `T` | `plugin toggle-pane max-preview` | Önizlemeyi büyüt / geri al |
| `m m` | `plugin mount` | Disk/USB bağlama |
| `b p` | `plugin toggle-pane min-preview` | Önizlemeyi gizle/küçült / geri al |
| `p` | `paste`, `tasks:show` | Yapıştırma ve görev ekranı |
| Girdi penceresinde `Esc` | `close` | Girdi penceresini kapat |

**Çakışma uyarısı:** `keymap.toml` içinde `[mgr] prepend_keymap = [ ... ]` zaten mevcut. Aynı dosyaya ayrıca `[[mgr.prepend_keymap]]` ekleme: TOML `duplicate key` hatası oluşur. Yeni kısayolları mevcut dizinin içine, uygun virgülle eklemelisin.

## 5. Kurulu 7 eklenti

| Eklenti | Kullanım | Açıklama |
|---|---|---|
| `git.yazi` | Otomatik (`init.lua`) | Git durum bilgisini Yazi'ye entegre eder |
| `full-border.yazi` | Otomatik (`init.lua`) | Panel kenarlıklarını tamamlar |
| `chmod.yazi` | `c m` | Dosya izinlerini değiştirir |
| `smart-enter.yazi` | `l` | Dosya/klasör için akıllı açma-girme |
| `jump-to-char.yazi` | `f` | Karakterle hızlı atlama |
| `toggle-pane.yazi` | `T`, `b p` | Önizleme paneli boyutunu değiştirir |
| `mount.yazi` | `m m` | Disk ve aygıt bağlama menüsü |

`package.toml` bu eklentilerin sürüm sabitlemelerini içeriyor. `init.lua` yalnızca `git` ve `full-border` için `setup()` çağırıyor; diğerleri tuşla tetikleniyor.

## 6. Dosya türüne göre açma (`yazi.toml`)

| Dosya türü | Program / komut |
|---|---|
| Kod, Markdown, TXT, JSON, TOML, CSV vb. | `NVIM_APPNAME=astronvim nvim` (AstroNvim) |
| PNG, JPG, SVG, WEBP, GIF vb. | `imv` |
| Video / ses | `mpv` |
| PDF | `zathura` |
| `.docx` | `~/.local/bin/orion-open-docx` (Google Docs yönlendirmesi) |
| `.xlsx` | `~/.local/bin/orion-open-xlsx` (Google Sheets yönlendirmesi) |
| `.pptx` | `~/.local/bin/orion-open-pptx` (Google Slides yönlendirmesi) |
| Diğer dosyalar | Sistem varsayılanı: `gio open` |

Office yönlendirme betiklerinin içeriği paylaşılmadığı için Google Docs/Sheets/Slides'a **nasıl** aktardıklarını doğrulayamıyoruz; tabloda yapılandırmada belirtilen niyet gösteriliyor. Aynı şekilde `imv`, `mpv`, `zathura` ve diğer programların kurulu olması gerekir.

## 7. Görünüm, önizleme ve sıralama

### Dosya yöneticisi

- Panel oranı: **1 : 3 : 4** (üst/yan dizin, dosya listesi, önizleme alanları).
- Sıralama: `natural` (ör. `file2` önce, `file10` sonra).
- Klasörler önce: `sort_dir_first = true`.
- Gizli dosyalar başlangıçta gizli: `show_hidden = false`.

### Önizleme

- Satır kaydırma: `wrap = "no"`.
- Sekme genişliği: `2`.
- En büyük önizleme: `1200 × 1200`.
- Görsel gecikmesi: `20`.
- Filtre: `triangle`; kalite: `90`.
- Görsel görev belleği ayarı: `image_alloc = 1073741824` (1 GiB).
- Görsel sınırı: `image_bound = [15000, 15000]`.

### Tema

**Catppuccin Mocha** renk paleti kullanıyorsun. Mavi seçim ve vurgu (`#89b4fa`), yeşil kopya işaretleri (`#a6e3a1`), kırmızı kesme işaretleri (`#f38ba8`), mor aktif sekme (`#cba6f7`) bulunuyor. Görev ekranı ve ilerleme göstergeleri de özel renklendirilmiş.

## 8. Sık kullanılan senaryolar

**Bir klasörde 20 dosyayı kopyala:** Dosyaları `Space` ile seç → `y` → hedef klasöre git → `p`.

**Dosyaları başka diske taşı:** Dosyaları seç → `x` → hedef diskin klasörüne git → `p`. Farklı dosya sistemleri arasında taşıma daha uzun sürebilir.

**USB diski bağla:** `m` ardından `m` → eklenti menüsünden aygıtı seç.

**Kod dosyasını düzenle:** Dosyanın üzerine gel → `l` → AstroNvim ile açılmasını bekle. Dosya türü açma kuralına uymuyorsa farklı davranabilir.

**Git deposunun köküne git:** Depo içindeyken `g` ardından `r`.

**Önizlemeyi büyüt:** `T`; geri almak için tekrar `T`.

**Kopyalama işlemlerini incele:** `w` veya `p` ile açılan görev ekranını kullan.

## 9. Sorun giderme

### `duplicate key` / `Failed to parse config`

Aynı `mgr.prepend_keymap` anahtarını hem `[mgr]` içindeki diziyle hem de `[[mgr.prepend_keymap]]` biçimiyle tanımlama. Yedek almadan düzenleme yapma.

```sh
cp ~/.config/yazi/keymap.toml ~/.config/yazi/keymap.toml.bak
python3 - <<'PY'
import tomllib
from pathlib import Path
p = Path.home() / '.config/yazi/keymap.toml'
with p.open('rb') as f:
    tomllib.load(f)
print('TOML sözdizimi geçerli')
PY
```

Bu test yalnızca TOML sözdizimini kontrol eder; Yazi komutlarının çalışma zamanında geçerli olduğunu garanti etmez.

### Kopyalama ilerlemesi görünmüyor

- Büyük bir dosyada dene; küçük dosya çok hızlı tamamlanabilir.
- `w` ile görev ekranını aç.
- `p` tuşunun özel eşlemesinin yüklendiğini Yazi yardım ekranından kontrol et.
- Terminalde hata olup olmadığına bak.

### Dragon açılmıyor

```sh
command -v dragon
```

Çıktı boşsa komut bulunamıyor demektir. Fedora'daki paket adı ve Wayland uyumluluğunu kurulu Dragon sürümüne göre doğrula.

### Programlar açılmıyor

```sh
for cmd in wl-copy dragon imv mpv zathura nvim gio; do
  command -v "$cmd" || echo "Eksik: $cmd"
done
```

## 10. Dosyaların ne işe yarıyor?

| Dosya/klasör | Görev |
|---|---|
| `init.lua` | Başlangıçta kurulan eklentiler |
| `keymap.toml` | Özel klavye kısayolları |
| `package.toml` | Eklenti bağımlılıkları ve sabit revizyonlar |
| `plugins/` | Eklenti kodları |
| `theme.toml` | Catppuccin Mocha renkleri ve bileşen görünümleri |
| `yazi.toml` | Yönetici, önizleme, görevler ve dosya açma kuralları |

### Rehberi bilgisayarına koyma

İndirdiğin dosyayı `~/İndirilenler` altında bulursan:

```sh
cp ~/İndirilenler/YAZI-REHBER.md ~/.config/yazi/YAZI-REHBER.md
```

İndirme klasörün farklıysa kaynak yolu ona göre değiştir. Rehberi terminalde okumak için:

```sh
less ~/.config/yazi/YAZI-REHBER.md
```

---

**Doğruluk notu:** Bu belge, paylaştığın yapılandırmayı temel alır. Yazi'nin varsayılan kısayolları sürümler arasında değişebilir; en güncel ve etkin tuşları Yazi'nin yardım ekranında kontrol et. Eklentilerin kaynak kodları değil yalnızca adları, dosya listesi ve kısayolları paylaşıldığından, açıklamalar bilinen amaçlarıyla sınırlıdır.
