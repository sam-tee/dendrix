_: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: let
    inherit (lib) hasSuffix optionalAttrs;
    inherit (lib.licenses) mit;
    inherit (lib.platforms) darwin;
  in
    optionalAttrs (hasSuffix "darwin" system) (let
      # The PR needs Swift 6.4 and the macOS 27 SDK, newer than nixpkgs' swift, and there are no
      # release artifacts, so build impurely with the host's Command Line Tools (needs sandbox = false)
      clt = "/Library/Developer/CommandLineTools";
    in {
      # AeroSpace with the scrolling and tabs layouts from https://github.com/nikitabobko/AeroSpace/pull/2057
      packages.aerospace-tiling = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
        pname = "aerospace-tiling";
        version = "0.21.3-Beta-unstable-2026-11-01";

        src = pkgs.fetchFromGitHub {
          owner = "vadika";
          repo = "AeroSpace";
          rev = "07e378adbde8631c0cd58ff2d70830ae2f9a5165";
          hash = "sha256-r1fFDt+wGD3OFB4ekCBfruPrG7tT9eRn4k/sIw/xjkI=";
        };

        swiftpmDeps = pkgs.swiftPackages.fetchSwiftPMDeps {
          inherit (finalAttrs) pname version src;
          hash = "sha256-vfXRPIrvzbsR7uuoU0JF3WTMz1F8xiw0PbrUrpcGgUE=";
        };

        __noChroot = true;
        strictDeps = true;
        __structuredAttrs = true;
        dontStrip = true;

        nativeBuildInputs = with pkgs; [
          asciidoctor
          cctools
          complgen
          installShellFiles
        ];

        postPatch = ''
          cat > Sources/Common/versionGenerated.swift <<EOF
          public let aeroSpaceAppVersion = "${finalAttrs.version}"
          EOF
          cat > Sources/Common/gitHashGenerated.swift <<EOF
          public let gitHash = "${finalAttrs.src.rev}"
          public let gitShortHash = "${builtins.substring 0 7 finalAttrs.src.rev}"
          EOF

          # In the macOS 27 SDK @State is a macro whose plugin only ships with Xcode, not the CLT
          substituteInPlace Sources/AppBundle/ui/VolumeView.swift \
            --replace-fail "@State var volume" "var volume"
          substituteInPlace Sources/AppBundle/ui/SecureInputView.swift \
            --replace-fail "@State var isMinimized: Bool = true" "private let _isMinimized = State(initialValue: true)
              var isMinimized: Bool {
                  get { _isMinimized.wrappedValue }
                  nonmutating set { _isMinimized.wrappedValue = newValue }
              }"
        '';

        configurePhase = ''
          runHook preConfigure

          export SDKROOT=${clt}/SDKs/MacOSX.sdk HOME=$TMPDIR
          mkdir -p .build
          install -m644 ${finalAttrs.swiftpmDeps}/workspace-state.json .build/
          ln -s ${finalAttrs.swiftpmDeps}/Packages Packages

          runHook postConfigure
        '';

        buildPhase = ''
          runHook preBuild

          swiftBuild=(${clt}/usr/bin/swift build -c release --disable-sandbox)
          "''${swiftBuild[@]}" --product aerospace
          "''${swiftBuild[@]}" --product AeroSpaceApp
          binPath="$("''${swiftBuild[@]}" --show-bin-path)"

          mkdir -p .man
          cp -r docs/*.adoc docs/util docs/config-examples .man
          (cd .man && asciidoctor -b manpage aerospace*.adoc)

          mkdir -p .shell-completion
          complgen --zsh .shell-completion/_aerospace grammar/commands-bnf-grammar.txt
          complgen --fish .shell-completion/aerospace.fish grammar/commands-bnf-grammar.txt
          complgen --bash .shell-completion/aerospace grammar/commands-bnf-grammar.txt

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          app=$out/Applications/AeroSpace.app/Contents

          install -Dm755 "$binPath/AeroSpaceApp" $app/MacOS/AeroSpace
          # bundle the Span back-deployment library like upstream instead of linking into the CLT
          spanLib=$(find ${clt}/usr/lib -path "*/macosx/libswiftCompatibilitySpan.dylib" | head -1)
          install -Dm644 "$spanLib" $app/Frameworks/libswiftCompatibilitySpan.dylib
          install_name_tool -delete_rpath "$(dirname "$spanLib")" \
            -add_rpath @executable_path/../Frameworks $app/MacOS/AeroSpace
          install -Dm644 docs/config-examples/default-config.toml $app/Resources/default-config.toml
          cat > $app/Info.plist <<EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
            <key>CFBundleExecutable</key><string>AeroSpace</string>
            <key>CFBundleIdentifier</key><string>bobko.aerospace</string>
            <key>CFBundleName</key><string>AeroSpace</string>
            <key>CFBundlePackageType</key><string>APPL</string>
            <key>CFBundleShortVersionString</key><string>${finalAttrs.version}</string>
            <key>CFBundleVersion</key><string>${finalAttrs.version}</string>
            <key>LSMinimumSystemVersion</key><string>13.0</string>
            <key>LSUIElement</key><true/>
            <key>NSPrincipalClass</key><string>NSApplication</string>
          </dict>
          </plist>
          EOF
          echo -n "APPL????" > $app/PkgInfo
          /usr/bin/codesign --force --deep --sign - --entitlements resources/AeroSpace.entitlements $out/Applications/AeroSpace.app

          install -Dm755 "$binPath/aerospace" $out/bin/aerospace

          installManPage .man/*.1
          installShellCompletion --bash .shell-completion/aerospace
          installShellCompletion --fish .shell-completion/aerospace.fish
          installShellCompletion --zsh .shell-completion/_aerospace

          runHook postInstall
        '';

        meta = {
          description = "i3-like tiling window manager for macOS, with scrolling and tabs layouts";
          homepage = "https://github.com/nikitabobko/AeroSpace/pull/2057";
          license = mit;
          mainProgram = "aerospace";
          platforms = darwin;
        };
      });
    });
}
