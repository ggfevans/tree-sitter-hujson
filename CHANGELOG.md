# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.2.0]: https://github.com/ggfevans/tree-sitter-hujson/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/ggfevans/tree-sitter-hujson/releases/tag/v0.1.0
