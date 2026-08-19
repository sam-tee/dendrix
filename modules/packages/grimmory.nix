{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    updateDeps = pkgs.callPackage "${inputs.nixpkgs}/pkgs/development/tools/build-managers/gradle/update-deps.nix" {};
    grimmory = pkgs.callPackage ./_grimmory/package.nix {};
  in {
    packages = {
      inherit grimmory;
      grimmory-gradle-update = updateDeps {
        pkg = grimmory.overrideAttrs (o: {sourceRoot = "${o.src.name}/backend";});
        pname = "grimmory";
        attrPath = null;
        bwrapFlags = "--ro-bind \"$PWD\" \"$PWD\"";
        data = toString ./_grimmory/deps.json;
        silent = false;
        useBwrap = false;
      };
    };
  };
}
