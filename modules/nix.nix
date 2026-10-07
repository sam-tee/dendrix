{
  inputs,
  lib,
  self,
  ...
}: let
  inherit (self.lib) mkRemoteBuilder;
  flakeInputs = lib.filterAttrs (name: value: (lib.isType "flake" value) && (name != "self")) inputs;
  remoteBuildMachines = config: currentHostname:
    self.hosts
    |> lib.filterAttrs (_: host: (host.remoteBuilder.publicHostKey or null) != null)
    |> lib.mapAttrsToList (hostname: _: mkRemoteBuilder config {inherit hostname;})
    |> lib.filter (machine: (machine.hostName |> lib.splitString ":" |> lib.head) != currentHostname);
in {
  flake.modules = {
    generic.default = self.modules.generic.nix;
    generic.nix = {
      config,
      hostname,
      ...
    }: {
      nix = {
        distributedBuilds = true;
        buildMachines = remoteBuildMachines config hostname;
        optimise.automatic = true;
        channel.enable = false;
        settings = {
          use-xdg-base-directories = true;
          keep-going = true;
          warn-dirty = false;
          builders-use-substitutes = true;
          extra-substituters = ["https://cache.${self.domain}/dendrix"];
          extra-trusted-public-keys = ["dendrix:lYCtmFj4pkP8VyJq0LryToQfVAXpMcRou8wPFKOw2xI="];
          flake-registry = "";
          experimental-features = [
            "flakes"
            "nix-command"
            "pipe-operators"
          ];
          trusted-users = [
            "root"
            "@build"
            "@wheel"
            "@admin"
          ];
        };
        registry =
          (flakeInputs |> builtins.mapAttrs (_: flake: {inherit flake;}))
          // {
            nixpkgs = lib.mkForce {flake = inputs.nixpkgs;};
            den.flake = self;
          };
      };
      nixpkgs.config = {
        allowUnfree = true;
        allowUnsupportedSystem = false;
        allowAliases = false;
      };
    };

    nixos.default = self.modules.nixos.nix;
    nixos.nix = {pkgs, ...}: {
      nix.settings = {
        use-cgroups = true;
        auto-allocate-uids = true;
        experimental-features = ["cgroups" "auto-allocate-uids"];
      };
      programs = {
        nh = {
          enable = true;
          flake = "$HOME/dendrix";
          clean.enable = true;
        };
        nix-ld = {
          enable = true;
          libraries = with pkgs; [
            stdenv.cc.cc.lib
            zlib
          ];
        };
      };
    };
  };
}
