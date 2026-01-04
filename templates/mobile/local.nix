{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;
  mobile = {
    boot.boot-control.enable = false;
    beautification.splash = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  networking.wireless = {
    enable = true;
    networks."NETWORK".psk = "PASSWORD";
  };

  # Set root password for SSH access
  users.users.root.password = "ROOT_PASSWORD.";

  users.users.USER = {
    isNormalUser = true;
    description = "USER";
    extraGroups = ["networkmanager" "wheel"];
    password = "USER_PASSWORD";
  };

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["USER"];
    };
    optimise.automatic = true;
  };

  # only for lenovo wormdinger
  # see mobile-nixos for other device specific options
  hardware.firmware = [
    pkgs.chromeos-sc7180-unredistributable-firmware
  ];

  environment.systemPackages = with pkgs; [
    git
    nano
    wget
    curl
  ];
}
