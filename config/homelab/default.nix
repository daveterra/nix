{ self, config, lib, pkgs, system, ... }:
with lib; let
  cfg = config.dave.homelab;
  # homelabApps = nixpkgs.lib.genAttrs [
  #   "pihole"
  # ];
in
{
  imports = [ ./pihole.nix ];
  options = {
    dave.homelab = {
      enabled = mkOption {
        description = ''
        '';
        type = types.bool;
        default = true;
      };

      enabledApps = mkOption {
        type = with types; listOf (enum [ "pihole" "arr" ]);
        default = [];
      };
    };
  };

  config = let 
        forAllApps = genAttrs cfg.enabledApps ;
  in mkIf (cfg.enabledApps != []) {
    # homelab =
    #   let
    #     forAllApps = lib.genAttrs [ cfg.apps ];
    #   in

    dave.homelab.apps = forAllApps ( app: {
      enabled = true;
    });

    # dave.homelab.apps = forEach cfg.enabledApps ( app: {
    #   enabled = true;
    # });
      # lib.forEach cfg.apps (app: rec {
      #   "${app}".enabled = true;
      # }
      # );
      # forAllApps ( app: {
      #   "${app}".enabled = true;
      #         });

      # dave.homelab.pihole.enabled = true;
  };
}
