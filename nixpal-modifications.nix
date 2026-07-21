# /etc/nixos/configuration.nix

{ ... }:

{

  # Prevent the system from shutting down when the power button is pressed
  # This allows steampowerbuttond to handle the event instead
  services.logind.settings.Login.HandlePowerKey = "ignore";

# Global Wake-on-LAN for all ethernet interfaces (e*)
  systemd.network.links."10-wake-on-lan" = {
    matchConfig.OriginalName = "e*";
    linkConfig.WakeOnLan = "magic";
  };

  # If you use NetworkManager, force WoL defaults globally across generated profiles (helps with tmpfs):

  networking.networkmanager.settings = {
      connection = {
        "802-3-ethernet.wake-on-lan" = 1;
      };
    };
  # Wake-on-Bluetooth for all integrated and USB adapters
  services.udev.extraRules = ''
    ACTION=="add|bind", SUBSYSTEM=="bluetooth", ATTR{power/wakeup}="enabled"
    ACTION=="add|bind", SUBSYSTEM=="usb", DRIVERS=="btusb", ATTR{power/wakeup}="enabled"
    ACTION=="add|bind", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="e0", ATTR{bInterfaceSubClass}=="01", ATTR{bInterfaceProtocol}=="01", ATTR{power/wakeup}="enabled"
  '';
}
