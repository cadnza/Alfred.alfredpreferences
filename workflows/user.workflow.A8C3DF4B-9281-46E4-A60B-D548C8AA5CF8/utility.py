"""Common objects."""

from typing import Literal

EditorId = Literal[
    "code",  # Visual Studio Code
    "insiders",  # Visual Studio Code - Insiders
    "positron",  # Positron
    "zed",  # Zed
    "xcode",  # Xcode
    "rstudio",  # RStudio
]
"""
An ID representing a specific editor.
"""

NAME_COMMON = "common"
"""
The name of the `common` directory.
"""
