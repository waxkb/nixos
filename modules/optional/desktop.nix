{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  programs.xwayland.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
    config.common.default = "*";
  };

  programs.niri.enable = true;

  programs.dank-material-shell = {
    enable = true;
  };

  security.polkit.enable = true;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
  };

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
    enable = true;
    enable32Bit = true;
  };
}
