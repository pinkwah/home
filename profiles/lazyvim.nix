{ pkgs, ... }:

{
  programs.lazyvim = {
    enable = true;

    config = {
      options = ''
        vim.g.lazyvim_python_lsp = "basedpyright"
        vim.opt.ttimeoutlen = 10
        vim.opt.shell = vim.fn.expand('~/.nix-profile/bin/fish')
      '';

      keymaps = ''
        local map = vim.keymap.set
        local opts = { noremap = true, silent = true } 

        -- Map SPC-[N] to go to window #N
        for i = 1, 9 do
          map('n', '<leader>' .. i, ':' .. i .. 'wincmd w<CR>', opts)
        end

        -- Emacs-like bindings (I'm a baby)
        map('n', '<C-x>0', '<CMD>close<CR>', opts)
        map('i', '<C-x>0', '<C-o><CMD>close<CR>', opts)
        map('n', '<C-x>1', '<CMD>only<CR>', opts)
        map('i', '<C-x>1', '<C-o><CMD>only<CR>', opts)
        map('n', '<C-x>2', '<CMD>split<CR>', opts)
        map('i', '<C-x>2', '<C-o><CMD>split<CR>', opts)
        map('n', '<C-x>3', '<CMD>vsplit<CR>', opts)
        map('i', '<C-x>3', '<C-o><CMD>vsplit<CR>', opts)
        map('n', '<C-x>o', '<C-w>w', opts)
        map('i', '<C-x>o', '<C-o><C-w>w', opts)
        map({'n','i'}, '<C-x><C-s>', '<CMD>write<CR>', opts)
        map({'n','i'}, '<C-x><C-f>', function () require('lazyvim.util').pick('files')() end, opts)

        -- From my Doom Emacs
        map('n', '<leader><Tab>', '<CMD>b#<CR>', opts)

        -- Terminal
        map('t', '<Esc>', "<C-\\><C-n>", opts)
        map('t', '<C-Space>', "<C-\\><C-n>", opts)
      '';
    };

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

      lang.python = {
        enable = true;
        installDependencies = true;
      };

      lang.ruby.enable = true;
      lang.rust.enable = true;
      lang.sql.enable = true;
      lang.tailwind.enable = true;
      lang.tex.enable = true;
      lang.toml.enable = true;
      lang.typescript.enable = true;
      lang.yaml.enable = true;
    };

    plugins = {
      toggleterm = ''
        return {
          'akinsho/toggleterm.nvim',
          version = '*',
          config = true,
          opts = {
            start_in_insert = false
          }
        }
      '';

      direnv = ''
        return {
          'direnv/direnv.vim',
          lazy = false,
        }
      '';
    };

    extraPackages = with pkgs; [
      basedpyright
    ];
  };
}
