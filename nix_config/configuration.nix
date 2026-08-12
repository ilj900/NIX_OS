{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./localization.nix
    ./dev.nix
    ./utils.nix
  ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ExMachina";

  # Enable networking
  networking.networkmanager.enable = true;
  
  # Enable GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgs.rocmPackages.clr.icd ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Belgrade";
  
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.hyprlock.enable = true;
  
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd 'uwsm start -eD Hyprland hyprland.desktop'";
        user = "greeter";
      };
    };
  };
  
  systemd.user.services.waybar = {
    description = "Waybar status bar";
    wantedBy = [ "graphical-session.target" ];
    partOf   = [ "graphical-session.target" ];
    after    = [ "graphical-session.target" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig = {
      ExecStart  = "${pkgs.waybar}/bin/waybar";
      Restart    = "on-failure";
      RestartSec = 1;
    };
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."ilj900" = {
    isNormalUser = true;
    description = "ilj900";
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  waybar
  rofi
  dunst
  networkmanagerapplet
  hyprlauncher
  hyprshutdown
  hyprshot
  hyprpicker
  wl-clipboard
  brightnessctl
  playerctl
  pavucontrol
  adwaita-icon-theme
  ];

  environment.variables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;       # optional: for Steam Remote Play
    dedicatedServer.openFirewall = true;  # optional: for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # optional: for local game transfers
  };

  system.activationScripts.dotfileSymlinks.text = ''
    u="ilj900"
    home="/home/$u"
    for d in hypr waybar mpv swayimg kitty fcitx5; do
      [ -e "$home/.config/$d" ] && [ ! -L "$home/.config/$d" ] && rm -rf "$home/.config/$d"
      ln -sfn "$home/NIX_OS/$d" "$home/.config/$d"
      chown -h "$u:users" "$home/.config/$d"
    done
    ln -sfn "$home/NIX_OS/mimeapps.list" "$home/.config/mimeapps.list"
    chown -h "$u:users" "$home/.config/mimeapps.list"
  '';

  system.stateVersion = "26.05"; # Did you read the comment?

}
