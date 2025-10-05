#!/bin/sh

# Check whether the given binary is in the path, writing a simple banner to stdout and exiting non-0 if not
command -v "$1" >/dev/null || {
    PYTHONPATH="$(dirname "$0")/.." /usr/bin/python3 -m alfred_script_filter.simple_banner \
        "Missing '$1'" \
        "Cannot find '$1' in \$PATH" \
        '/System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns' \
        ''
    exit 1
}
