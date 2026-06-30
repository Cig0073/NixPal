{

  description = "NixPal - Portable PC solution";

  inputs = {
  	nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
    in {
  	nixosConfigurations = {
  	  nixpal = lib.nixosSystem {
  		system = "x86_64-linux";
 		modules = [ ./configuration.nix ]
  	  };
  	};
  };

}
