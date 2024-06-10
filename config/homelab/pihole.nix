{ self, config, lib, pkgs, system, ... }:
with lib; let
  cfg = config.dave.homelab.apps.pihole;
in
{
  options = {
    dave.homelab.apps.pihole = {
      enabled = mkOption {
        description = ''
        '';
        type = types.bool;
        default = true;
      };
    };
    dave.homelab.apps.arr = {
      enabled = mkOption {
        description = ''
        '';
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf (cfg.enabled) { 
    dave.homelab.apps.pihole.enabled = false;
  };
}
