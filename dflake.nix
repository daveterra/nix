{
  description = "Daves Darwin system";

  inputs = {
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin,  home-manger, ... }@inputs: {
    darwinConfigurations."Hal" = darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [  ];
    };
  };
}
