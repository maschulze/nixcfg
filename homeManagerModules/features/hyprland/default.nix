{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{

  config = {

    wayland.windowManager.hyprland = {
      plugins = [ ];

      enable = true;

      settings = {
        "$mainMod" = "SUPER";

        bind = [
          "$mainMod, M, exit,"
        ];

        input = {
          kb_layout = "de";
        };
      };
    };

    home.packages = with pkgs; [ ];
  };
}
