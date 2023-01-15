{
  description = "Daves Darwin system";

  inputs = {
    stable.url = "nixpkgs";
    unstable.url = "github:nixos/nixpkgs/master";
    nur.url = "github:nix-community/NUR";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "stable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "stable";
    };
  };

  outputs = { self, nixpkgs, darwin,  home-manager, ... }@inputs: {
    darwinConfigurations."Hal" = darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        ./dave.nix
        home-manager.darwinModule
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
          };
        }
        ./modules/home.nix
      ];
    };
  };
}

