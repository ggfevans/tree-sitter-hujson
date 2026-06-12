package tree_sitter_hujson_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_hujson "github.com/ggfevans/tree-sitter-hujson/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_hujson.Language())
	if language == nil {
		t.Errorf("Error loading Hujson grammar")
	}
}
