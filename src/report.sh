#!/usr/bin/env bash

show_install_report() {
    local results_file="$1"
    local success=0 skip=0 error=0 status app_id message name report

    report="Kurulum Raporu\n\n"
    while IFS='|' read -r status app_id message; do
        [[ -z "$status" ]] && continue
        name=$(catalog_name "$app_id" 2>/dev/null || echo "$app_id")
        case "$status" in
            SUCCESS)
                success=$((success + 1))
                report+="✅ $name — $message\n"
                ;;
            SKIP)
                skip=$((skip + 1))
                report+="⏭️ $name — $message\n"
                ;;
            ERROR)
                error=$((error + 1))
                report+="❌ $name — $message\n"
                ;;
        esac
    done < "$results_file"

    report+="\nÖzet:\nBaşarılı: $success\nZaten kurulu/atlandı: $skip\nHatalı: $error\n\nLog dosyası:\n$LOG_FILE"
    ui_info "$report"
}
