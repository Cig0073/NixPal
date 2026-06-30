#
# copy of jovian.nix -- Gaming
#
{ config, pkgs, lib, ...}: let
  # Local user account for auto login
  # Separate and distinct from Steam login
  # Can be any name you like
  gameuser = "gamer";
  jovian-nixos = builtins.fetchGit {
    url = "https://github.com/Jovian-Experiments/Jovian-NixOS";
    ref = "development";
  };

  # 1. Dynamically pull all usernames defined in your configuration
  # This filters out system users (like 'root', 'nobody', etc.) by checking their UID
  allRealUsers = builtins.filter 
    (username: 
      let user = config.users.users.${username}; in
      user.isNormalUser && username != "root"
    ) 
    (builtins.attrNames config.users.users);

  # 2. Map over the users to generate tmpfiles rules for each one
  generateTmpfilesRules = username: [
    # Ensure Steam directory and compatibilitytools.d exist for the user
    "d  /home/${username}/.local/share/Steam/compatibilitytools.d 0755 ${username} users - -"
    "L+ /home/${username}/.local/share/Steam/compatibilitytools.d/proton-ge-bin - - - - ${pkgs.proton-ge-bin}"

    # Link the user's SteamApps folder to the shared directory
    "d  /home/${username}/.local/share/Steam 0755 ${username} users - -"
    "L+ /home/${username}/.local/share/Steam/steamapps - - - - /var/lib/shared-steamapps"
  ];

  # Flatten the nested lists of rules into one giant list systemd can read
  allUserTmpfilesRules = builtins.concatLists (map generateTmpfilesRules allRealUsers);
in {
  system.activationScripts = {
    print-jovian = {
      text = builtins.trace "building the jovian configuration..." "";
    };
  };

  #
  # Imports
  #
  imports = [ "${jovian-nixos}/modules" ];

  jovian.steam = {
  	enable = true;
  	autoStart = true;
  	desktopSession = "plasma";
  	user = "${gameuser}"; 	
  };  

  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extest.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    gamescopeSession.enable = true;
  };

  programs.gamescope = {
    enable = true;
  	#enableWsi = true; not yet in the repos
  	#capSysNice = true;
  };

  hardware.steam-hardware.enable = true;

  services.sunshine = {
  	enable = true;
  	openFirewall = true;
  	capSysAdmin = true;
  	autoStart = true;
  };

  environment.systemPackages = with pkgs; [
    git #needed to fetch jovian
  	lutris
  	ludusavi
  	mangohud
  ];

  # Automatically add every real user to the 'users' group so they have permissions
  users.groups.users.members = allRealUsers;

  # Shared base directory rules + the dynamically generated user symlinks
  systemd.tmpfiles.rules = [
    # Create and enforce permissions on the shared base folder
    "d /var/lib/shared-steamapps 2775 root users - -"
    "z /var/lib/shared-steamapps 2775 root users - -"
  ] ++ allUserTmpfilesRules;
  
  jovian.decky-loader.enable = true;
  jovian.decky-loader.user = "${gameuser}";
  jovian.devices.steamdeck.autoUpdate = true;
  jovian.steamos.useSteamOSConfig = true;
  #jovian.devices.steamdeck.enable = true;
  jovian.devices.steamdeck.enableGyroDsuService = true;
   

  #
  # Services
  #
  # 20251117 - Disabled because of build failure and I don't need it.
  services.orca.enable = false;

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

  #
  # Users
  #
  users = {
    groups.${gameuser} = {
      name = "${gameuser}";
      gid = 10000;
    };

    # Generate hashed password: mkpasswd -m sha-512
    # hashedPassword sets the initial password. Use `passwd` to change it.
    users.${gameuser} = {
      description = "${gameuser}";
      extraGroups = ["gamemode" "networkmanager"];
      group = "${gameuser}";
      hashedPassword = "$6$nwdrlyxXsr/tOvwm$7ghcLX0QDdU5Pql.ogFnHGQI2ZR/Bfk3i4RQJVQmICMJikFof09mMiOlpsE0Lh5gIOdh5Biumtdue.kULGcxp1"; # <<<--- Generate your own initial hashed password
      home = "/home/${gameuser}";
      isNormalUser = true;
      uid = 10000;
    };
  };
}
