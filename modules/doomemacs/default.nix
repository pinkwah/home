{ config, ... }:

{
  programs.doom-emacs = {
    enable = true;
    doomLocalDir = config.xdg.dataHome + "pinkwah/doom-emacs";
    extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];
  };
}
