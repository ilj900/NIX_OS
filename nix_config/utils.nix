{ pkgs, unstablePkgs, ... }:

{
  # ── Removable media / file management ────────────────────
  boot.supportedFilesystems = [ "ntfs" ];

  services.udisks2.enable = true; # backend that actually performs the mount
  services.gvfs.enable = true;    # lets Thunar see/trigger mounts, trash, etc.
  services.tumbler.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
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
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("wheel") &&
        (
          action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
          action.id == "org.freedesktop.udisks2.filesystem-mount" ||
          action.id == "org.freedesktop.udisks2.filesystem-mount-other-seat" ||
          action.id == "org.freedesktop.udisks2.encrypted-unlock-system" ||
          action.id == "org.freedesktop.udisks2.eject-media" ||
          action.id == "org.freedesktop.udisks2.power-off-drive"
        )
      ) {
        return polkit.Result.YES;
      }
    });
  '';

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
    drawing
    mpv
    transmission_4-gtk
    anydesk
    pkgsRocm.blender
  ];
  
  nixpkgs.overlays = [
    (final: prev: {
      telegram-desktop = unstablePkgs.telegram-desktop;
      discord = unstablePkgs.discord;
    })
  ];

  environment.shellAliases = {
    snrs = "sudo nixos-rebuild switch --flake $HOME/NIX_OS/nix_config#ExMachina --impure";
    sngc = "sudo nix-collect-garbage -d";
  };
}
