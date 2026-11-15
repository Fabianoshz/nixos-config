{ ... }:

{
  # Upstream's Thor config with my button layout (ayn_mcu): AYN = Guide,
  # Home/Back = back paddles. Same file name as upstream's, and devices.d loads
  # first, so it claims the controller.
  environment.etc."inputplumber/devices.d/50-ayn_thor.yaml".source = ./50-ayn_thor.yaml;
  environment.etc."inputplumber/capability_maps.d/ayn_mcu.yaml".source = ./ayn_mcu.yaml;
}
