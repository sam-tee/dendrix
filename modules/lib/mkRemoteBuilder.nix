{self, ...}: {
  flake.lib.mkRemoteBuilder = config: {
    hostname,
    publicHostKey ? self.hosts.${hostname}.remoteBuilder.publicHostKey or null,
    systems ? [self.hosts.${hostname}.system],
    port ? (
      if self.hosts.${hostname}.hostType == "darwin"
      then 22
      else 2222
    ),
    maxJobs ? self.hosts.${hostname}.remoteBuilder.maxJobs or 4,
    speedFactor ? self.hosts.${hostname}.remoteBuilder.speedFactor or 1,
  }: {
    hostName = "${hostname}:${toString port}";
    inherit systems publicHostKey maxJobs speedFactor;
    protocol = "ssh-ng";
    sshUser = self.hosts.${hostname}.username;
    sshKey = config.sops.secrets."ssh/${hostname}".path;
    supportedFeatures = [
      "benchmark"
      "big-parallel"
      "kvm"
      "nixos-test"
    ];
  };
}
