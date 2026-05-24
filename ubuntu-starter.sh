#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null)"
[[ -z "$VERSION" ]] && VERSION="1.0.4"

APP_ID="ubuntu-starter-kit"
APP_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/$APP_ID"
LOG_FILE="$APP_DATA_DIR/logs/ubuntu-starter-kit.log"

# shellcheck source=src/logger.sh
source "$SCRIPT_DIR/src/logger.sh"
# shellcheck source=src/ui_zenity.sh
source "$SCRIPT_DIR/src/ui_zenity.sh"
# shellcheck source=src/app_catalog.sh
source "$SCRIPT_DIR/src/app_catalog.sh"
# shellcheck source=src/system_check.sh
source "$SCRIPT_DIR/src/system_check.sh"
# shellcheck source=src/report.sh
source "$SCRIPT_DIR/src/report.sh"
# shellcheck source=src/install_runner.sh
source "$SCRIPT_DIR/src/install_runner.sh"
# shellcheck source=src/app_list_backup.sh
source "$SCRIPT_DIR/src/app_list_backup.sh"

ids_for_categories() {
    local categories="$1"
    local ids="" category cat_ids
    IFS='|' read -ra category_array <<< "$categories"
    for category in "${category_array[@]}"; do
        [[ -z "$category" ]] && continue
        cat_ids=$(catalog_ids_by_category "$category")
        ids+="$cat_ids"$'\n'
    done
    printf '%s\n' "$ids" | unique_lines
}

select_apps_by_profile() {
    local profile="$1"
    local ids selected preset
    ids=$(catalog_ids_by_tag "$profile" | unique_lines)
    if [[ -z "$ids" ]]; then
        ui_error "Bu profil için uygulama bulunamadı."
        return 1
    fi
    preset=$(ui_select_selection_preset "$(catalog_profile_title "$profile") Profili")
    [[ -z "$preset" ]] && return 0
    selected=$(ui_select_apps_by_ids "$(catalog_profile_title "$profile") Profili" "$ids" "$preset")
    [[ -z "$selected" ]] && return 0
    normalize_app_id_list "$selected"
}

select_apps_by_categories() {
    local categories="$1"
    local preset="${2:-empty}"
    local ids selected
    ids=$(ids_for_categories "$categories")
    if [[ -z "$ids" ]]; then
        ui_error "Seçilen kategoriler için uygulama bulunamadı."
        return 1
    fi
    selected=$(ui_select_apps_by_ids "Kategoriye Göre Uygulama Seçimi" "$ids" "$preset")
    [[ -z "$selected" ]] && return 0
    normalize_app_id_list "$selected"
}

select_all_apps() {
    local ids selected preset
    ids=$(catalog_all_ids | unique_lines)
    preset=$(ui_select_selection_preset "Tüm Uygulama Kataloğu")
    [[ -z "$preset" ]] && return 0
    selected=$(ui_select_apps_by_ids "Tüm Uygulama Kataloğu" "$ids" "$preset")
    [[ -z "$selected" ]] && return 0
    normalize_app_id_list "$selected"
}

handle_profile_flow() {
    local profile ids
    profile=$(ui_select_profile)
    [[ -z "$profile" ]] && return 0
    ids=$(select_apps_by_profile "$profile")
    [[ -z "$ids" ]] && return 0
    run_installation "$ids"
}

handle_category_flow() {
    local categories mode ids
    categories=$(ui_select_categories)
    [[ -z "$categories" ]] && return 0

    mode=$(ui_select_category_mode)
    [[ -z "$mode" ]] && return 0

    case "$mode" in
        all)
            ids=$(ids_for_categories "$categories")
            ;;
        select_empty)
            ids=$(select_apps_by_categories "$categories" "empty")
            ;;
        select_recommended)
            ids=$(select_apps_by_categories "$categories" "recommended")
            ;;
        *)
            ui_error "Bilinmeyen kategori seçim modu: $mode"
            return 1
            ;;
    esac

    [[ -z "$ids" ]] && return 0
    run_installation "$ids"
}

handle_all_apps_flow() {
    local ids
    ids=$(select_all_apps)
    [[ -z "$ids" ]] && return 0
    run_installation "$ids"
}

main() {
    ensure_not_root
    mkdir -p "$APP_DATA_DIR/logs"
    init_log
    log_info "Version: $VERSION"
    log_info "Catalog count: $(catalog_count)"
    ensure_zenity

    while true; do
        local choice
        choice=$(ui_main_menu)
        if [[ -z "$choice" ]]; then
            if ui_question "Programdan çıkmak istiyor musunuz?"; then
                log_info "Kullanıcı çıkış yaptı"
                exit 0
            fi
            continue
        fi

        case "$choice" in
            profile) handle_profile_flow ;;
            categories) handle_category_flow ;;
            all_apps) handle_all_apps_flow ;;
            app_list) manage_app_lists ;;
            show_log) ui_text_file "Ubuntu Starter Kit Log" "$LOG_FILE" ;;
            help) ui_help ;;
            exit)
                log_info "Program sonlandırıldı"
                exit 0
                ;;
            *)
                ui_error "Bilinmeyen işlem: $choice"
                ;;
        esac
    done
}

main "$@"
