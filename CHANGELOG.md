# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1]

### CI

- Moved the CI and release workflows off the deprecated Node 20 actions
  runtime to Node 24 majors (`actions/checkout`, `actions/setup-node`,
  `actions/upload-artifact`, `actions/download-artifact`, `actions/setup-python`,
  `softprops/action-gh-release`) ahead of GitHub's 2026-06-16 forced migration,
  and SHA-pinned every action in both workflows. No change to the published
  grammar, parser, or language bindings. (#38)

## [1.0.0]

### Added

- **First stable release.** The HuJSON (JWCC) grammar and its public node types
  (`document`, `object`, `array`, `pair`, `string`, `number`, `comment`, and the
  literal nodes) are now considered stable; future breaking changes will bump the
  major version per [Semantic Versioning](https://semver.org/).
- **Upstream sync process** documented in `UPSTREAM-SYNC.md`, establishing a
  quarterly cadence against `tree-sitter-json` (spec §11.3). First sync check
  confirmed no upstream grammar changes since our fork point
  (`001c28d7`). (#4)
- **`SECURITY.md`** with a release-driven, auto-updated supported-version
  table. (#27)

### Fixed

- **Negative-zero numbers** (`-0`, `-0.5`, `-0.0`, `-0e1`) now parse as valid
  `number` nodes instead of producing `ERROR`s. HuJSON is a strict superset of
  JSON, so every valid JSON number must parse. (#33)
- Corrected the Go binding's `go.mod` module path so the package resolves via
  `go get`. (#28)

### Changed

- The tree-sitter **ABI 14** pin is now a single source of truth (`TS_ABI` in the
  `Makefile`); `make generate` is the canonical parser-regeneration command, and
  CI verifies the committed `src/` is reproducible against it. (#35)

### Documentation

- Pre-v1.0 README revision with status badges, and the contributor guide split
  out into `CONTRIBUTING.md`. (#24)
- `scripts/bump-version.sh` now promotes the `## [Unreleased]` changelog section
  to the released version (with a fresh `[Unreleased]` and compare link). (#32)

## [0.2.3]

### CI

- First release distributed to **PyPI** (OIDC Trusted Publishing) and
  **crates.io**, completing multi-registry publishing alongside npm. No code
  changes — this release activates the previously dormant PyPI and crates.io
  publish jobs now that their publishers/credentials are configured.

## [0.2.2]

### CI

- Publish to npm via **OIDC Trusted Publishing** instead of a stored token,
  matching the existing PyPI flow. No long-lived npm credential is kept in the
  repository; npm authenticates each release through GitHub's OIDC identity and
  still attaches build provenance. (#23)

## [0.2.1]

### CI

- Upgrade npm on the Windows prebuild runner so it uses a bundled node-gyp
  `>= 12.1.0`, which can detect **Visual Studio 2026** (now preinstalled on the
  `windows-latest` image). This unblocks the Windows native prebuild and the
  project's first npm publish. (#22)

## [0.2.0]

### Changed

- **Numeric object keys are now rejected** to match JSON strictness. Previously
  bare numeric tokens could appear as object keys; they are now parse errors, so
  HuJSON object keys must be quoted strings as in standard JSON. This is a
  behaviour change relative to v0.1.0. (#11)
- Regenerated the parser at **tree-sitter ABI 14** for compatibility with current
  tree-sitter runtimes and editor integrations. (#14)
- Aligned packaging metadata across the npm, PyPI, crates.io, and C/pkg-config
  manifests so all distribution channels report consistent project information. (#10)

### Fixed

- Corrected `queries/outline.scm` so object pairs with an empty-string key still
  produce a well-formed outline item instead of an empty capture. (#12)

### CI

- Pinned the tree-sitter CLI version used in CI and assert that `tree-sitter
  generate` is a no-op against the committed `src/` files. (#14)
- Added query soundness and zero-`ERROR`-node sample-parse gates. (#14)
- Added a tag-driven release workflow publishing to npm, PyPI, and crates.io;
  each registry publish is skipped unless its credential is configured. (#15, #20)

## [0.1.0]

### Added

- Initial HuJSON (JWCC) grammar for tree-sitter: JSON with `//` and `/* */`
  comments plus trailing commas.
- Language bindings for Node, Rust, Python, Go, Swift, and C.
- Highlight, brackets, indents, and outline queries.
- Corpus tests and an example `examples/sample.hujson`.

[1.0.1]: https://github.com/ggfevans/tree-sitter-hujson/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/ggfevans/tree-sitter-hujson/compare/v0.2.3...v1.0.0
[0.2.3]: https://github.com/ggfevans/tree-sitter-hujson/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/ggfevans/tree-sitter-hujson/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/ggfevans/tree-sitter-hujson/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/ggfevans/tree-sitter-hujson/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/ggfevans/tree-sitter-hujson/releases/tag/v0.1.0
