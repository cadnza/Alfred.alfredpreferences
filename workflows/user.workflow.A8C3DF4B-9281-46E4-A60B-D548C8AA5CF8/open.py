#!/usr/bin/env python3.11

"""Opens a repo."""

import subprocess
import sys
from pathlib import Path
from typing import cast, get_args

from common.validation import one_of, usage
from utility import EditorId

# Define usage string and exit function
u, stop = usage(
    one_of(EditorId),
    "REPO",
)

# Assign editor ID argument
id_editor_raw: str = sys.argv[1]
if id_editor_raw not in get_args(EditorId):
    stop()
id_editor: EditorId = cast("EditorId", id_editor_raw)

# Assign repo argument
repo = sys.argv[2]

# Open repo
match id_editor:
    case "code":
        subprocess.run(  # noqa: S603
            [
                "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code",
                repo,
            ],
            check=True,
        )
    case "insiders":
        subprocess.run(  # noqa: S603
            [
                "/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/code",  # noqa: E501
                repo,
            ],
            check=True,
        )
    case "positron":
        subprocess.run(  # noqa: S603
            [
                "/Applications/Positron.app/Contents/Resources/app/bin/code",
                repo,
            ],
            check=True,
        )
    case "zed":
        subprocess.run(  # noqa: S603
            [
                "/Applications/Zed.app/Contents/MacOS/cli",
                repo,
            ],
            check=True,
        )
    case "xcode":
        subprocess.run(  # noqa: S603
            [
                "/usr/bin/open",
                "-a",
                "/Applications/Xcode.app",
                repo,
            ],
            check=True,
        )
    case "rstudio":
        subprocess.run(  # noqa: S603
            [
                "/usr/bin/open",
                "-a",
                "/Applications/RStudio.app",
                str(
                    next(
                        f for f in Path(repo).iterdir() if f.suffix.lower() == ".rproj"
                    ),
                ),
            ],
            check=True,
        )
