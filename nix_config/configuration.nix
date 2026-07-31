{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./hip.nix
  ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ExMachina";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # Select internationalisation properties.
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
  i18n.defaultLocale = "en_US.UTF-8";

  console.useXkbConfig = true; 

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:alt_shift_toggle";
  };
  
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

  boot.supportedFilesystems = [ "ntfs" ];

  services.udisks2.enable = true; # backend that actually performs the mount
  services.gvfs.enable = true;    # lets Thunar see/trigger mounts, trash, etc.

  # udiskie watches for udisks2 "device added" events and auto-mounts them.
  # It's started as a user service so it's running as soon as you log in,
  # regardless of what's in your Hyprland config.
  systemd.user.services.udiskie = {
    description = "Automatic mounting of removable media";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.udiskie}/bin/udiskie --tray";
      Restart = "on-failure";
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
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ntfs3g
  git
  gitkraken
  claude-code
  kitty
  waybar
  rofi
  dunst
  networkmanagerapplet
  thunar
  tumbler
  jetbrains.clion
  hyprlauncher
  google-chrome
  discord
  telegram-desktop
  swayimg
  mpv
  adwaita-icon-theme
  cmake
  ninja
  ];

  environment.shellAliases = {
    snrs = "sudo nixos-rebuild switch --flake $HOME/NIX_OS/nix_config#ExMachina --impure";
  };

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
    for d in hypr waybar mpv swayimg kitty; do
      ln -sfn "$home/NIX_OS/$d" "$home/.config/$d"
      chown -h "$u:users" "$home/.config/$d"
    done
    ln -sfn "$home/NIX_OS/mimeapps.list" "$home/.config//mimeapps.list"
    chown -h "$u:users" "$home/.config/mimeapps.list"
  '';

  system.stateVersion = "26.05"; # Did you read the comment?

}
