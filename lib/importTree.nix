_: {
  importTree = roots: let
    walk = dir: let
      entries = builtins.readDir dir;
    in
      builtins.concatMap (name: let
        path = dir + "/${name}";
        type = entries.${name};
      in
        if builtins.substring 0 1 name == "_"
        then []
        else if type == "directory"
        then walk path
        else if type == "regular" && builtins.match ".*\\.nix" name != null
        then [path]
        else [])
      (builtins.attrNames entries);
  in
    builtins.concatMap walk (
      if builtins.isList roots
      then roots
      else [roots]
    );
}
