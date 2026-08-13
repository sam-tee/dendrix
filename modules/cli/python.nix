{self, ...}: {
  flake.modules.generic = {
    default = self.modules.generic.python;
    python = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        python3
        ruff
        ty
        uv
      ];
    };
  };
}
