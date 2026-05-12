{
  flake.modules.nixvim.default = _: {
    plugins = {
      bufferline.enable = true;
      comment.enable = true;
      nvim-autopairs.enable = true;
      vim-surround.enable = true;

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            lsp_fallback = true;
            timeout_ms = 500;
          };
        };
      };
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
            "<C-Space>" = "cmp.mapping.complete()";
          };
          sources = [
            {name = "nvim_lsp";}
            {name = "luasnip";}
            {name = "path";}
            {name = "buffer";}
          ];
        };
      };
      lualine = {
        enable = true;
        settings.options = {
          component_separators = "";
          section_separators = "";
          globalstatus = true;
        };
      };
      luasnip.enable = true;
      noice.enable = true;
      notify.enable = true;
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        keymaps = {
          "<leader><space>" = {
            action = "find_files";
            options.desc = "Find files";
          };
          "<leader>ff" = {
            action = "find_files";
            options.desc = "Find files";
          };
          "<leader>fg" = {
            action = "live_grep";
            options.desc = "Live grep";
          };
          "<leader>fb" = {
            action = "buffers";
            options.desc = "Buffers";
          };
          "<leader>fh" = {
            action = "help_tags";
            options.desc = "Help tags";
          };
        };
      };
      neo-tree = {
        enable = true;
        settings.filesystem.follow_current_file.enabled = true;
      };
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };
      treesitter-context.enable = true;
      oil.enable = true;
      flash.enable = true;
      todo-comments.enable = true;
      web-devicons.enable = true;
      which-key = {
        enable = true;
        settings.spec = [
          {
            __unkeyed-1 = "<leader>f";
            group = "find";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "git";
          }
          {
            __unkeyed-1 = "<leader>l";
            group = "lsp";
          }
          {
            __unkeyed-1 = "<leader>x";
            group = "diagnostics";
          }
        ];
      };
    };
  };
}
