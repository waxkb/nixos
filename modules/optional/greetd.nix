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
        command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-session --cmd niri-session";
        user = "greeter";
      };
    };
  };
}
