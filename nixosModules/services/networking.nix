{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  # boot.kernel.sysctl."net.ipv6.conf.eth0.disable_ipv6" = true;
  networking.enableIPv6 = false;
}
