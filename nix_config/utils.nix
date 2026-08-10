{ pkgs, ... }:

{
  # ── Removable media / file management ────────────────────
  boot.supportedFilesystems = [ "ntfs" ];

  services.udisks2.enable = true; # backend that actually performs the mount
  services.gvfs.enable = true;    # lets Thunar see/trigger mounts, trash, etc.
  services.tumbler.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
    ];
  };

  # udiskie watches for udisks2 "device added" events and auto-mounts them.
  # Started as a user service so it's running as soon as you log in.
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

  # ── General-purpose applications ─────────────────────────
  environment.systemPackages = with pkgs; [
    ntfs3g
    geany
    kitty
    kdePackages.kcalc
    google-chrome
    discord
    telegram-desktop
    swayimg
    mpv
    transmission_4-gtk
  ];

  environment.shellAliases = {
    snrs = "sudo nixos-rebuild switch --flake $HOME/NIX_OS/nix_config#ExMachina --impure";
    sngc = "sudo nix-collect-garbage -d";
  };
}
