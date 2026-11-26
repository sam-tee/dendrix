{
  flake.modules.nixos.forgejo-layout = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) attrNames concatMapStrings escapeShellArg escapeShellArgs unique;
    cfg = config.services.forgejo;
    assets = ./forgejo-layout;
    ownTemplates = attrNames (builtins.readDir "${assets}/templates/repo");
    patchedTemplates = ["home.tmpl" "header.tmpl" "view_list.tmpl"];
    assetVersion = file: builtins.substring 0 12 (builtins.hashFile "sha256" "${assets}/${file}");
    customHeader = pkgs.writeText "header.tmpl" ''
      <link rel="stylesheet" href="{{AssetUrlPrefix}}/css/repo-layout.css?v=${assetVersion "repo-layout.css"}">
    '';
    customFooter = pkgs.writeText "footer.tmpl" ''
      <script src="{{AssetUrlPrefix}}/js/repo-layout.js?v=${assetVersion "repo-layout.js"}" defer></script>
    '';
    files =
      map (f: "templates/repo/${f}") (unique (patchedTemplates ++ ownTemplates))
      ++ [
        "templates/custom/header.tmpl"
        "templates/custom/footer.tmpl"
        "public/assets/css/repo-layout.css"
        "public/assets/js/repo-layout.js"
        "public/assets/img/svg/nix-snowflake.svg"
      ];
    customFiles = pkgs.runCommand "forgejo-layout" {} ''
      mkdir -p $out/templates/repo $out/templates/custom $out/public/assets/css $out/public/assets/js $out/public/assets/img/svg
      for f in ${escapeShellArgs patchedTemplates}; do
        install -m644 ${cfg.package.src}/templates/repo/$f $out/templates/repo/$f
      done
      patch --fuzz=0 --no-backup-if-mismatch -d $out/templates -p1 < ${assets}/templates.patch
      cp ${assets}/templates/repo/*.tmpl $out/templates/repo/
      cp ${customHeader} $out/templates/custom/header.tmpl
      cp ${customFooter} $out/templates/custom/footer.tmpl
      cp ${assets}/repo-layout.css $out/public/assets/css/repo-layout.css
      cp ${assets}/repo-layout.js $out/public/assets/js/repo-layout.js
      cp ${assets}/svg/*.svg $out/public/assets/img/svg/
    '';
  in {
    # Forgejo caches templates at startup.
    systemd.services.forgejo.restartTriggers = [customFiles];
    system.activationScripts.forgejo-layout.text = let
      owner = escapeShellArg "${cfg.user}:${cfg.group}";
      dirs = ["templates" "templates/repo" "templates/custom" "public" "public/assets" "public/assets/css" "public/assets/js" "public/assets/img" "public/assets/img/svg"];
    in
      concatMapStrings (d: ''
        install -dm750 -o ${escapeShellArg cfg.user} -g ${escapeShellArg cfg.group} ${escapeShellArg "${cfg.customDir}/${d}"}
      '')
      dirs
      + concatMapStrings (f: let
        link = escapeShellArg "${cfg.customDir}/${f}";
      in ''
        ln -sfn ${customFiles}/${f} ${link}
        chown -h ${owner} ${link}
      '')
      files;
  };
}
