{...}: {
  perSystem = {pkgs, ...}: let
    python = pkgs.python3.withPackages (pythonPackages: [
      pythonPackages.ruamel-yaml
    ]);
  in {
    packages.deploy-py = pkgs.writeShellApplication {
      name = "deploy-py";
      runtimeInputs = with pkgs; [
        git
        nix
        openssh
        ssh-to-age
        sops
      ];
      text = ''
        exec ${python}/bin/python ${./deploy.py} "$@"
      '';
    };
  };
}
