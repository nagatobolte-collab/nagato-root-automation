    echo ""
#!/bin/bash
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/banner.sh"
source "$(dirname "$0")/logger.sh"
source "$(dirname "$0")/checks.sh"
source "$(dirname "$0")/menu.sh"
source "$(dirname "$0")/device.sh"

# ============================================================
#   COMPLETE ROOT SCRIPT — Pixel 6a / 7a / 7 Pro
#   By NAGATO
#   Usage: bash root_pixel.sh
# ============================================================

PIXEL_FOLDER="$HOME/Desktop/pixel 7a"
EXTRACTOR="$PIXEL_FOLDER/android-ota-extractor"

# APKs
APK_DIR="$PIXEL_FOLDER/APK"
SUKISU_APK=$(find_best "$APK_DIR" "*SukiSU*.apk")
TELEGRAM_APK=$(find_best "$APK_DIR" "telegram*.apk")
HMAOSS_APK=$(find_best "$APK_DIR" "*HMA*.apk")
NAGATO_UPI_APK=$(find_best "$APK_DIR" "*UPI*.apk")
ANDROIDID_APK=$(find_best "$APK_DIR" "*AndroidID*.apk")
NAGATO_FINAL_V5_2_APK=$(find_best "$APK_DIR" "*UNENCRYPTED*.apk")

# Modules (zips)
MODULE_DIR="$PIXEL_FOLDER/MODULES"
ZYGISK_NEXT=$(find_best "$MODULE_DIR" "Zygisk*.zip")
LSPOSED=$(find_best "$MODULE_DIR" "LSPosed*.zip")
PLAY_INTEGRITY=$(find_best "$MODULE_DIR" "PlayIntegrity*.zip")
TRICKY_STORE=$(find_best "$MODULE_DIR" "Tricky_Store*.zip")
TRICKY_ADDON=$(find_best "$MODULE_DIR" "TRICKYSTORE*.zip")
YURIKEY=$(find_best "$MODULE_DIR" "Yurikey*.zip")

# Config
CONFIG_DIR="$PIXEL_FOLDER/CONFIG"
HMA_CONFIG=$(find_best "$CONFIG_DIR" "HMA*.json")

# OTA zips
OTA_DIR="$PIXEL_FOLDER/OTA"
BLUEJAY_OTA="$OTA_DIR/bluejay-ota-cp1a.260405.005-c48935a2.zip"
LYNX_OTA="$OTA_DIR/lynx-ota-cp1a.260505.005-fd391772.zip"
CHEETAH_OTA="$OTA_DIR/cheetah-ota-cp1a.260505.005.zip"

print_banner

# ── STEP 1: Check device connected ──
check_device_connected

# ── STEP 2: Get device info ──
get_device_info
display_device_info

MODEL="$D_MODEL"
CODENAME="$D_CODENAME"
SLOT="$D_SLOT"
ANDROID="$D_ANDROID"
BUILD="$D_BUILD"

select_reset_mode

if [ "$RESET_MODE" = "hard" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    warn "Factory Reset (Erase ALL data)?"
    echo ""
    echo "  [1] Yes (Recommended)"
    echo "  [2] No  (Keep apps & data)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    read -p "Choice [1/2]: " FACTORY_RESET
fi
select_root_manager
# ── STEP 3: Select correct OTA zip ──
select_ota

# ── STEP 4: Extract init_boot ──
info "Extracting init_boot from OTA zip..."
cd "$PIXEL_FOLDER" || error "pixel 7a folder not found!"
rm -f init_boot.img payload.bin
log "Cleaned old files"
unzip -o "$OTA_ZIP" payload.bin -d "$PIXEL_FOLDER" > /dev/null 2>&1
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log "Extracted payload.bin"
chmod +x "$EXTRACTOR"
"$EXTRACTOR" payload.bin init_boot > /dev/null 2>&1
log "Extracted init_boot.img ($(du -h init_boot.img | cut -f1))"


if [ "$RESET_MODE" = "hard" ]; then
    step "Fresh Setup"
    info "Flashing stock init_boot..."
    adb reboot bootloader
    sleep 10
    ACTIVE_SLOT=$(fastboot getvar current-slot 2>&1 | awk -F": " '/current-slot/ {print $2}' | tr -d "\r")
    [ -z "$ACTIVE_SLOT" ] && ACTIVE_SLOT=${SLOT#_}
    fastboot flash init_boot_a "$PIXEL_FOLDER/init_boot.img" || error "Failed to flash init_boot_a"
    fastboot flash init_boot_b "$PIXEL_FOLDER/init_boot.img" || error "Failed to flash init_boot_b"
    if [ "$FACTORY_RESET" = "1" ]; then
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}        ⚠  FACTORY RESET WARNING ⚠${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}This will permanently erase:${NC}"
        echo ""
        echo "   • Apps"
        echo "   • Photos & Videos"
        echo "   • Downloads"
        echo "   • Accounts"
        echo "   • Messages"
        echo "   • Internal Storage"
        echo ""
        echo -e "${RED}THIS ACTION CANNOT BE UNDONE!${NC}"
        echo ""
        read -p "Type YES to continue: " CONFIRM_RESET

        if [ "$CONFIRM_RESET" != "YES" ]; then
            warn "Factory Reset cancelled."
            FACTORY_RESET=2
        fi
        if [ "$CONFIRM_RESET" = "YES" ]; then
            fastboot -w || error "Factory reset failed"
        fi
    fi

    fastboot reboot

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Enable Developer Options if required"
    echo "Enable USB Debugging"
    echo "Tap Allow on USB debugging popup"
    echo ""
    read -p "Press ENTER when phone is ready..."

    check_device_connected
    get_device_info
    display_device_info

    info "Removing previous root environment..."

    adb shell pm uninstall me.weishu.kernelsu >/dev/null 2>&1
    adb shell pm uninstall me.bmax.apatch >/dev/null 2>&1
    adb shell pm uninstall io.github.sukisu >/dev/null 2>&1
    adb shell pm uninstall io.github.resukisu >/dev/null 2>&1

    adb shell 'rm -f /sdcard/Download/init_boot.img' >/dev/null 2>&1
    adb shell 'find /sdcard/Download -maxdepth 1 -type f -name "*patched*.img" -delete' >/dev/null 2>&1
    adb shell 'find /sdcard/Download -maxdepth 1 -type f \( -name "Zygisk*.zip" -o -name "LSPosed*.zip" -o -name "PlayIntegrity*.zip" -o -name "Tricky*.zip" -o -name "Yurikey*.zip" -o -name "HMA*.json" \) -delete' >/dev/null 2>&1

    log "Previous root environment cleaned."
fi

# ── STEP 5: Push init_boot ──
info "Pushing init_boot.img to phone..."
adb push "$PIXEL_FOLDER/init_boot.img" /sdcard/Download/init_boot.img
log "init_boot.img pushed!"

# ── STEP 6: Install APKs ──
echo ""
info "Installing APKs..."

install_apk() {
    local apk="$1"
    local name="$2"
    if [ -f "$apk" ]; then
        adb install -r "$apk" > /dev/null 2>&1
        log "$name installed!"
    else
        warn "$name not found — skipping"
    fi
}

install_apk "$ROOT_APK" "$ROOT_MANAGER"
# ── STEP 7: Push modules to phone ──
echo ""
info "Pushing KernelSU modules to phone..."

push_module() {
    local file="$1"
    local name="$2"
    if [ -f "$file" ]; then
        adb push "$file" "/sdcard/$(basename "$file")" > /dev/null 2>&1
        log "$name pushed to /sdcard/"
    else
        warn "$name not found — skipping"
    fi
}

push_module "$ZYGISK_NEXT"   "Zygisk-Next"
push_module "$LSPOSED"       "LSPosed"
push_module "$PLAY_INTEGRITY" "Play Integrity Fix"
push_module "$TRICKY_STORE"  "Tricky Store"
push_module "$TRICKY_ADDON"  "Tricky Store Addon"
push_module "$YURIKEY"       "Yurikey"

# ── STEP 8: Push HMA config ──
if [ -f "$HMA_CONFIG" ]; then
    adb push "$HMA_CONFIG" "/sdcard/HMA-OSS_config.json" > /dev/null 2>&1
    log "HMA config pushed to /sdcard/"
fi

# ── STEP 9: Wait for patching ──
echo ""
echo "============================================"
warn "NOW DO THIS ON YOUR PHONE:"
echo ""
echo "  1. Open SukiSU app"
echo "  2. Tap Install → Select file to patch"
echo "  3. Select /sdcard/init_boot.img"
echo "  4. Set your Superkey password"
echo "  5. Tap Start Patch"
echo "  6. Wait for SUCCESS message"
echo ""
echo "  Then install modules from /sdcard/:"
echo "  → Zygisk-Next.zip"
echo "  → LSPosed.zip"
echo "  → PlayIntegrity.zip"
echo "  → Tricky_Store.zip"
echo "  → TRICKYSTORE ADDON.zip"
echo "  → Yurikey.zip"
echo ""
echo "============================================"
echo "Patch init_boot.img using your selected root manager."
echo "The toolkit is now watching Download/ automatically."
echo "It will continue as soon as the patched image appears."
echo "============================================"
echo ""

# ── STEP 10: Wait for patched file ──
info "Waiting for patched image..."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Watching: /sdcard/Download"
echo "Patch init_boot.img on your phone..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

LAST_PATCHED=$(adb shell "find /storage/emulated/0/Download -maxdepth 1 -type f -name '*.img'" | tr -d "\r" | grep -Ei "$PATCH_KEYWORD" | tail -1)

START_TIME=$(date +%s)
TIMEOUT=300

while true
do
    PATCHED=$(adb shell "find /storage/emulated/0/Download -maxdepth 1 -type f -name '*.img'" | tr -d "\r" | grep -Ei "$PATCH_KEYWORD" | tail -1)

    if [ -n "$PATCHED" ] && [ "$PATCHED" != "$LAST_PATCHED" ]; then
        PATCHED_NAME=$(basename "$PATCHED")
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "✅ Patched image detected"
        echo ""
        echo "File:"
        echo "  $PATCHED_NAME"
        echo ""
        read -p "Flash this image? (Y/n): " ANSWER
        ANSWER=${ANSWER:-Y}
        if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
            PATCHED="$PATCHED_NAME"
            break
        fi
        LAST_PATCHED="$PATCHED"
        echo ""
        echo "Watching for another patched image..."
    fi

    NOW=$(date +%s)
    if (( NOW - START_TIME > TIMEOUT )); then
        echo ""
        warn "Timed out waiting for patched image."
        adb shell ls /sdcard/Download/
        echo ""
        read -p "Enter filename manually: " PATCHED
        break
    fi

    printf "\r⏳ Waiting for patch..."
    sleep 2
done

log "Using patched image: $PATCHED"

# ── STEP 11: Pull patched file ──
info "Pulling patched file to Mac..."
adb pull "/sdcard/Download/$PATCHED" "$PIXEL_FOLDER/$PATCHED"
log "Pulled: $PATCHED"

# ── STEP 12: Reboot to bootloader ──
info "Rebooting to bootloader..."
adb reboot bootloader
warn "Waiting for fastboot mode (15 seconds)..."


sleep 15

# ── STEP 13: Detect active slot ──
info "Detecting active slot..."
ACTIVE_SLOT=$(fastboot getvar current-slot 2>&1 | grep "current-slot" | awk '{print $2}' | tr -d '\r')
if [ -z "$ACTIVE_SLOT" ]; then
    ACTIVE_SLOT="${SLOT//_/}"
fi
log "Active slot: $ACTIVE_SLOT"

# ── STEP 14: Flash patched init_boot ──
info "Flashing patched init_boot to slot $ACTIVE_SLOT..."
fastboot flash "init_boot_$ACTIVE_SLOT" "$PIXEL_FOLDER/$PATCHED"
log "Flashed successfully!"

# ── STEP 15: Reboot ──
info "Rebooting phone..."
fastboot continue 2>/dev/null || fastboot reboot

wait_for_boot || error "Device failed to boot after flashing."

echo ""
info "Installing remaining applications..."
install_apk "$TELEGRAM_APK" "Telegram"
install_apk "$HMAOSS_APK" "HMA OSS"
install_apk "$NAGATO_UPI_APK" "NAGATO UPI"
install_apk "$ANDROIDID_APK" "Android ID Editor"
install_apk "$NAGATO_FINAL_V5_2_APK" "NAGATO Final V5.2"

echo ""
echo "============================================"
echo -e "${GREEN}  ROOT + SETUP COMPLETE! 🎉${NC}"
echo ""
echo "  ✅ Device      : $MODEL ($CODENAME)"
echo "  ✅ Android     : $ANDROID"
echo "  ✅ Slot        : $ACTIVE_SLOT"

echo ""
echo "  ✅ SukiSU      : installed"
echo "  ✅ Telegram    : installed"
echo "  ✅ HMA OSS     : installed"
echo "  ✅ NAGATO UPI  : installed"
echo "  ✅ AndroidID   : installed"
echo "  ✅ Modules     : pushed to /sdcard/"
echo "  ✅ HMA config  : pushed to /sdcard/"
echo "  ✅ Patched     : $PATCHED"
echo ""
echo "  After reboot:"

info "Cleaning temporary files..."
rm -f "$PIXEL_FOLDER/$PATCHED"
rm -f "$PIXEL_FOLDER/init_boot.img"
rm -f "$PIXEL_FOLDER/payload.bin"
adb shell rm -f "/sdcard/Download/$PATCHED" >/dev/null 2>&1
adb shell rm -f "/sdcard/Download/init_boot.img" >/dev/null 2>&1
log "Temporary files cleaned."

echo "  → Open SukiSU → enter Superkey"
echo "  → Install modules from /sdcard/"
echo "  → Import HMA config from /sdcard/"
echo "============================================"
echo ""
