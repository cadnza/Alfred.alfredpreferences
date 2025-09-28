#!/usr/bin/env python3

"""Opens a repo."""

import subprocess
import sys
from typing import cast, get_args

from common.validation import one_of, usage, zero_or_many_of
from utility import REPO_MODIFIERS_SEPARATOR, EditorId, RepoModifier

# Define usage string and exit function
u, stop = usage(
    one_of(EditorId),
    zero_or_many_of(RepoModifier),
    "REPO",
)

# Assign editor ID argument
id_editor_raw: str = sys.argv[1]
if id_editor_raw not in get_args(EditorId):
    stop()
id_editor: EditorId = cast("EditorId", id_editor_raw)

# Assign repo modifiers
repo_modifiers_raw: list[str] = sys.argv[2].split(REPO_MODIFIERS_SEPARATOR)
if any(rm not in get_args(RepoModifier) for rm in repo_modifiers_raw):
    stop()
repo_modifiers: list[RepoModifier] = [
    cast("RepoModifier", rm) for rm in repo_modifiers_raw
]

# Assign repo argument
repo = sys.argv[3]

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
