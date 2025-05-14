{
  nixpkgs.overlays = [
    (final: prev: {
      inputplumber = prev.inputplumber.overrideAttrs(old: {
        patches = [
          ./logs.patch
        ];
      });
    })
  ];
}
