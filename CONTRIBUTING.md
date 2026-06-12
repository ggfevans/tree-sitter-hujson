# Contributing to tree-sitter-hujson

## Development

### Prerequisites

- Node.js 18+
- `tree-sitter-cli`, pinned to the version CI uses:
  `npm install -g tree-sitter-cli@0.26.9`

### Build and test

Regenerate the parser at the pinned ABI (**14**) and run the corpus suite:

```bash
make generate   # = tree-sitter generate --abi 14 (the ABI lives in the Makefile)
tree-sitter test
```

The ABI is pinned in one place — `TS_ABI` in the [`Makefile`](Makefile) — and CI
runs `make generate` to verify the committed `src/` is reproducible. A bare
`tree-sitter generate` (without `--abi 14`) regenerates at a newer ABI and will
fail CI's no-op check, so always go through `make generate`. If you can't use
`make`, run `tree-sitter generate --abi 14` directly.

The corpus suite covers literals, objects, arrays, comments, trailing commas, degenerate inputs (empty, whitespace, BOM, unicode, deeply nested), and invalid inputs (the strictness-preserving rejections).

## Releasing

Releases are tag-driven, and changes accumulate under the `## [Unreleased]`
heading in [`CHANGELOG.md`](CHANGELOG.md) as they land. To cut a release:

1. Run `scripts/bump-version.sh X.Y.Z`. This updates the version in every
   manifest and **promotes the `## [Unreleased]` section to `## [X.Y.Z]`** (a
   fresh empty `## [Unreleased]` is left on top and a compare link is added), so
   the release notes are ready for that version.
2. Push a `vX.Y.Z` tag.

The [`Release`](.github/workflows/release.yml) workflow then validates the tag,
creates the GitHub Release from the `## [X.Y.Z]` changelog entry, and publishes
the bindings.

Each registry publish job runs **only** when that registry is configured,
otherwise it is skipped (the GitHub Release always succeeds):

| Registry | Authentication | Enabled by |
| --- | --- | --- |
| npm | OIDC Trusted Publishing (no stored token) | repo **variable** `NPM_TRUSTED_PUBLISHER` = `true`, plus an [npm trusted publisher](https://docs.npmjs.com/trusted-publishers/) for this repo + `release.yml` |
| PyPI | OIDC Trusted Publishing (no stored token) | repo **variable** `PYPI_TRUSTED_PUBLISHER` = `true`, plus a [PyPI trusted publisher](https://docs.pypi.org/trusted-publishers/) for this repo + `release.yml` |
| crates.io | OIDC Trusted Publishing (no stored token) | repo **variable** `CRATES_TRUSTED_PUBLISHER` = `true`, plus a [crates.io trusted publisher](https://crates.io/docs/trusted-publishing) for this repo + `release.yml` |

The Go, Swift, and C bindings are consumed directly from the git tag, so they
need no registry publish step.

To publish a registry you enabled *after* a tag was already cut, re-run the
`Release` workflow for that tag: the now-present variable flips its job on.

### Prebuild coverage

The npm tarball ships native prebuilds for **darwin-arm64**, **linux-x64**, and
**win32-x64** only. On other platforms (darwin-x64, linux-arm64, win32-arm64,
…) `node-gyp-build` falls back to compiling the parser from source at install
time, which works anywhere a C toolchain is available. This coverage is
intentional; additional prebuild targets are not currently planned.
