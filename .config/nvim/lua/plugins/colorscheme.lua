return {
  -- Atom colorscheme (kept available as :colorscheme atom)
  {
    "jdsimcoe/atom-nvim",
    lazy = false,
    priority = 1000,
  },

  -- Flexoki colorscheme (Steph Ango's inky palette)
  {
    "kepano/flexoki-neovim",
    name = "flexoki",
    lazy = false,
    priority = 1000,
  },

  -- Tell LazyVim which colorscheme to load at startup
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "flexoki-dark",
    },
  },
}
