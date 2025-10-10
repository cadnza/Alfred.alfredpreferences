"""Utilities for writing an Alfred script filter."""

import json
import sys
from typing import Literal, NoReturn, TypedDict, Union


class _IconNoType(TypedDict):
    """An icon without a type."""

    path: str


class _IconFileIcon(TypedDict):
    """An icon defaulting to the icon of a filepath."""

    path: str
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

    valid: bool
    arg: str
    subtitle: str
    icon: _Icon
    variables: _Variables


_Mod = dict[_ModKey, _ModValue]


class _Action(TypedDict):
    """A universal action."""

    text: Union[str, list[str]]
    url: str
    tile: str
    auto: Union[str, list[str]]


class _Text(TypedDict):
    """A text object."""

    copy: str
    largetype: str


class _Cache(TypedDict):
    """A cache configuration."""

    seconds: int
    loosereload: Literal[True]


class _Item(TypedDict):
    """A single item."""

    uid: str
    title: str
    subtitle: str
    arg: Union[str, list[str]]
    icon: _Icon
    valid: bool
    match: str
    autocomplete: str
    type: Literal["default", "file", "file:skipcheck"]
    mods: list[_Mod]
    action: Union[str, list[str], _Action]
    text: _Text
    quicklookurl: str
    variables: _Variables


class ScriptFilterJson(TypedDict):
    """An object conforming to the [script filter JSON format](https://www.alfredapp.com/help/workflows/inputs/script-filter/json/)."""

    items: list[_Item]
    variables: _Variables
    rerun: float
    cache: _Cache
    skipknowledge: Literal[True]


def send(x: ScriptFilterJson) -> NoReturn:
    """Send this script filter JSON object to Alfred."""
    j = json.dumps(x)
    sys.stdout.write(j)
    sys.exit(0)
