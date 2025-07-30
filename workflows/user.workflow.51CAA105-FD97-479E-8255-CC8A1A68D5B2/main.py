#!/usr/bin/env python3

import json
import os
import re
import sys
import tomllib
from pathlib import Path
from typing import Any, Dict

# Get crate source directory
d_src = Path(
    f"{os.getenv("HOME")}/.cargo/registry/src"
)
d_crates = Path(
    d_src / [
        d
        for d in os.listdir(d_src)
        if re.compile(r"^index\.crates\.io").match(d)
    ][0]
)


def parse_toml(path: Path) -> Dict[str, Any]:
    """
    Parses `Cargo.toml` files.
    """
    with open(path, "rb") as f:
        data = tomllib.load(f)
        pkg = data["package"]
        url = f"https://docs.rs/{pkg["name"]}/{pkg["version"]}"
        return {
            "uid": pkg["name"] + pkg["version"],
            "title": pkg["name"],
            "subtitle": f"{pkg["version"]} - {pkg["description"]}",
            "arg": url,
            "icon": {
                "path": "icon.png"
            },
            "autocomplete": pkg["name"],
            "text": {
                "copy": pkg["name"],
                "largetype": pkg["description"]
            },
            "quicklookurl": url
        }


# Get crate data
crates = [
    parse_toml(toml)
    for toml
    in [
        Path(d_crates / d / "Cargo.toml")
        for d
        in os.listdir(d_crates)
    ]
]

# Return
sys.stdout.write(json.dumps({"items": crates}))
