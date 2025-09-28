"""General utilities for working with Alfred workflows."""

import plistlib
from pathlib import Path
from typing import Any


def get_workflow_plist_value(x: str, plist: Path = Path("info.plist")) -> Any:  # noqa: ANN401
    """Retrieve a value from this workflow's plist."""
    with plist.open("rb") as f:
        p = plistlib.load(f)
        return p[x]
