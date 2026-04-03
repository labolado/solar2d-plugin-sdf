------------------------------------------------------------------------------
-- plugin.sdf Example
-- Clone this repo and open with Solar2D Simulator to run
------------------------------------------------------------------------------

local sdf = require("plugin.sdf")

display.setStatusBar(display.HiddenStatusBar)
display.setDefault("background", 0.1, 0.1, 0.12)

local cx, cy = display.contentCenterX, display.contentCenterY

-- Title
local title = display.newText("plugin.sdf — SDF Shapes", cx, 40, native.systemFontBold, 32)
title:setFillColor(1, 1, 0)

-- ═══════════════════════════════════════════════
-- Section 1: Basic shapes (direct API)
-- ═══════════════════════════════════════════════
local lbl1 = display.newText("Direct API — perfect anti-aliasing", cx, 90, native.systemFont, 20)
lbl1:setFillColor(0.6, 0.6, 0.6)

local c = sdf.newCircle(110, 180, 55)
c:setFillColor(0.3, 0.7, 1)

local r = sdf.newRect(290, 180, 100, 80)
r:setFillColor(0.3, 1, 0.5)

local rr = sdf.newRoundedRect(470, 180, 110, 80, 20)
rr:setFillColor(1, 0.6, 0.2)

local hex = sdf.newHexagon(110, 320, 50)
hex:setFillColor(0.5, 0.3, 1)

local star = sdf.newStar(290, 320, 55, 5, 22)
star:setFillColor(1, 0.3, 0.5)

local heart = sdf.newHeart(470, 320, 50)
heart:setFillColor(1, 0.3, 0.3)

-- ═══════════════════════════════════════════════
-- Section 2: Stroke + Shadow
-- ═══════════════════════════════════════════════
local lbl2 = display.newText("Stroke + Shadow", cx, 410, native.systemFont, 20)
lbl2:setFillColor(0.6, 0.6, 0.6)

local cs = sdf.newCircle(160, 510, 60)
cs:setFillColor(1, 1, 1)
cs:setStrokeColor(0, 0.5, 1)
cs.strokeWidth = 6
cs.shadow = {offsetX = 5, offsetY = 5, blur = 12, color = {0, 0, 0, 0.4}}

local rs = sdf.newRoundedRect(430, 510, 150, 90, 20)
rs:setFillColor(1, 1, 1)
rs:setStrokeColor(0.8, 0.2, 0.4)
rs.strokeWidth = 5
rs.shadow = {offsetX = 5, offsetY = 5, blur = 12, color = {0, 0, 0, 0.4}}

-- ═══════════════════════════════════════════════
-- Section 3: enable() — transparent replacement
-- ═══════════════════════════════════════════════
local lbl3 = display.newText("sdf.enable() — standard API, SDF rendering", cx, 610, native.systemFont, 20)
lbl3:setFillColor(0.6, 0.6, 0.6)

sdf.enable()

-- These use standard display.* API but render with SDF
local dc = display.newCircle(110, 710, 55)
dc:setFillColor(0, 0.8, 0.8)

local dr = display.newRect(290, 710, 100, 80)
dr:setFillColor(0.9, 0.9, 0.2)
dr.rotation = 15

local drr = display.newRoundedRect(470, 710, 110, 80, 20)
drr:setFillColor(0.8, 0.4, 1)
drr.strokeWidth = 4
drr:setStrokeColor(1, 1, 1)

-- ═══════════════════════════════════════════════
-- Section 4: Transition animation
-- ═══════════════════════════════════════════════
local lbl4 = display.newText("Animation", cx, 800, native.systemFont, 20)
lbl4:setFillColor(0.6, 0.6, 0.6)

local anim = sdf.newStar(cx, 880, 45, 6, 18)
anim:setFillColor(1, 0.8, 0.2)
transition.to(anim, {rotation = 360, time = 4000, iterations = -1})
transition.to(anim, {xScale = 1.5, yScale = 1.5, time = 1500, iterations = -1, transition = easing.continuousLoop})
