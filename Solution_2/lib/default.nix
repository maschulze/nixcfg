{
  lib,
  ...
}:
{
  # Returns a path relative to the repository root (../.)
  relativeToRoot = lib.path.append ../.;

  # Given a directory path, returns a list of all subdirectories and .nix files (except default.nix)
  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      # Prepend the directory path to each filename
      builtins.attrNames (
        # Get the list of attribute names (filenames)
        lib.attrsets.filterAttrs
          # Filter attributes (files and directories) in the directory
          (
            path: _type:
            # Keep if it's a directory, or a .nix file (but not default.nix)
            (_type == "directory") || ((path != "default.nix") && (lib.strings.hasSuffix ".nix" path))
          )
          (builtins.readDir path) # Read the directory contents as an attribute set
      )
    );
}
