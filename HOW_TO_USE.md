# NAGATO ROOT KIT v2.2 — How to Use

## Quick Start

1. Put your OTA zip in the `OTA/` folder
2. Double-click `root_pixel.command`
3. Follow the on-screen prompts

That's it. The script handles everything else automatically.

---

## Folder Structure

```
pixel 7a/
├── root_pixel.command      ← Double-click this to launch
├── root_pixel.sh           ← Main script (don't run directly)
├── banner.sh               ← Colors and spinners
├── checks.sh               ← File and tool checks
├── config.sh               ← Settings (edit this to customize)
├── device.sh               ← ADB device detection
├── menu.sh                 ← Menus and prompts
├── logger.sh               ← Session logging
├── android-ota-extractor   ← Binary (do not move)
│
├── APK/                    ← Drop APKs here
├── MODULES/                ← Drop module ZIPs here
├── OTA/                    ← Drop OTA zip files here
├── CONFIG/                 ← Drop JSON config files here
└── LOGS/                   ← Auto-generated session logs
```

---

## Before You Start (Phone Setup)

Do this once on each phone before running the script:

1. **Settings → About Phone** — tap Build Number 7 times to unlock Developer Options
2. **Settings → Developer Options** — turn ON:
   - USB Debugging
   - OEM Unlocking
3. Connect USB cable — tap **Allow** when phone asks about USB debugging
4. Run: `fastboot flashing unlock` (erases the phone — backup first!)

---

## Downloading OTA Zips

| Device | Codename | Download URL |
|--------|----------|-------------|
| Pixel 6a | bluejay | developers.google.com/android/ota#bluejay |
| Pixel 7a | lynx | developers.google.com/android/ota#lynx |
| Pixel 7 Pro | cheetah | developers.google.com/android/ota#cheetah |
| Pixel 7 | panther | developers.google.com/android/ota#panther |
| Pixel 6 | oriole | developers.google.com/android/ota#oriole |
| Pixel 6 Pro | raven | developers.google.com/android/ota#raven |

Save the downloaded zip to the `OTA/` folder. The script auto-matches by codename.

---

## APKs — What Goes in APK/

| APK | Purpose | Auto-detected by name |
|-----|---------|----------------------|
| SukiSU_*.apk | Root manager (SukiSU) | `SukiSU*.apk` |
| KernelSU_*.apk | Root manager (KernelSU) | `KernelSU*.apk` |
| APatch_*.apk | Root manager (APatch) | `APatch*.apk` |
| ReSukiSU_*.apk | Root manager (ReSukiSU) | `ReSukiSU*.apk` |
| telegram-*.apk | Telegram | `telegram*.apk` |
| HMAOSS.apk | Hide My Applist | `HMAOSS*.apk` |
| NAGATO_*.apk | NAGATO UPI | `NAGATO*.apk` |
| AndroidIDeditor.apk | AndroidID Editor | `AndroidID*.apk` |

Drop any new version — the script always picks the newest file matching each pattern.

---

## Modules — What Goes in MODULES/

All `.zip` files in MODULES/ are automatically pushed to `/sdcard/` on the phone.
Install them from the root manager app after rebooting.

Current modules:
- `Zygisk-Next.zip` — Zygisk implementation for KernelSU
- `LSPosed-v*.zip` — LSPosed framework
- `PlayIntegrity.zip` — Play Integrity Fix
- `Tricky_Store.zip` — Tricky Store
- `TRICKYSTORE ADDON.zip` — Tricky Store Addon
- `Yurikey.zip` — Yurikey

---

## Config Files — What Goes in CONFIG/

All `.json` and `.conf` files in CONFIG/ are pushed to `/sdcard/` automatically.

- `HMA-OSS_config.json` — Hide My Applist settings
- `SuSFS_Config_NAGATO.json` — SuSFS configuration

---

## Step-by-Step Walkthrough

### Step 1 — Setup Mode
```
[1]  Fresh Setup      — wipes existing root from both slots first
[2]  Update/Reinstall — just re-patches, keeps existing data
```
Choose **1** for a clean install. Choose **2** if you're updating the root manager.

### Step 2 — Root Manager
```
[1]  SukiSU
[2]  KernelSU Next
[3]  APatch
[4]  ReSukiSU
```
Press the number and Enter.

### Step 3 — Automated Steps
The script will automatically:
- Extract `init_boot.img` from your OTA zip
- Push it to `/sdcard/`
- Install your chosen root manager APK
- Install Telegram, HMA, NAGATO UPI, AndroidID Editor
- Push all modules to `/sdcard/`
- Push config files to `/sdcard/`
- Try to open the root manager app on the phone

### Step 4 — The One Manual Step (on your phone)
```
1. Open the root manager app (auto-launched)
2. Tap Install → Select file to patch
3. Choose /sdcard/init_boot.img
4. Set your Superkey password
5. Tap Start Patch → wait for SUCCESS
```
The script watches automatically — as soon as it sees the patched file it continues.

### Step 5 — Automated Flash
The script will automatically:
- Pull the patched image from the phone
- Reboot to bootloader
- If Fresh Setup: flash stock `init_boot` to both slots (removes old root)
- Flash patched `init_boot` to active slot
- Reboot the phone

### Step 6 — After Reboot
```
→ Open root manager → enter Superkey to grant root
→ Install modules from /sdcard/ in the root manager app
→ Import HMA config from /sdcard/HMA-OSS_config.json
```

---

## Configuration (`config.sh`)

Edit `config.sh` to change default behavior:

| Setting | Default | Description |
|---------|---------|-------------|
| `CREATE_LOGS` | `true` | Save session logs to LOGS/ |
| `MAX_LOGS` | `20` | Delete oldest logs when over this count |
| `PATCH_POLL_TIMEOUT` | `300` | Max seconds to wait for patched file |
| `FASTBOOT_WAIT` | `15` | Seconds to wait after reboot-to-bootloader |
| `BOOT_WAIT_TIMEOUT` | `120` | Max seconds to wait for post-flash boot |

---

## Troubleshooting

### "No device found"
- Check USB cable (use a data cable, not charge-only)
- Enable USB Debugging in Developer Options
- Tap **Allow** when phone asks about debugging

### "OTA zip not found"
- Download OTA from developers.google.com/android/ota
- Save to the `OTA/` folder
- Filename must start with the device codename (e.g. `lynx-ota-...zip`)

### "android-ota-extractor not found"
- The extractor binary must be in the `pixel 7a/` root folder
- Give it execute permission: `chmod +x android-ota-extractor`

### Patched file not detected after 5 minutes
- Check `/sdcard/Download/` on the phone manually
- The script will ask you to type the filename if it times out

### Device not entering fastboot mode
- Try a different USB port
- Hold Power + Volume Down on the phone for 10 seconds
- Run `adb reboot bootloader` manually

---

## Session Logs

Every run saves a log to `LOGS/session_YYYY-MM-DD_HH-MM-SS.log`.
Check the log if something goes wrong — it records every step with timestamps.
Old logs are auto-deleted when count exceeds `MAX_LOGS` (default: 20).
