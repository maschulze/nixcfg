{
  home-manager,
  inputs,
  ...
}: {
  imports = [
    disko.nixosModules.disko

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [];
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {inherit inputs;};
    }

    ./hosts
    ./modules
    ./users
  ];
}
