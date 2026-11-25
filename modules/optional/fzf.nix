# description: fzf fuzzy finder
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.fzf ];
}
