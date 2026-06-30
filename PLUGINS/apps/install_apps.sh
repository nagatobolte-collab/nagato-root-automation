
install_apks_auto() {
    echo ""
    info "PLUGIN: Installing Apps"

    for apk in APK/*.apk; do
        [ -e "$apk" ] || continue

        echo "Installing $(basename "$apk")..."
        adb install "$apk"

        if [ $? -eq 0 ]; then
            echo "✓ Installed: $(basename "$apk")"
        else
            echo "✗ FAILED: $(basename "$apk")"
        fi
    done
}
