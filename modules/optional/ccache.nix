{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs.ccache = {
    enable = true;
    owner = "root";
    group = "nixbld";
    packageNames = [ "noctalia" ];
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
}
