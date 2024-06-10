{
  self,
  config,
  lib,
  pkgs,
  system,
  ...
}:
with lib; let
  cfg = config.dave.linux-builder;
in {
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

    nix.linux-builder = let
      systems = ["x86_64-linux" "aarch64-linux"];
    in {
      enable = true;
      systems = systems;
      ephemeral = true;
      config = mkIf (cfg.enableConfig) (
        {pkgs, ...}: {
          system.stateVersion = "23.11";
          # This can't include aarch64-linux when building on aarch64,
          # for reasons I don't fully understand
          boot.binfmt.emulatedSystems = ["x86_64-linux"];
          nix.settings = {
            substituters = [
              "https://nix-community.cachix.org"
            ];
            trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
            extra-platforms = systems;
          };
        }
      );
      # nix store ping --store ssh-ng://builder@linux-builder?ssh-key=/etc/nix/builder_ed25519
    };
  };
}
