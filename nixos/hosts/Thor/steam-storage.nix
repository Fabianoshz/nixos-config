{ pkgs, inputs, steam-launcher, ... }:
let
  # Jovian's handler runs the x86 client through steam-run; hand steam:// URLs
  # (automount's fsck-failure report) to the running ARM client instead.
  jovian = (pkgs.extend inputs.jovian-nixos.overlays.default).jovianPackages.overrideScope (_: _: {
    jovian-steam-protocol-handler = pkgs.writeShellScript "thor-steam-protocol-handler" ''
      exec ${steam-launcher} "$@"
    '';
  });
  hwsupport = jovian.jupiter-hw-support;
  none = pkgs.emptyDirectory;

  # Built as Armada does: main at Armada's pin plus Armada's patches, whose 0002
  # stops it turning the controller into a Deck pad when no device config asks.
  steamosManagerSrc = pkgs.fetchFromGitLab {
    domain = "gitlab.steamos.cloud";
    owner = "holo";
    repo = "steamos-manager";
    rev = "61786e2909d638a8e4e15e5e2df80799c60b7619";
    hash = "sha256-ZMnqXoTWQejyXtfUn9fln7gJiFvXpzUth6H8m/Kqot8=";
  };
  armadaSteamosManagerPatches = pkgs.fetchgit {
    url = "https://github.com/armada-os/armada.git";
    rev = "b031deef99a095104ef234c5a0705850152dffe1";
    sparseCheckout = [ "packages/steamos-manager/patches" ];
    hash = "sha256-3ANsU4y38lxLB59iwjQP827s/fcT5VUWB1S+VhNHxYA=";
  };

  # Storage only (see platform.toml below). The Deck-only tools Jovian patches
  # in are never called with that config.
  steamos-manager = (jovian.steamos-manager.override {
    jovian-stubs = none;
    steamdeck-firmware = none;
    jupiter-dock-updater-bin = none;
    scx-scheds = none;
  }).overrideAttrs (old: {
    version = "26.4.1-unstable-2026-10-23";
    src = steamosManagerSrc;
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      src = steamosManagerSrc;
      hash = "sha256-iY5KE3gLkyvTXaZoUOxgOIl3fr/je6YOg5kTg9WRrcY=";
    };
    # Jovian's disable-ftrace.patch no longer applies on main; done in postPatch.
    patches = builtins.filter (p: !(pkgs.lib.hasSuffix "disable-ftrace.patch" (toString p))) old.patches
      ++ map (n: "${armadaSteamosManagerPatches}/packages/steamos-manager/patches/${n}")
      (builtins.attrNames (builtins.readDir "${armadaSteamosManagerPatches}/packages/steamos-manager/patches"));
    postPatch = old.postPatch + ''
      substituteInPlace steamos-manager/src/daemon/root.rs \
        --replace-fail "let ftrace = Ftrace::init().await?;" "" \
        --replace-fail "daemon.add_service(ftrace);" ""
      # Read the platform config from /etc, so changing it needs no rebuild.
      substituteInPlace steamos-manager/src/platform.rs \
        --replace-fail "$out/share/steamos-manager/platform.toml" /etc/steamos-manager/platform.toml
    '';
    # Device match by device tree, with Steam's performance profiles.
    postInstall = old.postInstall + ''
      install -m644 ${./ayn-thor.toml} $out/share/steamos-manager/devices/ayn-thor.toml
    '';
  });

  # Steam formats the SD card through this helper (pkexec on SteamOS, which
  # can't work in the FHS sandbox): ask steamos-manager instead, print the
  # script's stage= lines from the journal and return its exit code.
  format-sdcard = pkgs.writeTextFile {
    name = "steamos-format-sdcard";
    destination = "/bin/steamos-polkit-helpers/steamos-format-sdcard";
    executable = true;
    text = ''
      #!${pkgs.runtimeShell}
      set -eu
      label=""
      validate=true
      while [ $# -gt 0 ]; do
        case "$1" in
          --label) label="$2"; shift 2 ;;
          --skip-validation | --force) validate=false; shift ;;
          --owner) shift 2 ;;
          *) shift ;;
        esac
      done

      busctl=${pkgs.systemd}/bin/busctl
      bus=com.steampowered.SteamOSManager1
      since=$(${pkgs.coreutils}/bin/date +%s)
      job=$($busctl --user call $bus /com/steampowered/SteamOSManager1 $bus.Storage1 \
        FormatDevice ssb /dev/mmcblk0 "$label" $validate | ${pkgs.gawk}/bin/awk '{ gsub(/"/, "", $2); print $2 }')
      ${pkgs.systemd}/bin/journalctl -f -o cat --since=@$since -t holo-format-device &
      log=$!
      rc=$($busctl --user call $bus "$job" $bus.Job1 Wait | ${pkgs.gawk}/bin/awk '{ print $2 }')
      ${pkgs.coreutils}/bin/sleep 1
      kill $log
      exit "$rc"
    '';
  };
in
{
  thor.steam.extraPackages = [ format-sdcard ];

  environment.etc."steamos-manager/platform.toml".text = ''
    [storage.trim_devices]
    script = "${hwsupport}/lib/hwsupport/trim-devices.sh"

    [storage.format_device]
    script = "${hwsupport}/lib/hwsupport/format-device.sh"
    # fabiano:users; Valve's default is 1000:1000.
    script_args = ["--owner", "1000:100"]
    label_flag = "--label"
    device_flag = "--device"
    no_validate_flag = "--skip-validation"
  '';

  services.udisks2.enable = true;

  services.dbus.packages = [ steamos-manager ];
  systemd.packages = [ steamos-manager ];

  systemd.services.steamos-manager = {
    overrideStrategy = "asDropin";
    # format-device.sh calls an unqualified umount.
    path = [ "/run/wrappers" ];
    wantedBy = [ "multi-user.target" ];
  };
  systemd.user.services.steamos-manager = {
    overrideStrategy = "asDropin";
    wantedBy = [ "thor-gamescope-session.target" ];
  };

  # Valve's rule matches sd* too, which is the internal UFS here; SD slot only.
  # setpriv runs `test` from PATH, which systemd-run leaves without coreutils.
  services.udev.extraRules =
    let
      run = "${pkgs.systemd}/bin/systemd-run --no-block --collect --setenv=PATH=${pkgs.coreutils}/bin";
    in
    ''
      # Keep the internal UFS (all LUNs) out of udisks2, so Steam never offers it.
      SUBSYSTEM=="block", ENV{ID_PATH}=="platform-1d84000.ufshc-*", ENV{UDISKS_IGNORE}="1"
      KERNEL=="mmcblk0p*", ENV{ID_FS_TYPE}=="ext4", ACTION=="add", RUN+="${run} ${hwsupport}/lib/hwsupport/block-device-event.sh add %k"
      KERNEL=="mmcblk0p*", ACTION=="remove", RUN+="${run} ${hwsupport}/lib/hwsupport/block-device-event.sh remove %k"
    '';
}
