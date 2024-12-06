{ config, ... }: { 

imports = [ ./home.nix ../common ];

programs.kitty = {
  enable = true;
  font = {
    name = "JetBrainsMono Nerd Font";
    size = 16;
    };
  };
}
