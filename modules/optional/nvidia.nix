# Deprecated shim: use modules/hardware/gpu-nvidia.nix instead.
# Kept so old flake entries don't break; new hosts should include the
# hardware module directly (the installer does this).
{ ... }:
{
  imports = [ ../hardware/gpu-nvidia.nix ];
}
