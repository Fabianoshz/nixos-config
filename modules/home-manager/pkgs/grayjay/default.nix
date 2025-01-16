{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  fetchzip,
  internal,

  libz,
  icu,
  openssl,

  xorg,

  gtk3,
  glib,
  nss,
  nspr,
  dbus,
  atk,
  cups,
  libdrm,
  expat,
  libxkbcommon,
  pango,
  cairo,
  udev,
  alsa-lib,
  mesa,
  libGL,
  libsecret,
}:
let
  # need to grab prebuilt files that are failing to be fetched because of github lfs limit
  prebuilt = fetchzip {
    url = "https://updater.grayjay.app/Apps/Grayjay.Desktop/Grayjay.Desktop-linux-x64.zip";
    hash = "sha256-UqTDpPtl6kNg/4y3+HsQI+YBQ0vjvvm37xiYY90+gzw=";
  };
in
buildDotnetModule {
  name = "grayjay-desktop";
  src = fetchFromGitHub {
    owner = "futo-org";
    repo = "Grayjay.Desktop";
    rev = "08d8f13cc2e3effe8c54106fc3ee7fdd27ef9547";
    hash = "sha256-bkaqybU609uU+JKVZuBtL00ZF87C3iwMP35lidKsAJI=";
    fetchSubmodules = true;
    deepClone = true;
  };

  patches = [ ./fixes.patch ];

  executables = "Grayjay";

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  nugetDeps = ./deps.json;
  projectFile = "Grayjay.Desktop.CEF/Grayjay.Desktop.CEF.csproj";

  postInstall = ''
    rm $out/lib/Portable
    echo ${prebuilt}
    cp -r ${prebuilt}/cef/* $out/lib/cef
    mkdir -p $out/lib/wwwroot
    ln -s ${internal.grayjay-web} $out/lib/wwwroot/web
  '';

  runtimeDeps = [
    libz
    icu
    openssl # For updater

    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb

    gtk3
    glib
    nss
    nspr
    dbus
    atk
    cups
    libdrm
    expat
    libxkbcommon
    pango
    cairo
    udev
    alsa-lib
    mesa
    libGL
    libsecret
  ];

  meta = {
    mainProgram = "Grayjay";
  };
}

