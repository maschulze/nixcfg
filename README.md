# nixcfg


sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko hosts/thinkpad/disko-config.nix

sudo nixos-install --root /mnt --flake .#thinkpad

sudo reboot
