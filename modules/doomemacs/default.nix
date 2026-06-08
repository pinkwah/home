{ config, ... }:

{
  programs.doom-emacs = {
    enable = true;
    doomDir = ./.;
    doomLocalDir = config.xdg.dataHome + "pinkwah/doom-emacs";
    lspUsePlists = true;
    extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];
  };
}
