{
  pkgs,
  system,
  inputs,
  config,
  lib,
  myLib,
  ...
}:
let
  # Shortcut for accessing options under the myHomeManager namespace
  cfg = config.myHomeManager;

  # Collect all feature modules from ./features
  # Each feature gets an enable option and is only imported if enabled
  features =
    myLib.extendModules
      (name: {
        # Add an enable option for each feature (myHomeManager.<feature>.enable)
        extraOptions = {
          myHomeManager.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
        };

        # Only apply the module's config if the feature is enabled
        configExtension = config: (lib.mkIf cfg.${name}.enable config);
      })
      # Find all modules (files) in the ./features directory
      (myLib.filesIn ./features);

  # Collect all feature modules from ./bundles
  # Each feature gets an enable option and is only imported if enabled
  bundles =
    myLib.extendModules
      (name: {
        # Add an enable option for each feature (myHomeManager.bundles.<bundles>.enable)
        extraOptions = {
          myHomeManager.bundles.${name}.enable = lib.mkEnableOption "enable ${name} module bundle";
        };

        # Only apply the module's config if the feature is enabled
        configExtension = config: (lib.mkIf cfg.bundles.${name}.enable config);
      })
      # Find all modules (files) in the ./bundles directory
      (myLib.filesIn ./bundles);
in
{
  # Compose the imports list from features and bundles
  # We start with an empty list and append all enabled features and bundles
  imports = [ ] ++ features ++ bundles;
}
