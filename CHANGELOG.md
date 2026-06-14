# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0]

### Changed

- **Grammar tightened to RFC 8259 strictness.** HuJSON/JWCC adds nothing to JSON
  number or string syntax, so inputs that are invalid JSON now surface `ERROR`
  nodes instead of parsing cleanly: numbers require digits after the decimal
  point and no longer allow a leading dot (`.5`, `-.5`, `1.`, `1.e5`); a document
  has exactly one root value, which also enforces the no-leading-zeros rule
  (`01`, `007`, and multiple sibling values like `1 2`); and strings reject raw
  control characters U+0000–U+001F. Valid JSON and the public node types are
  unaffected. (#42, #43, #44, #53)
- **Rust binding** now exposes `LANGUAGE` as a `tree_sitter_language::LanguageFn`
  (the current tree-sitter template API), decoupling the crate from
  tree-sitter's internal `Language` representation. The old `language()` function
  is **deprecated** but retained as a shim and will be removed in 2.0; the
  `tree-sitter` dependency is now bounded (`>=0.23, <0.27`). (#47)
- **Runtime dependency pins bumped** to current tree-sitter: the npm
  `tree-sitter` peer dependency is now `^0.25.0` and the Python `core` extra is
  `~=0.25`. (#48)
- **Go binding restructured** to a repository-root `go.mod` module — import it as
  `github.com/ggfevans/tree-sitter-hujson/bindings/go` — using the official
  `tree-sitter/go-tree-sitter` runtime. (#55)
- **Python binding** migrated to the `PyCapsule` language API for compatibility
  with py-tree-sitter 0.22+. (#55)
- `npm run build` now delegates to `make generate`, so the ABI 14 pin
  (`TS_ABI` in the `Makefile`) is the single source of truth. (#45)

### Added

- `tree-sitter.json` is now shipped in the npm and crates.io packages so
  CLI 0.24+ tooling can read grammar metadata from installed packages. (#55)

### Fixed

- Anchored the injection regex to `^hujson$`, unified the package description
  across every manifest, and added `authors` and a `Repository` URL to the
  Python package metadata. (#55)
- Restored the upstream copyright notice and polished repo infrastructure. (#41)

### CI

- Bindings are now smoke-built on Linux, macOS, and Windows on every PR
  (Node `require`, `cargo check`, Python wheel, `go test`), and a `tree-sitter
  fuzz` job runs against the corpus. (#52, #54)
- Added CodeQL code scanning (C/C++, JavaScript, Python, Actions) and an OpenSSF
  Scorecard workflow, and extended Dependabot to the GitHub Actions and pip
  ecosystems. (#50, #51)
- **Hardened the release path:** the release workflow verifies the tag matches
  every manifest version before publishing, crates.io now publishes via OIDC
  trusted publishing (no stored token), and all publish jobs run behind a
  protected `release` environment. The default branch requires PRs and green
  checks, and `v*` tag creation is restricted. (#46, #49, #56)

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

[Unreleased]: https://github.com/ggfevans/tree-sitter-hujson/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/ggfevans/tree-sitter-hujson/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/ggfevans/tree-sitter-hujson/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/ggfevans/tree-sitter-hujson/compare/v0.2.3...v1.0.0
[0.2.3]: https://github.com/ggfevans/tree-sitter-hujson/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/ggfevans/tree-sitter-hujson/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/ggfevans/tree-sitter-hujson/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/ggfevans/tree-sitter-hujson/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/ggfevans/tree-sitter-hujson/releases/tag/v0.1.0
