{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  username = "worker";
  user = config.secretsSpec.users.${username};
in
{
  imports = lib.flatten [
    ## Rune Only ##
    # inputs.chaotic.nixosModules.default
    # ./config

    ## Hardware ##
    ./hardware.nix
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    (map lib.custom.relativeToRoot [
      ## Required Configs ##
      "hosts/global/core"

      ## Optional Configs ##
      #   "hosts/global/common/audio.nix" # pipewire and cli controls
      #   "hosts/global/common/adb.nix" # android tools
      #   "hosts/global/common/bluetooth.nix"
      #   "hosts/global/common/ddcutil.nix" # ddcutil for monitor controls
      #   "hosts/global/common/gaming.nix" # steam, gamescope, gamemode, and related hardware
      #   "hosts/global/common/gnome.nix"
      #   "hosts/global/common/libvirt.nix" # vm tools
      #   "hosts/global/common/nvtop.nix" # GPU monitor (not available in home-manager)
      #   "hosts/global/common/plymouth.nix" # fancy boot screen
      #   "hosts/global/common/solaar.nix" # Logitech Unifying Receiver support
      #   "hosts/global/common/vial.nix" # KB setup
    ])
  ];

  ## Host Specifications ##
  hostSpec = {
    hostName = "thinkpad";
    username = username;
    hashedPassword = user.hashedPassword;
    email = user.email;
    handle = user.handle;
    userFullName = user.fullName;
  };

  networking = {
    enableIPv6 = false;
  };

  ## System-wide packages ##
  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    # asdf-vm
  ];

  environment.sessionVariables = {
    # AMD_VULKAN_ICD = "RADV";
    # RADV_PERFTEST = "aco";
    # PROTON_USE_D9VK = 1;
  };

  system.stateVersion = "25.05";
}
