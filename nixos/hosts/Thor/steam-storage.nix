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

  # Storage only (see platform.toml below). The Deck-only tools Jovian patches
  # in are never called with that config.
  steamos-manager = (jovian.steamos-manager.override {
    jovian-stubs = none;
    steamdeck-firmware = none;
    jupiter-dock-updater-bin = none;
    scx.rustscheds = none;
  }).overrideAttrs (old: {
    # Read the platform config from /etc, so changing it needs no rebuild.
    postPatch = old.postPatch + ''
      substituteInPlace steamos-manager/src/platform.rs \
        --replace-fail "$out/share/steamos-manager/platform.toml" /etc/steamos-manager/platform.toml
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
