{

  description = "NixPal - Portable PC solution";

  inputs = {
  	nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

	# Unstable channel specifically for cutting-edge Gamescope/Steam changes
    #nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  	
    # Jovian tracking development
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS/d1bf8a75f336bdab658af05372bac9368030ad30";
     # inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, jovian-nixos, ... }@inputs:
  let
    lib = nixpkgs.lib;
  in {
  	nixosConfigurations = {
  	  nixpal = lib.nixosSystem {
  		system = "x86_64-linux";
  		specialArgs = { inherit inputs; };
 		modules = [ 
 		  ./configuration.nix 
 		];
  	  };
  	};
  };

}
