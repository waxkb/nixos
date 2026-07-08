{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  system = pkgs.system;
in
{

  # nix.package = pkgs.lixPackageSets.git.lix;

  system.nixos-core.enable = true;

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
    ];
  };

  # swapDevices = [
  #   {
  #     device = "/var/lib/swapfile";
  #     size = 16 * 1024; # 16 GiB
  #   }
  # ];

  # boot.zswap = {
  #   enable = true;
  #   compressor = "lz4";
  # };

  services.ncro = {
    enable = true;
    settings = {
      server = {
        listen = ":8081";
      };
      upstreams = [
        {
          url = "https://cache.nixos.org";
          priority = 10;
          public_key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
        }
        {
          url = "https://nix-community.cachix.org";
          priority = 20;
          public_key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
        }
        {
          url = "https://claude-code.cachix.org";
          priority = 5;
          public_key = "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=";
        }
        {
          url = "https://noctalia.cachix.org";
          priority = 5;
          public_key = "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=";
        }
        {
          url = "https://sss.cachix.org";
          priority = 5;
          public_key = "sss.cachix.org-1:YI2JMG95LEu62PC7VMz75N7bypEdUz9Z/Il1hkGH4AA=";
        }
      ];
    };
  };

  nix.settings.substituters = [ "http://localhost:8081" ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/max/nixos"; # sets NH_OS_FLAKE variable
  };

  programs.ccache = {
    enable = true;
    owner = "root";
    group = "nixbld";
    packageNames = [ "noctalia" ];
  };

  # programs.sss = {
  #   enable = true;
  #   code = true;
  # };

  programs.kdeconnect.enable = false;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    libx11
    libxinerama
    libxext
    libGL
  ];

  documentation.enable = false;
  documentation.man.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${
          inputs.tuigreet.packages.${system}.tuigreet
        }/bin/tuigreet --cmd niri-session --remember --remember-session";
        user = "greeter";
      };
    };
  };

  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };

  # programs.obs-studio = {
  #   enable = true;
  #   package = (
  #     pkgs.obs-studio.override {
  #       cudaSupport = true;
  #     }
  #   );
  #   plugins = with pkgs.obs-studio-plugins; [
  #     obs-pipewire-audio-capture
  #   ];
  # };

  programs.dank-material-shell = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
  };

  programs.java.enable = true;

  programs.niri.enable = true;

  systemd.services."getty@tty1".enable = false;

  system.stateVersion = "25.11";

  boot.loader.limine = {
    enable = false;
    maxGenerations = null;
    extraConfig = ''
      quiet: yes
    '';
  };

  services.power-profiles-daemon.enable = false;
  services.upower.enable = false;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
    config.common.default = "*";
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL = "1";
    BLINK_CMP_DIR = "${pkgs.vimPlugins.blink-cmp}";
    FRIENDLY_SNIPPETS_DIR = "${pkgs.vimPlugins.friendly-snippets}";
    GTK_THEME = "Adwaita:dark";
    GTK_COLOR_SCHEME = "prefer-dark";
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    "amdgpu.enable=0"
    "8250.nr_uarts=0"
    "quiet"
    "loglevel=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=false"
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
  ];
  boot.initrd.includeDefaultModules = false;

  boot.consoleLogLevel = 0;

  systemd.services.systemd-journal-flush.enable = false;

  boot.initrd.systemd.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false; # Doesn't wait to connect to internet before booting

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.desktopManager.gnome.enable = false;

  nixpkgs.config = {
    allowUnfree = true;
    freetype = {
      hinting = true;
    };
  };

  hardware.bluetooth = {
    enable = false;
    powerOnBoot = false;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  services.blueman.enable = false;

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

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

  nix.settings = {
    extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
  };

  system.activationScripts.ccacheCacheDir.text = ''
          mkdir -p ${config.programs.ccache.cacheDir}
        install -d -m 0770 -o ${config.programs.ccache.owner} -g ${config.programs.ccache.group} ${config.programs.ccache.cacheDir}
        install -d -m 0770 -o ${config.programs.ccache.owner} -g ${config.programs.ccache.group} ${config.programs.ccache.cacheDir}/tmp
        cat > ${config.programs.ccache.cacheDir}/ccache.conf <<'EOF'
    max_size = 15GiB
    EOF
        chown ${config.programs.ccache.owner}:${config.programs.ccache.group} ${config.programs.ccache.cacheDir}/ccache.conf
        chmod 0640 ${config.programs.ccache.cacheDir}/ccache.conf
  '';

  security.pam.loginLimits = [
    {
      domain = "*";
      item = "memlock";
      value = "unlimited";
      type = "soft";
    }
    {
      domain = "*";
      item = "memlock";
      value = "unlimited";
      type = "hard";
    }
  ];

  hardware.graphics.enable = true;

  services.envfs.enable = true;

  security.polkit.enable = true;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = false;
    wireplumber.enable = true;
  };
}
