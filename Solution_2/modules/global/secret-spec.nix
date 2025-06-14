# Specifications For Secret Data Structures
{
  pkgs,
  config,
  lib,
  ...
}:

# Define helper functions for securely creating SSH and GPG key files
let
  ## SSH key creation function ##
  # Creates a file containing an SSH private key, checks format validity.
  mkSshKeyFile =
    name: content:
    pkgs.writeTextFile {
      name = "ssh-key-${name}";
      text = content;
      executable = false;
      checkPhase = ''
        grep -q "BEGIN OPENSSH PRIVATE KEY" "$out" || (echo "Invalid SSH key format"; exit 1)
      '';
    };

  ## GPG key creation function ##
  # Creates a file containing a GPG private key, checks format validity.
  mkGpgKeyFile =
    name: content:
    pkgs.writeTextFile {
      name = "gpg-key-${name}";
      text = content;
      executable = false;
      checkPhase = ''
        grep -q "BEGIN PGP PRIVATE KEY BLOCK" "$out" || (echo "Invalid GPG key format"; exit 1)
      '';
    };
in
{
  options.secretsSpec = {
    # User secrets configuration (per-user secret data)
    users = lib.mkOption {
      # Each user is an attribute set (by username or handle)
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            # Hashed password for the user (generate with mkpasswd)
            hashedPassword = lib.mkOption {
              type = lib.types.str;
              description = "Hashed password for the user"; # nix-shell -p whois --run 'mkpasswd --method=sha-512 --rounds=656000'
            };
            # Email address for the user
            email = lib.mkOption {
              type = lib.types.str;
              description = "Email address for the user";
            };
            # Handle for the user (e.g., GitHub username)
            handle = lib.mkOption {
              type = lib.types.str;
              description = "The handle of the user (eg: github user)";
            };
            # Full name of the user
            fullName = lib.mkOption {
              type = lib.types.str;
              description = "Full name of the user";
            };

            ## SSH configuration for the user ##
            ssh = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  # List of SSH public keys (strings)
                  publicKeys = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    description = "SSH public keys for the user";
                    default = [ ];
                  };
                  # Map of SSH private key contents, keyed by name
                  privateKeyContents = lib.mkOption {
                    type = lib.types.attrsOf lib.types.str;
                    description = "SSH private key contents keyed by name";
                    default = { };
                  };
                  # Map of SSH private key file paths, created from contents above
                  privateKeys = lib.mkOption {
                    type = lib.types.attrsOf lib.types.path;
                    description = "SSH private key file paths keyed by name";
                    default = { };
                    # For each private key content, create a file using mkSshKeyFile
                    apply =
                      _:
                      let
                        userName = config.hostSpec.username;
                        userConfig = config.secretsSpec.users.${userName} or { };
                        privateKeyContents = userConfig.ssh.privateKeyContents or { };
                      in
                      lib.mapAttrs (name: content: mkSshKeyFile "${userName}-${name}" content) privateKeyContents;
                  };
                  # Path to SSH config file
                  config = lib.mkOption {
                    type = lib.types.path;
                    description = "SSH config file path";
                  };
                  # List of SSH known hosts entries
                  knownHosts = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    description = "SSH known hosts entries";
                    default = [ ];
                  };
                };
              };
              default = { };
              description = "SSH configuration for the user";
            };

            ## GPG configuration for the user ##
            gpg = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  # GPG public key content (string)
                  publicKey = lib.mkOption {
                    type = lib.types.str;
                    description = "GPG public key content";
                    default = "";
                  };
                  # GPG private key content (string)
                  privateKeyContents = lib.mkOption {
                    type = lib.types.str;
                    description = "GPG private key content";
                    default = "";
                  };
                  # Path to GPG private key file, created from content above
                  privateKey = lib.mkOption {
                    type = lib.types.path;
                    description = "GPG private key file path";
                    default = null;
                    # If privateKeyContents is set, create file using mkGpgKeyFile
                    apply =
                      _:
                      let
                        userName = config.hostSpec.username;
                        userConfig = config.secretsSpec.users.${userName} or { };
                        privateKeyContent = userConfig.gpg.privateKeyContents or "";
                      in
                      if privateKeyContent != "" then mkGpgKeyFile userName privateKeyContent else null;
                  };
                  # GPG trust database content (base64-encoded string)
                  trust = lib.mkOption {
                    type = lib.types.str;
                    description = "GPG trust database content (base64)";
                    default = "";
                  };
                };
              };
              default = { };
              description = "GPG configuration for the user";
            };

            ## SMTP configuration for the user ##
            smtp = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  # SMTP server hostname
                  host = lib.mkOption {
                    type = lib.types.str;
                    description = "SMTP server hostname";
                  };
                  # SMTP username for authentication
                  user = lib.mkOption {
                    type = lib.types.str;
                    description = "SMTP username for authentication";
                  };
                  # SMTP password for authentication
                  password = lib.mkOption {
                    type = lib.types.str;
                    description = "SMTP password for authentication";
                  };
                  # SMTP server port (default 587)
                  port = lib.mkOption {
                    type = lib.types.port;
                    description = "SMTP server port";
                    default = 587;
                  };
                  # Email address to send from
                  from = lib.mkOption {
                    type = lib.types.str;
                    description = "Email address to send from";
                  };
                };
              };
              description = "SMTP configuration for the user";
              default = null;
            };
          };
        }
      );
      description = "User information secrets";
      default = { };
    };

    ## Firewall configurations by host ##
    firewall = lib.mkOption {
      # Each host has its own firewall configuration (by hostname)
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            # List of allowed TCP ports
            allowedTCPPorts = lib.mkOption {
              type = lib.types.listOf lib.types.port;
              description = "Allowed TCP ports for this host";
              default = [ ];
              # example = [ 22 80 443 ];
            };
            # List of allowed TCP port ranges (each with from/to)
            allowedTCPPortRanges = lib.mkOption {
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {
                    from = lib.mkOption {
                      type = lib.types.port;
                      description = "Starting port in range";
                    };
                    to = lib.mkOption {
                      type = lib.types.port;
                      description = "Ending port in range";
                    };
                  };
                }
              );
              description = "Allowed TCP port ranges for this host";
              default = [ ];
              # example = [ { from = 25565; to = 25570; } ];
            };
            # List of allowed UDP ports
            allowedUDPPorts = lib.mkOption {
              type = lib.types.listOf lib.types.port;
              description = "Allowed UDP ports for this host";
              default = [ ];
              # example = [ 53 123 ];
            };
            # List of allowed UDP port ranges (each with from/to)
            allowedUDPPortRanges = lib.mkOption {
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {
                    from = lib.mkOption {
                      type = lib.types.port;
                      description = "Starting port in range";
                    };
                    to = lib.mkOption {
                      type = lib.types.port;
                      description = "Ending port in range";
                    };
                  };
                }
              );
              description = "Allowed UDP port ranges for this host";
              default = [ ];
              # example = [ { from = 25565; to = 25570; } ];
            };
          };
        }
      );
      description = "Firewall configuration by host";
      default = { };
    };

    ## API keys for various services ##
    api = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "API keys keyed by service name";
      default = { };
    };

    ## Docker environment variables per container ##
    docker = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      description = "Docker environment variables keyed by container name";
      default = { };
    };
  };
}
