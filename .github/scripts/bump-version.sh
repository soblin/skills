#!/usr/bin/env bash
# Bump "version" in every plugin manifest and print the new version.
# Usage: bump-version.sh <major|minor|patch>
set -euo pipefail

manifests=(.claude-plugin/plugin.json .codex-plugin/plugin.json)

read_version() {
    sed -nE 's/^  "version": "([0-9]+\.[0-9]+\.[0-9]+)",?$/\1/p' "$1"
}

current=$(read_version "${manifests[0]}")
if [ -z "$current" ]; then
    echo "no version in ${manifests[0]}" >&2
    exit 1
fi
for f in "${manifests[@]}"; do
    if [ "$(read_version "$f")" != "$current" ]; then
        echo "version in $f differs from ${manifests[0]} ($current)" >&2
        exit 1
    fi
done

IFS=. read -r major minor patch <<<"$current"
case "${1:-}" in
major) next="$((major + 1)).0.0" ;;
minor) next="$major.$((minor + 1)).0" ;;
patch) next="$major.$minor.$((patch + 1))" ;;
*)
    echo "usage: $0 <major|minor|patch>" >&2
    exit 2
    ;;
esac

for f in "${manifests[@]}"; do
    sed -i -E "s/^(  \"version\": \")$current(\")/\1$next\2/" "$f"
done
echo "$next"
