{self, ...}: let
  linuxPort = 22;
  envVar = "LANG LC_* EDITOR";
in {
  flake.modules = {
    nixos.default = self.modules.nixos.ssh;
    nixos.ssh = {username, ...}: {
      services.openssh = {
        enable = true;
        ports = [linuxPort];
        openFirewall = true;
        settings = {
          KbdInteractiveAuthentication = false;
          PasswordAuthentication = false;
          AuthenticationMethods = "publickey";
          PermitEmptyPasswords = false;
          PermitRootLogin = "no";
          X11Forwarding = false;
          AllowAgentForwarding = false;
          AllowUsers = [username];
          MaxAuthTries = 5;
          MaxSessions = 5;
          MaxStartups = "10:30:60";
          LoginGraceTime = 30;
          ClientAliveInterval = 300;
          ClientAliveCountMax = 2;
        };
        extraConfig = ''
          AcceptEnv ${envVar}
        '';
      };
      services.fail2ban.jails.sshd.settings = {
        enabled = true;
        port = "${toString linuxPort}";
        maxretry = 5;
        findtime = "10m";
        bantime = "1h";
      };
    };
    darwin.default = self.modules.darwin.ssh;
    darwin.ssh = {username, ...}: {
      services.openssh = {
        enable = true;
        extraConfig = ''
          AddressFamily any
          KbdInteractiveAuthentication no
          PasswordAuthentication no
          AuthenticationMethods publickey
          PermitEmptyPasswords no
          PermitRootLogin no
          X11Forwarding no
          AllowAgentForwarding no
          AllowUsers ${username}
          MaxAuthTries 5
          MaxSessions 5
          MaxStartups 10:30:60
          LoginGraceTime 30
          ClientAliveInterval 300
          ClientAliveCountMax 2
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
      inherit (lib) concatLines singleton;
      sshHosts =
        self.hosts
        |> lib.filterAttrs (_: host: host.hostType != "other")
        |> builtins.attrNames
        |> builtins.sort lib.lessThan;
      keysAttrs =
        self.hosts
        |> builtins.mapAttrs (name: value: {
          target = ".ssh/keys/${name}.pub";
          text = "${value.pubKey}";
        });
      mkSshConfigTailnet = host: ''
        Host ${host} ${host}.${self.tailnet}
          HostName ${host}.${self.tailnet}
          User ${self.hosts.${host}.username}
          Port ${
          if self.hosts.${host}.hostType == "darwin"
          then "22"
          else toString linuxPort
        }
          IdentitiesOnly yes
          IdentityFile ~/.ssh/keys/${host}
      '';
      sshConfig.".ssh/config".text = concatLines (
        (map mkSshConfigTailnet sshHosts)
        ++ singleton ''
          Host github.com
            HostName github.com
            IdentitiesOnly yes
            IdentityFile ~/.ssh/keys/git
            Port 22
            User git

          Host ${self.services.forgejo.fqdn}
            HostName ${self.services.forgejo.fqdn}
            IdentitiesOnly yes
            IdentityFile ~/.ssh/keys/git
            Port 22
            User forgejo

          Host *
            SendEnv ${envVar}
        ''
      );
    in {
      files = keysAttrs // sshConfig;
    };
  };
}
