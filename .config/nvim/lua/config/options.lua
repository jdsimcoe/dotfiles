-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.fillchars:append({ vert = " ", horiz = " ", vertleft = " ", vertright = " ", verthoriz = " " })

-- TypeScript: the native TS7 server (`tsc --lsp`, formerly tsgo) instead of
-- vtsls. vercel/front ships TypeScript 7; lspconfig picks node_modules/.bin/tsc.
vim.g.lazyvim_ts_lsp = "tsc"

-- In a terminal, Neovim asks Ghostty / Rex for its background and sets
-- 'background', so the vercel colorscheme follows the terminal theme. Embedded
-- UIs like neorex can't answer that, so follow the macOS appearance there.
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    for _, ui in ipairs(vim.api.nvim_list_uis()) do
      if ui.stdout_tty then
        return
      end
    end
    vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }, function(out)
      local background = out.stdout:match("Dark") and "dark" or "light"
      vim.schedule(function()
        if vim.o.background ~= background then
          vim.o.background = background
        end
      end)
    end)
  end,
})
