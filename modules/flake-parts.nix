_: {
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
  };
}
