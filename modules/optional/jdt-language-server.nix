# description: Eclipse JDT language server for Java
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    (pkgs.jdt-language-server.override { jdk25 = pkgs.jdk25; })
  ];
}
