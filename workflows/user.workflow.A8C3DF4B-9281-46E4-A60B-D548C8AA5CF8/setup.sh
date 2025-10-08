#!/bin/sh

set -e

# Assign arguments
app_name="$1"
app_bundle_path="$2"
app_icns_path="$3"
alfred_object_id="$4"

# Link common directory
[ -d common ] || ln -s "$(realpath ../common)" .

# Ensure python3.11 is in path
./common/checks/check_in_path.sh python3.11

# Ensure app is installed
./common/checks/check_installed.sh "$app_name" "$app_bundle_path"

# Link icon
./common/link.sh "$alfred_object_id.png" "$app_icns_path"
