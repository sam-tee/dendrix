{
  config,
  lib,
  ...
}: let
  username = config.primaryUser.username;
  cfg = config.ssh;
in {
  options = {
    ssh = {
      pubKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Public key of the machine";
      };
    };
  };
  config = {
    flake.modules.nixos.ssh = {
      environment.variables = {
        SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
      };
      users.users.${username}.openssh.authorizedKeys.keys = [cfg.pubKey];
      services = {
        openssh = {
          enable = true;
          ports = [2222];
          settings = {
            KbdInteractiveAuthentication = true;
            PasswordAuthentication = false;
            PermitRootLogin = "no";
          };
          extraConfig = ''
            AcceptEnv LANG LC_* TERM EDITOR
          '';
        };
        fail2ban.enable = true;
      };
    };
    flake.modules.darwin.ssh = {
      environment.variables = {
        SSH_AUTH_SOCK = "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock";
      };
      users.users.${username}.openssh.authorizedKeys.keys = [cfg.publicKey];
      services.openssh = {
        enable = true;
        extraConfig = ''
          AddressFamily any
          PermitRootLogin no
          UsePAM yes
          AcceptEnv LANG LC_* TERM EDITOR
          Include /etc/ssh/crypto.conf
        '';
      };
    };
    flake.modules.home.ssh = {
      home.file.".ssh/pubKeys" = {
        source = ./pubKeys;
        recursive = true;
      };
      programs.ssh = {
        enable = true;
        enableDefualtConfig = false;
        matchBlocks = {
          "u410" = {
            hostname = "u410";
            user = "u410";
            port = 2222;
            identityFile = "~/.ssh/pubKeys/u410.pub";
          };
          "a3" = {
            hostname = "a3";
            user = "sam";
            port = 2222;
            identityFile = "~/.ssh/pubKeys/a3.pub";
          };
          "duet3" = {
            hostname = "duet3";
            user = "sam";
            port = 2222;
            identityFile = "~/.ssh/pubKeys/duet3.pub";
          };
          "mba" = {
            hostname = "mba";
            user = "sam";
            port = 22;
            identityFile = "~/.ssh/pubKeys/mba.pub";
          };
          "*" = {};
        };
        extraConfig = ''
          SendEnv EDITOR TERM LANG LC_*
        '';
      };
    };
  };
}
