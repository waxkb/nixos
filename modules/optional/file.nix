# description: file(1) MIME/type detection
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.file ];
}
