{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    btop
    git
    nixfmt-rs
    starship
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "server"; # Define your hostname.

  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "max" ];
      MaxAuthTries = 5;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };

  users.users.max = {
    isNormalUser = true;
    description = "max";

    extraGroups = [
      "wheel"
      "networkmanager"
      "podman"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGh6KWt6dNi46lrhhzfS54012/UPitFzhRWlDDNqb+To maxwellr2028@gmail.com"
    ];
  };

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

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    # HandlePowerKey = "ignore";
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  systemd.services.systemd-udev-settle.enable = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.timeout = 1;

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  boot.supportedFilesystems = [ "bcachefs" ];

  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "26.11";

}
