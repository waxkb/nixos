{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  networking.hostName = "potato";

  system.stateVersion = "26.11";

  time.timeZone = "America/Los_Angeles";

  # Installer uses by-label mounts; the generated hardware config is kept
  # verbatim and these mkForce definitions win.
  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-label/nixos";
    fsType = "bcachefs";
  };

  fileSystems."/boot" = lib.mkForce {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
      "noatime"
    ];
  };

  swapDevices = lib.mkForce [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];

  users.users.max.hashedPassword = "$6$12VWhcncOMU9joPG$xO/MtJ8fJrmHYMtEXmHvLd3.RDD01xeaT9IQ6FmRuGWzI7qTPMrQino4EgG4bvOdx98bvfAoqKXKFB7gRvb8z.";
  users.users.root.hashedPassword = "$6$nG562ssYKjsyFcWK$eTYhM/NCgC/an0cthejNaiAe95aPoIZmENXusaGfIRStGnNBkjAxZI0.R2HUXs1jC6DWazLtFYkIYpMV19Jhw0";

  # Chromebook-only Umbriel config. The shared config.toml includes these
  # files optionally, so no other host needs (or sees) them. Umbriel watches
  # the missing includes and reloads when this link appears at activation.
  system.activationScripts.umbrielChromebookConfig = lib.stringAfter [ "users" ] ''
    install -d -o max -g users -m 755 /home/max/.config
    ln -sfnT /home/max/dotfiles/umbriel-chromebook /home/max/.config/umbriel-chromebook
  '';
}
