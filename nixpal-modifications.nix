# /etc/nixos/configuration.nix

{ config, pkgs, ... }:

{

  # Prevent the system from shutting down when the power button is pressed
  # This allows steampowerbuttond to handle the event instead
  services.logind.powerKey = "ignore";

  # Hardware Event Rules (Udev)
  services.udev.extraRules = ''
    # 1. Disable wakeup for all USB devices to prevent the ROG Arion from waking the PC
    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/wakeup}=="enabled", ATTR{power/wakeup}="disabled"

    # 2. Automatically enable Wake-on-LAN (Magic Packet) for all Ethernet interfaces
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="e*", RUN+="${pkgs.ethtool}/bin/ethtool -s %k wol g"
  '';

  # Ensure ethtool is installed so the udev rule can execute it
  environment.systemPackages = with pkgs; [
    ethtool
  ];
/*
# Lower swappiness so system memory is heavily favored over any swap space
  boot.kernel.sysctl = {
    "vm.swappiness" = 10; 
  };

  # Configure Zram to be your emergency overflow buffer
  zramSwap = {
    enable = true;
    # Set the size explicitly (e.g., 20% or 40% of your real memory capacity)
    # default is usually 50% or 100% of RAM size, which eats into real RAM headroom.
    memoryPercent = 50; 
    priority = 5; # Higher than SSD swap (0), but swappiness=10 keeps it quiet until needed
  };

  swapDevices = [ { device = "/var/lib/swapfile-dir/swapfile"; priority = 0; } ];

  system.activationScripts.setupHibernationSwap = {
      supportsDryActivation = false; 
      
      text = ''
        mkdir -p /var/lib/swapfile-dir
        chmod 700 /var/lib/swapfile-dir
  
        RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        RAM_MB=$((RAM_KB / 1024))
        
        if [ -f /sys/class/drm/card0/device/mem_info_vram_total ]; then
          VRAM_BYTES=$(cat /sys/class/drm/card0/device/mem_info_vram_total)
          VRAM_MB=$((VRAM_BYTES / 1024 / 1024))
        else
          VRAM_MB=4096
        fi
        
        TOTAL_MB=$((RAM_MB + VRAM_MB + 2048))
        
        FREE_SPACE_MB=$(df -m /var | tail -1 | awk '{print $4}')
        REQUIRED_SPACE=$((TOTAL_MB + 15360))
        
        if [ "$FREE_SPACE_MB" -lt "$REQUIRED_SPACE" ]; then
          echo "WARNING: Insufficient disk space to safely create a hibernation swapfile."
          if [ -f /var/lib/swapfile-dir/swapfile ]; then
            ${pkgs.util-linux}/bin/swapoff /var/lib/swapfile-dir/swapfile 2>/dev/null || true
            rm -f /var/lib/swapfile-dir/swapfile
          fi
        else
          CURRENT_SIZE=0
          if [ -f /var/lib/swapfile-dir/swapfile ]; then
            CURRENT_SIZE=$(du -m /var/lib/swapfile-dir/swapfile | awk '{print $1}')
          fi
  
          if [ "$CURRENT_SIZE" -ne "$TOTAL_MB" ]; then
            echo "Instantly allocating a $TOTAL_MB MB safe hibernation swap file..."
            ${pkgs.util-linux}/bin/swapoff /var/lib/swapfile-dir/swapfile 2>/dev/null || true
            
            # FIXED: Using fallocate instead of dd for instant allocation over USB
            ${pkgs.util-linux}/bin/fallocate -l "$TOTAL_MB"M /var/lib/swapfile-dir/swapfile
            
            chmod 600 /var/lib/swapfile-dir/swapfile
            ${pkgs.util-linux}/bin/mkswap /var/lib/swapfile-dir/swapfile >/dev/null
          fi
        fi
      '';
    };

# 1. Force the systemd sleep target to always drop into suspend-then-hibernate
  # This acts as a catch-all safety net for Gamescope sessions
  systemd.targets.suspend.unitConfig.DefaultDependencies = "no";
  systemd.targets.suspend.wants = [ "suspend-then-hibernate.target" ];

  services.logind = {
      lidSwitch = "suspend-then-hibernate";
      # powerKey = "suspend-then-hibernate"; handled by gamescope-session
      suspendKey = "suspend-then-hibernate";
    };
  
    # 3. Ensure the timeout config is strictly set for all systemd sleep modes
#  systemd.sleep.settings.Sleep = ''
#    HibernateDelaySec=43200
#  '';
*/
}
