# description: greetd + tuigreet login manager
# requires: niri
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # greetd owns tty1, so getty must not be started there.
  systemd.services."getty@tty1".enable = false;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-session --asterisks --cmd niri-session";
        user = "greeter";
      };
    };
  };
}
