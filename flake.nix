{
  # Short description of this flake project
  description = "A template that shows all standard flake outputs";

  # ===================== Flake Inputs ===================== #
  # Define dependencies for this flake. These are other flakes or repositories
  # that provide packages, modules, or utilities needed for your configuration.
  inputs = {
    # Official NixOS package set, pinned to the 25.05 release
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Hardware-specific NixOS modules (e.g., for laptops, desktops, servers)
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    # Home Manager for user-level configuration management
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      # Ensure home-manager uses the same nixpkgs as the rest of the flake
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko for declarative disk partitioning and formatting
    disko = {
      url = "github:nix-community/disko";
      # Use the same nixpkgs for consistency
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ===================== Flake Outputs ===================== #
  # The outputs function receives all resolved inputs and returns
  # an attribute set describing what this flake provides.
  outputs =
    inputs:
    # Import custom library functions from ./myLib, passing all inputs
    with (import ./myLib inputs); {
      # ----------- NixOS system configurations -----------
      nixosConfigurations = {
        # Define a NixOS configuration for the "thinkpad" host
        # mkSystem is a helper from ./myLib that sets up the system
        thinkpad = mkSystem ./hosts/thinkpad/configuration.nix;
      };

      # ----------- Home Manager user configurations -----------
      homeConfigurations = {
        # Define a Home Manager configuration for user "worker" on "thinkpad"
        # mkHome is a helper from ./myLib for user-level setup
        "worker@thinkpad" = mkHome "x86_64-linux" ./hosts/thinkpad/home.nix;
      };

      # ----------- Module exports for reuse -----------
      # Export custom Home Manager modules (for use in other projects)
      homeManagerModules.default = ./homeManagerModules;
      # Export custom NixOS modules
      nixosModules.default = ./nixosModules;

      # ----------- Code formatters -----------
      # Uncomment one of the following lines to choose a Nix code formatter
      # formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      # formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-classic;
      # formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      # formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;
      # Use nixfmt-tree as the default formatter for x86_64-linux
      formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
