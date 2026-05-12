{
  flake.modules.nixvim.default = _: {
    globals.have_nerd_font = true;
    opts = {
      clipboard = "unnamedplus";
      number = true;
      relativenumber = true;
      mouse = "a";
      showmode = false;

      breakindent = true;
      linebreak = true;
      wrap = false;

      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      expandtab = true;
      smartindent = true;

      ignorecase = true;
      smartcase = true;
      grepprg = "rg --vimgrep";
      grepformat = "%f:%l:%c:%m";

      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      sidescrolloff = 8;
      splitbelow = true;
      splitright = true;

      undofile = true;
      swapfile = false;
      backup = false;
      updatetime = 200;
      timeoutlen = 300;

      termguicolors = true;
      pumheight = 10;
      completeopt = "menu,menuone,noselect";
    };
  };
}
