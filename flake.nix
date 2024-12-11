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
          ({ pkgs, lib, ... }: {
            boot.loader = {
              systemd-boot.enable = true;
              efi.canTouchEfiVariables = true;
            };
 	    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
            boot.initrd.kernelModules = [ ];
	    boot.kernelModules = [ "kvm-intel" ];
	    boot.extraModulePackages = [ ];
            networking = { inherit hostName; };
            services.openssh.enable = true;
            environment.systemPackages = with pkgs; [
              htop
              git
              neovim
            ];

	networking.networkmanager.enable = true;
	networking.useDHCP = lib.mkDefault true;

		  # Set your time zone.
		  time.timeZone = "Europe/Berlin";

		  # Select internationalisation properties.
		  i18n.defaultLocale = "en_US.UTF-8";

		  i18n.extraLocaleSettings = {
		    LC_ADDRESS = "de_DE.UTF-8";
		    LC_IDENTIFICATION = "de_DE.UTF-8";
		    LC_MEASUREMENT = "de_DE.UTF-8";
		    LC_MONETARY = "de_DE.UTF-8";
		    LC_NAME = "de_DE.UTF-8";
		    LC_NUMERIC = "de_DE.UTF-8";
		    LC_PAPER = "de_DE.UTF-8";
		    LC_TELEPHONE = "de_DE.UTF-8";
		    LC_TIME = "de_DE.UTF-8";
		  };

		  # Configure keymap in X11
		  services.xserver.xkb = {
		    layout = "de";
		    variant = "nodeadkeys";
		  };

		  # Configure console keymap
		  console.keyMap = "de-latin1-nodeadkeys";

		  # Define a user account. Don't forget to set a password with ‘passwd’.
		  users.users.worker = {
		    isNormalUser = true;
		    description = "Worker";
		    extraGroups = [ "networkmanager" "wheel" ];
                    initialPassword = "start123";
		    packages = with pkgs; [];
		  };

		  # Allow unfree packages
		  nixpkgs.config.allowUnfree = true;
            
              nix.settings.trusted-users = ["worker"];
            
            system.stateVersion = "24.11";
          })
        ];
      };
    };
}
