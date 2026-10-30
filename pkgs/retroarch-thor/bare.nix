{ lib, retroarch-bare, fetchFromGitHub, makeBinaryWrapper }:
retroarch-bare.overrideAttrs (old: {
  version = "1.22.2-unstable-2026-10-29";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "RetroArch";
    rev = "e9a553a660e238cd88a4db66076f0ee2328ea844";
    hash = "sha256-lHt75xnmxNgKlqidOlFgpMGSyxVIOVwofyE5LVpnkEg=";
  };

  patches = (old.patches or [ ]) ++ [ ./x11-screen-windows.patch ];

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
