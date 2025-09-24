"""Utilities for writing an Alfred script filter."""

import json
import sys
from pathlib import Path
from typing import Literal, NoReturn, NotRequired, TypedDict, Union


class _IconNoType(TypedDict):
    """An icon without a type."""

    path: Path


class _IconFileIcon(TypedDict):
    """An icon defaulting to the icon of a filepath."""

    path: Path
    type: Literal["fileicon"]


class _IconFileType(TypedDict):
    """An icon of a filetype given by a UTI (Uniform Type Identifier)."""

    path: str
    type: Literal["filetype"]


_Icon = Union[_IconNoType, _IconFileIcon, _IconFileType]

_Variables = dict[str, str]


_ModKey = Literal[
    "cmd",
    "alt",
    "ctrl",
    "shift",
    "fn",
    "cmd+alt",
    "cmd+ctrl",
    "cmd+shift",
    "cmd+fn",
    "alt+ctrl",
    "alt+shift",
    "alt+fn",
    "ctrl+shift",
    "ctrl+fn",
    "shift+fn",
    "cmd+alt+ctrl",
    "cmd+alt+shift",
    "cmd+alt+fn",
    "cmd+ctrl+shift",
    "cmd+ctrl+fn",
    "cmd+shift+fn",
    "alt+ctrl+shift",
    "alt+ctrl+fn",
    "alt+shift+fn",
    "ctrl+shift+fn",
    "cmd+alt+ctrl+shift",
    "cmd+alt+ctrl+fn",
    "cmd+alt+shift+fn",
    "cmd+ctrl+shift+fn",
    "alt+ctrl+shift+fn",
    "cmd+alt+ctrl+shift+fn",
]


class _ModValue(TypedDict):
    """A mod element."""

    valid: NotRequired[bool]
    arg: NotRequired[str]
    subtitle: NotRequired[str]
    icon: NotRequired[_Icon]
    variables: NotRequired[_Variables]


_Mod = dict[_ModKey, _ModValue]


class _Action(TypedDict):
    """A universal action."""

    text: NotRequired[Union[str, list[str]]]
    url: NotRequired[str]
    tile: NotRequired[Path]
    auto: NotRequired[Union[str, list[str], Path]]


class _Text(TypedDict):
    """A text object."""

    copy: NotRequired[str]
    largetype: NotRequired[str]


class _Cache(TypedDict):
    """A cache configuration."""

    seconds: int
    loosereload: NotRequired[Literal[True]]


class _Item(TypedDict):
    """A single item."""

    uid: NotRequired[str]
    title: str
    subtitle: NotRequired[str]
    arg: NotRequired[Union[str, list[str]]]
    icon: NotRequired[_Icon]
    valid: NotRequired[bool]
    match: NotRequired[str]
    autocomplete: NotRequired[str]
    type: NotRequired[Literal["default", "file", "file:skipcheck"]]
    mods: NotRequired[list[_Mod]]
    action: NotRequired[Union[str, list[str], _Action]]
    text: NotRequired[_Text]
    quicklookurl: NotRequired[Union[str, Path]]
    variables: NotRequired[_Variables]


class ScriptFilterJson(TypedDict):
    """An object conforming to the [script filter JSON format](https://www.alfredapp.com/help/workflows/inputs/script-filter/json/)."""

    items: list[_Item]
    variables: NotRequired[_Variables]
    rerun: NotRequired[float]
    cache: NotRequired[_Cache]
    skipknowledge: NotRequired[Literal[True]]


def send(x: ScriptFilterJson) -> NoReturn:
    """Send this script filter JSON object to Alfred."""
    j = json.dumps(x)
    sys.stdout.write(j)
    sys.exit(0)
