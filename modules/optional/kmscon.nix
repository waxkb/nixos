{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.kmscon = {
    enable = true;
    useXkbConfig = true;
    config = {
      hwaccel = true;
      libseat = true;
      font-name = "Maple Mono NF";
    };
  };
}
