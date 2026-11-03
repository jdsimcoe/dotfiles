return {
  -- Atom and Flexoki stay available as :colorscheme atom / flexoki-dark, but
  -- only load when picked.
  { "jdsimcoe/atom-nvim", lazy = true },
  { "kepano/flexoki-neovim", name = "flexoki", lazy = true },

  -- vercel (colors/vercel.lua, lua/vercel) follows 'background': Vercel Dark
  -- or Vercel Light, the Geist terminal themes used in Ghostty and Rex.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vercel",
    },
  },

  -- Statusline in the Starship prompt's style: no blocks or separators,
  -- ▼ in normal mode and ▲ in insert, the directory in bold purple, the
  -- branch in secondary gray.
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local markers = {
        n = "▼",
        i = "▲",
        v = "▲ VISUAL",
        V = "▲ V-LINE",
        ["\22"] = "▲ V-BLOCK",
        R = "▲ REPLACE",
        c = "▼",
        t = "▲",
      }
      opts.options.theme = "vercel"
      opts.options.section_separators = ""
      opts.options.component_separators = ""
      opts.sections.lualine_a = {
        function()
          local m = vim.api.nvim_get_mode().mode
          return markers[m] or markers[m:sub(1, 1)] or m
        end,
      }
      opts.sections.lualine_b = { { "branch", icon = "" } }
      -- the last lualine_c entry is LazyVim's file path; modified files go amber
      opts.sections.lualine_c[#opts.sections.lualine_c] = {
        LazyVim.lualine.pretty_path({ directory_hl = "Directory", filename_hl = "Bold", modified_hl = "WarningMsg" }),
      }
      opts.sections.lualine_y = { "progress" }
      opts.sections.lualine_z = { "location" }
    end,
  },
}
