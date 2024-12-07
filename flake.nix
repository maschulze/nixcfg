{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, disko, ... }:
    let
      # TODO: Adjust these values to your needs
      system = "x86_64-linux";
      hostName = "thinkpad";
    in
    {
      nixosConfigurations.${hostName} = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./disk-config.nix
          disko.nixosModules.disko
          ({ pkgs, ... }: {
            boot.loader = {
              systemd-boot.enable = true;
              efi.canTouchEfiVariables = true;
            };
            networking = { inherit hostName; };
            services.openssh.enable = true;
            environment.systemPackages = with pkgs; [
              htop
              git
              neovim
            ];

            
              users.extraUsers.worker = {
                isNormalUser = true;
                uid = 1000;
                extraGroups = [ "users" "wheel" ];
                initialPassword = "start123";
              };
              nix.settings.trusted-users = ["worker"];
            }
            system.stateVersion = "24.11";
          })
        ];
      };
    };
}
