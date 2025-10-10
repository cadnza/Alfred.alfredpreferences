#!/usr/bin/python3

"""Opens a repo."""

import subprocess
import sys
from pathlib import Path
from typing import cast, get_args

from common.validation import one_of, usage
from utility import EditorName

# Define usage string and exit function
u, stop = usage(
    one_of(EditorName),
    "REPO",
)

# Assign editor ID argument
id_editor_raw: str = sys.argv[1]
if id_editor_raw not in get_args(EditorName):
    stop()
editor_name: EditorName = cast("EditorName", id_editor_raw)

# Assign repo argument
repo = sys.argv[2]

# Open repo

if editor_name == "Visual Studio Code":
    subprocess.run(  # noqa: S603
        [
            "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code",
            repo,
        ],
        check=True,
    )
elif editor_name == "Visual Studio Code - Insiders":
    subprocess.run(  # noqa: S603
        [
            "/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/code",  # noqa: E501
            repo,
        ],
        check=True,
    )
elif editor_name == "Positron":
    subprocess.run(  # noqa: S603
        [
            "/Applications/Positron.app/Contents/Resources/app/bin/code",
            repo,
        ],
        check=True,
    )
elif editor_name == "Zed":
    subprocess.run(  # noqa: S603
        [
            "/Applications/Zed.app/Contents/MacOS/cli",
            repo,
        ],
        check=True,
    )
elif editor_name == "Xcode":
    subprocess.run(  # noqa: S603
        [
            "/usr/bin/open",
            "-a",
            "/Applications/Xcode.app",
            repo,
        ],
        check=True,
    )
elif editor_name == "RStudio":
    subprocess.run(  # noqa: S603
        [
            "/usr/bin/open",
            "-a",
            "/Applications/RStudio.app",
            str(
                next(f for f in Path(repo).iterdir() if f.suffix.lower() == ".rproj"),
            ),
        ],
        check=True,
    )
elif editor_name == "CodeEdit":
    subprocess.run(  # noqa: S603
        [  # noqa: S607
            "codeedit",
            "open",
            repo,
        ],
        check=True,
    )
