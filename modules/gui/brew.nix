{
  inputs,
  self,
  ...
}: {
  flake.modules.darwin = {
    default = self.modules.darwin.brew;
    brew = {
      config,
      pkgs,
      username,
      ...
    }: let
      cfg = config.nix-homebrew;
      brewPrefix =
        cfg.prefixes.${
          if pkgs.stdenv.hostPlatform.isAarch64
          then cfg.defaultArm64Prefix
          else cfg.defaultIntelPrefix
        };
      inherit (brewPrefix) prefix;
    in {
      imports = [inputs.nix-homebrew.darwinModules.default];
      # static equivalent of `brew shellenv zsh`; the upstream integration
      # forks brew (~20ms) on every interactive shell for constant output
      programs.zsh.interactiveShellInit = ''
        export HOMEBREW_PREFIX="${prefix}"
        export HOMEBREW_CELLAR="${prefix}/Cellar"
        export HOMEBREW_REPOSITORY="${brewPrefix.library}/.homebrew-is-managed-by-nix"
        fpath[1,0]="${prefix}/share/zsh/site-functions"
        export FPATH
        export PATH="${prefix}/bin:${prefix}/sbin''${PATH+:$PATH}"
        [ -z "''${MANPATH-}" ] || { export MANPATH="''${MANPATH%"''${MANPATH##*[!:]}"}"; export MANPATH=":''${MANPATH#"''${MANPATH%%[!:]*}"}"; }
        export INFOPATH="${prefix}/share/info:''${INFOPATH:-}"
      '';
      nix-homebrew = {
        enable = true;
        enableZshIntegration = false;
        user = username;
        mutableTaps = false;
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
        };
      };
      homebrew = {
        enable = true;
        taps = builtins.attrNames config.nix-homebrew.taps;
        onActivation.cleanup = "zap";
      };
      environment.variables = {
        HOMEBREW_CACHE = "${config.xdg.dirs.cacheDir}/homebrew";
        HOMEBREW_LOGS = "${config.xdg.dirs.stateDir}/homebrew";
      };
    };
  };
}
