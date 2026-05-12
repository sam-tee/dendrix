{
  flake.modules.nixvim.default = _: {
    plugins.lsp = {
      enable = true;
      keymaps = {
        diagnostic = {
          "[d" = "goto_prev";
          "]d" = "goto_next";
          "<leader>xd" = "open_float";
        };
        lspBuf = {
          "K" = "hover";
          "gd" = "definition";
          "gD" = "declaration";
          "gi" = "implementation";
          "gr" = "references";
          "<leader>la" = "code_action";
          "<leader>lr" = "rename";
        };
      };
      servers = {
        nixd.enable = true;
        ruff.enable = true;
        ty.enable = true;
      };
    };
  };
}
