{
  config,
  pkgs,
  username,
  ...
}: {
  # Define a user account
  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "start";
    extraGroups = ["networkmanager" "wheel"];
  };
}
