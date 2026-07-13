{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  networking.hostName = "server";

  system.stateVersion = "26.11";

}
