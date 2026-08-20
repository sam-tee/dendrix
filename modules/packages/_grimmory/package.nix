{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs_24,
  pnpm_11,
  pnpmConfigHook,
  fetchPnpmDeps,
  gradle_9,
  jdk25,
  makeWrapper,
  ffmpeg-headless,
  kepubify,
  libarchive,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "grimmory";
  version = "0-unstable-2026-08-18";

  src = fetchFromGitHub {
    owner = "grimmory-tools";
    repo = "grimmory";
    rev = "ddb9d3cfcb92f3f8e45e13e01d4bcc566058c343";
    hash = "sha256-2mc8R9PXgTRKApFobREvnSbGoZFfCuS2WLXxD/FPQ8k=";
  };

  nativeBuildInputs = [
    nodejs_24
    pnpm_11
    pnpmConfigHook
    gradle_9
    jdk25
    makeWrapper
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-i5ITyeFOUBRjqct9LUepB09tnu87xgId2Ots/Q53rxQ=";
  };

  mitmCache = gradle_9.fetchDeps {
    pkg = {pname = "grimmory";};
    data = ./deps.json;
  };

  buildPhase = ''
    runHook preBuild

    CI=1 NG_CLI_ANALYTICS=false pnpm -C frontend run build:prod

    cd backend
    gradle --no-daemon -PfrontendDistDir="$PWD/../frontend/dist/grimmory/browser" bootJar

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/grimmory" "$out/bin"

    jar="$(find build/libs -maxdepth 1 -name '*.jar' ! -name '*plain.jar' | head -n 1)"
    cp "$jar" "$out/lib/grimmory/grimmory.jar"

    makeWrapper "${lib.getExe jdk25}" "$out/bin/grimmory" \
      --add-flags "--enable-native-access=ALL-UNNAMED --enable-preview" \
      --add-flags "-jar $out/lib/grimmory/grimmory.jar" \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath [libarchive stdenv.cc.cc.lib]}" \
      --prefix PATH : "${lib.makeBinPath [ffmpeg-headless kepubify]}"

    runHook postInstall
  '';

  meta = {
    description = "Self-hosted digital library for ebooks, comics, and audiobooks";
    homepage = "https://github.com/grimmory-tools/grimmory";
    license = lib.licenses.agpl3Only;
    mainProgram = "grimmory";
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
})
