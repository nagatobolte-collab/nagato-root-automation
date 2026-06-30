#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  NAGATO ROOT KIT — Configuration  (config.sh)
#  Edit paths and flags here — do NOT edit root_pixel.sh
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Subdirectory layout ──────────────────────────────
OTA_DIR="$TOOLKIT_ROOT/OTA"
APK_DIR="$TOOLKIT_ROOT/APK"
MODULES_DIR="$TOOLKIT_ROOT/MODULES"
CONFIG_DIR="$TOOLKIT_ROOT/CONFIG"
LOGS_DIR="$TOOLKIT_ROOT/LOGS"

# ── Extractor binary (stays in toolkit root) ─────────
EXTRACTOR="$TOOLKIT_ROOT/android-ota-extractor"

# ── Behavior flags ───────────────────────────────────
ENABLE_COLORS=true     # false = plain text output
CREATE_LOGS=true       # false = no log files
MAX_LOGS=20            # rotate when log count exceeds this

# ── Timing ──────────────────────────────────────────
PATCH_POLL_INTERVAL=3  # seconds between patch-detection polls
PATCH_POLL_TIMEOUT=300 # max seconds to wait for patched img
FASTBOOT_WAIT=15       # seconds after 'adb reboot bootloader'
BOOT_WAIT_TIMEOUT=120  # max seconds to wait for boot after flash

# ── Device friendly name lookup (bash 3.2 compatible) ─
# Returns the friendly name for a given Pixel codename.
get_device_friendly() {
    case "$1" in
        bluejay)    echo "Pixel 6a" ;;
        lynx)       echo "Pixel 7a" ;;
        cheetah)    echo "Pixel 7 Pro" ;;
        panther)    echo "Pixel 7" ;;
        raven)      echo "Pixel 6 Pro" ;;
        oriole)     echo "Pixel 6" ;;
        felix)      echo "Pixel Fold" ;;
        tangorpro)  echo "Pixel Tablet" ;;
        akita)      echo "Pixel 8a" ;;
        shiba)      echo "Pixel 8" ;;
        husky)      echo "Pixel 8 Pro" ;;
        komodo)     echo "Pixel 9 Pro XL" ;;
        tokay)      echo "Pixel 9 Pro" ;;
        caiman)     echo "Pixel 9 Pro Fold" ;;
        comet)      echo "Pixel 9" ;;
        *)          echo "$1" ;;
    esac
}
