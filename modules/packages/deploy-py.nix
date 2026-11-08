_: {
  perSystem = {pkgs, ...}: {
    # Vendored from pyScripts: upstream still assumes the old out-of-tree
    # secrets repo (~/nix-secrets plus a `secrets` flake input), while
    # secrets now live in-tree (./secrets.yaml + ./.sops.yaml).
    packages.deploy-py = let
      deployPython = pkgs.python313.withPackages (pythonPackages: [
        pythonPackages.ruamel-yaml
      ]);
    in
      pkgs.writeShellApplication {
        name = "deploy-py";
        runtimeInputs = with pkgs; [
          git
          nix
          openssh
          sops
          ssh-to-age
        ];
        text = ''
          exec ${deployPython}/bin/python ${./deploy-py.py} "$@"
        '';
      };
  };
}
