-- Tooling for Vercel repos, vercel/front in particular. It matches what CI
-- runs (`pnpm lint`, lint-staged) and front's .vscode/settings.json:
--   TypeScript  TS7 native server (vim.g.lazyvim_ts_lsp = "tsc" in options.lua)
--   oxlint      LSP from the oxc extra. With front's oxlint.config.ts it also
--               runs the rulesdir/* design system rules as JS plugins, so no
--               ESLint server is needed.
--   oxfmt       formats JS/TS/JSON (oxc extra); Prettier formats CSS, YAML
--               and Markdown, as in lint-staged
--   Tailwind    LSP, with front's class functions
--   tsc.nvim    whole-repo type check in the background (:TSC)
-- The language extras themselves are enabled in lazyvim.json.

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          settings = {
            tailwindCSS = {
              classFunctions = { "cva", "cx", "cn", "clsx" },
            },
          },
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs({ "css", "scss", "yaml", "markdown", "markdown.mdx", "mdx" }) do
        opts.formatters_by_ft[ft] = { "prettier" }
      end
    end,
  },

  {
    "dmmulroy/tsc.nvim",
    cmd = { "TSC", "TSCOpen", "TSCClose", "TSCStop" },
    keys = {
      { "<leader>ct", "<cmd>TSC<cr>", desc = "Type Check Project (tsc)" },
    },
    opts = {
      use_trouble_qflist = true,
      -- front's root tsconfig.json is a solution file ("files": []), so check
      -- every project under the cwd: the whole repo from the root, one
      -- package from inside it.
      run_as_monorepo = true,
    },
  },

  -- Claude Code over its IDE protocol (ai.claudecode extra). Claude runs in
  -- its own Ghostty / Rex pane; `/ide` there connects it to this Neovim for
  -- the current selection, diagnostics and diffs you accept with :w.
  {
    "coder/claudecode.nvim",
    opts = {
      terminal = { provider = "none" },
    },
  },
}
