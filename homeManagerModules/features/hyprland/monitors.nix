{
  lib,
  config,
  pkgs,
  ...
}:
let
  # Import mkOption and types from the lib attribute set for defining options
  inherit (lib) mkOption types;
in
{
  # Define options under the custom namespace 'myHomeManager'
  options.myHomeManager.monitors = mkOption {
    # This option is an attribute set (dictionary) where each key is a monitor name or ID
    type = types.attrsOf (
      types.submodule {
        options = {
          # Whether this monitor is the primary display
          primary = mkOption {
            type = types.bool;
            default = false;
          };
          # Monitor width in pixels (example value provided)
          width = mkOption {
            type = types.int;
            example = 1920;
          };
          # Monitor height in pixels (example value provided)
          height = mkOption {
            type = types.int;
            example = 1080;
          };
          # Refresh rate in Hz, defaulting to 60
          refreshRate = mkOption {
            type = types.float;
            default = 60;
          };
          # X position of the monitor in the virtual display space (default 0)
          x = mkOption {
            type = types.int;
            default = 0;
          };
          # Y position of the monitor in the virtual display space (default 0)
          y = mkOption {
            type = types.int;
            default = 0;
          };
          # Whether this monitor is enabled (default true)
          enabled = mkOption {
            type = types.bool;
            default = true;
          };
          # Optionally, a workspace can be assigned to this monitor
          # Uncomment if you want to use workspaces directly on monitors
          # workspace = mkOption {
          #   type = types.nullOr types.str;
          #   default = null;
          # };
        };
      }
    );
    # By default, no monitors are defined
    default = { };
  };

  # Define workspace options under the custom namespace 'myHomeManager'
  options.myHomeManager.workspaces = mkOption {
    # Attribute set where each key is a workspace name or ID
    type = types.attrsOf (
      types.submodule {
        options = {
          # The monitor ID this workspace is attached to
          monitorId = mkOption {
            type = types.int;
            default = false; # Note: 'false' as an int is probably a mistake, consider using 0 or null
          };
          # List of commands to autostart in this workspace
          autostart = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
        };
      }
    );
    # By default, no workspaces are defined
    default = { };
  };
}
