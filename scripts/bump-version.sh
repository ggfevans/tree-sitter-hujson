#!/usr/bin/env bash
#
# bump-version.sh — single source of truth for the project version.
#
# Updates the version string in all five manifests together so they can never
# drift apart:
#   - package.json      ("version": "X.Y.Z")
#   - tree-sitter.json  ("version": "X.Y.Z" under "metadata")
#   - Cargo.toml        (version = "X.Y.Z" in [package])
#   - pyproject.toml    (version = "X.Y.Z" in [project])
#   - Makefile          (VERSION := X.Y.Z)
#
# Idempotent: re-running with the current version is a no-op. Each edit is
# anchored to the specific field so unrelated occurrences (e.g. dependency
# version constraints) are left untouched.
#
# Usage: scripts/bump-version.sh X.Y.Z
#
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 X.Y.Z[-prerelease]" >&2
  exit 2
fi

VERSION="$1"

# Validate SemVer (matches the tag check in .github/workflows/release.yml,
# minus the leading 'v'). This also guarantees VERSION contains no characters
# that are special to sed, so it is safe to interpolate into the patterns below.
if ! printf '%s' "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$'; then
  echo "error: '$VERSION' is not a valid SemVer version (expected X.Y.Z or X.Y.Z-prerelease)" >&2
  exit 1
fi

# Resolve repo root from this script's location so it works from any CWD.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

# Portable in-place sed (GNU vs BSD/macOS differ on the -i argument).
sed_inplace() {
  if sed --version >/dev/null 2>&1; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

# Each replacement is anchored:
#   - package.json / tree-sitter.json: a top-level-indented "version": "..."
#     key. Both files use two-space indentation for that key, which avoids the
#     deeper-nested keys and dependency specs.
sed_inplace -E "s/^([[:space:]]*\"version\"[[:space:]]*:[[:space:]]*\")[^\"]*(\")/\1${VERSION}\2/" package.json
sed_inplace -E "s/^([[:space:]]*\"version\"[[:space:]]*:[[:space:]]*\")[^\"]*(\")/\1${VERSION}\2/" tree-sitter.json

#   - Cargo.toml / pyproject.toml: a line that starts with `version = "..."`
#     (no leading indentation), which is the [package]/[project] field and not
#     a dependency entry like `tree-sitter = ">=0.22.6"`.
sed_inplace -E "s/^(version[[:space:]]*=[[:space:]]*\")[^\"]*(\")/\1${VERSION}\2/" Cargo.toml
sed_inplace -E "s/^(version[[:space:]]*=[[:space:]]*\")[^\"]*(\")/\1${VERSION}\2/" pyproject.toml

#   - Makefile: the `VERSION := X.Y.Z` assignment at the top.
sed_inplace -E "s/^(VERSION[[:space:]]*:=[[:space:]]*).*/\1${VERSION}/" Makefile

echo "Bumped all manifests to ${VERSION}:"
grep -H '"version"' package.json tree-sitter.json
grep -HE '^version[[:space:]]*=' Cargo.toml pyproject.toml
grep -HE '^VERSION[[:space:]]*:=' Makefile
