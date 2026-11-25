# description: llama.cpp with CUDA and ccache
{
  config,
  lib,
  pkgs,
  ...
}:
let
  llama-cpp = pkgs.llama-cpp-cuda.overrideAttrs (old: {
    # Send the host and CUDA compilers through ccache so repeat builds of
    # llama.cpp are cheap. cudaCapabilities below keeps the build focused on
    # the local GPU architecture.
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      "-DCMAKE_C_COMPILER_LAUNCHER=${pkgs.ccache}/bin/ccache"
      "-DCMAKE_CXX_COMPILER_LAUNCHER=${pkgs.ccache}/bin/ccache"
      "-DCMAKE_CUDA_COMPILER_LAUNCHER=${pkgs.ccache}/bin/ccache"
      "-DGGML_CUDA_FA_QUANTS=q4_0-q4_0;q8_0-q8_0;f16-f16;bf16-bf16;q8_0-q4_0"
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
  imports = [ ./ccache.nix ];

  # llama.cpp with CUDA from nixpkgs. Only llama.cpp is CUDA-enabled; the rest
  # of the system stays on the normal package set (no global cudaSupport
  # rebuilds).
  environment.systemPackages = [ llama-cpp ];

  # The RTX 4070 is Ada Lovelace (sm_89). Without this nixpkgs emits device
  # code for every CUDA architecture it knows about, which makes the first
  # build much slower. Remove/adjust this if the GPU changes.
  nixpkgs.config.cudaCapabilities = lib.mkDefault [ "8.9" ];

  # Optional always-on OpenAI-compatible server + web UI.
  #
  # The module runs as a DynamicUser with ProtectHome = true, so it cannot
  # read models from /home. Easiest is to let llama-server download the model
  # itself (it is cached in /var/cache/llama-cpp). For a local .gguf you would
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
