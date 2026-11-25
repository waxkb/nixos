# description: Desktop session base (X11/Xwayland, polkit, graphics)
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # Desktop base. Compositor (niri) and audio (pipewire) are separate
  # optional modules so they can be selected independently.
  services.xserver = {
    enable = true;
    xkb = {
      layout = lib.mkDefault "us";
      variant = lib.mkDefault "";
    };
  };

  programs.xwayland.enable = true;

  security.polkit.enable = true;

  services.speechd.enable = false;

  security.pam.loginLimits = [
    {
      domain = "*";
      item = "memlock";
      value = "unlimited";
      type = "soft";
    }
    {
      domain = "*";
      item = "memlock";
      value = "unlimited";
      type = "hard";
    }
  ];

  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = lib.mkDefault false;
  };

  programs.kdeconnect.enable = lib.mkDefault false;

  services.power-profiles-daemon.enable = lib.mkDefault false;
  services.upower.enable = lib.mkDefault false;

  hardware.bluetooth = {
    enable = lib.mkDefault false;
    powerOnBoot = lib.mkDefault false;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };
  services.blueman.enable = lib.mkDefault false;

  services.accounts-daemon.enable = lib.mkDefault false;
  services.geoclue2.enable = lib.mkDefault false;

  environment.sessionVariables = {
    BLINK_CMP_DIR = "${pkgs.vimPlugins.blink-cmp}";
    FRIENDLY_SNIPPETS_DIR = "${pkgs.vimPlugins.friendly-snippets}";
    GTK_THEME = "Adwaita:dark";
    GTK_COLOR_SCHEME = "prefer-dark";
  };

  systemd.services."getty@tty1".enable = false;
}
