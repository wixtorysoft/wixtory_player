# Wixtory Player — Yerel Medya & Sonsuz TikTok Akış Oynatıcısı

**Wixtory Player**, telefonunuzdaki yerel MP3 müzik ve MP4 video dosyalarını TikTok / Reels benzeri dikey, akıcı ve sonsuz döngülü bir akışta birleştiren yeni nesil bir medya oynatıcıdır. Tamamen çevrimdışı çalışır, sıfır bulut transferi sağlar ve dosyalarınız sadece cihazınızda kalır (%100 Cihaz İçi Gizlilik).

---

## 🚀 Öne Çıkan Özellikler

### 1. 📱 Tam Ekran Dikey Kaydırma (TikTok / Reels UX)
- **Akıcı Dikey Sayfalama (`PageView.builder`):** Medyalar arasında yukarı-aşağı kaydırarak akıcı geçiş.
- **Otomatik Oynatma & Akıllı Kaynak Yönetimi:** Ekranda aktif olan video/müzik oynatılır, kaydırılıp ekrandan çıkan önceki medya anında duraklatılır ve bellek korunur.
- **Döngüsel Oynatma (`Looping`):** Medya bittiğinde otomatik olarak başa sarar veya sonraki parçaya geçer.

### 2. 🎵 MP3 & MP4 Tam Format Desteği
- Yerel MP3 ses dosyaları için analog vinil plak animasyonu ve frekans dalgaları.
- MP4 video dosyaları için orijinal en-boy oranını koruyan genişletilmiş tam ekran gösterimi (`BoxFit.contain` / `BoxFit.cover`).

### 3. 📂 Gelişmiş Medya İçe Aktarma & Yükleme Önizleyicisi (Preloader HUD)
- Cihaz hafızasından tek seferde 20, 30 veya daha fazla MP3/MP4 seçildiğinde ekranda beliren şık buzlu cam (glassmorphism) yükleme animasyonu.
- Dosya işleme sürecini anlık sayaç ile takip edebilme.

### 4. 🌐 Çok Dilli Mimari (i18n)
- 5 farklı dilde tam yerelleştirme:
  - 🇹🇷 Türkçe (`tr`)
  - 🇬🇧 English (`en`)
  - 🇩🇪 Deutsch (`de`)
  - 🇮🇹 Italiano (`it`)
  - 🇫🇷 Français (`fr`)
- Ayarlar ekranından anında dil değiştirme ve kalıcı tercih kaydı (`SharedPreferences`).

### 5. ⚙️ Ayarlar Ekranı & Sağdan Sola Geçiş Animasyonu
- Sağ üstteki ayarlar ikonu ile açılan sağdan sola kayma animasyonlu kontrol paneli.
- Uygulama hakkında bilgisi, sürüm detayları ve %100 yerel gizlilik taahhüdü.
- Yerel medya önbelleği sıfırlama seçeneği.

### 6. 🎛️ Zengin Kontroller & Çalma Listeleri
- Hız kontrolü (0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 2.0x).
- Özel ses kaydırma çubuğu (Volume HUD) ve anında sessize alma (`Mute`).
- Özelleştirilebilir çalma listeleri oluşturma, yeniden adlandırma ve yönetme.

---

## 📁 Proje Dizin Yapısı

```
wixtory_player/
├── lib/
│   ├── localization/
│   │   └── app_strings.dart           # 5 dilli tip güvenli i18n çeviri sözlüğü
│   ├── models/
│   │   ├── playlist_model.dart        # Çalma listesi modeli
│   │   └── video_item.dart            # MP3 / MP4 medya modeli
│   ├── screens/
│   │   ├── settings_screen.dart       # Ayarlar, dil seçimi & hakkında ekranı
│   │   └── tiktok_feed_screen.dart    # Ana sonsuz dikey akış ekranı
│   ├── services/
│   │   └── playlist_service.dart      # SharedPreferences kalıcı depolama servisi
│   ├── state/
│   │   └── video_feed_provider.dart   # ChangeNotifier durum yöneticisi
│   ├── theme/
│   │   ├── app_colors.dart            # Koyu tema, siber camgöbeği & neon kırmızı
│   │   └── app_theme.dart             # Plus Jakarta Sans tipografi & koyu tema
│   └── widgets/
│       ├── media_importing_hud.dart   # Çoklu dosya yükleme buzlu cam spinner HUD
│       ├── playlist_manager_sheet.dart# Çalma listesi yönetim sayfası
│       ├── tiktok_actions_bar.dart    # Sağ kenar kontrol butonları
│       ├── tiktok_bottom_info.dart    # Alt medya bilgisi paneli
│       ├── video_library_sheet.dart   # Kütüphane listesi
│       ├── video_player_item.dart     # Video/ses oynatıcı bileşeni
│       └── volume_slider_hud.dart     # Ses seviyesi kaydırıcı göstergesi
└── main.dart                          # Uygulama başlangıcı
```
