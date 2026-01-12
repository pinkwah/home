{ pkgs, ... }:

{
  imports = [ ./shared.nix ];

  programs.git.settings = {
    user.email = "git@wah.pink";
    user.name = "Tenné";
    signing.key = "A32FDE70EBD85C34";
    signing.signByDefault = true;
  };

  programs.rbenv.enable = true;

  home.packages = with pkgs; [
    ruby
    ruby-lsp
    solargraph
    intelephense
    astro-language-server

    (vala-language-server.overrideAttrs (final: prev: {
      version = "master";
      src = pkgs.fetchFromGitHub {
        owner = "vala-lang";
        repo = "vala-language-server";
        rev = "master";
        hash = "sha256-GDrEBy5xOb4JJB6g7PrDKK5KCXZfWVGg8ghQ+lM7dWY=";
      };
    }))
  ];

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };
}
