{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
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
