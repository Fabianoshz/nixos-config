{ config, pkgs, lib, inputs, ... }:
{
  home.stateVersion = "26.05";

  imports = [
    ./firefox.nix
    ./syncthing.nix

    ../../../optional/git/default.nix
    ../../../optional/kde/default.nix
    ../../../optional/neovim/default.nix
    ../../../optional/opencode/default.nix
    ../../../optional/thunderbird/default.nix
    ../../../optional/zsh/default.nix

    inputs.xdg-autostart.homeManagerModules.xdg-autostart
  ];

  programs.home-manager.enable = true;

  services.home-manager.autoExpire = {
    enable = true;
    timestamp = "-30 days";
    frequency = "weekly";
  };
  programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";

  xdg.autostart = {
    enable = true;
    entries = [
      "${pkgs.kdePackages.yakuake}/share/applications/org.kde.yakuake.desktop"
    ];
  };

  xdg.desktopEntries =
    let
      shield = id: name: host: {
        ${id} = {
          inherit name;
          exec = "${pkgs.writeShellApplication {
            name = id;
            runtimeInputs = [ pkgs.android-tools pkgs.scrcpy ];
            text = ''
              device=${host}.in.gambiarra.net:5555
              adb connect "$device"
              exec scrcpy -s "$device" --no-audio --keyboard=uhid --mouse=uhid --max-size=1280 --no-clipboard-autosync --window-title="${name}"
            '';
          }}/bin/${id}";
          icon = "video-television";
          terminal = false;
          type = "Application";
        };
      };
    in
    {
      actual = {
        name = "Actual Budget";
        exec = "appimage-run /home/fabiano/Applications/Actual-linux-x86_64.AppImage";
        terminal = false;
        type = "Application";
      };
    }
    // shield "shield-sala" "Shield Sala - scrcpy" "nvidia-shield-6b09ad"
    // shield "shield-suite" "Shield Suíte - scrcpy" "nvidia-shield-6b0812";

  services.ssh-agent = {
    enable = true;
  };

  home.username = "fabiano";
  home.homeDirectory = "/home/fabiano";
  home.sessionVariables = {
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${config.xdg.configHome}/java -Djavafx.cachedir=${config.xdg.cacheHome}/openjfx";
    ANSIBLE_HOME = "${config.xdg.dataHome}/ansible";
    AWS_CONFIG_FILE = "${config.xdg.configHome}/aws/config";
    AWS_SHARED_CREDENTIALS_FILE = "${config.xdg.configHome}/aws/credentials";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    CHECKPOINT_DISABLE = "1";
    CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
    EDITOR = "nvim";
    ELECTRUMDIR = "${config.xdg.dataHome}/electrum";
    GNUPGHOME = "${config.xdg.dataHome}/gnupg";
    GOPATH = "${config.xdg.dataHome}/go";
    HISTFILE = "${config.xdg.stateHome}/bash_history";
    KUBECACHEDIR = "${config.xdg.cacheHome}/kube";
    KUBECONFIG = "${config.xdg.configHome}/kube/kubeconfig";
    LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
    MAVEN_OPTS = "-Dmaven.repo.local=${config.xdg.dataHome}/maven/repository";
    MINIKUBE_HOME = "${config.xdg.dataHome}/minikube";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/config";
    PSQL_HISTORY = "${config.xdg.stateHome}/psql_history";
    PYTHON_HISTORY = "${config.xdg.stateHome}/python_history";
    RANDFILE = "${config.xdg.cacheHome}/rnd";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    SYSTEMD_EDITOR = "nvim";
    TF_PLUGIN_CACHE_DIR = "${config.xdg.cacheHome}/terraform/plugins";
    WGETRC = "${config.xdg.configHome}/wgetrc";
    WINEPREFIX = "${config.xdg.dataHome}/wine";
    ZPLUG_HOME = "${config.xdg.dataHome}/zplug";
  };

  xdg.configFile."wgetrc".text = ''
    hsts-file = ${config.xdg.cacheHome}/wget-hsts
  '';

  home.activation.terraformPluginCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${config.xdg.cacheHome}/terraform/plugins
  '';

  home.packages = [
    pkgs.awscli2
    pkgs.dbeaver-bin
    pkgs.dig
    pkgs.discord
    pkgs.feishin
    pkgs.godot
    pkgs.htop
    pkgs.iotop
    pkgs.keepassxc
    pkgs.moonlight-qt
    pkgs.obsidian
    pkgs.onlyoffice-desktopeditors
    pkgs.opencode
    pkgs.planify
    pkgs.ripgrep
    pkgs.rofi
    pkgs.rpi-imager
    pkgs.ssm-session-manager-plugin
    pkgs.steamtinkerlaunch
    pkgs.sweethome3d.application
    pkgs.unzip
    pkgs.usbutils
    pkgs.virt-manager
    pkgs.vlc

    pkgs.unstable.claude-code
    pkgs.unstable.grayjay

    # Rice stuff
    inputs.lightly.packages.${pkgs.stdenv.hostPlatform.system}.darkly-qt5
    inputs.lightly.packages.${pkgs.stdenv.hostPlatform.system}.darkly-qt6
    pkgs.plasma-panel-colorizer

    # KDE
    pkgs.kdePackages.dolphin
    pkgs.kdePackages.dolphin-plugins
    pkgs.kdePackages.filelight
    pkgs.kdePackages.gwenview
    pkgs.kdePackages.kate
    pkgs.kdePackages.kcalc
    pkgs.kdePackages.konsole
    pkgs.kdePackages.kwalletmanager
    pkgs.kdePackages.okular
    pkgs.kdePackages.yakuake

    (pkgs.streamcontroller.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src/backend/Store/StoreBackend.py \
          --replace-fail '        branch = plugin.get("branch")' \
          '        if url == "https://github.com/gensyn/HomeAssistantPlugin":
                    commit = "54355d6dba197db011961b8dfc68b290e52f2452"
                branch = plugin.get("branch")'
      '';
    }))
  ];
}
