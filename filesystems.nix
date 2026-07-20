{ config, pkgs, lib, inputs, ... }:

{
  # =========================================================================
  # 1. EPHEMERAL RAM ROOT & PERSISTENT STORAGE MAPS (LABEL-BASED)
  # =========================================================================

# Ephemeral root in RAM. Cleans itself on every single boot!
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=4G" "mode=755" ];
  };

  # Dedicated Nix store subvolume (Separate so we can snapshot /persistent cleanly)
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/1668713f-a2dd-4f83-8d98-5ab29edfc107";
    fsType = "btrfs";
    options = [ "subvol=@nixos_nix" "compress=zstd" "noatime" ];
  };

  # The persistent subvolume containing actual state, configs, and user data
  fileSystems."/persistent" = {
    device = "/dev/disk/by-uuid/1668713f-a2dd-4f83-8d98-5ab29edfc107";
    fsType = "btrfs";
    neededForBoot = true; # Critical: NixOS needs this mounted before loading the rest of the OS
    options = [ "subvol=@nixos_persistent" "compress=zstd" "noatime" ];
  };

  # Your shared, existing EFI boot partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/16C5-9FBB";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # Bind mounts to redirect heavy or stateful folders straight to Btrfs persistence
  fileSystems."/home" = { device = "/persistent/home"; fsType = "none"; options = [ "bind" ]; };
  fileSystems."/var/lib" = { device = "/persistent/var/lib"; fsType = "none"; options = [ "bind" ]; };
  fileSystems."/var/log" = { device = "/persistent/var/log"; fsType = "none"; options = [ "bind" ]; };

  systemd.tmpfiles.rules = [
	# --- System State Folders on SSD ---
    "d /persistent/etc/NetworkManager/system-connections 0700 root root - -"
    "d /persistent/etc/bluetooth                         0700 root root - -"

    # --- Dynamic System Symlinks (Moved from environment.etc) ---
    # L+ ensures that if /etc/bluetooth already exists, it maps over it cleanly at boot
    "L+ /etc/NetworkManager/system-connections - - - - /persistent/etc/NetworkManager/system-connections"
    "L+ /etc/bluetooth                         - - - - /persistent/etc/bluetooth"
    ];

  # =========================================================================
  # 2. HIGH-PERFORMANCE ZRAM SWAP
  # =========================================================================
  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
    priority = 5;
  };
}
