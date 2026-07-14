{
  pkgs,
  inputs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    fast
    btop
    git
    starship
  ];
}
