# description: Zsh shell (default for max and root)
{
  pkgs,
  ...
}:
{
  programs.zsh.enable = true;

  users.users.max.shell = pkgs.zsh;
  users.users.root.shell = pkgs.zsh;
}
