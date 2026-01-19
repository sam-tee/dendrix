let
  linuxPort = 2222;
  envVar = "LANG LC_* TERM EDITOR";
in {
  flake.modules = {
    nixos.ssh = _: {
      services = {
        openssh = {
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
        fail2ban.enable = true;
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
          "u410" = mkHost "u410";
          "a3" = mkHost "a3";
          "duet3" = mkHost "duet3";
          "mba" = mkHost "mba" // {port = 22;};
          "github" = mkBlock "github.com" "git" 22 "git";
          "forgejo" = mkBlock "git.akhlus.uk" "forgejo" 2222 "git";
          "*" = {};
        };
        extraConfig = ''
          SendEnv ${envVar}
        '';
      };
    };
  };
}
