#!/bin/bash

set -e

# ─────────────────────────────
# AUTO VERSION SYSTEM
# ─────────────────────────────

cd "$(dirname "$0")"

echo "▶ Checking git status..."

git add .

# get last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v4.0.0")

echo "Last tag: $LAST_TAG"

# extract version numbers
BASE=$(echo $LAST_TAG | cut -d. -f1)
MAJOR=$(echo $LAST_TAG | cut -d. -f2)
MINOR=$(echo $LAST_TAG | cut -d. -f3)

# increment patch version
NEW_MINOR=$((MINOR + 1))
NEW_TAG="${BASE}.${MAJOR}.${NEW_MINOR}"

echo "New version: $NEW_TAG"

git commit -m "Auto release $NEW_TAG" || echo "No changes to commit"

git push origin main

git tag "$NEW_TAG"
git push origin "$NEW_TAG"

gh release create "$NEW_TAG" \
  --title "NAGATO ROOT KIT $NEW_TAG Auto Release" \
  --notes "Auto-generated release from system update"

echo "✓ Release complete: $NEW_TAG"
