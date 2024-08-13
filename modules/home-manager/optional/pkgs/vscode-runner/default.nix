{ lib
, inputs
, buildDartApplication
, sqlite
, kdePackages
, ...
}:

buildDartApplication rec {
  pname = "vscode-runner";
  version = "fixed-by-flake";

  src = inputs.vscode-runner;

  vendorHash = "sha256-jS4jH00uxZIX81sZQIi+s42ofmXpD4/tPMRV2heaM2U=";

  autoPubspecLock = src + "/pubspec.lock";

  dartEntryPoints = { "bin/vscode_runner" = "bin/vscode_runner.dart"; };

  preFixup = ''
    wrapProgram $out/bin/vscode_runner \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ sqlite ]}
  '';

  postInstall = ''
    substituteInPlace ./package/codes.merritt.vscode_runner.service \
      --replace "Exec=" "Exec=$out/bin/vscode_runner"
    install -D \
      ./package/codes.merritt.vscode_runner.service \
      $out/share/dbus-1/services/codes.merritt.vscode_runner.service

    install -D \
      ./package/plasma-runner-vscode_runner.desktop \
      $out/share/krunner/dbusplugins/plasma-runner-vscode_runner.desktop
  '';

  meta = {
    description = "KRunner plugin for quickly opening recent VSCode workspaces";
    homepage = "https://github.com/Merrit/vscode-runner";
    changelog = "https://github.com/Merrit/vscode-runner/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    mainProgram = "vscode_runner";
    inherit (kdePackages.krunner.meta) platforms;
  };
}
