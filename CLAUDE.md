# tree-sitter-hujson — repo conventions

Project-specific guidance for Claude Code (and contributors). Loaded automatically at the start of every session in this repo.

## Documentation style

- **CHANGELOG.md: one line per bullet.** Write each `- ` entry as a single physical line, however long — do not insert manual newlines to wrap at a column. Soft-wrapping is the renderer's job (GitHub, the editor), not ours. The same applies to prose in Markdown docs generally.

## Parser regeneration

- The parser ABI is pinned to **14** via `TS_ABI` in the `Makefile`, which is the single source of truth. Always regenerate with `make generate` — never bare `tree-sitter generate`, which uses the CLI's default ABI and fails the CI no-op gate (`git diff --exit-code -- src/`).

## Releases

- Versioning is strict SemVer (post-1.0). Bump with `scripts/bump-version.sh X.Y.Z`, which updates all six manifests (`package.json`, `tree-sitter.json`, `Cargo.toml`, `pyproject.toml`, `Makefile`, `SECURITY.md`) and promotes the `## [Unreleased]` changelog section to the new version.
- Before bumping, make sure every user-facing change since the last tag is captured under `## [Unreleased]`.
- Releases publish to npm, PyPI, and crates.io via OIDC trusted publishing (no stored tokens), gated behind a protected `release` GitHub Environment that requires manual approval. Pushing a `vX.Y.Z` tag starts the flow; the release workflow asserts the tag matches every manifest version before publishing.
