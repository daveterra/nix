{ self, config, lib, pkgs, system, ... }:
with lib; let
  cfg = config.dave.linux-builder;
in
{
  options = {
    dave.linux-builder = {
      enabled = mkOption {
        description = ''
          Linux builder is: 
            1. A NixOS Linux VM that runs locally on the host machine
            2. A set of scripts and nix configuration that allows this VM to be used as a builder
        '';
        type = types.bool;
        default = false;
      };
      enableConfig = mkOption {
        type = types.bool;
        default = false;
        description = ''
          The reason the linux-builder works at all is because the default configuration is cached in binary form and available via the default nix cache. 

          However, the default is only meant to perform as a bootstrapping mechanism. Only after the default is running can we modify the VM to suit our needs (otherwise, there is nothing available to build the changes to the VM)
          '';
      };
    };
  };

  config = mkIf (cfg.enabled) {
    nix.settings = {
      trusted-users = [
        "dave"
        "@admin"
      ];
      extra-trusted-users = [
        "@admin"
        "dave"
      ];
    };

    launchd.daemons.linux-builder = {
      serviceConfig = {
        StandardOutPath = "/var/log/darwin-builder.log";
        StandardErrorPath = "/var/log/darwin-builder.log";
      };
    };

    nix.linux-builder = {
      enable = true;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      speedFactor = 10;
      maxJobs = 4;
      ephemeral = true;
      # mem8192
      config = mkIf (!cfg.enableConfig) ({ pkgs, ... }:
        {
          system.stateVersion = "23.11";

          virtualisation.darwin-builder.diskSize = 60 * 1024;
          virtualisation.darwin-builder.memorySize = 4096 * 2;
          virtualisation.cores = 8;

          environment.systemPackages = [ pkgs.nixos-rebuild ];
          services.openssh.enable = true;
          boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
          nix.settings = {
            substituters = [
              "https://nix-community.cachix.org"
            ];
            trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
          };
        }
      );
      # nix store ping --store ssh-ng://builder@linux-builder?ssh-key=/etc/nix/builder_ed25519
    };
  };
}
