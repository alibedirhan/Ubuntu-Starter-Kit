#!/usr/bin/env bash

LAST_SELECTION_FILE="$APP_DATA_DIR/last-selection.usk-list"

save_last_selection() {
    local ids="$1"
    mkdir -p "$APP_DATA_DIR"
    {
        echo "# Ubuntu Starter Kit app list"
        echo "# version=$VERSION"
        echo "# created_at=$(date --iso-8601=seconds)"
        printf '%s\n' "$ids" | sed '/^$/d'
    } > "$LAST_SELECTION_FILE"
    log_info "Son seçim listesi kaydedildi: $LAST_SELECTION_FILE"
}

save_selection_as_file() {
    if [[ ! -f "$LAST_SELECTION_FILE" ]]; then
        ui_info "Henüz kaydedilecek son seçim bulunmuyor. Önce uygulama seçip kurulum akışını başlatın."
        return 0
    fi

    local target
    target=$(ui_save_file "$HOME/ubuntu-starter-list-$(date +%Y%m%d).usk-list")
    [[ -z "$target" ]] && return 0
    cp "$LAST_SELECTION_FILE" "$target"
    ui_info "Kurulum listesi kaydedildi:\n$target"
}

read_app_list_file() {
    local file="$1"
    grep -v '^#' "$file" | sed '/^$/d' | while IFS= read -r app_id; do
        if catalog_has_id "$app_id"; then
            echo "$app_id"
        else
            log_warn "Katalogda olmayan uygulama atlandı: $app_id"
        fi
    done | unique_lines
}

restore_from_app_list() {
    local file
    file=$(ui_open_file)
    [[ -z "$file" ]] && return 0
    if [[ ! -f "$file" ]]; then
        ui_error "Liste dosyası bulunamadı."
        return 1
    fi

    local ids
    ids=$(read_app_list_file "$file")
    if [[ -z "$ids" ]]; then
        ui_error "Bu listede kurulabilecek katalog uygulaması bulunamadı."
        return 1
    fi

    run_installation "$ids"
}

manage_app_lists() {
    local choice
    choice=$(zenity --list \
        --title="Kurulum Listesi" \
        --text="Kurulum listeleri sadece Ubuntu Starter Kit kataloğundaki uygulamaları içerir. Tüm sistem paketlerini geri yüklemez." \
        --radiolist \
        --column="Seç" \
        --column="İşlem" \
        --column="Açıklama" \
        --width=780 \
        --height=340 \
        TRUE "save_last" "Son seçimi dosyaya kaydet" \
        FALSE "restore" "Kaydedilmiş listeden uygulama kur" \
        FALSE "show_last" "Son seçim listesini görüntüle" \
        FALSE "back" "Ana menüye dön" 2>/dev/null)

    case "$choice" in
        save_last) save_selection_as_file ;;
        restore) restore_from_app_list ;;
        show_last) ui_text_file "Son Seçim" "$LAST_SELECTION_FILE" ;;
        *) return 0 ;;
    esac
}
