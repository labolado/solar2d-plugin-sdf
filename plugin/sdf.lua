------------------------------------------------------------------------------
-- plugin.sdf — SDF anti-aliased shapes for Solar2D
-- Usage:
--   local sdf = require("plugin.sdf")
--   sdf.enable()                        -- patch display.newCircle/newRect/newRoundedRect
--   -- OR use directly:
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
-- ─────────────────────────────────────────────

local _enabled = false

local function isDisplayObject(v)
    return type(v) == "table" and v.insert ~= nil and v.numChildren ~= nil
end

function M.enable()
    if _enabled then return end

    display._originalNewCircle      = display.newCircle
    display._originalNewRect        = display.newRect
    display._originalNewRoundedRect = display.newRoundedRect

    display.newCircle = function(a, b, c, d)
        local parent, x, y, radius
        if isDisplayObject(a) then
            parent, x, y, radius = a, b, c, d
        else
            parent, x, y, radius = nil, a, b, c
        end
        local obj = sdf.newCircle(x, y, radius)
        if parent then parent:insert(obj._group) end
        return obj
    end

    display.newRect = function(a, b, c, d, e)
        local parent, x, y, w, h
        if isDisplayObject(a) then
            parent, x, y, w, h = a, b, c, d, e
        else
            parent, x, y, w, h = nil, a, b, c, d
        end
        local obj = sdf.newRect(x, y, w, h)
        if parent then parent:insert(obj._group) end
        return obj
    end

    display.newRoundedRect = function(a, b, c, d, e, f)
        local parent, x, y, w, h, cr
        if isDisplayObject(a) then
            parent, x, y, w, h, cr = a, b, c, d, e, f
        else
            parent, x, y, w, h, cr = nil, a, b, c, d, e
        end
        local obj = sdf.newRoundedRect(x, y, w, h, cr)
        if parent then parent:insert(obj._group) end
        return obj
    end

    _enabled = true
end

function M.disable()
    if not _enabled then return end
    display.newCircle      = display._originalNewCircle
    display.newRect        = display._originalNewRect
    display.newRoundedRect = display._originalNewRoundedRect
    _enabled = false
end

function M.isEnabled()
    return _enabled
end

return M
