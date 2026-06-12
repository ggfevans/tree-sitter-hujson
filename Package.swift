// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TreeSitterHujson",
    products: [
        .library(name: "TreeSitterHujson", targets: ["TreeSitterHujson"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "TreeSitterHujson",
                path: ".",
                exclude: [
                    "CHANGELOG.md",
                    "CONTRIBUTING.md",
                    "Cargo.toml",
                    "Makefile",
                    "SECURITY.md",
                    "UPSTREAM-SYNC.md",
                    "binding.gyp",
                    "bindings/c",
                    "bindings/go",
                    "bindings/node",
                    "bindings/python",
                    "bindings/rust",
                    "examples",
                    "go.mod",
                    "go.sum",
                    "grammar.js",
                    "package.json",
                    "pyproject.toml",
                    "scripts",
                    "setup.py",
                    "test",
                    "tree-sitter.json",
                    ".coderabbit.yaml",
                    ".editorconfig",
                    ".github",
                    ".gitignore",
                    ".gitattributes",
                ],
                sources: [
                    "src/parser.c",
                    // NOTE: if your language has an external scanner, add it here.
                ],
                resources: [
                    .copy("queries")
                ],
                publicHeadersPath: "bindings/swift",
                cSettings: [.headerSearchPath("src")])
    ],
    cLanguageStandard: .c11
)
