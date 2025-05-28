{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
{
  programs.firefox = {
    enable = true;
  };
}
