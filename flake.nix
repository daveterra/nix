{
  description = "Daves Nix Configs";

  nixConfig = {
    # builders = [ "ssh-ng://builder@linux-builder aarch64-linux,x86_64-linux" ];
    # builders-use-substitutes = true;
    build-users-group = [];
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # substituters = [
  #       "https://xe.cachix.org"
  #       "https://nix-community.cachix.org"
  #       "https://cuda-maintainers.cachix.org"
  #       "https://cache.floxdev.com?trusted=1"
  #       "https://cache.garnix.io"
  #     ];

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/NUR";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    nixos-generators,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
    ];

    forAllLinuxSystems = nixpkgs.lib.genAttrs [
      # "Max" from flight of the navigator
      # "COS" from X-Files
      # "Ziggy" from quantum leap
      "GladOS"
      "DeepThought"
    ];

    forAllDarwinSystems = nixpkgs.lib.genAttrs [
      "Hal"
      "Cinco" # Or should it be Cinco
    ];
  in rec {
    overlays = import ./overlays {inherit inputs;};

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        with pkgs; rec {
          default = mkShell {
            NIX_CONFIG = "
            experimental-features = nix-command flakes; 
            nix.configureBuildUsers = false;
            ";
            nativeBuildInputs = [
              nix
              git
              cachix
              pkgs.home-manager
              nix-darwin.packages.${system}.default
            ];
            packages = [hello];
          };
        }
    );

    # packages.aarch64-darwin.doImage = let
    #     pkgs = nixpkgs.legacyPackages.x86_64-linux;
    # in
    #   import ./do_image.nix {inherit pkgs;};

    # packages.aarch64-darwin.doImage = let
    #   pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    # in pkgs.lib.nixosSystem {
    #   system = "x86_64-linux";
    #   modules = [
    #     {
    #       imports = [
    #         "${pkgs}/nixos/modules/virtualisation/digital-ocean-image.nix"
    #       ];
    #     }
    #   ];
    # };

    packages.aarch64-darwin.doImage = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      modules = [];
      format = "do";
    };

    packages.aarch64-darwin.default = packages.aarch64-darwin.doImage;

    nixosConfigurations = forAllLinuxSystems (
      computer: let
      in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-generators.nixosModules.all-formats
            computers/${computer}.nix
          ];
        }
    );

    darwinConfigurations = forAllDarwinSystems (
      computer: let
        system = "aarch64-darwin";
      in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {inherit inputs outputs;};
          modules = [
            ./config
            nixos-generators.nixosModules.all-formats
            ./computers/${computer}.nix
            home-manager.darwinModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
              };
            }
          ];
        }
    );
  };
}
