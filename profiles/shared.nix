{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # Python
    ruff

    inputs.doom-emacs.packages.${pkgs.stdenv.system}.default
  ];

  fonts.fontconfig.enable = true;

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
      ".DS_Store"
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

  home.file.".bashrc.d/fish".text = ''
    # -*- sh -*-
    # https://wiki.archlinux.org/title/Fish#Modify_.bashrc_to_drop_into_fish

    if command -v fish 2>&1 >/dev/null
    then
      if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z $BASH_EXECUTION_STRING && $SHLVL == 1 ]]
      then
        shopt -q login_shell && LOGIN_OPTION="--login" || LOGIN_OPTION=""
        exec fish $LOGIN_OPTION
      fi
    fi
  '';
  home.file.".bashrc.d/fish".enable = false;

  home.file.".intellimacs".source = inputs.intellimacs;
  home.file.".ideavimrc".text = ''
    source ~/.intellimacs/spacemacs.vim
    source ~/.intellimacs/extra.vim
    source ~/.intellimacs/major.vim
    source ~/.intellimacs/hybrid.vim
    source ~/.intellimacs/which-key.vim
    source ~/.config/home-manager/ideavim-config.vim

    let g:WhichKeyDesc_Files_GotoFile = "<leader><leader> goto-file";
    nnoremap <leader><leader> :action GotoFile<CR>
    vnoremap <leader><leader> :action GotoFile<CR>
  '';

  programs.lazyvim = {
    enable = true;

    extras = {
      lang.astro.enable = true;
      lang.clangd.enable = true;
      lang.cmake.enable = true;
      lang.docker.enable = true;
      lang.git.enable = true;
      lang.json.enable = true;
      lang.markdown.enable = true;
      lang.nix.enable = true;
      lang.php.enable = true;
      lang.python.enable = true;
      lang.ruby.enable = true;
      lang.rust.enable = true;
      lang.sql.enable = true;
      lang.tailwind.enable = true;
      lang.tex.enable = true;
      lang.toml.enable = true;
      lang.typescript.enable = true;
      lang.yaml.enable = true;
    };
  };
}
