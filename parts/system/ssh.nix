let
  linuxPort = 2222;
  envVar = "LANG LC_* TERM EDITOR";
in {
  flake.modules = {
    nixos.ssh = {
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
    darwin.ssh = {
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
    homeManager.ssh = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = let
          mkBlock = hostname: user: port: {
            inherit hostname user port;
            identitiesOnly = true;
            identityFile = "~/.ssh/pubKeys/${hostname}.pub";
          };
          mkLinuxBlock = hostname: mkBlock hostname "sam" linuxPort;
        in {
          "u410" = mkLinuxBlock "u410";
          "a3" = mkLinuxBlock "a3";
          "duet3" = mkLinuxBlock "duet3";
          "mba" = mkBlock "mba" "sam" 22;
          "git" = {
            hostname = "github.com";
            identityFile = "~/.ssh/pubKeys/git.pub";
          };
          "*" = {};
        };
        extraConfig = ''
          SendEnv ${envVar}
        '';
      };
    };
  };
}
