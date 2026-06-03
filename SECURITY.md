# Security Policy

## Supported Versions

| Version | Supported |
| ------- | ---------- |
| 1.0.0   | :white_check_mark: |
| < 1.0.0 | :x: |

Only the latest release receives security fixes. Older versions should upgrade.

## Reporting a Vulnerability

1. **Private report:** Open a GitHub Security Advisory at
   [github.com/ggfevans/tree-sitter-hujson/security/advisories/new](https://github.com/ggfevans/tree-sitter-hujson/security/advisories/new).
2. **Acknowledgement:** You can expect an initial response within 48 hours.
3. **Disclosure:** Please allow time for a fix before public disclosure. We aim for
   coordinated disclosure whenever possible.

## AI-Assisted Code

AI-assisted contributions go through the same review process as human-written code:

- All changes are tested against the tree-sitter test suite before merging.
- Mandatory human review is required before any PR is merged.
- Security-sensitive code (grammar rules, Unicode handling, regex patterns) receives
  additional scrutiny regardless of origin.

## Security Considerations

tree-sitter-hujson is a **parser/grammar** — its primary attack surface is the input it
parses. Key considerations:

- **Untrusted input:** The grammar is designed to parse potentially untrusted HuJSON/JSON
  input. Grammar rules are structured to avoid unbounded backtracking; tree-sitter's
  GLR parser handles ambiguity without exponential blowup.
- **ReDoS safety:** The grammar avoids regex alternations that could lead to regular
  expression denial-of-service. String and number patterns are deterministic.
- **No network or filesystem access:** The parser itself has no network stack, no file I/O,
  and no execution primitives. A malicious input file cannot trigger outbound requests or
  code execution through the grammar alone.
- **No authentication or secrets:** The library neither stores nor transmits credentials,
  tokens, or sensitive data.

## Best Practices for Consumers

- Keep the grammar updated to the latest release for security fixes.
- If using the Node.js bindings, run `npm audit` regularly to check dependency health.
- Validate parsed output at the application layer — the grammar ensures syntactic
  correctness, but downstream consumers should enforce their own semantic constraints.

## Dependency Security

- Minimal dependency footprint (tree-sitter runtime + language bindings).
- Automated dependency scanning via GitHub Dependabot (npm + Cargo, weekly).
- Pre-release testing against the tree-sitter test suite on every CI run.