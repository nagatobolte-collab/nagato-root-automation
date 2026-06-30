
install_root_manager() {
    echo ""
    info "PLUGIN: Root Manager"

    local done=0

    for apk in ROOT_MANAGERS/*.apk; do
        [ -e "$apk" ] || continue

        if [ "$done" -eq 1 ]; then
            echo "⏭ Skip: $(basename "$apk")"
            continue
        fi

        echo "Installing ROOT: $(basename "$apk")"
        adb install "$apk"

        if [ $? -eq 0 ]; then
            echo "✓ ROOT OK"
            done=1
        else
            echo "✗ ROOT FAIL"
        fi
    done
}
