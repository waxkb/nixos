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
    nixfmt-rs
    starship
  ];

  networking.hostName = "server";

  system.stateVersion = "26.11";

}
