# IMPORTANT: This is used by NixOS and nix-darwin so options must exist in both!
{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  yay = inputs.yay.packages.${pkgs.system}.default;
in
{
  imports = lib.flatten [
    inputs.home-manager.nixosModules.home-manager
    (lib.custom.scanPaths ./.)

    (map lib.custom.relativeToRoot [
      "modules/global"
    ])
  ];

  # System-wide packages, root accessible
  environment.systemPackages = with pkgs; [
    # curl
    # git
    # git-crypt
    # gpg-tui
    # micro
    # openssh
    # sshfs
    # wget
    # yay # my yay teehee
    # yazi
  ];

  # Enable print to PDF.
  services.printing.enable = true;
  # Force home-manager to use global packages
  home-manager.useGlobalPkgs = true;
  # If there is a conflict file that is backed up, use this extension
  home-manager.backupFileExtension = "homeManagerBackupFileExtension";

  ## Overlays ##
  nixpkgs = {
    overlays = [
      outputs.overlays.default
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  ## Localization ##
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "Europe/Berlin";
  networking.timeServers = [ "pool.ntp.org" ];

  ## Nix Helper ##
  #   programs.nh = {
  #     enable = true;
  #     clean.enable = true;
  #     clean.extraArgs = "--keep-since 20d --keep 20";
  #     flake = "${config.hostSpec.home}/git/Nix/dot.nix/";
  #   };

  ## SUDO and Terminal ##
  environment.enableAllTerminfo = true;
  hardware.enableAllFirmware = true;

  #   security.sudo = {
  #     extraConfig = ''
  #       Defaults lecture = never # rollback results in sudo lectures after each reboot, it's somewhat useless anyway
  #       Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
  #       Defaults timestamp_timeout=120 # only ask for password every 2h
  #       # Keep SSH_AUTH_SOCK so that pam_ssh_agent_auth.so can do its magic.
  #       Defaults env_keep+=SSH_AUTH_SOCK
  #     '';
  #   };

  ## Primary shell enablement ##
  programs.fish.enable = true;
  environment.shells = with pkgs; [
    bash
    fish
  ];

  ## NIX NIX NIX ##
  #   documentation.nixos.enable = lib.mkForce false;
  #   nix = {
  #     # This will add each flake input as a registry
  #     # To make nix3 commands consistent with your flake
  #     registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

  #     # This will add your inputs to the system's legacy channels
  #     # Making legacy nix commands consistent as well, awesome!
  #     nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

  #     settings = {
  #       # See https://jackson.dev/post/nix-reasonable-defaults/
  #       connect-timeout = 5;
  #       log-lines = 25;
  #       min-free = 128000000; # 128MB
  #       max-free = 1000000000; # 1GB

  #       substituters = [ "https://hyprland.cachix.org" ];
  #       trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];

  #       trusted-users = [ "@wheel" ];
  #       # Deduplicate and optimize nix store
  #       auto-optimise-store = true;
  #       warn-dirty = false;

  #       allow-import-from-derivation = true;

  #       experimental-features = [
  #         "nix-command"
  #         "flakes"
  #       ];
  #     };
  #   };
}
