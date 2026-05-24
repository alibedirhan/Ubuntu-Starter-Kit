# Mimari

Ubuntu Starter Kit, tek parça büyük bir kurulum scripti yerine küçük modüllere ayrılmıştır.

```text
ubuntu-starter.sh
application-installer.sh
VERSION
src/
  logger.sh
  ui_zenity.sh
  system_check.sh
  app_catalog.sh
  install_runner.sh
  app_list_backup.sh
  report.sh
scripts/
  check_static.sh
  collect_logs.sh
  package_release.sh
```

Temel prensipler:

- UI katmanı `src/ui_zenity.sh` içinde kalır.
- Uygulama kataloğu `src/app_catalog.sh` içinde merkezi yönetilir.
- Kurulum işlemleri `src/install_runner.sh` içinde yürür.
- Katalogdan seçim toplu veya tek tek yapılabilir.
- Kurulum aşamaları terminale yazılır; Zenity sadece genel ilerleme penceresi sağlar.
- Sudo şifresi Zenity ile toplanmaz; terminalin standart sudo istemi kullanılır.
- Geri yükleme sistemi tüm dpkg paketlerini değil, sadece katalogdaki uygulama ID'lerini işler.


## v1.0.3 selection-polish

- Uygulama seçim listeleri varsayılan olarak boş açılır.
- Önerilenleri seçili getir ve tümünü seç akışları eklendi.
- Zenity listelerinde uygulama adı, kaynak, seviye ve açıklama ayrı kolonlarda gösterilir.
- Kurulum öncesi özet kaynak ve risk seviyesine göre gruplanır.
