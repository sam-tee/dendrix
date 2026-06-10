{
  perSystem = {pkgs, ...}: {
    packages.nhw = pkgs.writeShellApplication {
      name = "nhw";
      runtimeInputs = with pkgs; [
        nh
      ];
      text = ''
        exec ${pkgs.python3}/bin/python ${./nhw.py} "$@"
      '';
    };
  };
}
