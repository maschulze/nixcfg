{
  inputs,
  outputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ outputs.homeManagerModules.default ];

  #   myHomeManager.impermanence.data.directories = [
  #     "nixconf"

  #     "Videos"
  #     "Documents"
  #     "Projects"
  #   ];

  #   myHomeManager.impermanence.cache.directories = [
  #     ".local/share/PrismLauncher"
  #     ".config/openvr"
  #     ".config/tidal-hifi"

  #     "Android"
  #     ".local/share/godot"
  #     ".config/alvr"
  #   ];

  #   programs.foot.enable = true;
  #   programs.wezterm.enable = true;

  myHomeManager = {
    #     bundles.general.enable = true;
    #     bundles.desktop-full.enable = true;

    #     bundles.gaming.enable = true;

    git.enable = true;
    kitty.enable = true;
    vscode.enable = true;
    rofi.enable = true;

    firefox.enable = true;

    hyprland.enable = true;

    #     pipewire.enable = true;
    #     tenacity.enable = true;

    hyprland.split-workspaces.enable = false;

    monitors = {
      "eDP-1" = {
        width = 2560;
        height = 1440;
        refreshRate = 60.;
      };
    };

    #     workspaces = {
    #       "2" = {
    #         monitorId = 0;
    #         autostart = with pkgs; [
    #          (lib.getExe firefox)
    #         ];
    #       };
    #       "10" = {
    #         monitorId = 1;
    #         autostart =  with pkgs; [
    #           (lib.getExe telegram-desktop)
    #           # (lib.getExe vesktop)
    #         ];
    #       };
    #     };
  };

  home = {
    username = "worker";
    homeDirectory = lib.mkDefault "/home/worker";
    stateVersion = "25.05";

    # packages = with pkgs; [
    #   obs-studio
    #   wf-recorder
    #   prismlauncher
    #   tidal-hifi

    #   opencomposite
    # ];
  };

  # xdg.configFile."openxr/1/active_runtime.json".text =
  # ''
  #   {
  #       "file_format_version" : "1.0.0",
  #       "runtime" :
  #       {
  #           "VALVE_runtime_is_steamvr" : true,
  #           "library_path" : "/home/yurii/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrclient.so",
  #           "name" : "SteamVR"
  #       }
  #   }
  # '';

  # xdg.configFile."openvr/openvrpaths.vrpath".text = ''
  #   {
  #     "config" :
  #     [
  #       "${config.xdg.dataHome}/Steam/config"
  #     ],
  #     "external_drivers": [
  #       "${pkgs.alvr}/lib64/alvr"
  #     ],
  #     "jsonid": "vrpathreg",
  #     "log" :
  #     [
  #       "${config.xdg.dataHome}/Steam/logs"
  #     ],
  #     "runtime" :
  #     [
  #       "${pkgs.opencomposite}/lib/opencomposite"
  #     ],
  #     "version" : 1
  #   }
  # '';

  #   xdg.configFile."openxr/1/active_runtime.json".source = "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";

  #   xdg.configFile."openvr/openvrpaths.vrpath".text = ''
  #     {
  #       "config" :
  #       [
  #         "${config.xdg.dataHome}/Steam/config"
  #       ],
  #       "external_drivers" : null,
  #       "jsonid" : "vrpathreg",
  #       "log" :
  #       [
  #         "${config.xdg.dataHome}/Steam/logs"
  #       ],
  #       "runtime" :
  #       [
  #         "${pkgs.opencomposite}/lib/opencomposite"
  #       ],
  #       "version" : 1
  #     }
  #   '';
}
