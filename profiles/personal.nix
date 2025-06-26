{ pkgs, ... }:

{
  imports = [ ./shared.nix ];

  programs.git = {
    userEmail = "git@wah.pink";
    userName = "Tenné";
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
        hash = "sha256-DZEVzwG+WqVjkh3VL5w9gWFbsCNib8gaWEQuJX9BlC0=";
      };
    }))
  ];

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };
}
