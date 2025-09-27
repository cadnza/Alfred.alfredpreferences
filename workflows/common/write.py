"""Utilities for writing to standard streams."""

import sys
from typing import Any


def out(x: Any, end: str = "\n") -> None:  # noqa: ANN401
    """Write to `stdout`."""
    sys.stdout.write(f"{x}{end}")


def err(x: Any, end: str = "\n") -> None:  # noqa: ANN401
    """Write to `stderr`."""
    sys.stderr.write(f"{x}{end}")
