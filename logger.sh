#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  NAGATO ROOT KIT — Session Logger
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LOG_FILE=""

start_session_log() {
    mkdir -p "$LOGS_DIR"
    local ts
    ts="$(date '+%Y-%m-%d_%H-%M-%S')"
    LOG_FILE="$LOGS_DIR/session_${ts}.log"
    {
        echo "═══════════════════════════════════════════════════"
        echo "  NAGATO ROOT KIT — Session Log"
        echo "  Started : $(date '+%d %b %Y  %H:%M:%S')"
        echo "  Toolkit : $TOOLKIT_ROOT"
        echo "═══════════════════════════════════════════════════"
        echo ""
    } > "$LOG_FILE"
    log "Session log: ${LOG_FILE##*/}"
}

logf() {
    [ -n "$LOG_FILE" ] && echo "[$(date '+%H:%M:%S')]  $*" >> "$LOG_FILE"
}

rotate_logs() {
    local count
    count=$(ls "$LOGS_DIR"/session_*.log 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt "$MAX_LOGS" ]; then
        local del=$(( count - MAX_LOGS ))
        ls -t "$LOGS_DIR"/session_*.log 2>/dev/null | tail -"$del" | xargs rm -f
        dim "Rotated $del old log(s)."
    fi
}

finalize_log() {
    local status="$1"
    if [ -n "$LOG_FILE" ] && [ -f "$LOG_FILE" ]; then
        {
            echo ""
            echo "═══════════════════════════════════════════════════"
            echo "  Finished : $(date '+%d %b %Y  %H:%M:%S')"
            echo "  Result   : $status"
            echo "═══════════════════════════════════════════════════"
        } >> "$LOG_FILE"
    fi
}
