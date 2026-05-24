# Ubuntu Starter Kit v1.0.4 Kurulum Mantığı Denetimi

Bu doküman, v1.0.4 sürümünde yapılan mantık ve ürün denetimini özetler.

## Düzeltilenler

- Terminal kurulum çıktısı daha okunaklı, kutulu ve kısa satırlı hale getirildi.
- Uzun log yolları terminal satırını taşırmayacak şekilde kısaltıldı.
- APT ile birden fazla paket kuran uygulamalarda yalnızca ilk pakete bakıp "zaten kurulu" deme riski giderildi.
- Kurulum çıktısı üç aşamaya ayrıldı: sistem kontrolü, uygulama kurulumu, rapor.
- Her uygulama için kaynak, paket ve durum ayrı gösterilir.
- Neofetch katalogda tutuldu ama eski/nostaljik araç olarak işaretlendi; modern öneri Fastfetch'tir.

## Bilerek korunmuş kararlar

- Zenity seçim ve rapor için kullanılır; sudo şifresi Zenity içinde alınmaz.
- Dış web sitesinden rastgele `.deb` indirme yoktur.
- `curl | sudo bash` veya `dpkg --set-selections` gibi riskli kalıplar kullanılmaz.
- Paket listesi geri yükleme, tüm sistemi değil sadece katalogdaki uygulama ID'lerini işler.

## Dikkat edilmesi gereken paketler

Bazı uygulamalar Ubuntu sürümüne, etkin depolara veya Snap kullanılabilirliğine göre farklı davranabilir:

- Steam: Ubuntu depolarında multiverse/steam-installer durumuna bağlı olabilir.
- VS Code: Snap classic confinement kullanır; onay ekranında kaynak gösterilir.
- Signal/Discord/Telegram gibi uygulamalar Snap kaynağına bağlıdır.
- Timeshift, BleachBit, GParted gibi araçlar gelişmiş/dikkatli kullanım sınıfındadır.

## Sonraki iyileştirme fikirleri

- Kurulumdan önce paket kullanılabilirliği için opsiyonel `apt-cache policy` / `snap info` ön kontrolü.
- Katalogda uygulama seviyesi: önerilen, isteğe bağlı, gelişmiş, eski.
- Flatpak desteği ayrı ve açık onaylı bir hazırlık akışı olarak daha detaylı sunulabilir.


## v1.0.4 selection-polish

- Uygulama seçim listeleri varsayılan olarak boş açılır.
- Önerilenleri seçili getir ve tümünü seç akışları eklendi.
- Zenity listelerinde uygulama adı, kaynak, seviye ve açıklama ayrı kolonlarda gösterilir.
- Kurulum öncesi özet kaynak ve risk seviyesine göre gruplanır.
