#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  NAGATO ROOT KIT — Menus & Prompts
#  bash 3.2 compatible (no declare -A)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ROOT_MANAGER=""     # set by select_root_manager
ROOT_APK=""         # path to selected APK
ROOT_PKG=""         # Android package name
PATCH_KEYWORD=""    # grep pattern to detect patched file
RESET_MODE=""       # "hard" | "normal"  set by select_reset_mode

# ── Root manager tables (indexed 1-4, bash 3.2 compatible) ──
# Index 0 is unused so index matches menu number directly.
RM_DISPLAY=("" "SukiSU" "KernelSU Next" "APatch" "ReSukiSU")
RM_PATTERN=("" "SukiSU*.apk" "KernelSU*.apk" "APatch*.apk" "ReSukiSU*.apk")
RM_PKG=(""
    "me.bmax.apatch"
    "me.weishu.kernelsu"
    "me.bmax.apatch"
    "io.github.rsukisudev"
)
RM_PATCH_KW=(""
    "sukisu_patched\|kernelsu_patched\|patched"
    "kernelsu_patched\|patched"
    "apatch_patched\|patched"
    "sukisu_patched\|patched"
)

select_reset_mode() {
    step "Setup Mode"
    echo ""
    echo -e "  ${WHITE}[1]${NC}  Fresh Setup      ${DIM}— flashes STOCK init_boot to both slots first${NC}"
    echo -e "         ${DIM}  Wipes existing root (Magisk / KSU / APatch / SukiSU)${NC}"
    echo -e "         ${DIM}  Recommended for a clean reinstall${NC}"
    echo ""
    echo -e "  ${WHITE}[2]${NC}  Update / Reinstall ${DIM}— skips stock flash, just re-patches and flashes${NC}"
    echo -e "         ${DIM}  Faster; keeps existing modules and data intact${NC}"
    echo ""

    local choice
    while true; do
        read -p "  Choice [1/2]: " choice
        case "$choice" in
            1)
                RESET_MODE="hard"
                log "Mode: Fresh Setup — hard reset will run before patching"
                logf "RESET MODE: hard"
                return 0 ;;
            2)
                RESET_MODE="normal"
                log "Mode: Update/Reinstall — no hard reset"
                logf "RESET MODE: normal"
                return 0 ;;
            *)
                warn "Enter 1 or 2" ;;
        esac
    done
}

select_root_manager() {
    step "Select Root Manager"
    echo ""
    local i
    for i in 1 2 3 4; do
        local apk
        apk=$(find_best "$APK_DIR" "${RM_PATTERN[$i]}")
        local ver=""
        [ -n "$apk" ] && ver="  ($(basename "$apk"))"
        printf "    [%d]  %-16s%s\n" "$i" "${RM_DISPLAY[$i]}" "$ver"
    done
    printf "    [0]  Exit\n"
    echo ""

    local choice
    while true; do
        read -p "  Choice: " choice
        case "$choice" in
            1|2|3|4)
                ROOT_MANAGER="${RM_DISPLAY[$choice]}"
                ROOT_PKG="${RM_PKG[$choice]}"
                PATCH_KEYWORD="${RM_PATCH_KW[$choice]}"

                ROOT_APK=$(find_best "$APK_DIR" "${RM_PATTERN[$choice]}")
                if [ -z "$ROOT_APK" ]; then
                    warn "No APK found matching ${RM_PATTERN[$choice]} in APK/"
                    read -p "  Enter full path to APK: " ROOT_APK
                fi
                [ -f "$ROOT_APK" ] || { error "APK not found: $ROOT_APK"; continue; }
                log "Selected: $ROOT_MANAGER ($(basename "$ROOT_APK"))"
                logf "ROOT MANAGER: $ROOT_MANAGER | APK: $ROOT_APK"
                return 0
                ;;
            0)
                echo ""; info "Exiting."; finalize_log "User exit"; exit 0 ;;
            *)
                warn "Enter 1, 2, 3, 4, or 0" ;;
        esac
    done
}

confirm() {
    local prompt="${1:-Continue?}"
    local answer
    read -p "  $prompt [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

pause() {
    read -p "  ${1:-Press Enter to continue...}"
}
