{ config, pkgs, ... }:

{
  # 1. Keep the specific driver compiled and available in the system closure
  boot.extraModulePackages = [ 
    config.boot.kernelPackages.r8168 
  ];

  # 2. Dynamically swap drivers ONLY on your specific MSI motherboard
  boot.extraModprobeConfig = ''
    # If the system detects the Realtek chip, run a shell check first.
    # If the motherboard string matches your MSI B460M-A PRO, force r8168 to load and prevent r8169.
    install r8169 /bin/sh -c 'if [ "$(cat /sys/class/dmi/id/board_name 2>/dev/null)" = "B460M-A PRO (MS-7C88)" ]; then /run/current-system/sw/bin/modprobe r8168; else /run/current-system/sw/bin/modprobe --ignore-install r8169; fi'
  '';
}
