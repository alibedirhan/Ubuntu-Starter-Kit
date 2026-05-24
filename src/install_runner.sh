#!/usr/bin/env bash

APT_UPDATED=false

# Terminal output policy:
# - Zenity remains the selection/progress UI.
# - The terminal shows a compact, stable, video-friendly install trace.
# - Lines are intentionally kept <= 72 columns to avoid wrapping in common terminals.

TERM_WIDTH=72

supports_color() {
    [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]
}

if supports_color; then
    C_RESET=$'\033[0m'
    C_DIM=$'\033[2m'
    C_BOLD=$'\033[1m'
    C_GREEN=$'\033[0;32m'
    C_YELLOW=$'\033[1;33m'
    C_RED=$'\033[0;31m'
    C_CYAN=$'\033[0;36m'
    C_BLUE=$'\033[0;34m'
else
    C_RESET=""; C_DIM=""; C_BOLD=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_CYAN=""; C_BLUE=""
fi

term_print() {
    # Prefer the real terminal when available, but never fail in non-interactive checks.
    if [[ -e /dev/tty ]]; then
        { printf '%b\n' "$*" > /dev/tty; } 2>/dev/null && return 0
    fi
    printf '%b\n' "$*"
}

term_hr() {
    term_print "${C_DIM}────────────────────────────────────────────────────────────${C_RESET}"
}

term_compact_path() {
    local path="$1"
    path="${path/#$HOME/~}"
    if [[ ${#path} -le 58 ]]; then
        printf '%s' "$path"
    else
        printf '%s' "${path:0:24}…${path: -29}"
    fi
}

term_box_open() {
    local title="$1"
    term_print "${C_CYAN}╭─ ${C_BOLD}${title}${C_RESET}${C_CYAN} ─────────────────────────────────────────╮${C_RESET}"
}

term_box_close() {
    term_print "${C_CYAN}╰────────────────────────────────────────────────────────────╯${C_RESET}"
}

term_kv() {
    local key="$1" value="$2"
    term_print "${C_CYAN}│${C_RESET} ${C_DIM}${key}${C_RESET}: ${value}"
}

term_source_label() {
    case "$1" in
        apt) printf 'APT' ;;
        snap) printf 'Snap' ;;
        snap_classic) printf 'Snap classic' ;;
        *) printf '%s' "$1" ;;
    esac
}

term_install_header() {
    local ids="$1"
    local total compact_log
    total=$(printf '%s\n' "$ids" | sed '/^$/d' | wc -l | tr -d ' ')
    compact_log=$(term_compact_path "$LOG_FILE")

    term_print ""
    term_box_open "Ubuntu Starter Kit"
    term_kv "Seçilen" "$total uygulama"
    term_kv "Log" "$compact_log"
    term_kv "Mod" "Zenity seçim + terminal kurulum izlemesi"
    term_box_close
    term_print ""
}

term_install_plan() {
    local ids="$1"
    local app_id idx=0 name source pkg desc source_label
    term_print "${C_BOLD}${C_BLUE}Kurulum planı${C_RESET}"
    term_hr
    while IFS= read -r app_id; do
        [[ -z "$app_id" ]] && continue
        idx=$((idx + 1))
        name=$(catalog_name "$app_id")
        source=$(catalog_source "$app_id")
        pkg=$(catalog_package "$app_id")
        desc=$(catalog_description "$app_id")
        source_label=$(term_source_label "$source")
        term_print "${C_BOLD}[$idx] $name${C_RESET}"
        term_print "    ${C_DIM}Kaynak:${C_RESET} $source_label   ${C_DIM}Paket:${C_RESET} $pkg"
        term_print "    ${C_DIM}${desc}${C_RESET}"
    done <<< "$ids"
    term_hr
    term_print ""
}

term_phase() {
    local title="$1"
    term_print ""
    term_print "${C_CYAN}▶ ${C_BOLD}${title}${C_RESET}"
}

term_stage() {
    term_print "${C_CYAN}  ›${C_RESET} $*"
}

term_success() {
    term_print "${C_GREEN}  ✓${C_RESET} $*"
}

term_skip() {
    term_print "${C_YELLOW}  ↷${C_RESET} $*"
}

term_error() {
    term_print "${C_RED}  ✗${C_RESET} $*"
}

term_app_card_open() {
    local idx="$1" total="$2" name="$3"
    term_print ""
    term_print "${C_CYAN}╭─ ${C_BOLD}[$idx/$total] $name${C_RESET}${C_CYAN} ───────────────────────────────────────╮${C_RESET}"
}

term_app_card_close() {
    term_print "${C_CYAN}╰────────────────────────────────────────────────────────────╯${C_RESET}"
}

apt_update_once() {
    if [[ "$APT_UPDATED" == true ]]; then
        term_skip "APT paket listesi zaten güncellendi"
        return 0
    fi
    log_info "APT update çalışıyor"
    term_stage "APT paket listesi güncelleniyor"
    if sudo apt-get update >> "$LOG_FILE" 2>&1; then
        APT_UPDATED=true
        term_success "APT paket listesi güncellendi"
        return 0
    fi
    term_error "APT update başarısız. Ayrıntı log dosyasında."
    return 1
}

is_apt_package_group_installed() {
    local pkg_group="$1"
    local pkg
    for pkg in $pkg_group; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            return 1
        fi
    done
    return 0
}

is_installed() {
    local app_id="$1"
    local source pkg
    source=$(catalog_source "$app_id")
    pkg=$(catalog_package "$app_id")

    case "$source" in
        apt)
            is_apt_package_group_installed "$pkg"
            ;;
        snap|snap_classic)
            snap list 2>/dev/null | awk '{print $1}' | grep -qx "$pkg"
            ;;
        *)
            return 1
            ;;
    esac
}

install_apt_app() {
    local app_id="$1"
    local pkg
    pkg=$(catalog_package "$app_id")
    apt_update_once || return 1
    term_stage "APT kurulumu: $pkg"
    # shellcheck disable=SC2086
    sudo apt-get install -y $pkg >> "$LOG_FILE" 2>&1
}

install_snap_app() {
    local app_id="$1"
    local source pkg
    source=$(catalog_source "$app_id")
    pkg=$(catalog_package "$app_id")

    if ! command -v snap >/dev/null 2>&1; then
        log_warn "snapd bulunamadı, apt ile kurulmaya çalışılacak"
        term_stage "snapd bulunamadı; snap desteği kuruluyor"
        apt_update_once || return 1
        sudo apt-get install -y snapd >> "$LOG_FILE" 2>&1 || return 1
    fi

    if [[ "$source" == "snap_classic" ]]; then
        term_stage "Snap classic kurulumu: $pkg"
        sudo snap install "$pkg" --classic >> "$LOG_FILE" 2>&1
    else
        term_stage "Snap kurulumu: $pkg"
        sudo snap install "$pkg" >> "$LOG_FILE" 2>&1
    fi
}

install_one_app() {
    local app_id="$1"
    local name source pkg source_label
    name=$(catalog_name "$app_id")
    source=$(catalog_source "$app_id")
    pkg=$(catalog_package "$app_id")
    source_label=$(term_source_label "$source")

    term_kv "Kaynak" "$source_label"
    term_kv "Paket" "$pkg"

    if is_installed "$app_id"; then
        log_info "$name zaten kurulu"
        term_kv "Durum" "${C_YELLOW}Zaten kurulu${C_RESET}"
        printf 'SKIP|%s|Zaten kurulu\n' "$app_id"
        return 0
    fi

    log_info "Kuruluyor: $name ($source)"
    case "$source" in
        apt)
            if install_apt_app "$app_id"; then
                log_success "$name kuruldu"
                term_kv "Durum" "${C_GREEN}Kuruldu${C_RESET}"
                printf 'SUCCESS|%s|Kuruldu\n' "$app_id"
                return 0
            fi
            ;;
        snap|snap_classic)
            if install_snap_app "$app_id"; then
                log_success "$name kuruldu"
                term_kv "Durum" "${C_GREEN}Kuruldu${C_RESET}"
                printf 'SUCCESS|%s|Kuruldu\n' "$app_id"
                return 0
            fi
            ;;
    esac

    log_error "$name kurulamadı"
    term_kv "Durum" "${C_RED}Kurulamadı${C_RESET} - ayrıntı log dosyasında"
    printf 'ERROR|%s|Kurulamadı\n' "$app_id"
    return 1
}

classic_snap_warning_needed() {
    local ids="$1"
    local app_id source
    while IFS= read -r app_id; do
        [[ -z "$app_id" ]] && continue
        source=$(catalog_source "$app_id")
        [[ "$source" == "snap_classic" ]] && return 0
    done <<< "$ids"
    return 1
}

advanced_warning_needed() {
    local ids="$1"
    local app_id tags
    while IFS= read -r app_id; do
        [[ -z "$app_id" ]] && continue
        tags=$(catalog_tags "$app_id")
        [[ ",${tags}," == *",advanced,"* || ",${tags}," == *",legacy,"* ]] && return 0
    done <<< "$ids"
    return 1
}

confirm_installation_plan() {
    local ids="$1"
    local summary
    summary=$(selected_apps_summary "$ids")

    if classic_snap_warning_needed "$ids"; then
        summary+="\nDikkat: Listede snap classic confinement kullanan uygulama var. Bu uygulamalar sistemle daha geniş erişimle çalışabilir.\n"
    fi

    if advanced_warning_needed "$ids"; then
        summary+="\nDikkat: Listede gelişmiş/eski/dikkatli kullanılması gereken araçlar var. Ne kurduğunuzu kontrol edin.\n"
    fi

    ui_question "Kurulacak uygulamalar:\n\n$summary\nDevam edilsin mi?"
}

run_installation() {
    local ids="$1"
    local total
    total=$(printf '%s\n' "$ids" | sed '/^$/d' | wc -l | tr -d ' ')

    if [[ "$total" -eq 0 ]]; then
        ui_info "Kurulacak uygulama seçilmedi."
        return 0
    fi

    term_install_header "$ids"
    term_install_plan "$ids"

    if ! confirm_installation_plan "$ids"; then
        ui_info "Kurulum iptal edildi."
        term_skip "Kurulum kullanıcı tarafından iptal edildi"
        return 0
    fi

    term_phase "1/3 Sistem kontrolü"
    if ! run_system_check; then
        term_error "Sistem kontrolü başarısız"
        return 1
    fi
    term_success "Sistem kontrolü geçti"

    local results_file="$APP_DATA_DIR/last-install-results.txt"
    : > "$results_file"

    term_phase "2/3 Uygulama kurulumu"
    term_print "${C_DIM}Zenity genel ilerlemeyi gösterir; ayrıntılı durum bu terminaldedir.${C_RESET}"
    term_hr

    (
        local idx=0 app_id name percent result
        while IFS= read -r app_id; do
            [[ -z "$app_id" ]] && continue
            idx=$((idx + 1))
            name=$(catalog_name "$app_id")
            percent=$((idx * 100 / total))
            echo "$percent"
            echo "# $name işleniyor... ($idx/$total)"
            term_app_card_open "$idx" "$total" "$name"
            result=$(install_one_app "$app_id" 2>&1)
            printf '%s\n' "$result" >> "$results_file"
            term_app_card_close
            sleep 0.15
        done <<< "$ids"
        echo "100"
        echo "# Kurulum tamamlandı"
    ) | ui_progress_install "Uygulamalar kuruluyor" || true

    term_phase "3/3 Rapor"
    term_success "Kurulum akışı tamamlandı"
    term_kv "Log" "$(term_compact_path "$LOG_FILE")"
    term_print ""

    show_install_report "$results_file"
    save_last_selection "$ids"
}
