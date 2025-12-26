let
  mkSshOpt = lib: {
    pubKey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Public key of the machine";
    };
  };
in {
  flake.modules.nixos.ssh = {
    config,
    lib,
    username,
    ...
  }: let
    cfg = config.ssh;
  in {
    options.ssh = mkSshOpt lib;
    config = {
      environment.variables = {
        SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
      };
      users.users.${username}.openssh.authorizedKeys.keys = [cfg.pubKey];
      services = {
        openssh = {
          enable = true;
          ports = [2222];
          settings = {
            KbdInteractiveAuthentication = false;
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
  };
  flake.modules.darwin.ssh = {
    config,
    lib,
    username,
    ...
  }: let
    cfg = config.ssh;
  in {
    options.ssh = mkSshOpt lib;
    config = {
      environment.variables = {
        SSH_AUTH_SOCK = "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock";
      };
      users.users.${username}.openssh.authorizedKeys.keys = [cfg.pubKey];
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
  };
  flake.modules.homeManager.ssh = {
    home.file.".ssh/pubKeys" = {
      source = ./pubKeys;
      recursive = true;
    };
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = let
        mkBlock = hostname: user: port: {
          inherit hostname user port;
          identityFile = "~/.ssh/pubKeys/${hostname}.pub";
        };
      in {
        "u410" = mkBlock "u410" "sam" 2222;
        "a3" = mkBlock "a3" "sam" 2222;
        "duet3" = mkBlock "duet3" "sam" 2222;
        "mba" = mkBlock "mba" "sam" 22;
        "git" = {
          hostname = "github.com";
          identityFile = "~/.ssh/pubKeys/git.pub";
        };
        "*" = {};
      };
      extraConfig = ''
        SendEnv EDITOR TERM LANG LC_*
      '';
    };
  };
}
