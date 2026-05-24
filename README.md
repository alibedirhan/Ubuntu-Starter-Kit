# Ubuntu Starter Kit v1.0.4

Ubuntu Starter Kit, Ubuntu kurulumundan sonra sık kullanılan uygulamaları seçip kurmanıza yardımcı olan sade bir başlangıç asistanıdır.

Bu araç **Ubuntu App Center'ın yerine geçmez**. Amacı; yeni kullanıcıya anlaşılır bir seçim ekranı sunmak, uygulamaların hangi kaynaktan kurulacağını göstermek, kurulum aşamalarını terminalde görünür kılmak ve sonunda net bir rapor vermektir.

![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-orange.svg)
![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)
![GUI](https://img.shields.io/badge/GUI-Zenity-purple.svg)
![Version](https://img.shields.io/badge/version-1.0.3-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Ne yapar?

- Kullanıcı profiline göre uygulama önerir.
- Kategorilerden **boş liste**, **önerilenleri seç** veya **tümünü seç** akışı sunar.
- Tüm katalogdan manuel uygulama seçimi sunar.
- Seçim ekranlarında uygulamalar varsayılan olarak seçili gelmez; kullanıcı bilinçli seçim yapar.
- Kurulumdan önce hangi uygulamanın hangi kaynaktan kurulacağını gösterir.
- Kurulum sırasında terminalde daha temiz, kutulu ve okunaklı aşama çıktısı gösterir.
- APT ve Snap üzerinden kontrollü kurulum yapar.
- Sudo şifresini özel bir pencereyle toplamaz; terminalin standart sudo istemini kullanır.
- Kurulum sonucunu raporlar.
- Seçtiğiniz uygulama listesini kaydedip daha sonra tekrar kurabilir.

## Ne yapmaz?

- Rastgele internet sitesinden `.deb` indirmez.
- `curl | sudo bash` tarzı kök yetkili script çalıştırmaz.
- Tüm sistem paketlerini `dpkg --set-selections` ile geri yüklemez.
- Ubuntu App Center, apt veya snap yerine geçmez.

## Kurulum ve çalıştırma

```bash
git clone https://github.com/alibedirhan/Ubuntu-Starter-Kit.git
cd Ubuntu-Starter-Kit

bash scripts/check_static.sh
chmod +x ubuntu-starter.sh
./ubuntu-starter.sh
```

Eski dosya adını kullananlar için uyumluluk başlatıcısı da var:

```bash
./application-installer.sh
```

## Ana akış

1. Programı başlatın.
2. Profil, kategori veya tüm katalog seçimini açın.
3. Kategori akışında boş listeyle başlayın, önerilenleri seçili getirin veya tüm kategoriyi toplu seçin.
4. Kurulum kaynaklarını ve paket listesini onaylayın.
5. Terminalde sudo istenirse şifrenizi standart sudo istemine yazın.
6. Kurulum sırasında terminalde temiz aşama kartlarıyla hangi uygulamanın ne durumda olduğunu takip edin.
7. Kurulum raporunu inceleyin.

## Profiller

- Yeni kullanıcı
- Günlük kullanım
- Yazılımcı
- İçerik üretici
- Sistem araçları
- Oyun
- Minimal kurulum

## Kategoriler

- Günlük kullanım
- İletişim ve internet
- Medya ve içerik üretimi
- Geliştirici araçları
- Sistem araçları
- Oyun
- Flatpak desteği

## Kurulum kaynakları

| Kaynak | Kullanım |
|---|---|
| APT | Ubuntu depolarındaki güvenilir paketler |
| Snap | Snap ile dağıtılan son kullanıcı uygulamaları |
| Snap classic | Daha geniş sistem erişimi isteyen editörler; onay ekranında gösterilir |


## v1.0.4 notları

Bu sürümde seçim UX'i güvenli hale getirildi. Program listeleri varsayılan olarak boş açılır; kullanıcı isterse önerilenleri seçili getirebilir veya tümünü seçebilir. Zenity listelerinde uygulama adı, kaynak, seviye ve açıklama ayrı kolonlarda gösterilir. Kurulum öncesi özet APT, Snap ve dikkat gerektiren uygulamalar şeklinde daha net gruplanır.

## Loglar

Log dosyası şurada tutulur:

```text
~/.local/share/ubuntu-starter-kit/logs/ubuntu-starter-kit.log
```

Log paketi toplamak için:

```bash
bash scripts/collect_logs.sh
```

## Release kontrolü

```bash
bash scripts/check_static.sh
bash scripts/package_release.sh
```

## Güvenlik notu

Bu araç sisteminize paket kurar. Kurulumdan önce listelenen uygulamaları ve kaynakları inceleyin. Güvenmediğiniz bir scripti çalıştırmayın; bu proje de dahil olmak üzere her kurulum aracının yaptığı işlemleri okumanız önerilir.

## Dokümantasyon

- [Mimari](docs/ARCHITECTURE.md)
- [Güvenlik](docs/SECURITY.md)
- [Desteklenen uygulamalar](docs/SUPPORTED_APPS.md)
- [Kurulum mantığı denetimi](docs/INSTALLATION_LOGIC_AUDIT.md)
- [Video test listesi](docs/VIDEO_TEST_CHECKLIST.md)

## Lisans

MIT License. Detaylar için [LICENSE](LICENSE) dosyasına bakın.
