{
  description = "NixPal - Portable PC solution";

  inputs = {
  	nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
	nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  	
    # Jovian tracking development
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS/d1bf8a75f336bdab658af05372bac9368030ad30";
     # inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, jovian-nixos, ... }@inputs:
  {
  	nixosConfigurations = {
  	  nixpal = nixpkgs.lib.nixosSystem {
  		system = "x86_64-linux";
  		specialArgs = { inherit inputs; };
 		modules = [ 
 		  ./configuration.nix 
 		  {
 		    specialisation.gaming.configuration = {
 		      # 1. Inherit or import your Jovian setup on the fly
 		      imports = [
 		        jovian-nixos.nixosModules.default
 	            ./gaming-jovian.nix
      	        ];
 		    };
 		  }
 	    ];
  	  };
    };
  };
}
