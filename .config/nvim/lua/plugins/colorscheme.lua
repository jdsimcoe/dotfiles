return {
  -- Atom colorscheme
  {
    url = "git@github.com:jdsimcoe/atom-nvim.git",
    lazy = false,
    priority = 1000,
  },

  -- Tell LazyVim to use it
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "atom",
    },
  },
}
