# description: Glide keyboard-driven browser
{
  pkgs,
  inputs,
  ...
}:
let
  glide = inputs.glide.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    extraPolicies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
    };
  };
in
{
  environment.systemPackages = [ glide ];
}
