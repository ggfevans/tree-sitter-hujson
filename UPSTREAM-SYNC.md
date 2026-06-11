# Upstream Sync Process

This document describes the quarterly sync cadence against [tree-sitter-json](https://github.com/tree-sitter/tree-sitter-json) (per spec §11.3).

## Why Sync?

The HuJSON grammar is derived from `tree-sitter-json`. Upstream changes (new node types, bug fixes, performance improvements) should be periodically merged to avoid drift. Without regular syncs, divergence accumulates and becomes increasingly difficult to reconcile.

## Fork Provenance

Forked from `tree-sitter/tree-sitter-json` at commit `001c28d7a29832b06b0e831ec77845553c89b56d`.

## JWCC Modifications

When merging upstream changes, **preserve** these intentional divergences from the JSON grammar:

| Area | Upstream (`json`) | Downstream (`hujson`) | Purpose |
|------|-------------------|----------------------|---------|
| Grammar name | `json` | `hujson` | Distinguishes the grammar |
| Comments | `//` and `/* */` supported (same structure) | `//` and `/* */` supported | Both support comments; see single-line regex diff below |
| Trailing commas | Not allowed | Optional trailing comma in `commaSep1` | JWCC spec |
| `string_content` | Hidden (`_string_content`) with inlined pattern | Public named node with `repeat1(choice(...))` | Outline query support |
| String node shape | `string_content` and `escape_sequence` are siblings under `string` (since upstream 001c28d) | `escape_sequence` nodes nest *inside* `string_content` — `(string (string_content (escape_sequence)))` | Predates upstream 001c28d; zed-hujson queries depend on the nested shape. Do **not** flatten during sync (#53) |
| `string_content` pattern | `/[^\\"\n]+/` (admits raw control chars) | `/[^\\"\u0000-\u001f]+/` (rejects raw U+0000–U+001F) | RFC 8259 §7 forbids unescaped control characters (#44) |
| `escape_sequence` | `(\"\|\\|\/\|b\|f\|n\|r\|t\|u)` | `(\"\|\\|\/\|b\|f\|n\|r\|t\|u[0-9a-fA-F]{4})` | Correctness: requires 4 hex digits after `\u` |
| Number literal | Allows leading-dot (`.5`) and trailing-dot (`1.`) literals | Leading-dot alternative removed; fraction digits mandatory after `.` | RFC 8259 §6: `frac = decimal-point 1*DIGIT`; HuJSON adds nothing to number syntax (#42) |
| `document` root | `repeat($._value)` (zero or more roots) | `optional($._value)` (at most one root; empty file OK) | HuJSON requires exactly one root value; `repeat` masked leading-zero rejection (`01` parsed as two clean siblings) (#43) |
| Single-line comment regex | `/.*/` (greedy dot) | `/[^\r\n]*/` (explicit newline exclusion) | Prevents `\r` edge case |
| `commaSep1` / `commaSep` | Standard separator | Adds `optional(',')` for trailing comma | JWCC spec |

## Sync Schedule

- **Cadence**: Quarterly (every ~90 days)
- **Trigger**: Manual or scheduled issue creation
- **Responsible**: Repository maintainer

## Sync Procedure

### 1. Check for Upstream Changes

```bash
# Record the last-synced commit (stored in grammar.js header)
LAST_SYNC=$(sed -n 's/.*at commit \([0-9a-f]\{40\}\).*/\1/p' grammar.js)

# Fetch upstream and compare
gh api repos/tree-sitter/tree-sitter-json/commits --jq '.[0].sha' \
  | xargs -I{} echo "Upstream HEAD: {}"
echo "Last synced:  $LAST_SYNC"

# If they match, no sync is needed — close the issue with a note.
# If they differ, proceed to step 2.
```

### 2. Compare Grammars

```bash
# Download upstream grammar for diff
gh api repos/tree-sitter/tree-sitter-json/contents/grammar.js \
  --jq '.content' | base64 -d > /tmp/upstream-grammar.js

# The diff is NOT pre-filtered — it includes all differences, both
# upstream changes and expected JWCC divergences (see table above).
# Manually separate genuine upstream changes from known JWCC mods.
diff /tmp/upstream-grammar.js grammar.js
```

### 3. Merge Changes

For each upstream change not already in our grammar:

1. **Review** the upstream commit(s) for relevance
2. **Apply** the change, adapting for JWCC extensions
3. **Test** with `tree-sitter test`
4. **Commit** with message: `chore(sync): merge upstream <commit-short> — <description>`

### 4. Update Fork Provenance

After merging all changes, update the fork commit reference in `grammar.js`:

```javascript
 * Forked from tree-sitter-json at commit <NEW_UPSTREAM_SHA>.
```

### 5. Verify

```bash
tree-sitter test   # All tests pass
tree-sitter parse examples/sample.hujson  # Still parses correctly
```

### 6. Close the Sync Issue

Comment on the quarterly issue with:
- Upstream commits merged (if any)
- Confirmation that tests pass
- Updated fork provenance commit

## Sync Checklist

- [ ] Check upstream for new commits since last sync
- [ ] Download and diff upstream `grammar.js` against ours
- [ ] For each relevant change: review, apply (preserving JWCC mods), test
- [ ] Update fork commit reference in `grammar.js` header
- [ ] Update fork commit reference in `README.md` Provenance section
- [ ] Run `tree-sitter test`
- [ ] Run `tree-sitter parse` on sample files
- [ ] Update `CHANGELOG.md` with sync note
- [ ] Close the sync issue with summary

## Sync Records

Each record follows this format:

```text
**Date**: YYYY-MM-DD
**Upstream HEAD**: `<40-char SHA>`
**Last synced**: `<40-char SHA>`
**Result**: <No changes / Merged: list of commit shorts>
```

### 2026-06-03

**Upstream HEAD**: `001c28d7a29832b06b0e831ec77845553c89b56d`
**Last synced**: `001c28d7a29832b06b0e831ec77845553c89b56d`
**Result**: No upstream changes since fork. Grammar is up-to-date.
