{ pkgs, ... }:
{
  # llama.cpp with its CUDA backend.  nixpkgs ships `llama-cpp-cuda` (a thin
  # `llama-cpp.override { cudaSupport = true; }`), so there is no need for a
  # custom flake input or overlay anymore.
  environment.systemPackages = [ pkgs.llama-cpp-cuda ];

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
  #   package = pkgs.llama-cpp-cuda;
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
