#!/usr/bin/env bash

# Logger module for Ubuntu Starter Kit.
# The main script defines APP_DATA_DIR and LOG_FILE before loading this file.

init_log() {
    mkdir -p "$(dirname "$LOG_FILE")"
    : > "$LOG_FILE"
    log_info "Ubuntu Starter Kit started"
}

log_line() {
    local level="$1"
    shift
    local message="$*"
    printf '[%s] [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$message" >> "$LOG_FILE"
}

log_info() { log_line "INFO" "$@"; }
log_warn() { log_line "WARN" "$@"; }
log_error() { log_line "ERROR" "$@"; }
log_success() { log_line "SUCCESS" "$@"; }

print_error() {
    printf 'HATA: %s\n' "$*" >&2
    log_error "$*"
}
