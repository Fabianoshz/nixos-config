{ lib, retroarch-bare, fetchFromGitHub, makeBinaryWrapper }:
retroarch-bare.overrideAttrs (old: {
  version = "1.22.2-unstable-2026-11-11";

  src = fetchFromGitHub {
    owner = "Davey-Hughes";
    repo = "RetroArch";
    rev = "527897acee4836c0dbd81bff05aa0711f05101fe";
    hash = "sha256-hNujzhyAu0+94ZQlzM/JaLrggmIuPWOwlWMHa2TUZOw=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ makeBinaryWrapper ];

  # Vulkan would pick vk_wayland under gamescope; the screen windows and
  # gamescope's bottom-screen title rule are X11 only.
  postInstall = old.postInstall + ''
    wrapProgram $out/bin/retroarch --unset WAYLAND_DISPLAY
  '';

  configureFlags =
    lib.filter
      (
        f: !lib.elem f [
          "--disable-builtinmbedtls"
          "--enable-systemmbedtls"
          "--disable-builtinzlib"
        ]
      )
      old.configureFlags
    ++ [
      "--enable-mbedtls"
      "--enable-zlib"
      "--enable-video_windows"
    ];
})
