#!/bin/bash

set -e

echo "▶ Smart Versioning System Starting..."

cd "$(dirname "$0")"

git add .

# get last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v4.0.0")

BASE=$(echo $LAST_TAG | cut -d. -f1 | tr -d 'v')
MAJOR=$(echo $LAST_TAG | cut -d. -f2)
MINOR=$(echo $LAST_TAG | cut -d. -f3)

echo "Last version: $LAST_TAG"

# ─────────────────────────────
# ANALYZE CHANGES
# ─────────────────────────────

FILES_CHANGED=$(git diff --cached --name-only)

echo "Changed files:"
echo "$FILES_CHANGED"

# default bump type
BUMP="patch"

# detect major change
if echo "$FILES_CHANGED" | grep -E "root_pixel.sh|PLUGINS/core|CORE" >/dev/null; then
    BUMP="major"
elif echo "$FILES_CHANGED" | grep -E "PLUGINS|install|menu|device" >/dev/null; then
    BUMP="minor"
else
    BUMP="patch"
fi

echo "Detected change type: $BUMP"

# ─────────────────────────────
# CALCULATE VERSION
# ─────────────────────────────

if [ "$BUMP" = "major" ]; then
    BASE=$((BASE + 1))
    MAJOR=0
    MINOR=0
elif [ "$BUMP" = "minor" ]; then
    MINOR=$((MINOR + 1))
else
    MINOR=$((MINOR + 1))
fi

NEW_TAG="v${BASE}.${MAJOR}.${MINOR}"

echo "New version: $NEW_TAG"

# ─────────────────────────────
# COMMIT + PUSH
# ─────────────────────────────

git commit -m "Smart release $NEW_TAG ($BUMP)" || echo "No changes"

git push origin main

git tag "$NEW_TAG"
git push origin "$NEW_TAG"

# ─────────────────────────────
# RELEASE NOTES
# ─────────────────────────────

NOTES_FILE="/tmp/release_notes.md"

echo "## 🚀 Smart Release $NEW_TAG" > $NOTES_FILE
echo "" >> $NOTES_FILE
echo "### Change Type: $BUMP" >> $NOTES_FILE
echo "" >> $NOTES_FILE
echo "### Files changed:" >> $NOTES_FILE
echo "$FILES_CHANGED" >> $NOTES_FILE

gh release create "$NEW_TAG" \
  --title "NAGATO ROOT KIT $NEW_TAG ($BUMP)" \
  --notes-file $NOTES_FILE

echo "✓ Smart release complete: $NEW_TAG"
