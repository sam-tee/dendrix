_: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }:
    lib.optionalAttrs (system == "x86_64-linux" || system == "aarch64-linux") (let
      version = "0.0.46-nightly.20261014.3132";
      desktop_hash_x86_64 = "sha256-xUGmiCZKtyGwyUXswUPKohOlxt/l79VSQIskkHhyVSA=";
      desktop_hash_aarch64 = "sha256-mM3lBPtDUtTU0ZItOtZs5YxwOxA7KPRsSm3zCOsPrHs=";
      cli_hash_x86_64 = "sha256-zK1m6cUlw3GG1r3M9SoDYttuSMfgWVffuwQphptsjys=";
      cli_hash_aarch64 = "sha256-mbQ7CGL5Zs3yK0YOBWA5FXg8z6gPHuINjfupsfmw3D0=";
      isX86 = system == "x86_64-linux";
    in {
      packages.t3code-nightly = pkgs.stdenv.mkDerivation {
        pname = "t3";
        inherit version;
        src = pkgs.fetchurl (
          if isX86
          then {
            url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/t3-${version}-linux-x64.tar.gz";
            hash = cli_hash_x86_64;
          }
          else {
            url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/t3-${version}-linux-arm64.tar.gz";
            hash = cli_hash_aarch64;
          }
        );
        sourceRoot =
          if isX86
          then "t3-${version}-linux-x64"
          else "t3-${version}-linux-arm64";
        nativeBuildInputs = with pkgs; [autoPatchelfHook];
        buildInputs = with pkgs; [stdenv.cc.cc.lib];
        dontStrip = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/t3 $out/bin
          cp -r . $out/share/t3/
          ln -s $out/share/t3/t3 $out/bin/t3
          runHook postInstall
        '';
        meta = {
          description = "T3 Code server (nightly tarball repackaged)";
          platforms = ["x86_64-linux" "aarch64-linux"];
          mainProgram = "t3";
        };
      };

      packages.t3code-desktop-nightly = pkgs.appimageTools.wrapType2 {
        pname = "t3code-desktop";
        inherit version;
        src = pkgs.fetchurl (
          if isX86
          then {
            url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
            hash = desktop_hash_x86_64;
          }
          else {
            url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-arm64.AppImage";
            hash = desktop_hash_aarch64;
          }
        );
        meta = {
          description = "T3 Code desktop (nightly AppImage repackaged)";
          platforms = ["x86_64-linux" "aarch64-linux"];
        };
      };
    });
}
