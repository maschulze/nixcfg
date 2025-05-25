{
  description = "A template that shows all standard flake outputs";

  # Inputs to the flake
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # NixOS modules for specific hardware
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    with (import ./myLib inputs); {
      nixosConfigurations = {
        # ===================== NixOS Configurations ===================== #

        thinkpad = mkSystem ./hosts/thinkpad/configuration.nix;
      };

      homeConfigurations = {
        # ================ Home configurations ================ #

        "worker@thinkpad" = mkHome "x86_64-linux" ./hosts/thinkpad/home.nix;
      };

      homeManagerModules.default = ./homeManagerModules;
      nixosModules.default = ./nixosModules;

      # formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      # formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-classic;
      # formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;
    };
}
