-- Minimal mirrored dot-matrix spectrum for cliamp.
-- One dot every other column, mirrored around a quiet center line.
-- Lit dots brighten toward the center; unlit slots stay as faint grey
-- specks so the grid reads even in silence.
--
-- Kept deliberately cheap: no per-frame allocation beyond the output
-- rows, and an escape code only where the color actually changes.

local p = plugin.register({
    name = "Dots",
    type = "visualizer",
    version = "1.0.0",
    description = "Minimal mirrored dot-matrix spectrum",
})

local ESC   = string.char(27)
local RESET = ESC .. "[0m"
-- ANSI 16-color SGR codes so the terminal theme drives the RGB values.
local function sgr(n) return ESC .. "[" .. n .. "m" end

local OFF_C  = sgr(90)   -- bright black: faint grid
local MID_C  = sgr(37)   -- white: outer lit dots
local CORE_C = sgr(97)   -- bright white: dots near the center line
local TIP_C  = sgr(97)   -- bright white: the leading dot of each column

local OFF  = "·"
local ON   = "•"
local TIP  = "●"

local ATTACK = 0.6       -- fraction of the gap closed per frame going up
local DECAY  = 0.12      -- going down; slower so motion stays fluid
local MAX_ROWS = 12

local floor = math.floor

local level = {}         -- smoothed per-column level, 0..1
local row_buf = {}

function p:init()
    level = {}
end

-- Linear interpolation of the 10 bands across n columns.
local function sample(bands, i, n)
    local x = (i - 1) * 9 / (n > 1 and n - 1 or 1) + 1
    local a = floor(x)
    local t = x - a
    local b = a < 10 and a + 1 or 10
    return (bands[a] or 0) * (1 - t) + (bands[b] or 0) * t
end

function p:render(bands, frame, rows, cols)
    if cols < 4 or rows < 1 then return "" end
    bands = bands or {}

    local h = rows < MAX_ROWS and rows or MAX_ROWS
    local n = floor((cols + 1) / 2)
    local half = h / 2

    -- Smoothed heights, in rows from the center (0..half).
    local height = {}
    for i = 1, n do
        local target = sample(bands, i, n)
        local cur = level[i] or 0
        local k = target > cur and ATTACK or DECAY
        cur = cur + (target - cur) * k
        level[i] = cur
        height[i] = cur * half
    end

    local out = {}
    for r = 1, h do
        -- Distance of this row's center from the middle line, in rows.
        local d = r - 0.5 - half
        if d < 0 then d = -d end
        local core = d < half * 0.35
        local prev, len = nil, 0
        for i = 1, n do
            local hgt = height[i]
            local color, glyph
            if hgt > d + 1 then
                color = core and CORE_C or MID_C; glyph = ON
            elseif hgt > d then
                color = TIP_C; glyph = TIP
            else
                color = OFF_C; glyph = OFF
            end
            if color ~= prev then
                len = len + 1; row_buf[len] = color; prev = color
            end
            len = len + 1; row_buf[len] = glyph
            if i < n then len = len + 1; row_buf[len] = " " end
        end
        len = len + 1; row_buf[len] = RESET
        out[r] = table.concat(row_buf, "", 1, len)
    end

    return table.concat(out, "\n")
end
