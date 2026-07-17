{
  description = "NixPal - Portable PC solution";

  inputs = {
  	nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Jovian tracking development
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixkit = {
      url = "github:frostplexx/nixkit";
      inputs.nixpkgs.follows = "nixpkgs";	
    };
  };

  outputs = { self, nixpkgs, jovian-nixos, ... }@inputs:
  {
  	nixosConfigurations = {
  	  nixpal = nixpkgs.lib.nixosSystem {
  		system = "x86_64-linux";
  		specialArgs = { inherit inputs; };
 		modules = [ 
 		  jovian-nixos.nixosModules.default
 		  inputs.nixkit.nixosModules.default
 		  ./configuration.nix 
 	      ./gaming-jovian.nix
 	    ];
  	  };
    };
  };
}
