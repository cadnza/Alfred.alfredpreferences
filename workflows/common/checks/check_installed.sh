#!/bin/sh

# Check whether the given app is installed, writing a simple banner to stdout and exiting non-0 if not
[ -d "$2" ] || {
    PYTHONPATH="$(dirname "$0")/.." /usr/bin/python3 -m alfred_script_filter.simple_banner \
        "$1 not installed" \
        "Please install $1" \
        '/System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns' \
        ''
    exit 1
}
