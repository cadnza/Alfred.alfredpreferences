#!/usr/bin/env python3.11

"""Provides options to Alfred."""

import os
import sys
from pathlib import Path
from typing import Callable, ParamSpec, TypeVar, cast, get_args

from common.alfred_script_filter import (
    ScriptFilterJson,
    _Icon,  # pyright: ignore[reportPrivateUsage]
    send,
)
from common.alfred_workflow import get_workflow_plist_value
from common.validation import one_of, usage
from common.write import err
from utility import NAME_COMMON, EditorId

# Define usage string and exit function
u, stop = usage("DIRECTORY", one_of(EditorId))

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
    # case "rstudio":
    #     def filter_repo(x: Path) -> bool:
    #         return bool(
    #             [
    #                 p
    #                 for p in x.iterdir()
    #                 if re.search(r"\.rproj$", str(p), re.IGNORECASE)
    #             ],
    #         )
    case "zed":
        filter_repo = lambda x: True  # noqa: ARG005
    case "xcode":

        def filter_repo(x: Path) -> bool:  # noqa: D103
            return bool(
                [
                    p
                    for p in x.iterdir()
                    if p.name.lower() == "package.swift"
                    or p.suffix.lower() == ".xcodeproj"
                ],
            )
    case "rstudio":

        def filter_repo(x: Path) -> bool:  # noqa: D103
            return bool(
                [p for p in x.iterdir() if p.suffix.lower() == ".rproj"],
            )


# Decide whether this is the Alfred folder
is_alfred = dir_repos.name == os.environ["ALFRED_REPO_NAME"]

P = ParamSpec("P")
T = TypeVar("T")


def condition_on_alfred(
    if_vanilla_repo: T,
    if_alfred_workflow: Callable[P, T],
    *args: P.args,
    **kwargs: P.kwargs,
) -> T:
    """Retrieve a value conditionally on Alfred."""
    return if_alfred_workflow(*args, **kwargs) if is_alfred else if_vanilla_repo


# Get repos
repos = (
    [
        repo
        for repo in [Path(p) for p in Path.iterdir(dir_repos / "workflows")]
        if repo.is_dir()
    ]
    if is_alfred
    else [repo for repo in [Path(p) for p in Path.iterdir(dir_repos)] if repo.is_dir()]
)

# Prepare Alfred output
output: ScriptFilterJson = {
    "variables": {
        "id_editor": id_editor,
    },
    "items": [
        {
            "uid": str(repo),
            "title": condition_on_alfred(
                if_vanilla_repo=repo.name,
                if_alfred_workflow=get_workflow_plist_value,
                x="name",
                plist=repo
                / ("information.plist" if repo.name == NAME_COMMON else "info.plist"),
            ),
            "subtitle": condition_on_alfred(
                if_vanilla_repo=str(repo),
                if_alfred_workflow=get_workflow_plist_value,
                x="description",
                plist=repo
                / ("information.plist" if repo.name == NAME_COMMON else "info.plist"),
            ),
            "variables": {
                "repo": str(repo),
                "repoName": repo.name,
            },
            "icon": cast(
                "_Icon",
                condition_on_alfred(
                    if_vanilla_repo={
                        "path": str(repo),
                        "type": "fileicon",
                    },
                    if_alfred_workflow=(
                        lambda: {
                            "path": get_workflow_plist_value(
                                "modelicon",
                                plist=repo / "information.plist",  # noqa: B023
                            ),
                            "type": "fileicon",
                        }
                    )
                    if repo.name == NAME_COMMON
                    else lambda: {
                        "path": str(repo / "icon.png"),  # noqa: B023
                    },
                ),
            ),
            "type": "file:skipcheck",
            "autocomplete": condition_on_alfred(
                if_vanilla_repo=str(repo),
                if_alfred_workflow=get_workflow_plist_value,
                x="name",
                plist=repo
                / ("information.plist" if repo.name == NAME_COMMON else "info.plist"),
            ),
            "arg": str(repo),
        }
        for repo in repos
        if filter_repo(repo)
    ],
}

# Send it
send(output)
