{ config, pkgs, ... }:

{
	nixpkgs.config.allowUnfree = true;
	hardware.enableAllFirmware = true;
	hardware.enableAllHardware = true;
	#services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

	hardware.graphics = {
	    enable = true;
	    enable32Bit = true; 
	    extraPackages = with pkgs; [ libva-vdpau-driver libvdpau-va-gl ];
	  };

	# Nvidia GTX 950M specific legacy branch
	#  hardware.nvidia = {
	#    modesetting.enable = true;
	#    powerManagement.enable = false;
	#    open = false; 
	#    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
	#  };
	

  # Macbook air wifi drivers

  # nixpkgs.config.permittedInsecurePackages = [
    # "broadcom-sta-6.30.223.271-59-7.1"
    # ];

  # boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  # boot.kernelModules = [ "wl" ];
  # boot.blacklistedKernelModules = [ "b43" "bcma" "ssb" "brcmfmac" ];

}
