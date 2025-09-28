"""Utilities for documenting usage."""

import sys
from typing import Callable, NoReturn

from .write import err


def usage(
    string: str,
    n_args_expected: int,
) -> tuple[str, Callable[[], NoReturn]]:
    """Return a usage string and a function meant to show it and exit."""

    def show_usage_and_exit() -> NoReturn:
        err(string)
        sys.exit(1)

    if len(sys.argv) != n_args_expected + 1:
        show_usage_and_exit()

    return (string, show_usage_and_exit)
