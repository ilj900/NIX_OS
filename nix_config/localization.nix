{ pkgs, ... }:

{
  # ── Locales ──────────────────────────────────────────────
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" ];
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Japanese input method (fcitx5 + Mozc) ────────────────
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc        # Japanese conversion engine
      fcitx5-gtk         # IM module for GTK / XWayland apps
    ];
    fcitx5.waylandFrontend = true;  # Wayland text-input protocol (Hyprland)
  };

  # ── CJK fonts for displaying Japanese ────────────────────
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];
}
