#!/usr/bin/python3

"""Provides options to Alfred."""

import os
import sys
from collections.abc import Callable
from pathlib import Path
from typing import TypeVar, cast, get_args

from common.alfred_script_filter.jsn import (
    IconFileIcon,
    IconNoType,
    Item,
    ScriptFilterJson,
)
from common.alfred_workflow import get_workflow_plist_value
from common.validation import one_of, usage
from common.write import err
from utility import NAME_COMMON, EditorName

# Define usage string and exit function
u, stop = usage("DIRECTORY", one_of(EditorName))

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
if id_editor_raw not in get_args(EditorName):
    stop()
editor_name: EditorName = cast("EditorName", id_editor_raw)

# Define closure to decide which repos get shown
if editor_name in {
    "Visual Studio Code",
    "Visual Studio Code - Insiders",
    "Positron",
    "Zed",
}:
    filter_repo = lambda x: True  # noqa: ARG005
elif editor_name == "Xcode":

    def filter_repo(x: Path) -> bool:  # noqa: D103
        return bool(
            [
                p
                for p in x.iterdir()
                if p.name.lower() == "package.swift" or p.suffix.lower() == ".xcodeproj"
            ],
        )
elif editor_name == "RStudio":

    def filter_repo(x: Path) -> bool:  # noqa: D103
        return bool(
            [p for p in x.iterdir() if p.suffix.lower() == ".rproj"],
        )
elif editor_name == "CodeEdit":
    filter_repo = lambda x: True  # noqa: ARG005
else:
    msg = "Invalid editor ID"
    raise ValueError(msg)


# Decide whether this is the Alfred folder
is_alfred = dir_repos.name == os.environ["ALFRED_REPO_NAME"]

T = TypeVar("T")


def condition_on_alfred(
    if_vanilla_repo: T,
    if_alfred_workflow: Callable[..., T],
    *args,
    **kwargs,
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
output = ScriptFilterJson(
    variables={
        "id_editor": editor_name,
    },
    items=[
        Item(
            uid=str(repo),
            title=condition_on_alfred(
                if_vanilla_repo=repo.name,
                if_alfred_workflow=get_workflow_plist_value,
                x="name",
                plist=repo
                / ("information.plist" if repo.name == NAME_COMMON else "info.plist"),
            ),
            subtitle=condition_on_alfred(
                if_vanilla_repo=str(repo),
                if_alfred_workflow=get_workflow_plist_value,
                x="description",
                plist=repo
                / ("information.plist" if repo.name == NAME_COMMON else "info.plist"),
            ),
            variables={
                "repo": str(repo),
                "repoName": repo.name,
            },
            icon=condition_on_alfred(
                if_vanilla_repo=IconFileIcon(
                    path=str(repo),
                ),
                if_alfred_workflow=(
                    lambda: IconFileIcon(
                        path=get_workflow_plist_value(
                            "modelicon",
                            plist=repo / "information.plist",  # noqa: B023
                        ),
                    )
                )
                if repo.name == NAME_COMMON
                else lambda: IconNoType(
                    path=str(repo / "icon.png"),  # noqa: B023
                ),
            ),
            type="file:skipcheck",
            autocomplete=condition_on_alfred(
                if_vanilla_repo=str(repo.name),
                if_alfred_workflow=get_workflow_plist_value,
                x="name",
                plist=repo
                / ("information.plist" if repo.name == NAME_COMMON else "info.plist"),
            ),
            arg=str(repo),
        )
        for repo in repos
        if filter_repo(repo)
    ],
)

# Send it
output.send()
