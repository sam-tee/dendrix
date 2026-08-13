{self, ...}: let
  linuxPort = 2222;
  envVar = "LANG LC_* EDITOR";
in {
  flake.modules = {
    nixos.default = self.modules.nixos.ssh;
    nixos.ssh = _: {
      services.openssh = {
        enable = true;
        ports = [linuxPort];
        settings = {
          KbdInteractiveAuthentication = false;
          PasswordAuthentication = false;
          PermitRootLogin = "no";
          MaxAuthTries = 5;
        };
        extraConfig = ''
          AcceptEnv ${envVar}
        '';
      };
    };
    darwin.default = self.modules.darwin.ssh;
    darwin.ssh = _: {
      #environment.variables.SSH_AUTH_SOCK = "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock";
      services.openssh = {
        enable = true;
        extraConfig = ''
          AddressFamily any
          KbdInteractiveAuthentication no
          PasswordAuthentication no
          PermitRootLogin no
          MaxAuthTries 5
          UsePAM yes
          AcceptEnv ${envVar}
          Include /etc/ssh/crypto.conf
        '';
      };
    };
    generic.default = self.modules.generic.ssh;
    generic.ssh = {
      config,
      username,
      ...
    }: {
      hjem.extraModules = [self.modules.hjem.ssh];
      sops.secrets =
        self.hosts
        |> builtins.attrNames
        |> map (name: {
          name = "ssh/${name}";
          value = {
            path = "${config.users.users.${username}.home}/.ssh/keys/${name}";
            mode = "0600";
            owner = username;
          };
        })
        |> builtins.listToAttrs;
    };
    hjem.ssh = {lib, ...}: {
      files =
        (self.hosts
          |> builtins.mapAttrs (name: value: {
            target = ".ssh/keys/${name}.pub";
            text = "${value.pubKey}";
          }))
        // {
          ".ssh/config".text = let
            mkBlock = hostname: user: port: keyname: ''
              Host ${hostname}
                HostName ${hostname}
                IdentitiesOnly yes
                IdentityFile ~/.ssh/keys/${keyname}
                Port ${port}
                User ${user}
            '';
            mkHost = host: mkBlock host "sam" "2222" host;
          in
            lib.concatLines [
              (mkHost "a3")
              (mkHost "duet3")
              (mkHost "hp")
              (mkBlock "mba" "sam" "22" "mba")
              (mkHost "oracle")
              (mkHost "s340")
              (mkHost "u410")
              (mkBlock "github.com" "git" "22" "git")
              (mkBlock "git-ssh.akhlus.uk" "forgejo" "2222" "git")
              ''
                Host *
                  SendEnv ${envVar}
              ''
            ];
        };
    };
  };
}
