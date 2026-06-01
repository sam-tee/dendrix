{
  flake.modules.nixos.mullvad = {config, ...}: {
    sops.secrets.mullvadKey = {};
    networking.firewall = {
      trustedInterfaces = ["mullvad*"];
      allowedUDPPorts = [51820];
    };
    networking.wg-quick.interfaces = {
      mullvad-fr = {
        autostart = false;
        mtu = 1380;
        address = ["10.41.148.128/32" "fc00:bbbb:bbbb:bb01::1:947f/128"];
        privateKeyFile = config.sops.secrets.mullvadKey.path;
        dns = ["10.64.0.1"];
        peers = [
          {
            publicKey = "R5Ve+PJD24QjNXi2Dim7szwCiOLnv+6hg+WyTudAYmE=";
            endpoint = "193.32.126.67:51820";
            allowedIPs = ["0.0.0.0/0" "::0/0"];
          }
        ];
      };
    };
  };
}
