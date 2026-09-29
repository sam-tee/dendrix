{self, ...}: {
  flake.modules.generic = {
    default = self.modules.generic.fj;
    fj = {
      config,
      username,
      pkgs,
      ...
    }: let
      home = config.users.users.${username}.home;
      keysPath =
        if pkgs.stdenv.hostPlatform.isDarwin
        then "${home}/Library/Application Support/forgejo-cli.forgejo-cli/keys.json"
        else "${home}/.local/share/forgejo-cli/keys.json";
      fjPkg = pkgs.forgejo-cli.overrideAttrs (old: {
        postFixup =
          (old.postFixup or "")
          + ''
            for f in \
              "$out/share/zsh/site-functions/_fj" \
              "$out/share/bash-completion/completions/fj.bash" \
              "$out/share/fish/vendor_completions.d/fj.fish"
            do
              [ -f "$f" ] && sed -i '1{/^Could not find keys file\./d}' "$f"
            done
          '';
      });
    in {
      environment.systemPackages = [fjPkg];
      sops.secrets."fj-token".owner = username;
      sops.templates."fj-keys.json" = {
        owner = username;
        mode = "0600";
        path = keysPath;
        content = ''
          {"hosts":{"${self.services.forgejo.fqdn}":{"type":"Application","token":"${config.sops.placeholder."fj-token"}"}},"aliases":{},"default_ssh":[]}
        '';
      };
    };
  };
}
