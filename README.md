# tree-sitter-hujson

A [tree-sitter](https://tree-sitter.github.io) grammar for [HuJSON](https://github.com/tailscale/hujson) (Human JSON) — also known as [JWCC](https://nigeltao.github.io/blog/2021/json-with-commas-comments.html) (JSON With Commas and Comments).

HuJSON is a strict superset of JSON that adds exactly two features:

- **C-style comments** — line comments (`//`) and block comments (`/* */`)
- **Trailing commas** — optional trailing comma after the last element in arrays and objects

All valid JSON is valid HuJSON. HuJSON intentionally rejects all other extensions (unquoted keys, hex literals, `Infinity`/`NaN`, single-quoted strings, etc.).

## Provenance

Forked from [`tree-sitter/tree-sitter-json`](https://github.com/tree-sitter/tree-sitter-json) at commit [`001c28d`](https://github.com/tree-sitter/tree-sitter-json/commit/001c28d7a29832b06b0e831ec77845553c89b56d).

The only semantic change is the `commaSep` helper, which now allows an optional trailing comma:

```js
function commaSep1(rule) {
  return seq(rule, repeat(seq(',', rule)), optional(','));
}
```

The upstream grammar already supported comments, so no further changes were needed.

## Consumers

- **Zed** — via the [`ggfevans/zed-hujson`](https://github.com/ggfevans/zed-hujson) extension
- **Neovim / Helix** — usable directly via the standard tree-sitter grammar interface

## Development

### Prerequisites

- Node.js 18+
- `tree-sitter-cli` (`npm install -g tree-sitter-cli`)

### Build & test

```bash
tree-sitter generate
tree-sitter test
```

The corpus suite covers literals, objects, arrays, comments, trailing commas, degenerate inputs (empty/whitespace/BOM/unicode/deeply nested), and invalid inputs (the strictness-preserving rejections).

## Licence

[MIT](LICENSE) — matches the upstream tree-sitter-json licence.
