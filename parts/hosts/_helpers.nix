inputs: {
  mkDarwin = {
    hostname,
    username ? "sam",
    darwinModules,
    homeModules
  }: {
    system = "aarch64-darwin";
    specialArgs = {
      inherit username;
    };
    modules = with inputs.self.modules.darwin; [
      system
    {
      home-manager.sharedModules = [] ++ homeModules;
    }
    ] ++ darwinModules;
  };
}
