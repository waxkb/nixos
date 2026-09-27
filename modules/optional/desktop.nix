{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # Desktop (niri + pipewire) base. GPU-agnostic on purpose: the
  # installer adds exactly one (or two on hybrid) of
  # modules/hardware/gpu-{nvidia,amd,intel}.nix, which sets
  # services.xserver.videoDrivers + hardware.graphics extras.
  # Do NOT hardcode videoDrivers here.
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  programs.xwayland.enable = true;

  programs.niri.enable = true;
  programs.niri.useNautilus = false;

  security.polkit.enable = true;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = false;
    wireplumber.enable = true;
  };

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

  # Desktop defaults (moved here from hosts/nixos/configuration.nix so
  # new hosts inherit them). modules/hardware/laptop.nix overrides the
  # power + bluetooth bits with mkForce for laptops.
  services.power-profiles-daemon.enable = lib.mkDefault false;
  services.upower.enable = lib.mkDefault false;

  hardware.bluetooth = {
    enable = lib.mkDefault false;
    powerOnBoot = lib.mkDefault false;
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

  security.pam.services.hyprlock.enable = true;
}
