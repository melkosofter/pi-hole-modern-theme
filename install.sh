#!/usr/bin/env bash
# Pi-hole Modern theme installer (Pi-hole v6).
#
#   sudo ./install.sh              — install
#   sudo ./install.sh --restore    — restore the stock themes
#   sudo ./install.sh --dir PATH   — if the web interface is not in /var/www/html/admin
#
# The theme is copied over default-light.css and default-dark.css, so the
# "Pi-hole default theme (auto / light / dark)" options in Settings → Web interface / API
# become the auto / light / dark variants of this theme.
# The originals are kept next to them with the .orig extension.

set -euo pipefail

THEMES_DIR="/var/www/html/admin/style/themes"
MODE="install"

while [ $# -gt 0 ]; do
    case "$1" in
        --restore) MODE="restore" ;;
        --dir) THEMES_DIR="${2%/}/style/themes"; shift ;;
        -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

SRC="$(cd "$(dirname "$0")" && pwd)/pihole-modern.css"
TARGETS="default-light.css default-dark.css"

if [ ! -d "$THEMES_DIR" ]; then
    echo "Directory $THEMES_DIR not found — pass the web interface path with --dir" >&2
    exit 1
fi

if [ "$MODE" = "restore" ]; then
    for f in $TARGETS; do
        if [ -f "$THEMES_DIR/$f.orig" ]; then
            mv -f "$THEMES_DIR/$f.orig" "$THEMES_DIR/$f"
            echo "restored $f"
        else
            echo "no backup $f.orig — skipping"
        fi
    done
    exit 0
fi

if [ ! -f "$SRC" ]; then
    echo "$SRC not found" >&2
    exit 1
fi

for f in $TARGETS; do
    if [ ! -f "$THEMES_DIR/$f.orig" ] && [ -f "$THEMES_DIR/$f" ]; then
        cp -p "$THEMES_DIR/$f" "$THEMES_DIR/$f.orig"
    fi
    cp "$SRC" "$THEMES_DIR/$f"
    chmod 644 "$THEMES_DIR/$f"
    echo "installed $f"
done

echo
echo "Done. Open Settings → Web interface / API → Theme and pick"
echo "\"Pi-hole default theme (auto)\", \"(light)\" or \"(dark)\", then reload the page (Ctrl+F5)."
echo "'pihole -up' brings the stock files back — just run this script again afterwards."
