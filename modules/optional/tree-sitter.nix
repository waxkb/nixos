# description: tree-sitter parser generator
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.tree-sitter ];
}
