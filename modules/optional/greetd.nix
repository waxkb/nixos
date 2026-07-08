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
        command = "${
          inputs.tuigreet.packages.${pkgs.system}.tuigreet
        }/bin/tuigreet --cmd niri-session --remember --remember-session";
        user = "greeter";
      };
    };
  };
}
