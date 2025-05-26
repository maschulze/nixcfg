{
  pkgs,
  system,
  inputs,
  config,
  lib,
  myLib,
  ...
}: let
  # Define `cfg` as an alias for the `myHomeManager` configuration section.
  # This is used to access options and settings under `myHomeManager`.
  cfg = config.myHomeManager;

  # Define `features` as a list of modules, each corresponding to a file in ./features.
  # For each feature, we add an `enable` option and only apply the feature's config if enabled.
  features =
    # Use a helper function from myLib to extend each module with extra options and conditional config
    myLib.extendModules
    (name: {
      # For each feature, add an option to enable/disable it under myHomeManager.<feature>.enable
      extraOptions = {
        myHomeManager.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
      };

      # Only apply the configuration for this feature if it is enabled
      configExtension = config: (lib.mkIf cfg.${name}.enable config);
    })
    # Find all modules (files) in the ./features directory
    (myLib.filesIn ./features);

  # Define `bundles` as a list of module bundles, each corresponding to a file in ./bundles.
  # Similar to features, but for bundles, and options are under myHomeManager.bundles.<bundle>
  bundles =
    # Use the same helper function to extend each bundle module
    myLib.extendModules
    (name: {
      # For each bundle, add an option to enable/disable it under myHomeManager.bundles.<bundle>.enable
      extraOptions = {
        myHomeManager.bundles.${name}.enable = lib.mkEnableOption "enable ${name} module bundle";
      };

      # Only apply the configuration for this bundle if it is enabled
      configExtension = config: (lib.mkIf cfg.bundles.${name}.enable config);
    })
    # Find all modules (files) in the ./bundles directory
    (myLib.filesIn ./bundles);
in {
  # The main output: a list of imports.
  # We start with an empty list and append all enabled features and bundles.
  imports =
    []
    ++ features
    ++ bundles;
}
