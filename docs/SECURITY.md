# Güvenlik

Bu araç sisteminize paket kurar. Bu nedenle güvenlik ve şeffaflık önceliklidir.

## Bilerek yapılmayanlar

- `curl | sudo bash` kullanılmaz.
- Zenity ile sudo şifresi toplanmaz.
- Tüm sistem paketleri `dpkg --set-selections` ile geri yüklenmez.
- Kullanıcının seçmediği uygulamalar sessizce kurulmaz.

## Sudo davranışı

Kurulum gerektiğinde standart terminal sudo istemi kullanılır. Bu, kullanıcı için daha güvenilir ve Linux davranışına daha uygundur.

## Snap classic

Bazı uygulamalar Snap classic confinement gerektirebilir. Bu uygulamalar kurulum onay ekranında kaynak olarak görünür.

## Loglar

Loglar yerelde tutulur:

```text
~/.local/share/ubuntu-starter-kit/logs/ubuntu-starter-kit.log
```

Loglar otomatik olarak herhangi bir sunucuya gönderilmez.
