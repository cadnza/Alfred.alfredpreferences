"""Common objects."""

from typing import Literal

EditorName = Literal[
    "Visual Studio Code",  # Visual Studio Code
    "Visual Studio Code - Insiders",  # Visual Studio Code - Insiders
    "Positron",  # Positron
    "Zed",  # Zed
    "Xcode",  # Xcode
    "RStudio",  # RStudio
]
"""
An ID representing a specific editor.
"""

NAME_COMMON = "common"
"""
The name of the `common` directory.
"""
