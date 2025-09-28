#!/usr/bin/env python3

"""Provides options to Alfred."""

import re
import sys
from pathlib import Path
from typing import cast, get_args

from common.alfred_script_filter import ScriptFilterJson, send
from common.usage import one_of, usage
from common.write import err
from utility import REPO_MODIFIERS_SEPARATOR, EditorId, RepoModifier

# Define usage string and exit function
usage, stop = usage(f"DIRECTORY {one_of(EditorId)}", 2)

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
    case "positron":
        filter_repo = lambda x: True  # noqa: ARG005
    case "rstudio":

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
    case "xcode":

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


def repo_modifier(x: RepoModifier) -> RepoModifier:
    """Return a repo modifier (for type checking)."""
    return x


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
            "variables": {
                "repo_modifiers": REPO_MODIFIERS_SEPARATOR.join(
                    [
                        repo_modifier("alfred")
                        if repo.name == "Alfred.alfredpreferences"
                        else repo_modifier("none"),
                    ],
                ),
                "repo": str(repo),
            },
            "icon": {"path": str(repo), "type": "fileicon"},
        }
        for repo in repos
        if filter_repo(repo)
    ],
}

# Send it
send(output)
