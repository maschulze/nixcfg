{
  pkgs,
  config,
  lib,
  inputs,
  #  split-monitor-workspaces,
  ...
}:
{
  imports = [
    ./keybindings.nix
    ./monitors.nix
  ];

  options.myHomeManager.hyprland = {
    split-workspaces.enable = lib.mkEnableOption "enable split workspaces plugin";
  };

  config = {

    myHomeManager.hyprland.split-workspaces.enable = lib.mkDefault true;

    wayland.windowManager.hyprland = {
      plugins =
        [ ]
        ++ lib.optional config.myHomeManager.hyprland.split-workspaces.enable (
          inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
        );

      enable = true;

      settings = {

        monitor =
          lib.mapAttrsToList
          (
            name: m: let
              resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
              position = "${toString m.x}x${toString m.y}";
            in "${name},${
              if m.enabled
              then "${resolution},${position},1"
              else "disable"
            }"
          )
          (config.myHomeManager.monitors);

        input = {
          kb_layout = "de";
        };
      };
    };

    home.packages = with pkgs; [ ];
  };
}
