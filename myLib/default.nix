inputs:
let
  # Import the main library file, passing all flake inputs
  myLib = (import ./default.nix) { inherit inputs; };

  # Reference to the outputs of the current flake (usually set in flake.nix)
  outputs = inputs.self.outputs;

  # Shortcut for the main nixpkgs input
  nixpkgs = inputs.nixpkgs;
in
rec {
  # =========================== Helpers ============================ #

  # Import overlays from the overlays directory, passing inputs and outputs
  myOverlays = import ./../overlays { inherit inputs outputs; };

  # Helper function to get a pkgs set for a given system, with overlays applied
  pkgsFor =
    system:
    import nixpkgs {
      inherit system;
      overlays = myOverlays;
    };

  # Module to inject overlays into nixpkgs
  overlayModule = {
    nixpkgs.overlays = myOverlays;
  };

  # ========================== Buildables ========================== #

  # Helper to create a NixOS system configuration
  mkSystem =
    config:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs myLib;
      };
      modules = [
        config # User/system config file
        outputs.nixosModules.default # Default NixOS modules from flake
        overlayModule # Inject overlays

        # Example: set nix.package to pkgs.lix (could be customized)
        (
          { pkgs, ... }:
          {
            nix.package = pkgs.lix;
          }
        )
      ];
    };

  # Helper to create a Home Manager configuration for a user
  mkHome =
    sys: config:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys; # Use overlays for this system
      extraSpecialArgs = {
        inherit inputs myLib outputs;
      };
      modules = [
        # TODO: move this to a better place
        inputs.stylix.homeManagerModules.stylix
        {
          stylix.image = ./../nixosModules/features/stylix/gruvbox-mountain-village.png;
          nixpkgs.config.allowUnfree = true;
        }
        config # User's home.nix config
        outputs.homeManagerModules.default # Default Home Manager modules from flake
      ];
    };

  # =========================== Helpers ============================ #

  # List all files in a directory, returning their full paths
  filesIn = dir: (map (fname: dir + "/${fname}") (builtins.attrNames (builtins.readDir dir)));

  # List all subdirectories in a directory
  dirsIn = dir: nixpkgs.lib.filterAttrs (name: value: value == "directory") (builtins.readDir dir);

  # Get the base name of a file path, without its extension
  fileNameOf = path: (builtins.head (builtins.split "\\." (baseNameOf path)));

  # ========================== Extenders =========================== #

  # Evaluates a nixos/home-manager module and extends its options/config.
  # Not currently used, but kept for reference.
  extendModule =
    { path, ... }@args:
    { pkgs, ... }@margs:
    let
      # Import or call the module, depending on its type
      eval = if (builtins.isString path) || (builtins.isPath path) then import path margs else path margs;
      # Remove 'imports' and 'options' attributes for extension
      evalNoImports = builtins.removeAttrs eval [
        "imports"
        "options"
      ];

      # If extraOptions or extraConfig are provided, add them as an extra module
      extra =
        if (builtins.hasAttr "extraOptions" args) || (builtins.hasAttr "extraConfig" args) then
          [
            (
              { ... }:
              {
                options = args.extraOptions or { };
                config = args.extraConfig or { };
              }
            )
          ]
        else
          [ ];
    in
    {
      # Compose imports from the module and any extra modules
      imports = (eval.imports or [ ]) ++ extra;

      # Extend or override options if an optionsExtension is provided
      options =
        if builtins.hasAttr "optionsExtension" args then
          (args.optionsExtension (eval.options or { }))
        else
          (eval.options or { });

      # Extend or override config if a configExtension is provided
      config =
        if builtins.hasAttr "configExtension" args then
          (args.configExtension (eval.config or evalNoImports))
        else
          (eval.config or evalNoImports);
    };

  # Applies extendModule to a list of modules.
  # Not currently used, but kept for reference.
  extendModules =
    extension: modules:
    map (
      f:
      let
        name = fileNameOf f;
      in
      (extendModule ((extension name) // { path = f; }))
    ) modules;

  # ============================ Shell ============================= #
  # Helper to generate attributes for all common systems.
  # Not currently used, but kept for reference.
  # forAllSystems = pkgs:
  #   inputs.nixpkgs.lib.genAttrs [
  #     "x86_64-linux"
  #     "aarch64-linux"
  #     "x86_64-darwin"
  #     "aarch64-darwin"
  #   ]
  #   (system: pkgs inputs.nixpkgs.legacyPackages.${system});
}
