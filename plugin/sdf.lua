------------------------------------------------------------------------------
-- plugin.sdf — SDF anti-aliased shapes for Solar2D
-- Usage:
--   local sdf = require("plugin.sdf")
--   sdf.enable()   -- patches display.newCircle/newRoundedRect with SDF AA
--   -- OR use directly for advanced features (stroke, shadow, gradient):
--   local circle = sdf.newCircle(x, y, r)
------------------------------------------------------------------------------

local sdf = require("sdf_shapes")

local M = {}

-- Re-export all sdf_shapes API
for k, v in pairs(sdf) do
    M[k] = v
end

-- ─────────────────────────────────────────────
-- Override system
-- Returns NATIVE display objects with SDF shaders applied.
-- No proxy — 100% compatible with widgets, transitions, physics, etc.
-- ─────────────────────────────────────────────

local _enabled = false

-- Content scale for smoothness calculation
local function getContentScale()
    if display.pixelWidth and display.actualContentWidth and display.actualContentWidth > 0 then
        return display.pixelWidth / display.actualContentWidth
    end
    return 1
end

local function smoothness(size)
    return 0.5 / (size * getContentScale())
end

local function isDisplayObject(v)
    return type(v) == "table" and v.insert ~= nil and v.numChildren ~= nil
end

function M.enable()
    if _enabled then return end

    -- Ensure SDF shaders are registered
    sdf.init()

    display._originalNewCircle      = display.newCircle
    display._originalNewRect        = display.newRect
    display._originalNewRoundedRect = display.newRoundedRect

    -- display.newCircle → native rect + sdf_circle shader
    display.newCircle = function(a, b, c, d)
        local parent, x, y, radius
        if isDisplayObject(a) then
            parent, x, y, radius = a, b, c, d
        else
            parent, x, y, radius = nil, a, b, c
        end

        local size = radius * 2
        local obj = display._originalNewRect(x, y, size, size)
        obj:setFillColor(1, 1, 1)
        obj.fill.effect = "filter.custom.sdf_circle"
        obj.fill.effect.radius = 0.95
        obj.fill.effect.smoothness = smoothness(size)

        if parent then parent:insert(obj) end
        return obj
    end

    -- display.newRoundedRect → native rect + sdf_rounded_rect shader
    display.newRoundedRect = function(a, b, c, d, e, f)
        local parent, x, y, w, h, cr
        if isDisplayObject(a) then
            parent, x, y, w, h, cr = a, b, c, d, e, f
        else
            parent, x, y, w, h, cr = nil, a, b, c, d, e
        end

        local obj = display._originalNewRect(x, y, w, h)
        obj:setFillColor(1, 1, 1)
        obj.fill.effect = "filter.custom.sdf_rounded_rect"
        obj.fill.effect.aspect = w / h
        obj.fill.effect.cornerRadius = cr / math.min(w, h)
        obj.fill.effect.smoothness = smoothness(math.min(w, h))

        if parent then parent:insert(obj) end
        return obj
    end

    -- display.newRect is NOT overridden — straight edges don't need SDF AA,
    -- and overriding it breaks widget internals (ScrollView, TableView, etc.)

    _enabled = true
end

function M.disable()
    if not _enabled then return end
    display.newCircle      = display._originalNewCircle
    display.newRoundedRect = display._originalNewRoundedRect
    _enabled = false
end

function M.isEnabled()
    return _enabled
end

return M
