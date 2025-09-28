"""Common objects."""

from typing import Literal

EditorId = Literal[
    "code",  # Visual Studio Code
    "insiders",  # Visual Studio Code - Insiders
    "positron",  # Positron
    "rstudio",  # RStudio
    "zed",  # Zed
    "xcode",  # Xcode
]
"""
An ID representing a specific editor.
"""

RepoModifier = Literal[
    "alfred",
    "none",
]
"""
A text tag passed with a repo to modify its handling.
"""

REPO_MODIFIERS_SEPARATOR = ","
"""
The separator used to delimit repo modifiers.
"""
