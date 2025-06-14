{
  pkgs,
  config,
  lib,
  ...
}:
let
in
{

  secretsSpec = {

    users = {

      worker = {
        hashedPassword = "$y$j9T$Rcj7d0CMprzE.SiuTK6lV.$cdnr9xQYAb1B/gHDJQOH/CSCUSp6QAjt3fc6qlRvluD";
      };
    };
  };
}
