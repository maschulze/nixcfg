{
  description = "A template that shows all standard flake outputs";

  # Inputs to the flake
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # NixOS modules for specific hardware
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Outputs this flake produces
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
    username = "worker";
    inherit (self) outputs;
  in {
    nixosConfigurations = {
      thinkpad = let
        system = "x86_64-linux";
        hostname = "thinkpad";
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit system hostname username inputs;} // inputs;
          modules = [
            ./.
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t460p
          ];
        };
    };

    # formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    # formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
