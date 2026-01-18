let
  starship = {
    enable = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      add_newline = true;
      scan_timeout = 100;
      command_timeout = 1000;
      format = "$hostname$directory$character";
      right_format = "$git_branch$git_status$nix_shell$python";
      character = {
        error_symbol = "[❯](bold red)";
        success_symbol = "[❯](bold purple)";
      };
      directory = {
        fish_style_pwd_dir_length = 1;
        format = "[ $path]($style) ";
        style = "bold purple";
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      hostname = {
        format = "[$ssh_symbol $hostname]($style) ";
        ssh_only = true;
        ssh_symbol = "";
        style = "blue dimmed bold";
      };

      git_branch = {
        format = "[$symbol $branch(:$remote_branch)]($style) ";
        style = "italic cyan";
        symbol = "";
      };
      git_status = {
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        conflicted = "\${count}";
        deleted = "×\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        format = "([$all_status$ahead_behind]($style)) ";
        modified = "!\${count}";
        renamed = "»\${count}";
        staged = "+\${count}";
        stashed = "*\${count}";
        style = "cyan";
        untracked = "?\${count}";
        up_to_date = "";
      };
      nix_shell = {
        format = "[\${symbol}]($style) ";
        style = "bold blue";
        symbol = "";
      };
      python = {
        detect_extensions = [];
        detect_files = [];
        detect_folders = [];
        format = "[\${symbol} $virtualenv]($style)";
        style = "bold yellow";
        symbol = "";
      };
    };
  };
in {
  flake.modules = _: {
    nixos.cli.programs = {inherit starship;};
    homeManager.cli.programs = {inherit starship;};
  };
}
