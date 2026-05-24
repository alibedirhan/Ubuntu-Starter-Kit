#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

fail() { echo "[FAIL] $*" >&2; exit 1; }
ok() { echo "[OK] $*"; }

VERSION="$(tr -d '[:space:]' < VERSION)"
[[ -n "$VERSION" ]] || fail "VERSION boş"

printf '[1/13] Dosya yapısı\n'
for file in \
  ubuntu-starter.sh \
  application-installer.sh \
  VERSION \
  README.md \
  src/logger.sh \
  src/ui_zenity.sh \
  src/system_check.sh \
  src/app_catalog.sh \
  src/install_runner.sh \
  src/app_list_backup.sh \
  src/report.sh \
  docs/INSTALLATION_LOGIC_AUDIT.md; do
    [[ -f "$file" ]] || fail "Eksik dosya: $file"
done
ok "Dosya yapısı tamam"

printf '[2/13] Bash sözdizimi\n'
while IFS= read -r file; do
    bash -n "$file" || fail "Bash syntax hatası: $file"
done < <(find . -type f -name '*.sh' -not -path './release/*' -not -path './dist/*')
ok "Bash sözdizimi OK"

printf '[3/13] ShellCheck opsiyonel\n'
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck --severity=warning ubuntu-starter.sh application-installer.sh src/*.sh scripts/*.sh || fail "ShellCheck hata verdi"
    ok "ShellCheck OK"
else
    echo "[INFO] shellcheck bulunamadı, atlandı"
fi

printf '[4/13] Sürüm tutarlılığı\n'
grep -q "v$VERSION" README.md || fail "README içinde v$VERSION bulunamadı"
ok "Sürüm tutarlılığı OK"

printf '[5/13] Tehlikeli kalıp kontrolü\n'
if find . -type f -name '*.sh' -not -path './release/*' -not -path './dist/*' -not -path './scripts/check_static.sh' -print0 \
    | xargs -0 grep -InE 'curl .*\|.*sudo|wget .*\|.*sudo|zenity --password|sudo -S|dpkg --set-selections|dselect-upgrade'; then
    fail "Tehlikeli kurulum/parola/restore kalıbı bulundu"
fi
ok "Tehlikeli kalıp yok"

printf '[6/13] Kişisel isim sızıntısı\n'
if find . -type f -not -path './.git/*' -not -path './release/*' -not -path './dist/*' -not -path './scripts/check_static.sh' -print0 \
    | xargs -0 grep -InE 'mrgözlük|mr gözlük|deniz'; then
    fail "İstenmeyen kişisel isim bulundu"
fi
ok "Kişisel isim kontrolü OK"

printf '[7/13] Katalog bütünlüğü\n'
CATALOG_LINES="$(grep -E '^[a-z0-9_-]+\|' src/app_catalog.sh || true)"
[[ -n "$CATALOG_LINES" ]] || fail "Katalog satırı bulunamadı"
printf '%s\n' "$CATALOG_LINES" | awk -F'|' 'NF != 7 { print "Hatalı katalog satırı: " $0; exit 1 }' || fail "Katalog format hatası"
DUP_COUNT="$(printf '%s\n' "$CATALOG_LINES" | cut -d'|' -f1 | sort | uniq -d | wc -l | tr -d ' ')"
[[ "$DUP_COUNT" == "0" ]] || fail "Tekrarlanan app id var"
APP_COUNT="$(printf '%s\n' "$CATALOG_LINES" | wc -l | tr -d ' ')"
[[ "$APP_COUNT" -ge 60 ]] || fail "Katalog çok küçük: $APP_COUNT uygulama"
REC_COUNT="$(printf '%s\n' "$CATALOG_LINES" | grep -c 'recommended' || true)"
[[ "$REC_COUNT" -ge 25 ]] || fail "Önerilen uygulama sayısı düşük: $REC_COUNT"
ok "Katalog bütünlüğü OK ($APP_COUNT uygulama, $REC_COUNT önerilen)"

printf '[8/13] Seçim akışı kontrolü\n'
grep -q 'ui_select_category_mode' src/ui_zenity.sh || fail "Toplu/tek tek kategori seçim modu eksik"
grep -q 'ui_select_selection_preset' src/ui_zenity.sh || fail "Boş/önerilen/tümünü seç preset akışı eksik"
grep -q 'select_recommended' src/ui_zenity.sh || fail "Önerilenleri seçili getirme modu eksik"
grep -q 'all_apps' ubuntu-starter.sh || fail "Tüm katalog seçim akışı eksik"
grep -q 'ui_select_apps_by_ids' src/ui_zenity.sh || fail "Güvenli app seçim fonksiyonu eksik"
if grep -RIn 'mapfile -d' ubuntu-starter.sh src/*.sh; then
    fail "Null byte uyarısı üretebilecek mapfile -d kullanımı bulundu"
fi
ok "Seçim akışı OK"

printf '[9/13] Zenity seçim UX kontrolü\n'
grep -q 'FALSE "daily"' src/ui_zenity.sh || fail "Kategori checklist varsayılanı boş değil"
grep -q 'Boş listeyle aç' src/ui_zenity.sh || fail "Boş liste modu eksik"
grep -q 'Önerilenleri seçili getir' src/ui_zenity.sh || fail "Önerilen seçim modu eksik"
grep -q 'Tümünü seç' src/ui_zenity.sh || fail "Tümünü seç modu eksik"
grep -q 'column="Uygulama"' src/ui_zenity.sh || true
grep -q 'Uygulama' src/ui_zenity.sh || fail "Uygulama kolonu eksik"
grep -q 'Kaynak' src/ui_zenity.sh || fail "Kaynak kolonu eksik"
grep -q 'Seviye' src/ui_zenity.sh || fail "Seviye kolonu eksik"
grep -q 'catalog_is_recommended' src/app_catalog.sh || fail "Katalog önerilen fonksiyonu eksik"
grep -q 'catalog_risk_level' src/app_catalog.sh || fail "Katalog risk seviyesi fonksiyonu eksik"
ok "Zenity seçim UX OK"

printf '[10/13] Terminal kurulum aşaması kontrolü\n'
grep -q 'term_install_header' src/install_runner.sh || fail "Terminal kurulum başlığı eksik"
grep -q 'term_stage' src/install_runner.sh || fail "Terminal aşama çıktısı eksik"
grep -q '/dev/tty' src/install_runner.sh || fail "Terminale doğrudan aşama yazma desteği eksik"
ok "Terminal kurulum aşaması OK"


printf '[11/13] Terminal çıktı tasarımı kontrolü\n'
grep -q 'term_app_card_open' src/install_runner.sh || fail "Uygulama kurulum kartı çıktısı eksik"
grep -q 'term_compact_path' src/install_runner.sh || fail "Uzun log yolu kısaltma eksik"
grep -q 'is_apt_package_group_installed' src/install_runner.sh || fail "Çoklu APT paket kontrolü eksik"
grep -q '3/3 Rapor' src/install_runner.sh || fail "Aşamalı terminal rapor çıktısı eksik"
ok "Terminal çıktı tasarımı OK"

printf '[12/13] README link/repo kontrolü\n'
grep -q 'Ubuntu Starter Kit' README.md || fail "README ürün adı eksik"
grep -q 'INSTALLATION_LOGIC_AUDIT' README.md || fail "README kurulum mantığı denetimi dokümanını bağlamıyor"
if grep -RIn 'Tamindir\|Gezginler' README.md docs 2>/dev/null; then
    fail "README/docs içinde yanlış ürün benzetmesi var"
fi
ok "README kontrolü OK"

printf '[13/13] Release artığı kontrolü\n'
if find . -path './release' -prune -o -path './dist' -prune -o -path './logs' -prune -o -name '*.tmp' -o -name '*.bak' | grep -q .; then
    fail "Release dışı geçici dosya bulundu"
fi
ok "Release artığı yok"

echo "Statik kontrol tamamlandı."
