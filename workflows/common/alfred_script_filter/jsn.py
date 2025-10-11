"""Utilities for writing an Alfred script filter."""

import json
import sys
from dataclasses import asdict, dataclass
from typing import Literal, NoReturn, Optional, Union


@dataclass(frozen=True)
class IconNoType:
    """An icon without a type."""

    path: str


@dataclass(frozen=True)
class IconFileIcon:
    """An icon defaulting to the icon of a filepath."""

    path: str
    type: Literal["fileicon"] = "fileicon"


@dataclass(frozen=True)
class IconFileType:
    """An icon of a filetype given by a UTI (Uniform Type Identifier)."""

    path: str
    type: Literal["filetype"] = "filetype"


Icon = Union[IconNoType, IconFileIcon, IconFileType]

Variables = dict[str, str]


ModKey = Literal[
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


@dataclass(frozen=True)
class ModValue:
    """A mod element."""

    valid: Optional[bool] = None
    arg: Optional[str] = None
    subtitle: Optional[str] = None
    icon: Optional[Icon] = None
    variables: Optional[Variables] = None


@dataclass(frozen=True)
class Action:
    """A universal action."""

    text: Optional[Union[str, list[str]]] = None
    url: Optional[str] = None
    tile: Optional[str] = None
    auto: Optional[Union[str, list[str]]] = None


@dataclass(frozen=True)
class Text:
    """A text object."""

    copy: Optional[str] = None
    largetype: Optional[str] = None


@dataclass(frozen=True)
class Cache:
    """A cache configuration."""

    seconds: int
    loosereload: Optional[Literal[True]] = None


@dataclass(frozen=True)
class Item:
    """A single item."""

    title: str
    uid: Optional[str] = None
    subtitle: Optional[str] = None
    arg: Optional[Union[str, list[str]]] = None
    icon: Optional[Icon] = None
    valid: Optional[bool] = None
    match: Optional[str] = None
    autocomplete: Optional[str] = None
    type: Optional[Literal["default", "file", "file:skipcheck"]] = None
    mods: Optional[dict[ModKey, ModValue]] = None
    action: Optional[Union[str, list[str], Action]] = None
    text: Optional[Text] = None
    quicklookurl: Optional[str] = None
    variables: Optional[Variables] = None


@dataclass(frozen=True)
class ScriptFilterJson:
    """An object conforming to the [script filter JSON format](https://www.alfredapp.com/help/workflows/inputs/script-filter/json/)."""

    items: list[Item]
    variables: Optional[Variables] = None
    rerun: Optional[float] = None
    cache: Optional[Cache] = None
    skipknowledge: Optional[Literal[True]] = None

    def send(self) -> NoReturn:
        """Send this script filter JSON object to Alfred."""
        j = json.dumps(asdict(self))
        sys.stdout.write(j)
        sys.exit(0)
