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
in
{
  environment.systemPackages = with pkgs; [
    activate-linux
    bat
    bibata-cursors
    vimPlugins.blink-cmp
    # broot
    btop
    # claude-code
    codex
    curl
    deploy-rs
    # e2fsprogs
    efibootmgr
    fd
    file
    fio
    foot
    fzf
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
    inputs.ncro.packages.${pkgs.system}.ncro
    # neo
    niri
    noctalia
    # nvme-cli
    # noctalia-shell
    opencode
    # parted
    pavucontrol
    pkg-config
    playerctl
    pulseaudio
    ripgrep
    starship
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
    zoom-us
    # zsh

    # ---Neovim formatters---

    # astyle
    # clang-tools
    nixfmt-rs
    # ruff
    # rustfmt
    shfmt
    stylua

    # ---Neovim lsp packages---

    bash-language-server
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
