"""
Bump the version number in pyproject.toml and devcontainer-feature.json.

This script updates:
- The `version` field in the [project] section of `pyproject.toml`
- The `version` and `openfactory-version.default` fields in
  `.devcontainer/features/infra/devcontainer-feature.json`

Usage:
    python scripts/bump_version.py <new_version>

Example:
    python scripts/bump_version.py 0.3.1

Notes:
    - Requires `tomlkit` and `json` (built-in)
    - Will exit with an error if expected fields are missing
"""

from pathlib import Path
import sys
import json
from tomlkit import parse, dumps


def bump_pyproject_version(version: str) -> None:
    pyproject_path = Path(__file__).resolve().parent.parent / "pyproject.toml"

    if not pyproject_path.exists():
        print("ERROR: pyproject.toml not found.")
        sys.exit(1)

    with pyproject_path.open("r", encoding="utf-8") as f:
        toml_doc = parse(f.read())

    if "project" not in toml_doc or "version" not in toml_doc["project"]:
        print("ERROR: [project] section or version field not found.")
        sys.exit(1)

    old_version = toml_doc["project"]["version"]
    toml_doc["project"]["version"] = version

    with pyproject_path.open("w", encoding="utf-8") as f:
        f.write(dumps(toml_doc))

    print(f"[pyproject.toml] Version updated: {old_version} → {version}")


def bump_devcontainer_version(version: str) -> None:
    json_path = (
        Path(__file__).resolve().parent.parent /
        ".devcontainer/features/infra/devcontainer-feature.json"
    )

    if not json_path.exists():
        print("ERROR: devcontainer-feature.json not found.")
        sys.exit(1)

    with json_path.open("r", encoding="utf-8") as f:
        data = json.load(f)

    if "version" not in data or "options" not in data \
       or "openfactory-version" not in data["options"] \
       or "default" not in data["options"]["openfactory-version"]:
        print("ERROR: Required fields missing in devcontainer-feature.json.")
        sys.exit(1)

    old_version = data["version"]
    old_default = data["options"]["openfactory-version"]["default"]

    data["version"] = version
    data["options"]["openfactory-version"]["default"] = f"v{version}"

    with json_path.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")

    print(f"[devcontainer-feature.json] version updated: {old_version} → {version}")
    print(f"[devcontainer-feature.json] openfactory-version.default updated: {old_default} → v{version}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: bump_version.py <new_version>")
        sys.exit(1)

    new_version = sys.argv[1]
    bump_pyproject_version(new_version)
    bump_devcontainer_version(new_version)
