{
  flake.modules.homeManager.ssh = let
    keys = import ./_pubKeys.nix;
  in {
    home.file =
      builtins.mapAttrs (name: value: {
        target = ".ssh/pubKeys/${name}.pub";
        text = "${value}\n";
      })
      keys;
  };
}
