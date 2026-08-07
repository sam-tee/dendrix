{self, ...}: let
  linuxPort = 2222;
  envVar = "LANG LC_* TERM EDITOR";
in {
  flake.modules = {
    nixos.ssh = _: {
      services.openssh = {
        enable = true;
        ports = [linuxPort];
        settings = {
          KbdInteractiveAuthentication = false;
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
        extraConfig = ''
          AcceptEnv ${envVar}
        '';
      };
    };
    darwin.ssh = _: {
      environment.variables.SSH_AUTH_SOCK = "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock";
      services.openssh = {
        enable = true;
        extraConfig = ''
          AddressFamily any
          PermitRootLogin no
          UsePAM yes
          AcceptEnv ${envVar}
          Include /etc/ssh/crypto.conf
        '';
      };
    };
    homeManager.ssh = {config, ...}: let
      hostKeys = builtins.attrNames self.hosts;
    in {
      sops.secrets =
        hostKeys
        |> map (name: {
          name = "ssh/${name}";
          value = {
            path = "${config.home.homeDirectory}/.ssh/keys/${name}";
            mode = "0600";
          };
        })
        |> builtins.listToAttrs;
      home.file =
        self.hosts
        |> builtins.mapAttrs (name: value: {
          target = ".ssh/keys/${name}.pub";
          text = "${value.pubKey}";
        });
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = let
          mkBlock = HostName: User: Port: keyName: {
            inherit HostName User Port;
            IdentitiesOnly = true;
            IdentityFile = "~/.ssh/keys/${keyName}";
          };
          mkHost = hostname: mkBlock hostname "sam" 2222 hostname;
        in {
          a3 = mkHost "a3";
          deck = mkBlock "steamdeck" "deck" 22 "deck";
          duet3 = mkHost "duet3";
          hp = mkHost "hp";
          mba = mkHost "mba" // {Port = 22;};
          s340 = mkHost "s340";
          oracle = mkHost "oracle";
          prometheus = mkHost "prometheus";
          u410 = mkHost "u410";
          github = mkBlock "github.com" "git" 22 "git";
          "git-ssh.akhlus.uk" = mkBlock "git-ssh.akhlus.uk" "forgejo" 2222 "git";
          uni = mkBlock "10.148.2.163" "sl2110" 22 "uni";
          "*" = {};
        };
        extraConfig = ''
          SendEnv ${envVar}
        '';
      };
    };
  };
}
