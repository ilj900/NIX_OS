{ config, pkgs, ... }:

let
  vulkanShell = import ./vulkan.nix { inherit pkgs; };
  hipShell    = import ./hip.nix    { inherit pkgs; };
in

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./localization.nix
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

  boot.supportedFilesystems = [ "ntfs" ];

  services.udisks2.enable = true; # backend that actually performs the mount
  services.gvfs.enable = true;    # lets Thunar see/trigger mounts, trash, etc.
  
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
    ];
  };
  services.tumbler.enable = true;

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
  ntfs3g
  git
  gitkraken
  claude-code
  geany
  kitty
  waybar
  rofi
  dunst
  networkmanagerapplet
  hyprlauncher
  hyprshutdown
  brightnessctl
  kdePackages.kcalc
  playerctl
  pavucontrol
  google-chrome
  discord
  telegram-desktop
  swayimg
  mpv
  adwaita-icon-theme
  jetbrains.clion
  clang
  clang-tools
  lldb
  llvmPackages.llvm
  cmake
  ninja
  transmission_4-gtk
  
  (python313.withPackages (ps: with ps; [
    numpy
    matplotlib
  ]))
  
  (writeShellScriptBin "clion-vk" ''
      setsid nix develop "$HOME/NIX_OS/nix_config#vulkan" -c clion "$@" \
        >/dev/null 2>&1 < /dev/null &
    '')
    
  (writeShellScriptBin "clion-hip" ''
      setsid nix develop "$HOME/NIX_OS/nix_config#hip" -c clion "$@" \
        >/dev/null 2>&1 < /dev/null &
    '')
  ];

  environment.shellAliases = {
    snrs = "sudo nixos-rebuild switch --flake $HOME/NIX_OS/nix_config#ExMachina --impure";
    sngc = "sudo nix-collect-garbage -d";
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
    for d in hypr waybar mpv swayimg kitty fcitx5; do
      ln -sfn "$home/NIX_OS/$d" "$home/.config/$d"
      chown -h "$u:users" "$home/.config/$d"
    done
    ln -sfn "$home/NIX_OS/mimeapps.list" "$home/.config/mimeapps.list"
    chown -h "$u:users" "$home/.config/mimeapps.list"
  '';
  
  system.activationScripts.devShellRoots.text = ''
    ln -sfn ${vulkanShell.inputDerivation} /nix/var/nix/gcroots/vulkan-dev
    ln -sfn ${hipShell.inputDerivation}    /nix/var/nix/gcroots/hip-dev
  '';

  system.stateVersion = "26.05"; # Did you read the comment?

}
