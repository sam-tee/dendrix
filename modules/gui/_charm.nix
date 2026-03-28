{inputs, ...}: {
  flake-file.inputs.nur.url = "github:nix-community/NUR";
  flake.modules.homeManager.extraPackages = _: {
    imports = [
      inputs.nur.modules.homeManager.default
      inputs.nur.repos.charmbracelet.modules.crush
    ];
    programs.crush = {
      enable = true;
      settings = {
        lsp = {
          nix = {
            command = "nixd";
            enabled = true;
          };
          python = {
            command = "ty";
            enabled = true;
          };
        };
      };
    };
  };
}
