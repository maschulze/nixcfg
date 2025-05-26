{
  pkgs,
  config,
  lib,
  inputs,
  outputs,
  myLib,
  ...
}: let
  # Shortcut to access the `myNixOS` configuration section
  cfg = config.myNixOS;

  # Define `features` as a list of modules from ./features.
  # Each feature module is extended to have an `enable` option and only applies its config if enabled.
  features =
    myLib.extendModules
    (name: {
      # Add an enable option for each feature under myNixOS.<feature>.enable
      extraOptions = {
        myNixOS.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
      };

      # Only include the feature's configuration if it is enabled
      configExtension = config: (lib.mkIf cfg.${name}.enable config);
    })
    # Collect all modules (files) from the ./features directory
    (myLib.filesIn ./features);

  # Define `bundles` as a list of module bundles from ./bundles.
  # Each bundle is extended to have an `enable` option and only applies its config if enabled.
  bundles =
    myLib.extendModules
    (name: {
      # Add an enable option for each bundle under myNixOS.bundles.<bundle>.enable
      extraOptions = {
        myNixOS.bundles.${name}.enable = lib.mkEnableOption "enable ${name} module bundle";
      };

      # Only include the bundle's configuration if it is enabled
      configExtension = config: (lib.mkIf cfg.bundles.${name}.enable config);
    })
    # Collect all modules (files) from the ./bundles directory
    (myLib.filesIn ./bundles);

  # Define `services` as a list of service modules from ./services.
  # Each service is extended to have an `enable` option and only applies its config if enabled.
  services =
    myLib.extendModules
    (name: {
      # Add an enable option for each service under myNixOS.services.<service>.enable
      extraOptions = {
        myNixOS.services.${name}.enable = lib.mkEnableOption "enable ${name} service";
      };

      # Only include the service's configuration if it is enabled
      configExtension = config: (lib.mkIf cfg.services.${name}.enable config);
    })
    # Collect all modules (files) from the ./services directory
    (myLib.filesIn ./services);
in {
  # Combine all enabled modules into the imports list.
  # This includes the home-manager module, all enabled features, bundles, and services.
  imports =
    [
      # Import the home-manager NixOS module from flake inputs
      inputs.home-manager.nixosModules.home-manager
    ]
    ++ features
    ++ bundles
    ++ services;

  # Example of an option definition (commented out for now)
  # options.myNixOS = {
  #   hyprland.enable = lib.mkEnableOption "enable hyprland";
  # };

  # Set some default Nix/Nixpkgs configuration
  config = {
    # Enable experimental Nix features: nix-command and flakes
    nix.settings.experimental-features = ["nix-command" "flakes"];
    # Enable nix-ld (commented out, uncomment to use)
    # programs.nix-ld.enable = true;
    # Allow unfree packages in nixpkgs
    nixpkgs.config.allowUnfree = true;
  };
}
