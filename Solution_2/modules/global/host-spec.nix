# Specifications For Differentiating Hosts
{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Define custom options under the `hostSpec` namespace.
  options.hostSpec = {
    # Hostname for the machine.
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "The hostname of the host";
    };

    # Primary username for this host.
    username = lib.mkOption {
      type = lib.types.str;
      description = "The username for the host's user";
    };

    # Hashed password for the user (for security).
    hashedPassword = lib.mkOption {
      type = lib.types.str;
      description = "Hashed password for the host's user";
    };

    # Email address associated with the user.
    email = lib.mkOption {
      type = lib.types.str;
      description = "The email of the user";
    };

    # User handle, e.g., GitHub username.
    handle = lib.mkOption {
      type = lib.types.str;
      description = "The handle of the user (eg: github user)";
    };

    # Full name of the user.
    userFullName = lib.mkOption {
      type = lib.types.str;
      description = "The full name of the user";
    };

    # Home directory for the user.
    home = lib.mkOption {
      type = lib.types.str;
      description = "The home directory of the user";
      # Default value depends on OS: /home/username for Linux, /Users/username for macOS.
      default =
        let
          user = config.hostSpec.username;
        in
        if pkgs.stdenv.isLinux then "/home/${user}" else "/Users/${user}";
    };

    # Is this host running on ARM architecture (AArch64)?
    isARM = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a host that is aarch64";
    };

    # Should this host use a minimal configuration?
    isMinimal = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a minimal configuration host";
    };

    # Is this host a server?
    isServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a server host";
    };

    # Desktop environment selection: Gnome, Hyprland, or none (null).
    desktop = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "Gnome"
          "Hyprland"
        ]
      );
      # Default: null for servers, Gnome otherwise.
      default = if config.hostSpec.isServer then null else "Gnome";
      description = "Desktop environment (Gnome, Hyprland or null)";
    };

    # Default shell: fish or bash.
    shell = lib.mkOption {
      type = lib.types.enum [
        pkgs.fish
        pkgs.bash
      ];
      default = pkgs.fish;
      description = "Default shell (pkgs.fish or pkgs.bash)";
    };

    # Should this host mount a pool from PVE (Proxmox VE)?
    pool = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether it mounts pool from PVE";
    };
  };
}
