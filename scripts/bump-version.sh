#!/usr/bin/env bash
#
# bump-version.sh — single source of truth for the project version.
#
# Updates the version string in all six manifests together so they can never
# drift apart:
#   - package.json      ("version": "X.Y.Z")
#   - tree-sitter.json  ("version": "X.Y.Z" under "metadata")
#   - Cargo.toml        (version = "X.Y.Z" in [package])
#   - pyproject.toml    (version = "X.Y.Z" in [project])
#   - Makefile          (VERSION := X.Y.Z)
#   - SECURITY.md       (supported version row in the table)
#
# It also promotes the CHANGELOG "## [Unreleased]" section to "## [X.Y.Z]" (with
# a fresh empty [Unreleased] left on top and a compare link added), so the
# release workflow can extract the notes for the new version.
#
# Idempotent: re-running with the current version is a no-op (manifest edits
# re-apply cleanly and the CHANGELOG promotion is skipped once "## [X.Y.Z]"
# exists). Each edit is anchored to the specific field so unrelated occurrences
# (e.g. dependency version constraints) are left untouched.
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
if ! printf '%s' "$VERSION" | grep -qE '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-((0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*)(\.(0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*))*))?$'; then
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

#   - SECURITY.md: both version cells in the supported-versions table.
#     Row 1: the latest release version (anchored to a table cell starting with a digit).
#     Row 2: the "< previous.version" cell (anchored to a table cell starting with "< ").
#     Both patterns anchor on the markdown-pipe cell boundary and the version
#     token itself, not on emoji shortcodes, so they tolerate emoji changes.
sed_inplace -E "s/^(\| (< )?)[0-9][0-9A-Za-z._-]*/\1${VERSION}/" SECURITY.md

#   - CHANGELOG.md: promote the "## [Unreleased]" section to "## [${VERSION}]" so
#     the release workflow (which extracts notes by version header) finds them.
#     A fresh empty "## [Unreleased]" is left on top, and a compare link is added.
#     Idempotent: a no-op when "## [${VERSION}]" already exists or there is no
#     "## [Unreleased]" section. PREV is captured BEFORE the new header is
#     inserted, so it is the previous released version.
ESCAPED_VERSION="$(printf '%s' "$VERSION" | sed 's/\./\\./g')"
if grep -q '^## \[Unreleased\]$' CHANGELOG.md && ! grep -qE "^## \[${ESCAPED_VERSION}\]" CHANGELOG.md; then
  # The grep exits non-zero when there is no prior version header (e.g. a first
  # release); `|| true` keeps set -o pipefail / set -e from aborting here, so
  # PREV is left empty and the compare link below is skipped.
  PREV="$(grep -m1 -E '^## \[[0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md | sed -E 's/^## \[([0-9][0-9A-Za-z.+-]*)\].*/\1/' || true)"
  REPO_URL="https://github.com/ggfevans/tree-sitter-hujson"
  # Reseed an empty [Unreleased] and rename the old one to [VERSION].
  awk -v ver="$VERSION" '
    !promoted && /^## \[Unreleased\]$/ {
      print "## [Unreleased]"; print ""; print "## [" ver "]"; promoted=1; next
    }
    { print }
  ' CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md
  # Add the compare link above the most recent version link (skipped when there
  # is no prior version). The key regex matches any SemVer link key including
  # prerelease suffixes (e.g. [1.0.0-rc.1]:), and the END block appends as a
  # fallback when the link block has no version entry to anchor against.
  if [ -n "$PREV" ]; then
    awk -v ver="$VERSION" -v prev="$PREV" -v url="$REPO_URL" '
      !linked && /^\[[0-9][0-9A-Za-z.+-]*\]:/ {
        print "[" ver "]: " url "/compare/v" prev "...v" ver; linked=1
      }
      { print }
      END { if (!linked) print "[" ver "]: " url "/compare/v" prev "...v" ver }
    ' CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md
  fi
  # Re-point the [Unreleased] link reference at the new tag so the fresh
  # "## [Unreleased]" header keeps a live compare link. A no-op when the
  # link line is absent.
  sed_inplace -E "s|^\[Unreleased\]:.*|[Unreleased]: ${REPO_URL}/compare/v${VERSION}...HEAD|" CHANGELOG.md
  echo "Promoted CHANGELOG [Unreleased] -> [${VERSION}]${PREV:+ (compare v${PREV}...v${VERSION})}"
fi

echo "Bumped all manifests to ${VERSION}:"
grep -H '"version"' package.json tree-sitter.json
grep -HE '^version[[:space:]]*=' Cargo.toml pyproject.toml
grep -HE '^VERSION[[:space:]]*:=' Makefile
count=$(grep -cE "\|.*${VERSION}" SECURITY.md) && [ "$count" -eq 2 ]
