{
  services.inputplumber.enable = true;

  nixpkgs.overlays = [
    (final: prev: {
      inputplumber = prev.inputplumber.overrideAttrs(old: {
        src = prev.fetchFromGitHub {
          owner = "winghugs";
          repo = "InputPlumber";
          rev = "e76da54b5cbd8150fe56d676194d9bc90116ba1e";
          hash = "sha256-s/eDu0wW3vOousB4fVwKyQVyiUSVchIKiMc8NkHECkM=";
        };

        checkFlags = [
          "--skip=drivers::flydigi_vader_4_pro::hid_report_test::test_flydigi_vader_4_pro"
        ];
      });
    })
  ];
}
