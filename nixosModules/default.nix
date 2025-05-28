{
  pkgs,
  config,
  lib,
  inputs,
  outputs,
  myLib,
  ...
}:
let
  # Shortcut for accessing options under the myNixOS namespace
  cfg = config.myNixOS;

  # Collect all feature modules from ./features
  # Each feature gets an enable option and is only imported if enabled
  features = myLib.extendModules (name: {
    # Add an enable option for each feature (myNixOS.<feature>.enable)
    extraOptions = {
      myNixOS.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
    };
    # Only apply the module's config if the feature is enabled
    configExtension = config: (lib.mkIf cfg.${name}.enable config);
  }) 
  # Find all modules (files) in the ./features directory
  (myLib.filesIn ./features);

  # Collect all bundle modules from ./bundles
  # Each bundle is a group of features with its own enable switch
  bundles = myLib.extendModules (name: {
    # Add an enable option for each bundle (myNixOS.bundles.<bundle>.enable)
    extraOptions = {
      myNixOS.bundles.${name}.enable = lib.mkEnableOption "enable ${name} module bundle";
    };
    # Only apply the bundle's config if enabled
    configExtension = config: (lib.mkIf cfg.bundles.${name}.enable config);
  }) 
  # Find all modules (files) in the ./bundles directory
  (myLib.filesIn ./bundles);

  # Collect all service modules from ./services
  # Each service can be toggled individually
  services = myLib.extendModules (name: {
    # Add an enable option for each service (myNixOS.services.<service>.enable)
    extraOptions = {
      myNixOS.services.${name}.enable = lib.mkEnableOption "enable ${name} service";
    };
    # Only apply the service's config if enabled
    configExtension = config: (lib.mkIf cfg.services.${name}.enable config);
  }) 
  # Find all modules (files) in the ./services directory
  (myLib.filesIn ./services);
in
{
  # Compose the imports list from home-manager, features, bundles, and services
  imports =
    [
      # Import the home-manager NixOS module from flake inputs
      inputs.home-manager.nixosModules.home-manager
    ]
    ++ features
    ++ bundles
    ++ services;

  # Define options for the custom myNixOS namespace
  options.myNixOS = {
    # Example: add an enable option for Hyprland
    hyprland.enable = lib.mkEnableOption "enable hyprland";
  };

  # Set global Nix/Nixpkgs configuration defaults
  config = {
    # Enable Nix flakes and the new nix-command interface
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Optionally enable nix-ld for running binaries with missing libraries
    # programs.nix-ld.enable = true;
    # Allow unfree packages in nixpkgs (e.g., proprietary software)
    nixpkgs.config.allowUnfree = true;
  };
}
