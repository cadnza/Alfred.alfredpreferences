#!/usr/bin/env python3

"""Provides options to Alfred."""

import re
import sys
from pathlib import Path
from typing import NoReturn, cast, get_args

from common.alfred_script_filter import ScriptFilterJson, send
from common.write import err
from universal import EditorId

# Define usage string and exit function
usage = f"options.py DIRECTORY [{'|'.join(get_args(EditorId))}]"


def stop() -> NoReturn:
    """Print usage and exit."""
    err(usage)
    sys.exit(1)


# Validate argument count
n_args = 3
if len(sys.argv) != n_args:
    stop()

# Assign ad validate directory argument
dir_repos = Path(sys.argv[1])
if not dir_repos.exists():
    err(f"NOT FOUND: {dir_repos}")
    sys.exit(1)
if not dir_repos.is_dir():
    err(f"NOT A DIRECTORY: {dir_repos}")
    sys.exit(1)

# Assign editor ID argument
id_editor_raw: str = sys.argv[2]
if id_editor_raw not in get_args(EditorId):
    stop()
id_editor: EditorId = cast("EditorId", id_editor_raw)

# Define closure to decide which repos get shown
match id_editor:
    case "code":
        filter_repo = lambda x: True  # noqa: ARG005
    case "insiders":
        filter_repo = lambda x: True  # noqa: ARG005
    case "pt":
        filter_repo = lambda x: True  # noqa: ARG005
    case "rs":

        def filter_repo(x: Path) -> bool:  # noqa: D103
            return bool(
                [
                    p
                    for p in x.iterdir()
                    if re.search(r"\.rproj$", str(p), re.IGNORECASE)
                ],
            )
    case "zed":
        filter_repo = lambda x: True  # noqa: ARG005
    case "xc":

        def filter_repo(x: Path) -> bool:  # noqa: D103
            return bool(
                [
                    p
                    for p in x.iterdir()
                    if re.search(
                        r"(\.xcodeproj$|^package.swift$)",
                        p.name,
                        re.IGNORECASE,
                    )
                ],
            )


# Prepare Alfred output
repos = [repo for repo in [Path(p) for p in Path.iterdir(dir_repos)] if repo.is_dir()]
output: ScriptFilterJson = {
    "variables": {
        "id_editor": id_editor,
    },
    "items": [
        {
            "title": repo.name,
            "subtitle": str(repo),
            "arg": [
                str(repo),
                "is_alfred"
                if repo.name == "Alfred.alfredpreferences"
                else "not_alfred",
            ],
            "icon": {"path": str(repo), "type": "fileicon"},
        }
        for repo in repos
        if filter_repo(repo)
    ],
}

# Send it
send(output)
