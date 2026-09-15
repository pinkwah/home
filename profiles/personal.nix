{ pkgs, ... }:

{
  imports = [ ./shared.nix ];

  programs = {
    git.settings = {
      user.email = "git@wah.pink";
      user.name = "Tenné";
      signing.key = "A32FDE70EBD85C34";
      signing.signByDefault = true;
    };

    obsidian = {
      enable = true;
      cli.enable = true;
    };

    nh.enable = true;
  };

  home.packages = with pkgs; [
    ruby
    ruby-lsp
    solargraph
    intelephense
    sops
  ];

  services = {
    gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3;
    };

    nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };
}
