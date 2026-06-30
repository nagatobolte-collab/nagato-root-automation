#!/bin/bash

load_plugins() {
    echo ""
    echo "▶ Loading plugins..."

    # SAFE LOOP (no shopt, no zsh errors)
    for file in PLUGINS/core/*.sh PLUGINS/core/*.sh(N) \
                PLUGINS/apps/*.sh PLUGINS/apps/*.sh(N) \
                PLUGINS/root/*.sh PLUGINS/root/*.sh(N)
    do
        [ -f "$file" ] && source "$file"
    done 2>/dev/null

    echo "✓ Plugins loaded"
}
