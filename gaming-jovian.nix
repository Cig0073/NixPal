#
# copy of jovian.nix -- Gaming
#
{ config, pkgs, lib, inputs, ...}:

{
/*
  imports = [
  	./steam-switch.nix
  ];
*/
  system.activationScripts = {
    print-jovian = {
      text = builtins.trace "building the jovian configuration..." "";
    };
  };

  # Create a custom session definition that drops to SDDM
  environment.systemPackages = with pkgs; [    
    lutris
    ludusavi
    mangohud
  ];  
  
  jovian.steam = {
  	enable = true;
  	autoStart = true;
  	desktopSession = "plasma";
  	user = "cig0073";
    environment = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${pkgs.proton-ge-bin}";
    };
  };  

  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extest.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    #gamescopeSession.enable = true;
  };
  
  hardware.steam-hardware.enable = true;

  services.sunshine = {
  	enable = true;
  	openFirewall = true;
  	capSysAdmin = true;
  	autoStart = true;
  };
  
  jovian.decky-loader.enable = true;
  jovian.decky-loader.user = "cig0073";
  #jovian.devices.steamdeck.autoUpdate = true;
  jovian.steamos.useSteamOSConfig = true;
  #jovian.devices.steamdeck.enable = true;
  #jovian.devices.steamdeck.enableGyroDsuService = true;
   

  #
  # Services
  #
  # 20251117 - Disabled because of build failure and I don't need it.
  services.orca.enable = true;

  #
  # Steam
  #
  # Set game launcher: gamemoderun %command%
  #   Set this for each game in Steam, if the game could benefit from a minor
  #   performance tweak: YOUR_GAME > Properties > General > Launch > Options
  #   It's a modest tweak that may not be needed. Jovian is optimized for
  #   high performance by default.
  programs.gamemode = {
    enable = true;
    /*
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility"; # For systems with AMD GPUs
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
    */
  };
}
