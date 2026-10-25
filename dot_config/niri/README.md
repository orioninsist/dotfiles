
## 📚 Niri Yapılandırma Belgeleri

Niri yapılandırma dosyalarımın Türkçe açıklamaları, klavye kısayolları ve kullanım detayları `docs/` klasöründe düzenli olarak belgelenmektedir.

| Yapılandırma Dosyası | Açıklama |
|---|---|
| 📄 [config.kdl](docs/config.md) | Ana yapılandırma, monitörler, giriş aygıtları ve pencere kuralları |
| 🚀 [applications.kdl](docs/applications.md) | Uygulama başlatma, ekran görüntüsü ve sistem kısayolları |
| 🪟 [window-management.kdl](docs/window-management.md) | Pencere, sütun, boyutlandırma ve monitör yönetimi |
| 🗂️ [workspaces.kdl](docs/workspaces.md) | Çalışma alanları, geçişler ve taşıma kısayolları |

### 📖 Terminalde Belgeleri Görüntüleme

Belgeleri terminal üzerinden [Glow](https://github.com/charmbracelet/glow) ile etkileşimli olarak okuyabilirsiniz.

```bash
cd /home/murat/.config/niri/docs && glow
```

Bu komut `docs/` klasörüne geçer ve Glow arayüzünü açarak Markdown belgeleri arasında gezinmenizi sağlar.

> **Not:** Belgelerin asıl kaynağı `docs/` klasörüdür. Buradaki dosyalar güncellendiğinde README bağlantıları da otomatik olarak güncel içeriklere yönlenir. README dosyasını ayrıca düzenlemek gerekmez.
