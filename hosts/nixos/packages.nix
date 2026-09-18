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
    # claude-code
    inputs.codebase-memory-mcp.packages.${pkgs.system}.default
    # codex
    contour
    curl
    deploy-rs
    # discord-canary
    # dua
    # e2fsprogs
    efibootmgr
    fast
    # fd
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
    gradle
    # halloy
    hyperfine
    hyprlock
    hyprpicker
    infisical
    iwd
    jq
    libnotify
    # lsof
    lz4
    matugenFixed
    microfetch
    mpv
    # inputs.ncro.packages.${pkgs.system}.ncro
    # neo
    niri
    inputs.nix-alien.packages.${pkgs.system}.nix-alien
    noctalia
    # nvme-cli
    # noctalia-shell
    opencode
    # parted
    pavucontrol
    pkg-config
    playerctl
    pulseaudio
    ratty
    ripgrep
    # roccat-tools
    starship
    steam-run
    stow
    # tex
    # tmux
    tofi
    tree
    tree-sitter
    # typioca
    # udisks
    unzip
    # uv
    # wayland-bongocat
    wev
    wget
    wl-clipboard
    xwayland-satellite
    yazi
    zathura
    zathuraPkgs.zathura_pdf_poppler
    # inputs.zen-browser.packages.${pkgs.system}.default
    # zsh

    # ---Neovim formatters---

    astyle
    # clang-tools
    nixfmt-rs
    # ruff
    # rustfmt
    shfmt
    stylua

    # ---Neovim lsp packages---

    bash-language-server
    jdt-language-server
    # (inputs.jls.packages.${pkgs.system}.default.override {
    #   jdk = pkgs.openjdk25;
    #   maven = jlsMaven;
    # })
    lua-language-server
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
