{
  pkgs,
  inputs,
  ...
}:

let
  tex = (
    pkgs.texliveSmall.withPackages (
      ps: with ps; [
        latexmk
        thmtools
        tikz-cd
        mdframed
        newtx
        zref
        needspace
        mhchem
        siunitx
        latexindent
        fancyhdr
        biblatex
        biblatex-chicago
        biber
        csquotes
        babel
        xstring
      ]
    )
  );
  matugenFixed = pkgs.writeShellScriptBin "matugen" ''
    #!/usr/bin/env bash

    args=()
    for arg in "$@"; do
      case "$arg" in
        file://*)
          args+=("$(printf '%s\n' "$arg" | sed 's|^file://||')")
          ;;
        *)
          args+=("$arg")
          ;;
      esac
    done

    exec ${pkgs.matugen}/bin/matugen --base16-backend wal --source-color-index 0 "''${args[@]}"
  '';
  jlsMaven = pkgs.maven.overrideAttrs (old: {
    passthru = (old.passthru or { }) // {
      buildMavenPackage =
        args:
        pkgs.maven.buildMavenPackage (
          args
          // {
            mvnHash = "sha256-PNBuentUs+bv7IKK1mg9ZbisW7FtsENX/0bpkJ6qa6w=";
            mvnParameters = (args.mvnParameters or "-DskipTests") + " -Dmaven.test.skip=true";
          }
        );
    };
  });
in
{
  environment.systemPackages = with pkgs; [
    activate-linux
    bat
    bibata-cursors
    vimPlugins.blink-cmp
    broot
    btop
    curl
    deploy-rs
    # e2fsprogs
    efibootmgr
    fast
    file
    fio
    foot
    fzf
    gcc
    git
    gita
    # gnumake
    (inputs.glide.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      extraPolicies = {
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
      };
    })
    # gptfdisk
    hyperfine
    hyprlock
    hyprpicker
    infisical
    iwd
    jq
    libnotify
    lz4
    matugenFixed
    microfetch
    mpv
    # inputs.ncro.packages.${pkgs.system}.ncro
    niri
    noctalia
    nodejs_26
    # nvme-cli
    # parted
    pavucontrol
    pkg-config
    playerctl
    pulseaudio
    ripgrep
    starship
    stow
    # tex
    tofi
    tree
    tree-sitter
    # udisks
    unzip
    # wayland-bongocat
    wev
    wget
    wl-clipboard
    xwayland-satellite
    yazi
    zathura
    zathuraPkgs.zathura_pdf_poppler

    # ---Neovim formatters---

    astyle
    # clang-tools
    nixfmt-rs
    # ruff
    # rustfmt
    shfmt
    stylua

    # ---Neovim lsp packages---

    # bash-language-server
    jdt-language-server
    # (inputs.jls.packages.${pkgs.system}.default.override {
    #   jdk = pkgs.openjdk25;
    #   maven = jlsMaven;
    # })
    # lua-language-server
    # ty
    # rust-analyzer

    # ---Matrix clients---
    # cinny-desktop
    # cinny
    # element-desktop
    # element-web
    # gomuks
    # gomuks-web
  ];
}
