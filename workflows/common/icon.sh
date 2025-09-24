#!/bin/sh

# Symlinks an icon at runtime.

set -e

# Assign arguments
name="$1"
path="$2"

# Make sure path exists
[ -f "$path" ] || {
    echo "Not found: $path"
    exit 1
}

# Link if missing
[ -f "$name" ] || ln -s "$(realpath "$path")" "$name"
