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
    homeManager.ssh = _: {
      home.file =
        builtins.mapAttrs (name: value: {
          target = ".ssh/pubKeys/${name}.pub";
          text = "${value.pubKey}";
        })
        self.hosts;
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = let
          mkBlock = hostname: user: port: keyName: {
            inherit hostname user port;
            identitiesOnly = true;
            identityFile = "~/.ssh/pubKeys/${keyName}.pub";
          };
          mkHost = hostname: mkBlock hostname "sam" 2222 hostname;
        in {
          a3 = mkHost "a3";
          deck = mkHost "deck";
          duet3 = mkHost "duet3";
          hp = mkHost "hp";
          mba = mkHost "mba" // {port = 22;};
          s340 = mkHost "s340";
          u410 = mkHost "u410";
          github = mkBlock "github.com" "git" 22 "git";
          forgejo = mkBlock "git-ssh.akhlus.uk" "forgejo" 2222 "git";
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
