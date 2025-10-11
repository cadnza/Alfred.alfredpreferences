#!/usr/bin/python3

"""Return a simple banner given arguments _with no validation_.

- `$1`: Title
- `$2`: Subtitle
- `$3`: Icon path
- `$4`: Icon type (none if blank or unrecognized, _i.e._ forces a `_IconNoType`)
"""

import sys

from alfred_script_filter.jsn import (
    IconFileIcon,
    IconFileType,
    IconNoType,
    Item,
    ScriptFilterJson,
)

title = sys.argv[1]
subtitle = sys.argv[2]
icon_path = sys.argv[3]
icon_type = sys.argv[4]

if icon_type == "fileicon":
    icon = IconFileIcon(path=icon_path)
elif icon_type == "filetype":
    icon = IconFileType(path=icon_path)
else:
    icon = IconNoType(path=icon_path)

ScriptFilterJson(
    items=[
        Item(
            title=title,
            subtitle=subtitle,
            icon=icon,
        ),
    ],
).send()
