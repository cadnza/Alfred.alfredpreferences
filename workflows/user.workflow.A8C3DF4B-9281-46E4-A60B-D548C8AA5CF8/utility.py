"""Common objects."""

from typing import Literal

EditorId = Literal[
    "code",  # Visual Studio Code
    "insiders",  # Visual Studio Code - Insiders
    "pt",  # Positron
    "rs",  # RStudio
    "zed",  # Zed
    "xc",  # Xcode
]

RepoModifier = Literal[
    "alfred",
    "none",
]
