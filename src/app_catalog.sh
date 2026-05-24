#!/usr/bin/env bash

# App catalog format:
# id|name|category|source|package|description|tags
# source: apt, snap, snap_classic
# categories: daily, communication, media, development, system, gaming, flatpak

APP_CATALOG_DATA=$(cat <<'CATALOG'
# Günlük kullanım
vlc|VLC Media Player|daily|apt|vlc|Video ve ses oynatıcı|beginner,daily,creator,recommended
libreoffice|LibreOffice|daily|apt|libreoffice|Ofis paketi|beginner,daily,office,recommended
thunderbird|Thunderbird|daily|apt|thunderbird|E-posta istemcisi|beginner,daily,office,recommended
evince|Document Viewer|daily|apt|evince|PDF ve belge görüntüleyici|beginner,daily,recommended
file-roller|Archive Manager|daily|apt|file-roller|Arşiv açma ve sıkıştırma aracı|beginner,daily,minimal,recommended
keepassxc|KeePassXC|daily|apt|keepassxc|Şifre kasası|beginner,daily,recommended
flameshot|Flameshot|daily|apt|flameshot|Ekran görüntüsü aracı|beginner,daily,creator,recommended
gnome-tweaks|GNOME Tweaks|daily|apt|gnome-tweaks|GNOME ince ayar aracı|daily,system
pavucontrol|PulseAudio Volume Control|daily|apt|pavucontrol|Ses giriş/çıkış kontrolü|beginner,daily,creator,recommended
transmission|Transmission|daily|apt|transmission|Torrent istemcisi|daily
qbittorrent|qBittorrent|daily|apt|qbittorrent|Gelişmiş torrent istemcisi|daily
simple-scan|Document Scanner|daily|apt|simple-scan|Tarayıcı uygulaması|beginner,daily,recommended

# İnternet ve iletişim
telegram|Telegram Desktop|communication|snap|telegram-desktop|Telegram masaüstü uygulaması|beginner,daily,communication,recommended
discord|Discord|communication|snap|discord|Sesli/yazılı iletişim|communication,creator,gaming
signal|Signal Desktop|communication|snap|signal-desktop|Güvenli mesajlaşma uygulaması|communication
filezilla|FileZilla|communication|apt|filezilla|FTP/SFTP istemcisi|daily,developer,communication,recommended
remmina|Remmina|communication|apt|remmina|Uzak masaüstü istemcisi|communication,system,developer,recommended
hexchat|HexChat|communication|apt|hexchat|IRC sohbet istemcisi|communication

# Medya ve içerik üretimi
obs|OBS Studio|media|apt|obs-studio|Ekran kaydı ve canlı yayın|creator,media,recommended
kdenlive|Kdenlive|media|apt|kdenlive|Video düzenleme|creator,media,recommended
gimp|GIMP|media|apt|gimp|Görsel düzenleme|creator,media,recommended
inkscape|Inkscape|media|apt|inkscape|Vektörel çizim aracı|creator,media,recommended
audacity|Audacity|media|apt|audacity|Ses düzenleme|creator,media,recommended
handbrake|HandBrake|media|apt|handbrake|Video dönüştürme|creator,media,recommended
blender|Blender|media|apt|blender|3D modelleme ve animasyon|creator,media
ffmpeg|FFmpeg|media|apt|ffmpeg|Medya dönüştürme altyapısı|creator,media,developer,recommended
imagemagick|ImageMagick|media|apt|imagemagick|Komut satırı görsel işleme|creator,media,developer
pinta|Pinta|media|apt|pinta|Basit görsel düzenleme|beginner,media,recommended

# Geliştirici araçları
git|Git|development|apt|git|Versiyon kontrol sistemi|developer,development,minimal,recommended
curl|curl|development|apt|curl|URL/HTTP aracı|developer,development,minimal,recommended
wget|wget|development|apt|wget|Dosya indirme aracı|developer,development,minimal,recommended
vim|Vim|development|apt|vim|Terminal metin editörü|developer,development,minimal,recommended
neovim|Neovim|development|apt|neovim|Modern terminal editörü|developer,development
build-essential|Build Essential|development|apt|build-essential|Derleme araçları|developer,development,recommended
make|Make|development|apt|make|Derleme otomasyon aracı|developer,development
cmake|CMake|development|apt|cmake|Çapraz platform derleme sistemi|developer,development
pkg-config|pkg-config|development|apt|pkg-config|Derleme bağımlılığı bulma aracı|developer,development
python3-pip|Python pip|development|apt|python3-pip|Python paket yöneticisi|developer,development,recommended
python3-venv|Python venv|development|apt|python3-venv|Python sanal ortam aracı|developer,development,recommended
pipx|pipx|development|apt|pipx|Python CLI uygulamalarını izole kurma|developer,development,recommended
nodejs|Node.js + npm|development|apt|nodejs npm|Ubuntu deposundan Node.js ve npm|developer,development,recommended
openjdk|OpenJDK|development|apt|default-jdk|Java geliştirme kiti|developer,development
vscode|Visual Studio Code|development|snap_classic|code|Kod editörü - Snap classic confinement|developer,development,recommended
gh|GitHub CLI|development|apt|gh|GitHub komut satırı aracı|developer,development
dbeaver|DBeaver CE|development|snap|dbeaver-ce|Veritabanı yönetim aracı|developer,development
postman|Postman|development|snap|postman|API test aracı|developer,development

# Sistem araçları
htop|htop|system|apt|htop|Sistem izleme|system,minimal,recommended
btop|btop|system|apt|btop|Modern sistem monitörü|system,recommended
fastfetch|Fastfetch|system|apt|fastfetch|Modern sistem bilgisi gösterimi|system,minimal,recommended
neofetch|Neofetch|system|apt|neofetch|Eski/nostaljik sistem bilgisi; modern alternatif Fastfetch|legacy,advanced
ncdu|ncdu|system|apt|ncdu|Disk kullanım analizi|system,minimal,recommended
duf|duf|system|apt|duf|Modern disk kullanım görüntüleyici|system
baobab|Disk Usage Analyzer|system|apt|baobab|Grafik disk kullanım analizi|beginner,system,recommended
zip|zip|system|apt|zip|ZIP arşiv oluşturma|system,minimal,recommended
unzip|unzip|system|apt|unzip|ZIP arşiv açıcı|system,minimal,recommended
tree|tree|system|apt|tree|Dizin ağacı gösterimi|system,minimal,recommended
gparted|GParted|system|apt|gparted|Disk bölümleme aracı|system,advanced
gufw|GUFW|system|apt|gufw|Grafik güvenlik duvarı aracı|beginner,system,recommended
ufw|UFW|system|apt|ufw|Komut satırı güvenlik duvarı|system
synaptic|Synaptic|system|apt|synaptic|Grafik paket yöneticisi|system
gnome-disk-utility|GNOME Disks|system|apt|gnome-disk-utility|Disk ve USB yönetimi|beginner,system,recommended
timeshift|Timeshift|system|apt|timeshift|Sistem geri yükleme aracı|system,advanced
bleachbit|BleachBit|system|apt|bleachbit|Temizlik aracı - dikkatli kullanılmalı|system,advanced

# Oyun ve eğlence
steam|Steam|gaming|apt|steam-installer|Steam oyun platformu|gaming,recommended
lutris|Lutris|gaming|apt|lutris|Linux oyun yöneticisi|gaming,recommended
heroic|Heroic Games Launcher|gaming|snap|heroic|Epic/GOG oyun başlatıcı|gaming
mangohud|MangoHud|gaming|apt|mangohud|Oyun performans göstergesi|gaming
gamemode|GameMode|gaming|apt|gamemode|Oyun performans iyileştirme servisi|gaming

# Flatpak hazırlığı
flatpak|Flatpak|flatpak|apt|flatpak|Flatpak altyapısı|flatpak,advanced
gnome-software-flatpak|GNOME Software Flatpak Plugin|flatpak|apt|gnome-software-plugin-flatpak|GNOME Software için Flatpak desteği|flatpak,advanced
CATALOG
)

catalog_rows() {
    printf '%s\n' "$APP_CATALOG_DATA" | awk 'NF && $0 !~ /^#/'
}

catalog_all_ids() {
    catalog_rows | awk -F'|' 'NF >= 7 {print $1}'
}

catalog_get_row() {
    local app_id="$1"
    catalog_rows | awk -F'|' -v id="$app_id" '$1 == id {print; exit}'
}

catalog_get_field() {
    local app_id="$1"
    local field_index="$2"
    local row
    row=$(catalog_get_row "$app_id")
    [[ -z "$row" ]] && return 1
    awk -F'|' -v idx="$field_index" '{print $idx}' <<< "$row"
}

catalog_name() { catalog_get_field "$1" 2; }
catalog_category() { catalog_get_field "$1" 3; }
catalog_source() { catalog_get_field "$1" 4; }
catalog_package() { catalog_get_field "$1" 5; }
catalog_description() { catalog_get_field "$1" 6; }
catalog_tags() { catalog_get_field "$1" 7; }

catalog_has_id() {
    [[ -n "$(catalog_get_row "$1")" ]]
}

catalog_ids_by_category() {
    local category="$1"
    catalog_rows | awk -F'|' -v cat="$category" '$3 == cat {print $1}'
}

catalog_ids_by_tag() {
    local tag="$1"
    catalog_rows | awk -F'|' -v tag="$tag" 'index("," $7 ",", "," tag ",") > 0 {print $1}'
}

catalog_category_title() {
    case "$1" in
        daily) echo "Günlük kullanım" ;;
        development) echo "Geliştirici araçları" ;;
        media) echo "Medya ve içerik" ;;
        system) echo "Sistem araçları" ;;
        communication) echo "İletişim" ;;
        gaming) echo "Oyun" ;;
        flatpak) echo "Flatpak desteği" ;;
        *) echo "$1" ;;
    esac
}

catalog_profile_title() {
    case "$1" in
        beginner) echo "Yeni kullanıcı" ;;
        daily) echo "Günlük kullanım" ;;
        developer) echo "Yazılımcı" ;;
        creator) echo "İçerik üretici" ;;
        system) echo "Sistem araçları" ;;
        gaming) echo "Oyun" ;;
        minimal) echo "Minimal" ;;
        *) echo "$1" ;;
    esac
}

catalog_risk_level() {
    local app_id="$1"
    local source tags
    source=$(catalog_source "$app_id")
    tags=$(catalog_tags "$app_id")

    if [[ ",${tags}," == *",legacy,"* ]]; then
        echo "Eski/nostaljik"
    elif [[ ",${tags}," == *",advanced,"* ]]; then
        echo "Dikkatli kullan"
    elif [[ "$source" == "snap_classic" ]]; then
        echo "Gelişmiş erişim"
    elif [[ "$source" == "snap" ]]; then
        echo "Snap"
    else
        echo "Güvenli"
    fi
}

catalog_is_recommended() {
    local app_id="$1"
    local tags
    tags=$(catalog_tags "$app_id")
    [[ ",${tags}," == *",recommended,"* ]]
}

catalog_ids_recommended_from_ids() {
    local ids="$1"
    local app_id
    while IFS= read -r app_id; do
        [[ -z "$app_id" ]] && continue
        catalog_has_id "$app_id" || continue
        if catalog_is_recommended "$app_id"; then
            echo "$app_id"
        fi
    done <<< "$ids" | unique_lines
}

catalog_zenity_desc() {
    local app_id="$1"
    local name desc source risk
    name=$(catalog_name "$app_id")
    desc=$(catalog_description "$app_id")
    source=$(catalog_source "$app_id")
    risk=$(catalog_risk_level "$app_id")
    printf '%s|%s|%s|%s' "$name" "$source" "$risk" "$desc"
}

unique_lines() {
    awk 'NF && !seen[$0]++'
}

normalize_app_id_list() {
    local raw="$1"
    printf '%s' "$raw" | tr '|' '\n' | sed '/^$/d' | unique_lines
}

source_display_name() {
    case "$1" in
        apt) echo "APT" ;;
        snap) echo "Snap" ;;
        snap_classic) echo "Snap classic" ;;
        *) echo "$1" ;;
    esac
}

selected_apps_summary() {
    local ids="$1"
    local app_id name source pkg desc risk summary=""
    local apt_section="" snap_section="" classic_section="" careful_section=""

    while IFS= read -r app_id; do
        [[ -z "$app_id" ]] && continue
        name=$(catalog_name "$app_id")
        source=$(catalog_source "$app_id")
        pkg=$(catalog_package "$app_id")
        desc=$(catalog_description "$app_id")
        risk=$(catalog_risk_level "$app_id")
        local line="• $name\n  Kaynak: $(source_display_name "$source") | Paket: $pkg | Seviye: $risk\n  $desc\n\n"

        case "$source" in
            apt) apt_section+="$line" ;;
            snap) snap_section+="$line" ;;
            snap_classic) classic_section+="$line" ;;
            *) careful_section+="$line" ;;
        esac

        if [[ "$risk" == "Dikkatli kullan" || "$risk" == "Eski/nostaljik" ]]; then
            careful_section+="$line"
        fi
    done <<< "$ids"

    [[ -n "$apt_section" ]] && summary+="APT ile kurulacaklar:\n$apt_section"
    [[ -n "$snap_section" ]] && summary+="Snap ile kurulacaklar:\n$snap_section"
    [[ -n "$classic_section" ]] && summary+="Snap classic / geniş erişim isteyenler:\n$classic_section"
    [[ -n "$careful_section" ]] && summary+="Dikkat gerektiren uygulamalar:\n$careful_section"
    printf '%b' "$summary"
}

catalog_count() {
    catalog_all_ids | wc -l | tr -d ' '
}
