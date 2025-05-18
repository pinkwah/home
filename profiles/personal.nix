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
    ruby-lsp
  ];
}
