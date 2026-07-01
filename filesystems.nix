{ config, pkgs, lib, inputs, ... }:

{
  # =========================================================================
  # 1. EPHEMERAL RAM ROOT & PERSISTENT STORAGE MAPS (LABEL-BASED)
  # =========================================================================
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=4G" "mode=755" ];
  };

  fileSystems."/persistent" = {
    device = "/dev/disk/by-label/nixos-storage";
    fsType = "ext4";
    neededForBoot = true;
    options = [ "noatime" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/nixos-boot";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # Bind mounts to redirect heavy write folders straight to the physical SSD
  fileSystems."/nix" = { device = "/persistent/nix"; fsType = "none"; options = [ "bind" ]; };
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
