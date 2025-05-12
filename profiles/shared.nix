{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Python
    ruff
  ];

  fonts.fontconfig.enable = true;

  programs.doom-emacs = {
    enable = true;
    emacs = pkgs.emacs30-pgtk;
    doomDir = ../doom;

    extraPackages = epkgs: with epkgs; [
      treesit-grammars.with-all-grammars
    ];
  };

  programs.direnv.enable = true;
  programs.fish.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      ".idea/"
      ".venv/"
      "__pycache__/"
      "result"
      "result-*"
      "venv/"
    ];
  };

  programs.gh.enable = true;
  programs.gh-dash.enable = true;
  programs.home-manager.enable = true;
  programs.jq.enable = true;
  programs.lsd.enable = true;
  programs.nix-index-database.comma.enable = true;
  programs.nix-your-shell.enable = true;

  programs.poetry = {
    enable = true;
    settings = {
      virtualenvs.create = true;
      virtualenvs.in-project = true;
    };
  };

  programs.ripgrep.enable = true;

  programs.uv = {
    enable = true;
    settings = {
      python-downloads = "never";
      python-preference = "only-system";
    };
  };

  programs.vim.enable = true;

  programs.gpg.enable = true;
  services.gpg-agent.enable = true;
}
