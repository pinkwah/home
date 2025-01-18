{ lib, fetchFromGitHub, tree-sitter }:

{
  tree-sitter-astro = tree-sitter.buildGrammar {
    language = "astro";
    version = "0.1.0";
    src = fetchFromGitHub {
      owner = "virchau13";
      repo = "tree-sitter-astro";
      rev = "0ad33e32ae9726e151d16ca20ba3e507ff65e01f";
      hash = "sha256-LhehKOhCDPExEgEiOj3TiuFk8/DohzYhy/9GmUSxaIg=";
    };
  };

  tree-sitter-bicep = tree-sitter.buildGrammar rec {
    language = "bicep";
    version = "1.1.0";
    src = fetchFromGitHub {
      owner = "tree-sitter-grammars";
      repo = "tree-sitter-bicep";
      rev = "v${version}";
      hash = "sha256-+qvhJgYqs8aj/Kmojr7lmjbXmskwVvbYBn4ia9wOv3k=";
    };
  };
}
