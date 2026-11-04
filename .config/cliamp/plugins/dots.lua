-- Minimal dot-matrix spectrum for cliamp.
-- One dot every other column, bass on the left through treble on the
-- right, each column rising from the bottom row.
-- Every slot is the same small dot; lit ones turn bright white and unlit
-- ones stay faint grey so the grid reads even in silence.
--
-- Kept deliberately cheap: no per-frame allocation beyond the output
-- rows, and an escape code only where the color actually changes.

local p = plugin.register({
    name = "Dots",
    type = "visualizer",
    version = "1.0.0",
    description = "Minimal dot-matrix spectrum",
})

local ESC   = string.char(27)
local RESET = ESC .. "[0m"
-- ANSI 16-color SGR codes so the terminal theme drives the RGB values.
local function sgr(n) return ESC .. "[" .. n .. "m" end

local OFF_C = sgr(90)    -- bright black: faint grid
local ON_C  = sgr(97)    -- bright white: lit dots

local DOT = "·"

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

    -- Smoothed heights, in rows from the bottom (0..h).
    local height = {}
    for i = 1, n do
        local target = sample(bands, i, n)
        local cur = level[i] or 0
        local k = target > cur and ATTACK or DECAY
        cur = cur + (target - cur) * k
        level[i] = cur
        height[i] = cur * h
    end

    local out = {}
    for r = 1, h do
        -- Rows between this one and the bottom; row h is the floor.
        local d = h - r
        local prev, len = nil, 0
        for i = 1, n do
            local color = height[i] > d and ON_C or OFF_C
            if color ~= prev then
                len = len + 1; row_buf[len] = color; prev = color
            end
            len = len + 1; row_buf[len] = DOT
            if i < n then len = len + 1; row_buf[len] = " " end
        end
        len = len + 1; row_buf[len] = RESET
        out[r] = table.concat(row_buf, "", 1, len)
    end

    return table.concat(out, "\n")
end
