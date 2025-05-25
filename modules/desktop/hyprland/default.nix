{
  config,
  pkgs,
  lib,
  home-manager,
  username,
  ...
}: {
  options.my.hyprland.enable = lib.mkEnableOption "Enable hyprland";

  config = lib.mkIf config.my.hyprland.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };

    home-manager.users.${username} = {
      config,
      pkgs,
      ...
    }: {
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {};
      };
    };
  };
}
