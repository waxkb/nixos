{ config, pkgs, ... }:
let
  # llama.cpp's CUDA build uses `cudaPackages.backendStdenv` instead of the
  # regular stdenv, so `programs.ccache.packageNames` cannot reach it.  Wrap
  # that stdenv with the system ccache wrapper explicitly.
  ccacheCudaStdenv = pkgs.ccacheStdenv.override {
    stdenv = pkgs.cudaPackages.backendStdenv;
  };

  llama-cpp = (pkgs.llamaPackages.llama-cpp.override {
    useCuda = true;
    effectiveStdenv = ccacheCudaStdenv;
  }).overrideAttrs (old: {
    # The stdenv wrapper only covers the host C/C++ compiler; send nvcc
    # through ccache as well so the CUDA kernels are cached too.
    cmakeFlags = old.cmakeFlags ++ [
      "-DCMAKE_CUDA_COMPILER_LAUNCHER=${pkgs.ccache}/bin/ccache"
    ];
    env = (old.env or { }) // {
      CCACHE_DIR = toString config.programs.ccache.cacheDir;
      CCACHE_COMPRESS = "1";
      CCACHE_SLOPPINESS = "random_seed";
      CCACHE_UMASK = "007";
    };
  });
in
{
  # llama.cpp from its own flake (overlay applied in flake.nix), so we track
  # upstream instead of waiting for nixpkgs.  Overriding `useCuda` builds only
  # llama.cpp against CUDA; the rest of the system stays on the normal package
  # set (no global `cudaSupport` rebuilds).
  environment.systemPackages = [ llama-cpp ];

  # The RTX 4070 is Ada Lovelace (sm_89).  Without this nixpkgs emits device
  # code for every CUDA architecture it knows about, which makes the first
  # build much slower.  Remove/adjust this if the GPU changes.
  nixpkgs.config.cudaCapabilities = [ "8.9" ];

  # Optional always-on OpenAI-compatible server + web UI.
  #
  # The module runs as a DynamicUser with ProtectHome = true, so it cannot
  # read models from /home.  Easiest is to let llama-server download the model
  # itself (it is cached in /var/cache/llama-cpp).  For a local .gguf you would
  # need to put it in a system path and manage permissions yourself.
  #
  # services.llama-cpp = {
  #   enable = true;
  #   package = llama-cpp;
  #   settings = {
  #     host = "127.0.0.1";
  #     port = 8080;
  #     # either a local file...
  #     # model = "/var/lib/llama-cpp/models/model.gguf";
  #     # ...or let it fetch from Hugging Face:
  #     hf-repo = "unsloth/SmolLM2-135M-Instruct-GGUF:Q4_K_M";
  #     # text-only agents: don't also download a vision projector
  #     no-mmproj = true;
  #     gpu-layers = "all";
  #     flash-attn = "on";
  #     jinja = true;
  #     ctx-size = 16384;
  #   };
  # };
}
