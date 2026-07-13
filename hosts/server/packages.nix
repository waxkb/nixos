{
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
}
