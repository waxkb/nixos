{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.zsh = {
    enable = true;
  };

  # opencode tries to auto-download prebuilt LSP binaries (FHS binaries)
  # which fail on NixOS. Use nixpkgs-provided LSPs instead (see
  # opencode.jsonc `lsp.*.command` overrides).
  environment.sessionVariables = {
    OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
  };

  documentation.enable = false;
  documentation.man.enable = false;

  services.desktopManager.gnome.enable = false;

  services.envfs.enable = true;
}
