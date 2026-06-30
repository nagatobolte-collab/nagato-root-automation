#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  NAGATO ROOT KIT — Device Detection
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

D_MODEL=""
D_CODENAME=""
D_ANDROID=""
D_BUILD=""
D_SLOT=""
D_BOOTLOADER=""
D_FRIENDLY=""

check_device_connected() {
    step "Checking USB connection"

    # Quick check first
    if adb devices 2>/dev/null | grep -q "device$"; then
        log "Device already connected"
        logf "DEVICE: already connected"
        return 0
    fi

    echo ""
    echo -e "  ${YELLOW}${BOLD}Waiting for phone — connect USB now${NC}"
    dim "  1. USB Debugging must be ON  (Settings → Developer Options)"
    dim "  2. Phone will ask 'Allow USB Debugging' — tap ${BOLD}Allow${NC}"
    dim "  3. Use a data cable, not charge-only"
    dim "  4. Close this terminal to cancel"
    echo ""

    local _elapsed=0
    local _frames; _frames=('◐' '◓' '◑' '◒')
    local _si=0

    while true; do
        if adb devices 2>/dev/null | grep -q "device$"; then
            printf "\r  ${GREEN}✓${NC}  Device connected!                                    \n"
            logf "DEVICE CONNECTED after ${_elapsed}s"
            echo ""
            return 0
        fi
        printf "\r  ${CYAN}${_frames[$((_si % 4))]}${NC}  No device yet... connect USB and tap Allow ${DIM}(${_elapsed}s)${NC}  "
        _si=$((_si+1))
        sleep 2
        _elapsed=$((_elapsed+2))
    done
}

get_device_info() {
    step "Reading device information"
    spin_start "Querying device"

    D_MODEL=$(adb shell getprop ro.product.model       2>/dev/null | tr -d '\r\n ')
    D_CODENAME=$(adb shell getprop ro.product.device   2>/dev/null | tr -d '\r\n ')
    D_ANDROID=$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r\n ')
    D_BUILD=$(adb shell getprop ro.build.id            2>/dev/null | tr -d '\r\n ')
    D_SLOT=$(adb shell getprop ro.boot.slot_suffix     2>/dev/null | tr -d '\r\n ')
    D_BOOTLOADER=$(adb shell getprop ro.boot.flash.locked 2>/dev/null | tr -d '\r\n ')
    D_FRIENDLY="$(get_device_friendly "$D_CODENAME")"

    spin_ok
    logf "DEVICE: model=$D_MODEL codename=$D_CODENAME android=$D_ANDROID build=$D_BUILD slot=$D_SLOT bl=$D_BOOTLOADER"
}

display_device_info() {
    echo ""
    sep
    printf "  ${WHITE}%-14s${NC} ${CYAN}%s${NC}\n" "Model" "$D_MODEL"
    printf "  ${WHITE}%-14s${NC} ${MAGENTA}%s${NC}\n" "Codename" "$D_CODENAME ($D_FRIENDLY)"
    printf "  ${WHITE}%-14s${NC} ${GREEN}Android %s${NC}\n" "Android" "$D_ANDROID"
    printf "  ${WHITE}%-14s${NC} ${YELLOW}%s${NC}\n" "Build" "$D_BUILD"
    printf "  ${WHITE}%-14s${NC} ${BLUE}%s${NC}\n" "Active slot" "${D_SLOT:-unknown}"
    printf "  ${WHITE}%-14s${NC} ${RED}%s${NC}\n" "Bootloader" "${D_BOOTLOADER:-unknown}"
    sep
    echo ""
}
# ── Select OTA zip for detected device ──────────────
select_ota() {
    step "Selecting OTA for $D_CODENAME"

    # Search OTA dir for a zip matching the codename
    local best
    best=$(find_best "$OTA_DIR" "${D_CODENAME}-ota-*.zip")

    if [ -n "$best" ]; then
        OTA_ZIP="$best"
        log "Found OTA: $(basename "$OTA_ZIP")"
        logf "OTA: $OTA_ZIP"
        return 0
    fi

    # No matching OTA — list what's available and ask
    warn "No OTA found for codename '$D_CODENAME' in OTA/"
    echo ""
    echo -e "  ${YELLOW}Available OTA files:${NC}"
    local i=1
    local ota_list=()
    while IFS= read -r f; do
        ota_list+=("$f")
        printf "    [%d] %s\n" "$i" "$(basename "$f")"
        i=$((i+1))
    done < <(ls "$OTA_DIR"/*.zip 2>/dev/null)

    if [ "${#ota_list[@]}" -eq 0 ]; then
        error "No OTA zips at all in OTA/ — download from developers.google.com/android/ota"
        finalize_log "FAILED — no OTA"; exit 1
    fi

    echo ""
    read -p "  Choose OTA number (or press Enter to enter path manually): " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#ota_list[@]}" ]; then
        OTA_ZIP="${ota_list[$((choice-1))]}"
    else
        read -p "  Enter full path to OTA zip: " OTA_ZIP
    fi

    [ -f "$OTA_ZIP" ] || { error "File not found: $OTA_ZIP"; finalize_log "FAILED — OTA not found"; exit 1; }
    log "Using OTA: $(basename "$OTA_ZIP")"
    logf "OTA (manual): $OTA_ZIP"
}

# ── Wait for device to boot after flash ─────────────
wait_for_boot() {
    step "Waiting for device to boot"
    spin_start "Waiting for ADB"
    local elapsed=0
    while [ $elapsed -lt $BOOT_WAIT_TIMEOUT ]; do
        if adb get-state 2>/dev/null | grep -q "device"; then
            spin_ok
            sleep 3  # settle
            return 0
        fi
        sleep 5; elapsed=$((elapsed+5))
    done
    spin_fail "Timed out after ${BOOT_WAIT_TIMEOUT}s"
    return 1
}
