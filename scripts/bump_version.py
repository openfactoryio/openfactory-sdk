"""
Bump the version number in pyproject.toml and devcontainer-feature.json.

This script updates:
- The `version` field in the [project] section of `pyproject.toml`
- The `version` and `openfactory-version.default` fields in
  `.devcontainer/features/infra/devcontainer-feature.json`

Usage:
    python scripts/bump_version.py <new_version>

Arguments:
    <new_version> — A semantic version string (e.g., 0.4.0), or the special keyword "dev"

Behavior:
- If <new_version> is a semantic version (e.g., 0.4.0):
    • Sets that version in both pyproject.toml and devcontainer-feature.json
    • Sets openfactory-version.default in the JSON to "v<new_version>"

- If <new_version> is "dev":
    • Transforms the current version in both files to "<base>-dev.1"
      (e.g., from 0.4.0 → 0.4.0-dev.1)
    • Sets openfactory-version.default in the JSON to "main"

    This is used to create a consistent pre-release version (used during active development),
    allowing downstream components to rely on a stable `dev` tag for CI/CD integration.

Notes:
    - Will exit with an error if expected fields are missing or files do not exist
    - Prints the final version string to stdout (for use in GitHub Actions)

Dependency:
    - Requires `tomlkit` (install with `pip install tomlkit`)
"""

from pathlib import Path
import sys
import json
from tomlkit import parse, dumps


def bump_pyproject_version(version: str) -> None:
    """
    Update the version in pyproject.toml.

    If the version is "dev", it transforms the current version to "<base>-dev.1".
    Otherwise, sets the version to the provided semantic version.

    Args:
        version (str): The new version string, e.g., "0.4.0" or the special keyword "dev".

    Returns:
        str: The final version string written to pyproject.toml

    Raises:
        SystemExit: If the pyproject.toml file is missing or malformed.
    """
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

    if version == "dev":
        base_version = old_version.split("-")[0]
        new_version = f"{base_version}-dev.1"
    else:
        new_version = version

    toml_doc["project"]["version"] = new_version

    with pyproject_path.open("w", encoding="utf-8") as f:
        f.write(dumps(toml_doc))

    print(f"[pyproject.toml] Version updated: {old_version} → {new_version}")
    return new_version


def bump_devcontainer_version(version: str) -> None:
    """
    Update the version and openfactory-version.default in devcontainer-feature.json.

    If the version is "dev", it transforms the current version to "<base>-dev.1"
    and sets openfactory-version.default to "main". Otherwise, it sets the version
    and default tag based on the semantic version provided.

    Args:
        version (str): The new version string, e.g., "0.4.0" or the special keyword "dev".

    Raises:
        SystemExit: If the JSON file is missing or required fields are not found.
    """
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

    if version == "dev":
        base_version = old_version.split("-")[0]
        new_version = f"{base_version}-dev.1"
        data["version"] = new_version
        data["options"]["openfactory-version"]["default"] = "main"
    else:
        data["version"] = version
        data["options"]["openfactory-version"]["default"] = f"v{version}"

    with json_path.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")

    print(f"[devcontainer-feature.json] version updated: {old_version} → {data['version']}")
    print(f"[devcontainer-feature.json] openfactory-version.default updated: {old_default} → {data['options']['openfactory-version']['default']}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: bump_version.py <new_version>")
        sys.exit(1)

    new_version = sys.argv[1]
    final_version = bump_pyproject_version(new_version)
    bump_devcontainer_version(new_version)

    # print final version for workflow to capture
    print(final_version)
