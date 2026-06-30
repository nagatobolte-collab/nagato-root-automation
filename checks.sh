#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  NAGATO ROOT KIT — Environment & File Checks
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_tools() {
    step "Checking required tools"
    local missing=0
    for tool in adb fastboot unzip; do
        if command -v "$tool" &>/dev/null; then
            log "$tool found ($(command -v $tool))"
            logf "TOOL OK: $tool"
        else
            error "$tool not found — install with: brew install --cask android-platform-tools"
            logf "TOOL MISSING: $tool"
            missing=1
        fi
    done
    if [ -f "$EXTRACTOR" ]; then
        chmod +x "$EXTRACTOR"
        log "android-ota-extractor found"
        logf "TOOL OK: android-ota-extractor"
    else
        error "android-ota-extractor not found at: $EXTRACTOR"
        logf "TOOL MISSING: android-ota-extractor"
        missing=1
    fi
    [ "$missing" -eq 1 ] && { finalize_log "FAILED — missing tools"; exit 1; }
}

ensure_dirs() {
    for d in "$OTA_DIR" "$APK_DIR" "$MODULES_DIR" "$CONFIG_DIR" "$LOGS_DIR"; do
        mkdir -p "$d"
    done
}

# ── Move flat files into subdirectories on first run ──
organize_files() {
    local moved=0

    # APKs
    for f in "$TOOLKIT_ROOT"/*.apk; do
        [ -f "$f" ] || continue
        mv "$f" "$APK_DIR/" 2>/dev/null && moved=$((moved+1))
    done

    # Modules (zip) — but NOT OTA zips
    for f in "$TOOLKIT_ROOT"/*.zip; do
        [ -f "$f" ] || continue
        local base
        base="$(basename "$f")"
        # OTA zips have codename-ota- prefix
        if echo "$base" | grep -qiE '^(bluejay|lynx|cheetah|panther|raven|oriole|felix|tangorpro|akita|shiba|husky|komodo|tokay|caiman|comet)-ota-'; then
            mv "$f" "$OTA_DIR/" 2>/dev/null && moved=$((moved+1))
        else
            mv "$f" "$MODULES_DIR/" 2>/dev/null && moved=$((moved+1))
        fi
    done

    # Config JSON
    for f in "$TOOLKIT_ROOT"/*.json; do
        [ -f "$f" ] || continue
        mv "$f" "$CONFIG_DIR/" 2>/dev/null && moved=$((moved+1))
    done

    [ "$moved" -gt 0 ] && log "Organized $moved file(s) into subfolders"
}

# ── Scan toolkit and print inventory ─────────────────
scan_inventory() {
    step "Toolkit inventory"

    local ota_count apk_count mod_count cfg_count
    ota_count=$(find "$OTA_DIR"     -maxdepth 1 -name "*.zip"  2>/dev/null | wc -l | tr -d ' ')
    apk_count=$(find "$APK_DIR"     -maxdepth 1 -name "*.apk"  2>/dev/null | wc -l | tr -d ' ')
    mod_count=$(find "$MODULES_DIR" -maxdepth 1 -name "*.zip"  2>/dev/null | wc -l | tr -d ' ')
    cfg_count=$(find "$CONFIG_DIR"  -maxdepth 1 \( -name "*.json" -o -name "*.conf" \) 2>/dev/null | wc -l | tr -d ' ')

    echo ""
    printf "  ${WHITE}%-12s${NC} %s files\n" "OTAs"    "$ota_count"
    printf "  ${WHITE}%-12s${NC} %s files\n" "APKs"    "$apk_count"
    printf "  ${WHITE}%-12s${NC} %s files\n" "Modules" "$mod_count"
    printf "  ${WHITE}%-12s${NC} %s files\n" "Configs" "$cfg_count"
    echo ""

    logf "INVENTORY: OTA=$ota_count APK=$apk_count MOD=$mod_count CFG=$cfg_count"

    if [ "$ota_count" -eq 0 ]; then
        warn "No OTA zips found in OTA/ — download from developers.google.com/android/ota"
    fi
    if [ "$apk_count" -eq 0 ]; then
        warn "No APKs found in APK/"
    fi
}

# ── Find best (newest) file matching a pattern ────────
# Usage: find_best "APK" "SukiSU*.apk"
find_best() {
    local dir="$1"
    local pattern="$2"

    find "$dir" -maxdepth 1 -type f -name "$pattern" -exec stat -f "%m %N" {} \; |
    sort -rn |
    head -1 |
    cut -d" " -f2-
}
