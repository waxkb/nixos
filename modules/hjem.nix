{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  hjem.users.max = {
    enable = true;
    directory = "/home/max";
    files = {
      ".config/nvim/init.lua".text = ''
        local opt = vim.opt

        opt.spelllang = "en_us"
        opt.number = true
        opt.relativenumber = true
        opt.shiftwidth = 2
        opt.tabstop = 2
        opt.softtabstop = 2
        opt.expandtab = true
        opt.termguicolors = true
        opt.clipboard = "unnamedplus"

        opt.ignorecase = true
        opt.cursorline = true
        opt.expandtab = true
        opt.ruler = false
        opt.showmode = false
        opt.signcolumn = "no"
        opt.smartcase = true
        opt.smartindent = true

        opt.undofile = true
        opt.undolevels = 10000
        opt.undodir = vim.fn.expand("~/.local/state/nvim/undo")

        opt.updatetime = 300
        opt.virtualedit = "block"
      '';
      ".config/git/config".text = ''
        [init]
        	defaultBranch = "main"

        [user]
        	email = "maxwellr2028@gmail.com"
        	name = "waxkb"
      '';
      ".config/starship.toml".text = ''
        "$schema" = 'https://starship.rs/config-schema.json'

        format = """
        \u256d\u2574\
        $username\
        $hostname\
        $directory\
        $git_branch\
        $git_state\
        $git_status\
        $cmd_duration\
        $line_break\
        $python\
        \u2570\u2500\
        $character"""

        add_newline = false

        [directory]
        style = "blue"

        [character]
        success_symbol = "[❯](purple)"
        error_symbol = "[❯](red)"
        vimcmd_symbol = "[❮](green)"

        [git_branch]
        format = "[$branch]($style)"
        style = "bright-black"

        [git_status]
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)"
        style = "cyan"
        conflicted = ""
        untracked = ""
        modified = ""
        staged = ""
        renamed = ""
        deleted = ""
        stashed = "≡"

        [git_state]
        format = '\([$state( $progress_current/$progress_total)]($style)\) '
        style = "bright-black"

        [cmd_duration]
        format = "[$duration]($style) "
        style = "yellow"

        [python]
        format = "[$virtualenv]($style) "
        style = "bright-black"
        detect_extensions = []
        detect_files = []
      '';
    };
  };
}
