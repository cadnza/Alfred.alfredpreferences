#!/bin/sh

# Check whether the given binary is in the path, writing a simple banner to stdout and exiting non-0 if not
command -v "$1" >/dev/null || {
    PYTHONPATH="$(dirname "$0")/.." "$(dirname "$0")/../alfred_script_filter/simple_banner.py" \
        "Missing $1" \
        "Cannot find \`$1\` in \$PATH" \
        '/System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns' \
        ''
    exit 8
}
