{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      maple-mono.NF-unhinted
      commit-mono
      inter
      noto-fonts
      material-symbols
      corefonts
    ];
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        autohint = false;
        style = "slight";
      };
      subpixel = {
        lcdfilter = "none";
        rgba = "none";
      };
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Inter" ];
        monospace = [ "Maple Mono NF" ];
      };
    };
    fontDir.enable = true;
  };

  environment.variables = {
    FREETYPE_PROPERTIES = "truetype:interpreter-version=40";
  };
}
