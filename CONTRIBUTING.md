# Contributing to tree-sitter-hujson

## Development

### Prerequisites

- Node.js 18+
- `tree-sitter-cli` (`npm install -g tree-sitter-cli`)

### Build and test

```bash
tree-sitter generate
tree-sitter test
```

The corpus suite covers literals, objects, arrays, comments, trailing commas, degenerate inputs (empty, whitespace, BOM, unicode, deeply nested), and invalid inputs (the strictness-preserving rejections).

## Releasing

Releases are tag-driven. Bump the version in every manifest at once with
`scripts/bump-version.sh X.Y.Z`, add a matching `## [X.Y.Z]` entry to
[`CHANGELOG.md`](CHANGELOG.md), then push a `vX.Y.Z` tag. The
[`Release`](.github/workflows/release.yml) workflow validates the tag, creates
the GitHub Release from the changelog entry, and publishes the bindings.

Each registry publish job runs **only** when that registry is configured,
otherwise it is skipped (the GitHub Release always succeeds):

| Registry | Authentication | Enabled by |
| --- | --- | --- |
| npm | OIDC Trusted Publishing (no stored token) | repo **variable** `NPM_TRUSTED_PUBLISHER` = `true`, plus an [npm trusted publisher](https://docs.npmjs.com/trusted-publishers/) for this repo + `release.yml` |
| PyPI | OIDC Trusted Publishing (no stored token) | repo **variable** `PYPI_TRUSTED_PUBLISHER` = `true`, plus a [PyPI trusted publisher](https://docs.pypi.org/trusted-publishers/) for this repo + `release.yml` |
| crates.io | API token | repo **secret** `CARGO_REGISTRY_TOKEN` |

The Go, Swift, and C bindings are consumed directly from the git tag, so they
need no registry publish step.

To publish a registry you enabled *after* a tag was already cut, re-run the
`Release` workflow for that tag: the now-present variable or secret flips its
job on.
