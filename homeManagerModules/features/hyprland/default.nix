{
  pkgs,
  config,
  lib,
  inputs,
  split-monitor-workspaces,
  ...
}:
{
  imports = [
    ./keybindings.nix
  ];

  options.myHomeManager.hyprland = {
    split-workspaces.enable = lib.mkEnableOption "enable split workspaces plugin";
  };

  config = {

    myHomeManager.hyprland.split-workspaces.enable = lib.mkDefault true;

    wayland.windowManager.hyprland = {
      plugins =
        []
        ++ lib.optional
        config.myHomeManager.hyprland.split-workspaces.enable
        (split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces);

      enable = true;

      settings = {

        input = {
          kb_layout = "de";
        };
      };
    };

    home.packages = with pkgs; [ ];
  };
}
