# description: opencode AI coding agent
{
  pkgs,
  ...
}:
{
  # opencode tries to auto-download prebuilt LSP binaries (FHS binaries)
  # which fail on NixOS. Use nixpkgs-provided LSPs instead (see
  # opencode.jsonc `lsp.*.command` overrides).
  environment.sessionVariables = {
    OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
  };

  environment.systemPackages = [ pkgs.opencode ];
}
