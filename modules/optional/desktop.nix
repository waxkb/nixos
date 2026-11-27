# description: Desktop session base (X11/Xwayland, polkit, graphics)
{
  lib,
  ...
}:
{
  # Desktop base. Compositor (niri), sound, bluetooth, power management
  # and KDE Connect are separate optional modules so they can be
  # selected independently.
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

  services.accounts-daemon.enable = lib.mkDefault false;

  environment.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    GTK_COLOR_SCHEME = "prefer-dark";
  };
}
