# nixcfg


sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko hosts/x86/thinkpad/disko.nix

sudo nixos-install --root /mnt --flake .#thinkpad

nix flake update

nix fmt

sudo reboot
