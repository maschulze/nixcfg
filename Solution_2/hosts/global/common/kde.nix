{
  pkgs,
  config,
  ...
}:
{

  services = {

    displayManager = {
      sddm = {
        enable = true;
      };
    };

    desktopManager.plasma6 = {
      enable = true;
    };

    xserver = {
      enable = true;

      xkb = {
        layout = "de";
        variant = "nodeadkeys";
      };
    };
  };
}
