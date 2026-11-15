{
  flake.modules.nixos.forgejo-templates = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) concatMapStrings escapeShellArg;
    cfg = config.services.forgejo;
    readme = ''{{if and .ReadmeExist (or .IsMarkup .IsPlainText)}}'';
    viewFile = ''{{template "repo/view_file" .}}'';
    templates = pkgs.runCommand "forgejo-templates" {} ''
      mkdir -p $out/repo
      substitute ${cfg.package.src}/templates/repo/view_list.tmpl $out/repo/view_list.tmpl \
        --replace-fail ${escapeShellArg "${readme}\n\t${viewFile}\n{{end}}\n"} ""
      substitute ${cfg.package.src}/templates/repo/home.tmpl $out/repo/home.tmpl \
        --replace-fail ${escapeShellArg "{{else}}{{/* IsViewDirectory */}}\n"} \
          ${escapeShellArg "{{else}}{{/* IsViewDirectory */}}\n${readme}<div class=\"tw-mb-4\">${viewFile}</div>{{end}}\n"}
    '';
    files = ["home.tmpl" "view_list.tmpl"];
    templatesDir = "${cfg.customDir}/templates";
  in {
    systemd.services.forgejo.restartTriggers = [templates];
    system.activationScripts.forgejo-templates.text = let
      owner = escapeShellArg "${cfg.user}:${cfg.group}";
    in
      ''
        install -dm750 -o ${escapeShellArg cfg.user} -g ${escapeShellArg cfg.group} ${escapeShellArg templatesDir} ${escapeShellArg "${templatesDir}/repo"}
      ''
      + concatMapStrings (f: let
        link = escapeShellArg "${templatesDir}/repo/${f}";
      in ''
        ln -sfn ${templates}/repo/${f} ${link}
        chown -h ${owner} ${link}
      '')
      files;
  };
}
