{ lib
, stdenvNoCC
, fetchFromGitHub
, fetchPnpmDeps
, pnpmConfigHook
, pnpm
, nodejs
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "decky-pip";
  version = "1.0.0-unstable-2025-01-13";

  src = fetchFromGitHub {
    owner = "rossimo";
    repo = "decky-pip";
    rev = "4cc181bccadda77c38b81e52eb43c61bd176bdc3";
    hash = "sha256-+8cxpuIlzvHdNeppEv7+cUx+T4THF1ygtGJY5KR6myk=";
  };

  # https://github.com/rossimo/decky-pip/pull/19
  patches = [ ./live-screen-size.patch ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-oIdgg2p8jqrDldf+GrlTPcI5BJGKBLq3CKwYv4BnW+E=";
  };

  nativeBuildInputs = [ nodejs pnpm pnpmConfigHook ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r dist plugin.json package.json LICENSE README.md $out/
    runHook postInstall
  '';
})
