{
  # A brief description of this flake template
  description = "A template that shows all standard flake outputs";

  inputs = {
    # Import the Nixpkgs package set from the official NixOS 25.05 release on GitHub
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # Stable channel for Nixpkgs (can be used for reproducible builds)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    # Unstable channel for Nixpkgs (for latest packages)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ----------- NixOS -----------

    # Hardware support modules for NixOS
    hardware = {
      url = "github:nixos/nixos-hardware";
    };

    # Home Manager for managing user environments
    home-manager = {
      url = "github:nix-community/home-manager";
      # Make Home Manager use the stable Nixpkgs input for consistency
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  # Define the outputs function, which receives all flake inputs as arguments
  outputs =
    { self, nixpkgs, ... }@inputs: # Pattern-matching to unpack flake inputs as a set
    let
      # Bring 'outputs' from self (the current flake) into scope
      inherit (self) outputs;
      # Bring the 'lib' attribute from nixpkgs into scope for utility functions
      inherit (nixpkgs) lib;

      # Define system identifiers for ARM and x86_64 Linux
      ARM = "aarch64-linux";
      X86 = "x86_64-linux";

      # Helper function to generate attributes for all systems (used for multi-platform support)
      forAllSystems = nixpkgs.lib.genAttrs [
        ARM
        X86
      ];

      # ----------- Host Config -----------

      # Reads the names of all host configuration files for the given architecture
      readHosts = arch: lib.attrNames (builtins.readDir ./hosts/${arch});

      # Function to create a NixOS system configuration for a given host
      mkHost =
        host: isARM:
        let
          # Determine the folder ("arm" or "x86") and system string based on architecture
          folder = if isARM then "arm" else "x86";
          system = if isARM then ARM else X86;
        in
        {
          # Generate a NixOS system for the host, keyed by hostname
          "${host}" = lib.nixosSystem {
            specialArgs = {
              # Pass useful arguments to all modules
              inherit
                inputs
                outputs
                isARM
                system
                ;
              # Extend the default lib with a custom library (lib.custom)
              lib = nixpkgs.lib.extend (
                # INFO: Extend lib with lib.custom; This approach allows lib.custom to propagate into hm
                self: super: {
                  custom = import ./lib { inherit (nixpkgs) lib; };
                }
              );
            };
            modules = [
              # Add the default overlay from this flake
              { nixpkgs.overlays = [ self.overlays.default ]; }

              # Import secrets module and file
              ./modules/global/secret-spec.nix
              ./secrets.nix

              # Host-specific configuration file
              ./hosts/${folder}/${host}
            ];
          };
        };

      # Function to generate a set of host configurations for a list of hostnames
      # hosts: list of host names, isARM: boolean for architecture
      # The result is a merged attribute set of all host configs
      mkHostConfigs =
        hosts: isARM: lib.foldl (acc: set: acc // set) { } (lib.map (host: mkHost host isARM) hosts);
    in
    {
      # ----------- Overlays -----------

      # Import overlays defined in ./overlays and pass all flake inputs
      overlays = import ./overlays { inherit inputs; };

      # ----------- NixOS Configurations -----------

      # Generate nixosConfigurations for all hosts (both x86 and ARM)
      nixosConfigurations =
        (mkHostConfigs (readHosts "x86") false) // (mkHostConfigs (readHosts "arm") true);

      # ----------- Packages -----------

      # Generate packages attribute for each supported system
      packages = forAllSystems (
        system:
        let
          # Import nixpkgs for the current system and apply the default overlay
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };

          # Get the list of package directories from ./pkgs
          packageDirs = builtins.attrNames (builtins.readDir ./pkgs);

          # Filter only those packages that exist in pkgs
          validPackages = builtins.filter (name: builtins.hasAttr name pkgs) packageDirs;

          # Build an attribute set of custom packages
          customPackages = builtins.listToAttrs (
            builtins.map (name: {
              inherit name;
              value = pkgs.${name};
            }) validPackages
          );
        in
        customPackages
      );

      # ----------- Code formatters -----------

      # The following lines show how to set up different Nix code formatters.
      # Uncomment one of these lines to select your preferred formatter for x86_64-linux:

      # formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      # formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-classic;
      # formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      # formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;

      # By default, use nixfmt-tree as the code formatter for x86_64-linux
      formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
