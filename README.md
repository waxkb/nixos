# nixos

Personal NixOS flake. Hosts are discovered automatically; optional software
is one module per file under `modules/optional/`.

## Layout

```text
flake.nix                 # auto-discovers hosts/, builds deploy.nodes from meta.nix
hosts/<name>/
  default.nix             # imports hardware + configuration + modules
  configuration.nix       # host identity, filesystems, stateVersion
  hardware-configuration.nix
  modules.nix             # selected hardware + optional modules
  meta.nix                # architecture and deploy-rs settings
modules/global/           # non-optional system base
modules/hardware/         # CPU/GPU/laptop modules
modules/optional/         # everything that can be added or left out
```

A host is added or removed simply by creating/removing its directory; there is
no host list in `flake.nix` to edit.

## Optional modules

The installer discovers modules by listing `modules/optional/*.nix`, so adding
a new file is enough to make it selectable. Optional metadata is read from the
first comment lines:

```nix
# description: Short text shown in the installer prompt
# requires: another-module   # comma-separated, auto-included if selected
# installer-default: yes     # optional; defaults to no
```

Cohesive feature modules (for example `desktop.nix`, `pipewire.nix`,
`fonts.nix`) sit alongside per-application modules.

## deploy-rs

`hosts/<name>/meta.nix` controls deployment:

```nix
{
  system = "x86_64-linux";
  deploy = {
    enable = true;
    hostname = "10.0.0.43";
    sshUser = "root";
  };
}
```

Only hosts with `deploy.enable = true` become `deploy.nodes.<name>`. The flake
still runs `deployChecks`.

## Installer

The installer lives in the companion ISO repo (`~/iso/install.sh`) and is baked
into the live image. It prompts for system information, detects CPU/GPU/laptop
hardware, loops through every optional module, optionally registers the host
with deploy-rs, and commits the new `hosts/<name>/` directory so Nix flakes can
see it.

## Common commands

```sh
sudo nixos-rebuild switch --flake .#nixos
sudo nixos-rebuild switch --flake .#server
nh os switch .#nixos
deploy .#server
nix flake check
```
