{ config, pkgs, ... }:

let
  activeUser = config.jovian.steam.user;

  killScript = pkgs.writeScriptBin "kill-gamescope-session" ''
      #!/bin/sh
      # 1. Give the display system 1 second to settle and process the session switch
      sleep 1
  
      # 2. Kill the gamescope compositor processes aggressively if they are hanging around
      killall -9 gamescope steam 2>/dev/null || true
  
      # 3. Force loginctl to kill ALL active graphical sessions for your specific user.
      # This bypasses the unreliability of $XDG_SESSION_ID inside nested sessions.
      ${pkgs.systemd}/bin/loginctl terminate-user "${activeUser}"
    '';
  # Build the package explicitly
  killSessionPackage = (pkgs.runCommand "kill-session-desktop" {} ''
    mkdir -p $out/share/wayland-sessions
    mkdir -p $out/share/xsessions

    cat <<EOF > $out/share/wayland-sessions/kill-session.desktop
    [Desktop Entry]
    Name=Kill Session
    Comment=Custom exit vector to drop back to SDDM smoothly
    Exec=${killScript}/bin/kill-gamescope-session
    Type=Application
    EOF

    cp $out/share/wayland-sessions/kill-session.desktop $out/share/xsessions/kill-session.desktop
  '').overrideAttrs (old: {
    passthru.providedSessions = [ "kill-session" ];
  });

in
{
  # FORCE STAGING: Put both the script and the desktop layout directly into the system path
  environment.systemPackages = [ 
    killScript 
    killSessionPackage 
  ];

  # Tells NixOS to make sure "share" outputs from systemPackages are physically linked
  environment.extraOutputsToInstall = [ "share" ];

  services.displayManager = {
    # Keep this here to satisfy Jovian's internal list lookup
    sessionPackages = [ killSessionPackage ];
  };

  jovian.steam = {
  	autoStart = true;
    desktopSession = "kill-session"; 
  };
}
