_: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: let
    inherit (lib) hasSuffix optionalAttrs;
    inherit (lib.licenses) bsd3;
    inherit (lib.platforms) linux;
  in
    optionalAttrs (hasSuffix "linux" system) {
      # Google Security Chip (Cr50/Ti50) tool, not in nixpkgs. Used to open CCD on
      # Chromebooks running Mobile NixOS: `sudo gsctool -a -o` (needs /dev/tpm0)
      packages.gsctool = pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "gsctool";
        version = "0-unstable-2026-11-08";

        # ChromiumOS builds gsctool from this branch (chromeos-base/chromeos-gsc-dev)
        src = pkgs.fetchgit {
          url = "https://chromium.googlesource.com/chromiumos/platform/ec";
          rev = "0e40e71781c0c01e0ac212068e6554bd36126e84";
          hash = "sha256-iwRVRM1V2BVxV+lg5Mf7DgKYpf5nr2gnY7i23occJ+A=";
        };

        strictDeps = true;
        nativeBuildInputs = [pkgs.pkg-config];
        buildInputs = with pkgs; [libusb1 openssl];

        postPatch = ''
          patchShebangs util/getversion.sh
        '';

        # getversion.sh falls back to VCSID when there is no .git
        env.VCSID = "gsc_utils-${finalAttrs.src.rev}";

        makeFlags = [
          "-C"
          "extra/usb_updater"
          "gsctool"
          "CC=${pkgs.stdenv.cc.targetPrefix}cc"
          "PKG_CONFIG=${pkgs.stdenv.cc.targetPrefix}pkg-config"
        ];

        installPhase = ''
          runHook preInstall
          install -Dm755 extra/usb_updater/gsctool $out/bin/gsctool
          runHook postInstall
        '';

        meta = {
          description = "Utility to talk to the Google Security Chip (Cr50/Ti50) on Chromebooks";
          homepage = "https://chromium.googlesource.com/chromiumos/platform/ec/+/refs/heads/gsc_utils/extra/usb_updater";
          license = bsd3;
          mainProgram = "gsctool";
          platforms = linux;
        };
      });
    };
}
