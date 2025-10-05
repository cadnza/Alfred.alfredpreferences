"""Return a simple banner given arguments _with no validation_.

- `$1`: Title
- `$2`: Subtitle
- `$3`: Icon path
- `$4`: Icon type (none if blank or unrecognized, _i.e._ forces a `_IconNoType`)
"""

import json
import sys

from write import out

title = sys.argv[1]
subtitle = sys.argv[2]
icon_path = sys.argv[3]
icon_type = sys.argv[4]

if icon_type == "fileicon":
    icon = {
        "path": icon_path,
        "type": "filepath",
    }
elif icon_type == "filetype":
    icon = {
        "path": icon_path,
        "type": "filetype",
    }
else:
    icon = {
        "path": icon_path,
    }

out(
    json.dumps(
        {
            "items": [
                {
                    "title": title,
                    "subtitle": subtitle,
                    "icon": icon,
                },
            ],
        },
    ),
)
