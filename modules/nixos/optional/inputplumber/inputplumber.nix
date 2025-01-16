{
  services.inputplumber.enable = true;

  nixpkgs.overlays = [
    (final: prev: {
      inputplumber = prev.inputplumber.overrideAttrs(old: {
        patches = (old.patches or []) ++ [
          ./flydigi-extra-buttons.patch
        ]; 

	postInstall = (old.postInstall or "") + ''
	  cp -r ${./devices/40-flydigi-vader-4-pro.yaml} $out/share/inputplumber/devices/40-flydigi-vader-4-pro.yaml
	  cp -r ${./capability_maps/flydigi-vader-4-pro.yaml} $out/share/inputplumber/capability_maps/flydigi-vader-4-pro.yaml
	'';	
      });
    })
  ];
}
