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
    starship
  ];

  networking.hostName = "server";

  system.stateVersion = "26.11";

}
