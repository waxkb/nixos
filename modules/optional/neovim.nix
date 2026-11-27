# description: Neovim editor
{
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.sessionVariables = {
    BLINK_CMP_DIR = "${pkgs.vimPlugins.blink-cmp}";
    FRIENDLY_SNIPPETS_DIR = "${pkgs.vimPlugins.friendly-snippets}";
  };
}
