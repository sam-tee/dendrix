{
  inputs,
  self,
  ...
}: {
  flake.modules.darwin = {
    default = self.modules.darwin.brew;
    brew = {
      config,
      username,
      ...
    }: {
      imports = [inputs.nix-homebrew.darwinModules.default];
      nix-homebrew = {
        enable = true;
        user = username;
        mutableTaps = false;
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
        };
      };
      homebrew = {
        enable = true;
        taps = builtins.attrNames config.nix-homebrew.taps;
        onActivation.cleanup = "zap";
      };
    };
  };
}
