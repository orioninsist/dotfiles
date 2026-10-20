# Fedora + Chezmoi + GitHub — Dosya Yönetimi Rehberi

> [Ana sayfa](../README.md) · [Chezmoi notları](chezmoi.md) · [Çalışma günlüğü](gunluk.md)

## Amaç ve sınırlar

Bu rehber Fedora'da **yeni bir kullanıcı yapılandırma dosyasını** chezmoi'ye eklemek, kontrol etmek ve GitHub'a güvenli biçimde göndermek içindir. Her adımın çıktısını kontrol et; hata varsa sonraki adıma geçme. Komutlar Fedora terminalinde çalıştırılır. GitHub'daki `docs/` belgeleri ise doğrudan Git ile sürümlenir, chezmoi ile ev dizinine uygulanmaz.

**Önemli:** Her örnekteki `HEDEF` değerini gerçek dosya yoluna göre değiştir. Dizinleri topluca eklemek yerine mümkünse tek dosyayla başla. Parola, token, özel anahtar, kişisel veri veya makineye özgü sır içeren dosyayı herkese açık depoya gönderme. `git push` öncesi diff'i insan gözüyle incele.

## A. Yeni dosya ekleme — sırasıyla

### 1. Dosya gerçekten var mı?

```bash
HEDEF="$HOME/.config/kitty/kitty.conf"  # Örnek; gerçek yolu yaz
test -f "$HEDEF" && ls -l "$HEDEF"
```

Dosya yoksa dur. Dosyanın içeriğini yerel olarak incele; hassas verileri terminal çıktısı olarak paylaşma.

### 2. Chezmoi'ye ekle

```bash
chezmoi add "$HEDEF"
chezmoi source-path "$HEDEF"
```

İlk komut hedef dosyayı chezmoi kaynak dizinine alır. İkinci komut Git'te tutulacak kaynak dosyanın **gerçek yolunu** gösterir. `dot_`, `private_` veya `.tmpl` gibi adlandırmalar olabileceği için yolu tahmin etme.

### 3. Chezmoi ve Git durumunu kontrol et

```bash
chezmoi managed
chezmoi status
chezmoi diff
chezmoi apply --dry-run --verbose
git -C "$(chezmoi source-path)" status --short
```

`managed` yönetilen hedefleri listeler. `status` ve `diff` kaynak–hedef farkını, `--dry-run` uygulamanın önizlemesini gösterir. Yeni eklenen dosya hedefle aynıysa `chezmoi diff` **boş olabilir**; bu, Git'e gönderildiği anlamına gelmez. `git status --short` yeni/değişen kaynak dosyalarını gösterir.

### 4. Yalnızca istediğin dosyayı Git'e hazırla

```bash
cd "$(chezmoi source-path)"
git status --short
```

`chezmoi source-path "$HEDEF"` çıktısının kaynak dizinine göre yolunu bul. Örneğin Kitty dosyası için yol `dot_config/kitty/kitty.conf` olabilir. Aşağıdaki örneği yalnızca yol doğrulandıysa çalıştır:

```bash
git add -- dot_config/kitty/kitty.conf
git diff --cached --check
git diff --cached
git status --short
```

`git add` yalnızca seçilen dosyayı aşamaya alır. `git diff --cached` **yeni dosyaların içeriğini de** gösterir. Gizli bilgi, yanlış dosya veya beklenmedik değişiklik varsa dur; commit/push yapma. `git add .` veya `git add -A` komutlarını otomatik alışkanlık olarak kullanma.

### 5. Commit ve GitHub'a gönderme

Yalnızca aşamaya alınan değişiklikler onaylandıktan sonra:

```bash
git commit -m "feat(chezmoi): manage kitty configuration"
git push origin main
```

Commit mesajını gerçek uygulamaya göre değiştir. Push reddedilirse zorla gönderme (`--force` kullanma); önce yerel ve uzak dal farkını incele. `git pull --rebase` gibi geçmişi etkileyen işlemleri sonucu değerlendirmeden çalıştırma.

### 6. Sonucu doğrula

```bash
git status --short
git log -1 --oneline
git ls-remote --heads origin main
chezmoi status
chezmoi diff
```

`git status --short` boşsa yerel çalışma ağacında görünür değişiklik yoktur. `git log -1` yerel commit'i, `git ls-remote` uzak `main` commit'ini gösterir; SHA'ların eşleşmesini ve GitHub'daki dosyanın içeriğini kontrol et. `chezmoi status`/`diff` boş olması hedefin kaynakla uyumlu olduğuna işaret eder, GitHub push'unu **kanıtlamaz**.

### 7. Günlüğe ve envantere kaydet

[Çalışma günlüğüne](gunluk.md) tarih, hedef dosya, kaynak yolu, çalıştırılan önemli komutlar, kontrol sonuçları, commit SHA ve GitHub bağlantısını ekle. [Google Sheets yönetim merkezindeki](https://docs.google.com/spreadsheets/d/1sutPQH5P0kotlz__uTs7v_PY3LeRZcvSjgDekgImyRg/edit) **Yönetilen Dosyalar** ve **Değişiklik Günlüğü** sekmelerini yalnızca doğrulanmış verilerle güncelle. Komut çalıştırılmadıysa veya sonuç bilinmiyorsa bunu açıkça belirt.

## B. Mevcut yönetilen dosyayı düzenleme

```bash
chezmoi edit "$HEDEF"
chezmoi status
chezmoi diff
chezmoi apply --dry-run --verbose
```

`chezmoi edit` kaynak kopyayı düzenler; hedef dosyayı hemen değiştirmez. Farkı onayladıktan sonra `chezmoi apply "$HEDEF"` hedefi değiştirebilir. Önce yedekleme ve uygulamanın çalışmasına etkisini değerlendir; ardından A bölümündeki Git kontrol, commit, push ve doğrulama adımlarını uygula.

**Hedef dosyayı chezmoi dışında değiştirdiysen:** `chezmoi diff` ile farkı incele; yerel değişikliği kaynak depoya almak istiyorsan `chezmoi re-add "$HEDEF"` seçeneğini değerlendir. Bu komutu mevcut kaynak içeriğini değiştirebileceği için önizleme/karşılaştırma olmadan kullanma.

## C. Tüm dizini eklemek (isteğe bağlı, daha riskli)

```bash
find "$HOME/.config/kitty" -maxdepth 2 -type f -print
```

Dosyaların her birini inceledikten ve tümünü yönetmek istediğine karar verdikten sonra:

```bash
chezmoi add --recursive "$HOME/.config/kitty"
```

Sonraki Git adımlarında bütün eklenen dosyaları **tek tek** kontrol et. Gizli bilgiler, önbellek, geçici dosyalar ve makineye özgü ayarlar bulunabilir.

## D. Hata olursa

- **Dosya bulunamadı:** Hedef yolu `ls -l` ile doğrula.
- **Chezmoi farkı boş:** `git status --short` ve `chezmoi source-path` ile kaynak dosyayı kontrol et.
- **Push reddedildi:** `git fetch origin`, `git status`, `git log --oneline --graph --decorate --all -n 15` ile farkı incele; körlemesine rebase/force yapma.
- **Yanlış dosya stage edildi:** Commit öncesi `git restore --staged -- DOSYA` ile yalnızca staging'den çıkar; dosya içeriği korunur.
- **Çakışma veya beklenmedik değişiklik:** İşlemi durdur; çıktıyı değerlendir, mevcut yapılandırmayı ezme.

## E. Her yeni dosya için kısa kontrol listesi

- [ ] Hedef dosya ve içeriği doğrulandı
- [ ] Gizli bilgi bulunmadığı kontrol edildi
- [ ] Chezmoi kaynak yolu doğrulandı
- [ ] `chezmoi status`, `diff`, dry-run incelendi
- [ ] Yalnızca ilgili dosya Git'e eklendi
- [ ] `git diff --cached` incelendi
- [ ] Commit ve push başarılı
- [ ] Uzak commit ve dosya GitHub'da doğrulandı
- [ ] Günlük ve gerekli Sheets kayıtları güncellendi

## Resmî kaynaklar

- [Chezmoi günlük işlemler](https://www.chezmoi.io/user-guide/daily-operations/)
- [Chezmoi komut referansı](https://www.chezmoi.io/reference/commands/)
- [Git belgeleri](https://git-scm.com/docs)
