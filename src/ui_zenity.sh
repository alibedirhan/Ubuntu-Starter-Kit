#!/usr/bin/env bash

# Zenity UI helpers. Keep all user-facing dialogs here so the CLI/business logic
# stays maintainable and testable.

UI_WIDTH=900
UI_HEIGHT=560

ui_error() {
    local text="$1"
    log_error "$text"
    zenity --error --title="Ubuntu Starter Kit" --width=520 --text="$text" 2>/dev/null || true
}

ui_info() {
    local text="$1"
    log_info "$text"
    zenity --info --title="Ubuntu Starter Kit" --width=620 --text="$text" 2>/dev/null || true
}

ui_question() {
    local text="$1"
    zenity --question --title="Ubuntu Starter Kit" --width=700 --text="$text" 2>/dev/null
}

ui_text_file() {
    local title="$1"
    local file="$2"
    if [[ -f "$file" ]]; then
        zenity --text-info --title="$title" --filename="$file" --width=920 --height=680 2>/dev/null || true
    else
        ui_info "Gösterilecek dosya bulunamadı:\n$file"
    fi
}

ui_main_menu() {
    zenity --list \
        --title="Ubuntu Starter Kit v$VERSION" \
        --text="Ubuntu kurulum sonrası uygulama seçimi ve güvenli kurulum asistanı." \
        --radiolist \
        --column="Seç" \
        --column="İşlem" \
        --column="Açıklama" \
        --ok-label="Devam" \
        --cancel-label="Çıkış" \
        --width=860 \
        --height=470 \
        TRUE "profile" "Profil seç: yeni kullanıcı, yazılımcı, içerik üretici" \
        FALSE "categories" "Kategori seç: tek tek, önerilen veya tüm kategori" \
        FALSE "all_apps" "Tüm katalog: uygulamaları elle seç" \
        FALSE "app_list" "Liste: seçimi kaydet veya kaydedilmiş listeyi kur" \
        FALSE "show_log" "Log dosyasını görüntüle" \
        FALSE "help" "Yardım ve güvenlik notları" \
        FALSE "exit" "Çıkış" 2>/dev/null
}

ui_select_profile() {
    zenity --list \
        --title="Kullanıcı Profili" \
        --text="Hazır profiller sadece başlangıç önerisidir. Sonraki ekranda uygulamaları yine düzenleyebilirsiniz." \
        --radiolist \
        --column="Seç" \
        --column="Profil" \
        --column="Açıklama" \
        --ok-label="Profil seç" \
        --cancel-label="Geri" \
        --width=860 \
        --height=500 \
        TRUE "beginner" "Yeni kullanıcı: güvenli temel uygulamalar" \
        FALSE "daily" "Günlük kullanım: ofis, medya, iletişim" \
        FALSE "developer" "Yazılımcı: geliştirme araçları" \
        FALSE "creator" "İçerik üretici: video/ses/görsel araçları" \
        FALSE "system" "Sistem araçları: bakım ve izleme" \
        FALSE "gaming" "Oyun: Steam/Lutris ve oyun yardımcıları" \
        FALSE "minimal" "Minimal: sadece temel yardımcılar" 2>/dev/null
}

ui_select_categories() {
    zenity --list \
        --title="Kategori Seçimi" \
        --text="Kategori seçin. Bir sonraki ekranda boş liste, önerilenler veya tüm kategori seçeneklerinden birini seçebilirsiniz." \
        --checklist \
        --column="Seç" \
        --column="Kategori" \
        --column="Açıklama" \
        --separator="|" \
        --ok-label="Kategori seç" \
        --cancel-label="Geri" \
        --width=860 \
        --height=520 \
        FALSE "daily" "Günlük kullanım" \
        FALSE "development" "Geliştirici araçları" \
        FALSE "media" "Medya ve içerik" \
        FALSE "communication" "İletişim ve internet" \
        FALSE "system" "Sistem araçları" \
        FALSE "gaming" "Oyun" \
        FALSE "flatpak" "Flatpak desteği" 2>/dev/null
}

ui_select_selection_preset() {
    local title="$1"
    zenity --list \
        --title="$title" \
        --text="Seçim ekranı nasıl açılsın? Güvenli varsayılan boş listedir." \
        --radiolist \
        --column="Seç" \
        --column="Mod" \
        --column="Açıklama" \
        --ok-label="Devam" \
        --cancel-label="Geri" \
        --width=820 \
        --height=360 \
        TRUE "empty" "Boş listeyle aç - hiçbir uygulama seçili gelmez" \
        FALSE "recommended" "Önerilenleri seçili getir - yine düzenleyebilirsiniz" \
        FALSE "all" "Tümünü seç - listedeki her şeyi seçili getir" 2>/dev/null
}

ui_select_category_mode() {
    zenity --list \
        --title="Kategori Kurulum Şekli" \
        --text="Seçtiğiniz kategoriler için nasıl ilerlemek istiyorsunuz?" \
        --radiolist \
        --column="Seç" \
        --column="Mod" \
        --column="Açıklama" \
        --ok-label="Devam" \
        --cancel-label="Geri" \
        --width=860 \
        --height=390 \
        TRUE "select_empty" "Tek tek seçim: boş listeyle aç" \
        FALSE "select_recommended" "Önerilenleri seçili getir, sonra düzenle" \
        FALSE "all" "Toplu seçim: seçili kategorilerdeki tüm uygulamaları kur" 2>/dev/null
}

ui_select_apps_by_ids() {
    local title="$1"
    local ids="$2"
    local preset="${3:-empty}"
    local zenity_args=()
    local app_id selected name source risk desc desc_fields

    while IFS= read -r app_id; do
        [[ -z "$app_id" ]] && continue
        catalog_has_id "$app_id" || continue
        selected="FALSE"
        case "$preset" in
            all) selected="TRUE" ;;
            recommended)
                if catalog_is_recommended "$app_id"; then
                    selected="TRUE"
                fi
                ;;
            empty|*) selected="FALSE" ;;
        esac
        IFS='|' read -r name source risk desc <<< "$(catalog_zenity_desc "$app_id")"
        zenity_args+=("$selected" "$app_id" "$name" "$(source_display_name "$source")" "$risk" "$desc")
    done <<< "$ids"

    if [[ ${#zenity_args[@]} -eq 0 ]]; then
        ui_error "Seçilecek uygulama bulunamadı."
        return 1
    fi

    zenity --list \
        --title="$title" \
        --text="Uygulamaları seçin. Hiçbir şey kurulumdan önce onay ekranı gösterilmeden kurulmaz." \
        --checklist \
        --column="Seç" \
        --column="ID" \
        --column="Uygulama" \
        --column="Kaynak" \
        --column="Seviye" \
        --column="Açıklama" \
        --separator="|" \
        --ok-label="Seçimi onayla" \
        --cancel-label="Geri" \
        --width=1120 \
        --height=700 \
        "${zenity_args[@]}" 2>/dev/null
}

ui_progress_install() {
    local title="$1"
    zenity --progress --title="$title" --text="Başlatılıyor..." --width=640 --auto-close --no-cancel 2>/dev/null
}

ui_save_file() {
    local default_file="$1"
    zenity --file-selection --save --confirm-overwrite --title="Kurulum listesini kaydet" --filename="$default_file" 2>/dev/null
}

ui_open_file() {
    zenity --file-selection --title="Kurulum listesi seç" --file-filter="Ubuntu Starter Kit listeleri | *.usk-list *.txt" 2>/dev/null
}

ui_help() {
    zenity --info \
        --title="Ubuntu Starter Kit - Yardım" \
        --width=800 \
        --height=650 \
        --text="Ubuntu Starter Kit, Ubuntu kurulumundan sonra sık kullanılan uygulamaları seçip kurmanıza yardımcı olur.\n\nBu araç App Center'ın yerine geçmez. Seçilmiş uygulamaları kategorilere ayırır, kurulum kaynağını gösterir ve işlemleri daha anlaşılır hale getirir.\n\nSeçim ekranları:\n• Varsayılan olarak uygulamalar seçili gelmez.\n• İsterseniz önerilenleri seçili getirebilir veya tümünü seçebilirsiniz.\n• Kurulumdan önce kaynak ve paket özeti gösterilir.\n\nKurulum sırasında:\n• Terminal penceresinde aşamalar görünür.\n• Zenity ilerleme penceresi genel durumu gösterir.\n• Ayrıntılı çıktı log dosyasına yazılır.\n\nGüvenlik notları:\n• Sudo şifresi özel Zenity penceresinde istenmez.\n• APT/Snap kaynakları onay ekranında gösterilir.\n• Kaydedilen listeler sadece katalog uygulamalarını içerir; tüm sistemi geri yüklemez.\n\nLog konumu:\n$LOG_FILE" 2>/dev/null || true
}
