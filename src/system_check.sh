#!/usr/bin/env bash

ensure_not_root() {
    if [[ $EUID -eq 0 ]]; then
        echo "Bu aracı root olarak çalıştırmayın. Normal kullanıcı ile başlatın; gerekli yerde sudo sorulacak." >&2
        exit 1
    fi
}

ensure_zenity() {
    if command -v zenity >/dev/null 2>&1; then
        return 0
    fi

    echo "Zenity bulunamadı. Grafik arayüz için Zenity gerekiyor."
    read -r -p "Zenity kurulsun mu? [e/H]: " answer
    case "$answer" in
        e|E|evet|EVET|Evet)
            sudo apt-get update && sudo apt-get install -y zenity
            ;;
        *)
            echo "Zenity olmadan devam edilemez."
            exit 1
            ;;
    esac
}

check_internet_quick() {
    # Prefer HTTPS endpoint instead of only raw ICMP; some networks block ping.
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --max-time 5 https://archive.ubuntu.com >/dev/null 2>&1 && return 0
    fi
    ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1
}

require_sudo() {
    ui_info "Kurulum için sudo yetkisi gerekecek.\n\nŞifre istenirse terminalin standart sudo istemine yazın. Bu araç sudo şifresini özel bir pencerede toplamaz."
    if sudo -v; then
        log_success "Sudo yetkisi alındı"
        return 0
    fi
    ui_error "Sudo yetkisi alınamadı. Kurulum yapılamaz."
    return 1
}

run_system_check() {
    log_info "Sistem kontrolü başlatıldı"
    local os="unknown"
    if command -v lsb_release >/dev/null 2>&1; then
        os=$(lsb_release -ds 2>/dev/null || echo "unknown")
    fi
    log_info "OS: $os"

    if ! check_internet_quick; then
        ui_error "İnternet bağlantısı doğrulanamadı. Paket kurulumları için bağlantı gerekiyor."
        return 1
    fi

    if ! require_sudo; then
        return 1
    fi

    return 0
}
