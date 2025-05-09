{
  config,
  pkgs,
  inputs,
  ...
}: {
  users.users.worker = {
    initialPassword = "test";
    isNormalUser = true;
    description = "worker";
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "flatpak"
      "audio"
      "video"
      "plugdev"
      "input"
      "kvm"
      "qemu-libvirtd"
    ];
    packages = [inputs.home-manager.packages.${pkgs.system}.default];
  };
  home-manager.users.worker =
    import ../../../home/worker/${config.networking.hostName}.nix;
}
