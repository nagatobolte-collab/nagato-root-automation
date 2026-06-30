#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  NAGATO ROOT KIT — Banner, Colors & Animations
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DARK_RED='\033[38;5;88m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Section separator ──────────────────────────────
sep() {
    echo -e "${GRAY}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ── Status printers ────────────────────────────────
log()   { echo -e "  ${GREEN}✓${NC}  $1"; }
warn()  { echo -e "  ${YELLOW}!${NC}  $1"; }
error() { echo -e "  ${RED}✗${NC}  ${RED}$1${NC}"; }
info()  { echo -e "  ${BLUE}→${NC}  $1"; }
step()  { echo -e "\n  ${CYAN}▶${NC}  ${BOLD}$1${NC}"; }
dim()   { echo -e "  ${DIM}$1${NC}"; }

# ── Spinner (background process) ──────────────────
_SPIN_PID=""
_SPIN_MSG=""

spin_start() {
    _SPIN_MSG="$1"
    local frames=('◐' '◓' '◑' '◒')
    (
        local i=0
        while true; do
            printf "\r  ${CYAN}${frames[$((i % 4))]}${NC}  $1... "
            i=$((i+1))
            sleep 0.12
        done
    ) &
    _SPIN_PID=$!
    disown "$_SPIN_PID" 2>/dev/null
}

spin_ok() {
    [ -n "$_SPIN_PID" ] && kill "$_SPIN_PID" 2>/dev/null && wait "$_SPIN_PID" 2>/dev/null
    _SPIN_PID=""
    printf "\r  ${GREEN}✓${NC}  $_SPIN_MSG${NC}\n"
}

spin_fail() {
    [ -n "$_SPIN_PID" ] && kill "$_SPIN_PID" 2>/dev/null && wait "$_SPIN_PID" 2>/dev/null
    _SPIN_PID=""
    printf "\r  ${RED}✗${NC}  $_SPIN_MSG${NC}: ${RED}${1:-failed}${NC}\n"
}

# ── Print main banner ──────────────────────────────
print_banner() {
    clear
    echo ""
    echo -e "${DARK_RED}"
    printf '  ███╗   ██╗ █████╗  ██████╗  █████╗ ████████╗ ██████╗ \n'
    printf '  ████╗  ██║██╔══██╗██╔════╝ ██╔══██╗╚══██╔══╝██╔═══██╗\n'
    printf '  ██╔██╗ ██║███████║██║  ███╗███████║   ██║   ██║   ██║\n'
    printf '  ██║╚██╗██║██╔══██║██║   ██║██╔══██║   ██║   ██║   ██║\n'
    printf '  ██║ ╚████║██║  ██║╚██████╔╝██║  ██║   ██║   ╚██████╔╝\n'
    printf '  ╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝    ╚═════╝\n'
    echo ""
    printf '  ██████╗  ██████╗  ██████╗ ████████╗    ██╗  ██╗██╗████████╗\n'
    printf '  ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝    ██║ ██╔╝██║╚══██╔══╝\n'
    printf '  ██████╔╝██║   ██║██║   ██║   ██║       █████╔╝ ██║   ██║   \n'
    printf '  ██╔══██╗██║   ██║██║   ██║   ██║       ██╔═██╗ ██║   ██║   \n'
    printf '  ██║  ██║╚██████╔╝╚██████╔╝   ██║       ██║  ██╗██║   ██║   \n'
    printf '  ╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝       ╚═╝  ╚═╝╚═╝   ╚═╝   \n'
    echo -e "${NC}"
    echo -e "  ${WHITE}${BOLD}       Professional Pixel Root Toolkit  v3.0.0 Stable${NC}"
    echo -e "  ${DIM}       $(date '+%d %b %Y  %H:%M')  •  $TOOLKIT_ROOT${NC}"
    sep
    echo ""
}
