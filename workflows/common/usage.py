"""Utilities for documenting usage."""

import sys
from pathlib import Path
from typing import Any, Callable, NoReturn, get_args

from .write import err


def usage(
    string: str,
    n_args_expected: int,
) -> tuple[str, Callable[[], NoReturn]]:
    """Return a usage string and a function meant to show it and exit."""
    string_updated = f"{Path(sys.argv[0]).name} {string}"

    def show_usage_and_exit() -> NoReturn:
        err(string_updated)
        sys.exit(1)

    if len(sys.argv) != n_args_expected + 1:
        show_usage_and_exit()

    return (string_updated, show_usage_and_exit)


def one_of(t: Any) -> str:
    """Return type variants as a one-of string for usage."""
    return f"[{'|'.join(get_args(t))}]"


def zero_or_many_of(t: Any) -> str:
    """Return type variants as a zero-or-many-of string for usage."""
    return f"[{','.join(get_args(t))}]"
