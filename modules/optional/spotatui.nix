# description: spotatui terminal Spotify client
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  spotatui = inputs.spotatui.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  environment.systemPackages = [
    (spotatui.overrideAttrs (old: {
      # The nixpkgs cargo setup hook sets AWS_LC_SYS_USE_SYSTEM=1, which makes
      # aws-lc-sys hard-fail unless a system AWS-LC is installed. Let it build
      # the bundled AWS-LC from source instead.
      dontCargoUseSystemLibs = true;
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
        pkgs.cmake
        pkgs.perl
      ];
    }))
  ];
}
