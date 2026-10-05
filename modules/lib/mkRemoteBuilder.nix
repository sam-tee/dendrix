{self, ...}: {
  flake.lib.mkRemoteBuilder = config: {
    hostname,
    publicHostKey,
    systems ? [self.hosts.${hostname}.system],
    port ? 2222,
    maxJobs ? 4,
    speedFactor ? 1,
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
