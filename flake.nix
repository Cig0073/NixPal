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
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = { self, nixpkgs, jovian-nixos,chaotic, ... }@inputs:
    let
      inherit (chaotic.vendored) jovian;
    in
    {
  	nixosConfigurations = {
  	  nixpal = nixpkgs.lib.nixosSystem {
    		system = "x86_64-linux";
    		specialArgs = { inherit inputs; };
   	   	modules = [ 
   	  	  jovian-nixos.nixosModules.default
   	  	  chaotic.nixosModules.default
   	  	  inputs.nixkit.nixosModules.default
   	      #./bigscreen-workaround.nix
   	  	  ./configuration.nix 
   	      ./gaming-jovian.nix
   	      ./sshd-inhibit-suspend.nix
 	      ];
  	  };
    };
  };
}
