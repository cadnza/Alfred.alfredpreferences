#!/bin/sh

# Symlinks an item at runtime and tracks its reference such that it gets relinked when the destination changes.

set -e

# Assign arguments
name="$1"
path="$2"

# Name cache file
# shellcheck disable=SC2154
f_cache="$alfred_workflow_cache/$name.cache"

# Make sure path exists
[ -f "$path" ] || {
    echo "Not found: $path"
    exit 1
}
path="$(realpath "$path")"

# Open variable to track whether the file should be relinked
should_relink=0

# Check whether file has already been linked
[ -f "$name" ] || should_relink=1

# Make sure path value matches cache entry
[ -f "$f_cache" ] || should_relink=1
[ "$should_relink" = 0 ] && [ "$path" = "$(cat "$f_cache")" ] || should_relink=1

# Proceed to relink if needed
[ "$should_relink" = 0 ] || {

    # Create cache directory if needed
    [ -d "$alfred_workflow_cache" ] || {
        mkdir -p "$alfred_workflow_cache"
    }

    # Remove already linked file if needed
    [ -f "$name" ] && rm "$name"

    # Create link
    ln -s "$path" "$name"

    # Write path to cache
    echo "$path" >"$f_cache"

}
