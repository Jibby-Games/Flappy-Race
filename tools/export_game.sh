#!/bin/bash
set -e

GODOT=${GODOT:-godot3}
VERSION=$(grep 'config/version=' project.godot | sed 's/config\/version="v\(.*\)"/\1/')

PRESETS=("windows"        "mac"            "linux"             "html5")
FILES=(  "FlappyRace.exe" "FlappyRace.zip" "FlappyRace.x86_64" "index.html")

FILTER="$1"
if [ -n "$FILTER" ]; then
    found=false
    for p in "${PRESETS[@]}"; do
        if [ "$p" = "$FILTER" ]; then found=true; break; fi
    done
    if [ "$found" = false ]; then
        echo "Unknown preset '$FILTER'. Valid presets: ${PRESETS[*]}" >&2
        exit 1
    fi
fi

for i in "${!PRESETS[@]}"; do
    preset="${PRESETS[$i]}"
    if [ -n "$FILTER" ] && [ "$preset" != "$FILTER" ]; then continue; fi
    dir="builds/${preset}"
    file="${FILES[$i]}"

    echo "Exporting ${preset}..."
    rm -rf "${dir:?}"/*
    mkdir -p "$dir"
    "$GODOT" --no-window --export "$preset" "$dir/$file"

    echo "Zipping ${preset}..."
    dest="builds/FlappyRace-${VERSION}-${preset}.zip"
    if [ "$preset" = "mac" ]; then
        # Mac exports already come as a zip, so just move it
        mv -f "$dir/$file" "$dest"
    else
        cd "$dir"
        zip -f "$dest" *
        cd - > /dev/null
    fi
    echo "Created $dest"
done

echo "All exports and zips complete!"
