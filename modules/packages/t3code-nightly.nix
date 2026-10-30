_: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }:
    lib.optionalAttrs (system == "x86_64-linux" || system == "aarch64-linux") (let
      version = "0.1.6-nightly.20261029.3892";
      desktop_hash_x86_64 = "sha256-h2GPqCxtyX/tvZJd0G8x3pNmKx4dCmktQTjEpHVqSiA=";
      desktop_hash_aarch64 = "sha256-rAn1zCkMXd3usIt8BPsnmSfpMJwL7qBdpjrMTUBLq64=";
      cli_hash_x86_64 = "sha256-Zhd8RNDWXh8bo8uKAF5lljD0EsB09bWoU8UZOCRiD0A=";
      cli_hash_aarch64 = "sha256-sZ020m8krEf0Cz2+1UjEyypWCMDVQ8co+LawEgtFqIc=";
      isX86 = system == "x86_64-linux";
      desktopSrc = pkgs.fetchurl (
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
      appimageContents = pkgs.appimageTools.extract {
        pname = "t3code-desktop";
        inherit version;
        src = desktopSrc;
      };
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
        src = desktopSrc;
        extraInstallCommands = ''
          install -m 444 -D ${appimageContents}/t3code.desktop $out/share/applications/t3code.desktop
          cp -r ${appimageContents}/usr/share/icons $out/share/
          substituteInPlace $out/share/applications/t3code.desktop \
            --replace 'Exec=AppRun' 'Exec=t3code-desktop'
        '';
        meta = {
          description = "T3 Code desktop (nightly AppImage repackaged)";
          platforms = ["x86_64-linux" "aarch64-linux"];
          mainProgram = "t3code-desktop";
        };
      };
    });
}
