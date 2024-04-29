{ pkgs  }:

let config = {
  imports = [ "pkgs/nixos/modules/virtualisation/digital-ocean-image.nix" ];
};
in
(pkgs.nixos config).digitalOceanImage
