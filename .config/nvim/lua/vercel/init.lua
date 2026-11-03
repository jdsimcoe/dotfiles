-- Vercel Dark / Vercel Light for Neovim.
--
-- The 16 ANSI slots, background, foreground and selection are the official
-- Geist terminal themes (vercel.com/geist/terminal, also in
-- vercel/front apps/geist-docs/public/geist/terminal), so Neovim matches the
-- vercel-dark / vercel-light Ghostty and Rex themes exactly. The few UI
-- surfaces the terminal palette has no slot for come from Geist gray tokens.
--
-- Roles follow the Starship prompt (.config/starship.toml):
--   purple   directory, the one accent (file paths, current mode)
--   white    secondary gray (ANSI 7): Git branch, line numbers, separators
--   yellow   dirty / changed state
--   red      failure
--   green    success, added
-- Syntax follows the Geist code block theme (geistcn syntax-theme.module.css):
-- keywords pink (purple here; the terminal palette has no pink), strings and
-- constants green, functions, types and tags blue, properties red,
-- attributes amber, comments quiet gray.
--
-- Every color is a solid hex value: neorex and other RGB UIs take Normal's
-- background as the default and blend floats over it.

local M = {}

M.palettes = {
  dark = {
    bg = "#000000",
    fg = "#EDEDED",
    selection = "#2E2E2E",
    ansi = {
      "#1A1A1A",
      "#E5484D",
      "#63C174",
      "#F1A10D",
      "#52A9FF",
      "#BF7AF0",
      "#0AC5B3",
      "#A0A0A0",
      "#8F8F8F",
      "#FE7573",
      "#83E293",
      "#FFC983",
      "#97C9FE",
      "#D7A4FF",
      "#4BE6D3",
      "#FFFFFF",
    },
    -- Geist dark gray-100, gray-200, gray-500
    surface = "#1A1A1A",
    surface2 = "#1F1F1F",
    border = "#454545",
  },
  light = {
    bg = "#FBFBFA",
    fg = "#24292F",
    selection = "#DCE3EC",
    ansi = {
      "#24292F",
      "#CF2F36",
      "#18703A",
      "#8A5300",
      "#1A5FB4",
      "#7E3AB8",
      "#0B7268",
      "#4F5359",
      "#656A70",
      "#A8242B",
      "#0F5A2C",
      "#6B3F00",
      "#124A8C",
      "#622A92",
      "#085A52",
      "#171717",
    },
    -- Geist light gray-100, gray-200, gray-500, warmed to sit on #FBFBFA
    surface = "#F2F2F1",
    surface2 = "#EBEBEA",
    border = "#C9C9C8",
  },
}

--- Named colors for `background` ("dark" or "light").
function M.colors(background)
  local p = M.palettes[background] or M.palettes.dark
  local a = p.ansi
  return {
    bg = p.bg,
    fg = p.fg,
    selection = p.selection,
    surface = p.surface,
    surface2 = p.surface2,
    border = p.border,
    secondary = a[8], -- ANSI 7
    quiet = a[9], -- ANSI 8
    red = a[2],
    green = a[3],
    yellow = a[4],
    blue = a[5],
    purple = a[6],
    cyan = a[7],
    bright_red = a[10],
    bright_green = a[11],
    bright_yellow = a[12],
    bright_blue = a[13],
    bright_purple = a[14],
    bright_cyan = a[15],
    bright_white = a[16],
    ansi = a,
  }
end

--- `amount` (0-1) of `fg` over `bg`.
local function blend(fg, bg, amount)
  local function ch(hex, i)
    return tonumber(hex:sub(i, i + 1), 16)
  end
  local out = "#"
  for _, i in ipairs({ 2, 4, 6 }) do
    out = out .. string.format("%02X", math.floor(amount * ch(fg, i) + (1 - amount) * ch(bg, i) + 0.5))
  end
  return out
end

local function highlights(c)
  local tint = function(color, amount)
    return blend(color, c.bg, amount or 0.14)
  end
  local diff_add = tint(c.green)
  local diff_delete = tint(c.red)
  local diff_change = tint(c.blue, 0.10)

  return {
    -- Editor
    Normal = { fg = c.fg, bg = c.bg },
    NormalNC = { link = "Normal" },
    NormalFloat = { fg = c.fg, bg = c.bg },
    FloatBorder = { fg = c.border, bg = c.bg },
    FloatTitle = { fg = c.fg, bg = c.bg, bold = true },
    FloatFooter = { fg = c.quiet, bg = c.bg },
    WinSeparator = { fg = c.surface2, bg = c.bg },
    VertSplit = { link = "WinSeparator" },
    Cursor = { fg = c.bg, bg = c.fg },
    lCursor = { link = "Cursor" },
    TermCursor = { link = "Cursor" },
    CursorLine = { bg = c.surface },
    CursorColumn = { link = "CursorLine" },
    ColorColumn = { bg = c.surface },
    CursorLineNr = { fg = c.fg, bold = true },
    LineNr = { fg = c.quiet },
    LineNrAbove = { link = "LineNr" },
    LineNrBelow = { link = "LineNr" },
    SignColumn = { bg = c.bg },
    FoldColumn = { fg = c.quiet, bg = c.bg },
    Folded = { fg = c.secondary, bg = c.surface },
    Visual = { bg = c.selection },
    VisualNOS = { link = "Visual" },
    Search = { fg = c.bg, bg = c.yellow },
    IncSearch = { fg = c.bg, bg = c.bright_yellow, bold = true },
    CurSearch = { link = "IncSearch" },
    Substitute = { fg = c.bg, bg = c.red },
    MatchParen = { fg = c.bright_purple, bold = true, underline = true },
    NonText = { fg = c.border },
    Whitespace = { fg = c.surface2 },
    SpecialKey = { fg = c.border },
    EndOfBuffer = { fg = c.bg },
    Conceal = { fg = c.quiet },
    Directory = { fg = c.purple, bold = true },
    Title = { fg = c.fg, bold = true },
    ModeMsg = { fg = c.fg, bold = true },
    MoreMsg = { fg = c.green },
    Question = { fg = c.blue },
    MsgArea = { fg = c.fg },
    ErrorMsg = { fg = c.red, bold = true },
    WarningMsg = { fg = c.yellow },
    QuickFixLine = { bg = c.selection, bold = true },
    WildMenu = { link = "PmenuSel" },

    -- Statusline: no background blocks, like the prompt
    StatusLine = { fg = c.secondary, bg = c.bg },
    StatusLineNC = { fg = c.quiet, bg = c.bg },
    TabLine = { fg = c.quiet, bg = c.bg },
    TabLineFill = { bg = c.bg },
    TabLineSel = { fg = c.fg, bg = c.bg, bold = true },
    WinBar = { fg = c.secondary, bg = c.bg },
    WinBarNC = { fg = c.quiet, bg = c.bg },

    -- Popup menu
    Pmenu = { fg = c.fg, bg = c.surface },
    PmenuSel = { fg = c.fg, bg = c.selection, bold = true },
    PmenuKind = { fg = c.secondary, bg = c.surface },
    PmenuKindSel = { fg = c.secondary, bg = c.selection },
    PmenuExtra = { fg = c.quiet, bg = c.surface },
    PmenuExtraSel = { fg = c.quiet, bg = c.selection },
    PmenuMatch = { fg = c.purple, bold = true },
    PmenuMatchSel = { fg = c.purple, bg = c.selection, bold = true },
    PmenuSbar = { bg = c.surface },
    PmenuThumb = { bg = c.border },

    -- Diff
    DiffAdd = { bg = diff_add },
    DiffDelete = { fg = c.red, bg = diff_delete },
    DiffChange = { bg = diff_change },
    DiffText = { bg = tint(c.blue, 0.28) },
    Added = { fg = c.green },
    Changed = { fg = c.yellow },
    Removed = { fg = c.red },
    diffAdded = { link = "Added" },
    diffRemoved = { link = "Removed" },
    diffChanged = { link = "Changed" },

    -- Spelling
    SpellBad = { sp = c.red, undercurl = true },
    SpellCap = { sp = c.yellow, undercurl = true },
    SpellLocal = { sp = c.cyan, undercurl = true },
    SpellRare = { sp = c.purple, undercurl = true },

    -- Syntax (Geist code block roles)
    Comment = { fg = c.quiet, italic = true },
    Constant = { fg = c.green },
    String = { fg = c.green },
    Character = { fg = c.green },
    Number = { fg = c.blue },
    Float = { link = "Number" },
    Boolean = { fg = c.green },
    Identifier = { fg = c.fg },
    Function = { fg = c.blue },
    Statement = { fg = c.purple },
    Conditional = { link = "Statement" },
    Repeat = { link = "Statement" },
    Label = { fg = c.purple },
    Operator = { fg = c.fg },
    Keyword = { fg = c.purple },
    Exception = { fg = c.purple },
    PreProc = { fg = c.purple },
    Include = { fg = c.purple },
    Define = { fg = c.purple },
    Macro = { fg = c.cyan },
    PreCondit = { fg = c.purple },
    Type = { fg = c.blue },
    StorageClass = { fg = c.purple },
    Structure = { fg = c.blue },
    Typedef = { fg = c.blue },
    Special = { fg = c.cyan },
    SpecialChar = { fg = c.yellow },
    Tag = { fg = c.blue },
    Delimiter = { fg = c.secondary },
    SpecialComment = { fg = c.secondary, italic = true },
    Debug = { fg = c.red },
    Underlined = { underline = true },
    Ignore = { fg = c.quiet },
    Error = { fg = c.red },
    Todo = { fg = c.bg, bg = c.yellow, bold = true },

    -- Treesitter
    ["@variable"] = { fg = c.fg },
    ["@variable.builtin"] = { fg = c.cyan },
    ["@variable.parameter"] = { fg = c.fg },
    ["@variable.member"] = { fg = c.red },
    ["@property"] = { fg = c.red },
    ["@constant"] = { fg = c.green },
    ["@constant.builtin"] = { fg = c.green },
    ["@constant.macro"] = { fg = c.cyan },
    ["@module"] = { fg = c.fg },
    ["@label"] = { fg = c.purple },
    ["@string"] = { link = "String" },
    ["@string.escape"] = { fg = c.yellow },
    ["@string.regexp"] = { fg = c.yellow },
    ["@string.special"] = { fg = c.cyan },
    ["@string.special.url"] = { fg = c.purple, underline = true },
    ["@character"] = { link = "Character" },
    ["@number"] = { link = "Number" },
    ["@boolean"] = { link = "Boolean" },
    ["@type"] = { fg = c.blue },
    ["@type.builtin"] = { fg = c.cyan },
    ["@attribute"] = { fg = c.yellow },
    ["@function"] = { fg = c.blue },
    ["@function.builtin"] = { fg = c.cyan },
    ["@function.call"] = { fg = c.blue },
    ["@function.method"] = { fg = c.blue },
    ["@function.method.call"] = { fg = c.blue },
    ["@constructor"] = { fg = c.blue },
    ["@operator"] = { fg = c.fg },
    ["@keyword"] = { fg = c.purple },
    ["@keyword.return"] = { fg = c.purple },
    ["@keyword.import"] = { fg = c.purple },
    ["@keyword.exception"] = { fg = c.purple },
    ["@punctuation.delimiter"] = { fg = c.secondary },
    ["@punctuation.bracket"] = { fg = c.secondary },
    ["@punctuation.special"] = { fg = c.cyan },
    ["@comment"] = { link = "Comment" },
    ["@comment.error"] = { fg = c.red, bold = true },
    ["@comment.warning"] = { fg = c.yellow, bold = true },
    ["@comment.todo"] = { fg = c.yellow, bold = true },
    ["@comment.note"] = { fg = c.blue, bold = true },
    ["@tag"] = { fg = c.blue },
    ["@tag.builtin"] = { fg = c.blue },
    ["@tag.attribute"] = { fg = c.yellow },
    ["@tag.delimiter"] = { fg = c.secondary },
    ["@markup.heading"] = { fg = c.fg, bold = true },
    ["@markup.strong"] = { bold = true },
    ["@markup.italic"] = { italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.underline"] = { underline = true },
    ["@markup.raw"] = { fg = c.blue },
    ["@markup.link"] = { fg = c.purple },
    ["@markup.link.url"] = { fg = c.purple, underline = true },
    ["@markup.link.label"] = { fg = c.blue },
    ["@markup.list"] = { fg = c.secondary },
    ["@markup.quote"] = { fg = c.secondary, italic = true },
    ["@diff.plus"] = { link = "Added" },
    ["@diff.minus"] = { link = "Removed" },
    ["@diff.delta"] = { link = "Changed" },
    -- JSON keys are primary text in Geist
    ["@property.json"] = { fg = c.fg },
    ["@property.jsonc"] = { fg = c.fg },

    -- LSP
    ["@lsp.type.property"] = { link = "@property" },
    ["@lsp.type.parameter"] = { link = "@variable.parameter" },
    ["@lsp.type.namespace"] = { link = "@module" },
    ["@lsp.type.interface"] = { link = "@type" },
    ["@lsp.type.enumMember"] = { link = "@constant" },
    ["@lsp.typemod.variable.readonly"] = {},
    ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
    LspReferenceText = { bg = c.surface2 },
    LspReferenceRead = { bg = c.surface2 },
    LspReferenceWrite = { bg = c.surface2, underline = true },
    LspInlayHint = { fg = c.quiet, bg = c.surface },
    LspCodeLens = { fg = c.quiet },
    LspSignatureActiveParameter = { fg = c.purple, bold = true },

    -- Diagnostics: FAIL red, WARN amber, INFO blue, as on the Geist terminal page
    DiagnosticError = { fg = c.red },
    DiagnosticWarn = { fg = c.yellow },
    DiagnosticInfo = { fg = c.blue },
    DiagnosticHint = { fg = c.cyan },
    DiagnosticOk = { fg = c.green },
    DiagnosticUnderlineError = { sp = c.red, undercurl = true },
    DiagnosticUnderlineWarn = { sp = c.yellow, undercurl = true },
    DiagnosticUnderlineInfo = { sp = c.blue, undercurl = true },
    DiagnosticUnderlineHint = { sp = c.cyan, undercurl = true },
    DiagnosticVirtualTextError = { fg = c.red, bg = tint(c.red, 0.08) },
    DiagnosticVirtualTextWarn = { fg = c.yellow, bg = tint(c.yellow, 0.08) },
    DiagnosticVirtualTextInfo = { fg = c.blue, bg = tint(c.blue, 0.08) },
    DiagnosticVirtualTextHint = { fg = c.cyan, bg = tint(c.cyan, 0.08) },
    DiagnosticUnnecessary = { fg = c.quiet },
    DiagnosticDeprecated = { strikethrough = true },

    -- Git signs: added green, changed amber (the prompt's dirty color), removed red
    GitSignsAdd = { fg = c.green },
    GitSignsChange = { fg = c.yellow },
    GitSignsDelete = { fg = c.red },
    GitSignsCurrentLineBlame = { fg = c.quiet },

    -- Snacks (picker, dashboard, notifier, indent)
    SnacksPickerDir = { fg = c.quiet },
    SnacksPickerFile = { fg = c.fg },
    SnacksPickerMatch = { fg = c.purple, bold = true },
    SnacksPickerPrompt = { fg = c.purple, bold = true },
    SnacksPickerBorder = { link = "FloatBorder" },
    SnacksPickerTitle = { link = "FloatTitle" },
    SnacksPickerListCursorLine = { bg = c.surface },
    SnacksPickerGitStatusModified = { fg = c.yellow },
    SnacksPickerGitStatusAdded = { fg = c.green },
    SnacksPickerGitStatusDeleted = { fg = c.red },
    SnacksPickerGitStatusUntracked = { fg = c.yellow },
    SnacksIndent = { fg = c.surface2 },
    SnacksIndentScope = { fg = c.border },
    SnacksDashboardHeader = { fg = c.fg, bold = true },
    SnacksDashboardKey = { fg = c.purple, bold = true },
    SnacksDashboardDesc = { fg = c.fg },
    SnacksDashboardFooter = { fg = c.quiet },
    SnacksDashboardSpecial = { fg = c.purple },

    -- Blink completion
    BlinkCmpMenu = { link = "Pmenu" },
    BlinkCmpMenuBorder = { fg = c.border, bg = c.surface },
    BlinkCmpMenuSelection = { link = "PmenuSel" },
    BlinkCmpLabelMatch = { fg = c.purple, bold = true },
    BlinkCmpLabelDeprecated = { fg = c.quiet, strikethrough = true },
    BlinkCmpKind = { fg = c.secondary },
    BlinkCmpSource = { fg = c.quiet },
    BlinkCmpDoc = { fg = c.fg, bg = c.surface },
    BlinkCmpDocBorder = { fg = c.border, bg = c.surface },
    BlinkCmpGhostText = { fg = c.quiet },

    -- which-key, flash, noice, trouble, todo-comments, bufferline
    WhichKey = { fg = c.purple, bold = true },
    WhichKeyGroup = { fg = c.blue },
    WhichKeyDesc = { fg = c.fg },
    WhichKeySeparator = { fg = c.quiet },
    WhichKeyNormal = { link = "NormalFloat" },
    FlashLabel = { fg = c.bg, bg = c.purple, bold = true },
    FlashMatch = { fg = c.fg, bg = c.selection },
    FlashCurrent = { fg = c.bg, bg = c.yellow },
    FlashBackdrop = { fg = c.quiet },
    NoiceCmdlineIcon = { fg = c.purple },
    NoiceCmdlinePopupBorder = { link = "FloatBorder" },
    NoiceCmdlinePopupTitle = { link = "FloatTitle" },
    TroubleNormal = { link = "Normal" },
    TroubleNormalNC = { link = "Normal" },
    TodoBgTODO = { fg = c.bg, bg = c.blue, bold = true },
    TodoFgTODO = { fg = c.blue },
    TodoBgFIX = { fg = c.bg, bg = c.red, bold = true },
    TodoFgFIX = { fg = c.red },
    TodoBgWARN = { fg = c.bg, bg = c.yellow, bold = true },
    TodoFgWARN = { fg = c.yellow },
    TodoBgNOTE = { fg = c.bg, bg = c.cyan, bold = true },
    TodoFgNOTE = { fg = c.cyan },
    BufferLineFill = { bg = c.bg },
    BufferLineBackground = { fg = c.quiet, bg = c.bg },
    BufferLineBufferSelected = { fg = c.fg, bg = c.bg, bold = true },
    BufferLineIndicatorSelected = { fg = c.purple, bg = c.bg },

    -- Neogit / Diffview
    NeogitBranch = { fg = c.secondary, bold = true },
    NeogitRemote = { fg = c.secondary },
    NeogitHunkHeader = { fg = c.secondary, bg = c.surface },
    NeogitHunkHeaderHighlight = { fg = c.fg, bg = c.surface2, bold = true },
    NeogitDiffAdd = { fg = c.green, bg = diff_add },
    NeogitDiffAddHighlight = { fg = c.green, bg = diff_add },
    NeogitDiffDelete = { fg = c.red, bg = diff_delete },
    NeogitDiffDeleteHighlight = { fg = c.red, bg = diff_delete },
    NeogitDiffContext = { bg = c.bg },
    NeogitDiffContextHighlight = { bg = c.surface },
    NeogitChangeModified = { fg = c.yellow, bold = true },
    NeogitChangeAdded = { fg = c.green, bold = true },
    NeogitChangeDeleted = { fg = c.red, bold = true },
    DiffviewFilePanelTitle = { fg = c.purple, bold = true },
    DiffviewFilePanelCounter = { fg = c.secondary },
  }
end

--- Loads the theme for `background`, or for the current 'background'.
function M.load(background)
  if background then
    vim.o.background = background
  end
  local c = M.colors(vim.o.background)

  if vim.g.colors_name then
    vim.cmd("hi clear")
  end
  vim.o.termguicolors = true
  vim.g.colors_name = background and ("vercel-" .. background) or "vercel"

  for group, spec in pairs(highlights(c)) do
    vim.api.nvim_set_hl(0, group, spec)
  end

  -- :terminal uses the same 16 colors as Ghostty / Rex
  for i, color in ipairs(c.ansi) do
    vim.g["terminal_color_" .. (i - 1)] = color
  end
end

return M
