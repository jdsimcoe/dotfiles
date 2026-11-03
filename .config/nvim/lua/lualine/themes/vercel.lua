-- lualine theme for the vercel colorscheme: no background blocks, like the
-- Starship prompt. Everything sits on the editor background.
local c = require("vercel").colors(vim.o.background)

local section = { fg = c.secondary, bg = c.bg }
local mode = function(fg)
  return { a = { fg = fg, bg = c.bg, gui = "bold" }, b = section, c = section }
end

return {
  normal = mode(c.fg),
  insert = mode(c.fg),
  visual = mode(c.purple),
  replace = mode(c.red),
  command = mode(c.fg),
  terminal = mode(c.fg),
  inactive = {
    a = { fg = c.quiet, bg = c.bg },
    b = { fg = c.quiet, bg = c.bg },
    c = { fg = c.quiet, bg = c.bg },
  },
}
