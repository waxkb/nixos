# description: Podman containers with Docker compatibility
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.yami.nixosModules.default ];
  programs.yami = {
    enable = true;
    loginScreen.user = "max";
    apps = false;
    tools = false;
  };
}
