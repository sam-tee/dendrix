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
    hjem.ssh = {lib, ...}: let
      sshHosts =
        self.hosts
        |> lib.filterAttrs (_: host: host.hostType == "nixos" || host.hostType == "darwin")
        |> builtins.attrNames
        |> builtins.sort lib.lessThan;
    in {
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
            mkHost = name: let
              host = self.hosts.${name};
              port =
                if host.hostType == "darwin"
                then "22"
                else "2222";
            in
              mkBlock name host.username port name;
          in
            lib.concatLines (
              (map mkHost sshHosts)
              ++ [
                (mkBlock "github.com" "git" "22" "git")
                (mkBlock "git-ssh.akhlus.uk" "forgejo" "2222" "git")
                ''
                  Host *
                    SendEnv ${envVar}
                ''
              ]
            );
        };
    };
  };
}
