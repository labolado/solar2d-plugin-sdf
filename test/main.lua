------------------------------------------------------------------------------
-- SDF Shapes — Full Test Suite
-- P0: alpha/color/AA  P1: stroke/shapes/proxy  P2: shadow/gradient/transition
-- P3: edge cases/perf
-- Navigation: swipe left/right or tap arrows to switch pages
------------------------------------------------------------------------------

package.path = "../?.lua;../?/?.lua;" .. package.path
local sdf = require("plugin.sdf")

display.setStatusBar(display.HiddenStatusBar)

local cx, cy = display.contentCenterX, display.contentCenterY
local W, H = display.actualContentWidth, display.actualContentHeight
local safeTop = display.safeScreenOriginY or 0
local safeH = display.safeActualContentHeight or H

-- ═══════════════════════════════════════════════
-- Test framework
-- ═══════════════════════════════════════════════
local pages = {}
local currentPage = 0
local pageGroup

local pass, fail, total = 0, 0, 0
local function check(name, cond)
    total = total + 1
    if cond then
        pass = pass + 1
        print("PASS: " .. name)
    else
        fail = fail + 1
        print("FAIL: " .. name)
    end
    return cond
end

-- Screenshot directory
local screenshotDir = system.pathForFile("", system.TemporaryDirectory)
local autoScreenshot = true  -- set false for manual navigation

local activeTimers = {}
local activeListeners = {}

local function addTimer(t) activeTimers[#activeTimers+1] = t end
local function addListener(fn) activeListeners[#activeListeners+1] = fn end

local function cleanupPage()
    for _, t in ipairs(activeTimers) do timer.cancel(t) end
    for _, fn in ipairs(activeListeners) do Runtime:removeEventListener("enterFrame", fn) end
    activeTimers = {}
    activeListeners = {}
    transition.cancelAll()
end

local function showPage(idx)
    cleanupPage()
    if pageGroup then pageGroup:removeSelf() end
    pageGroup = display.newGroup()
    currentPage = idx
    pages[idx](pageGroup)

    -- Page indicator
    local label = display.newText(pageGroup,
        idx .. "/" .. #pages, cx, safeTop + 12, native.systemFontBold, 13)
    label:setFillColor(0.5, 0.5, 0.5)

    -- Auto screenshot after 1 frame render
    timer.performWithDelay(100, function()
        local filename = "sdf_test_page_" .. idx .. ".png"
        display.save(display.currentStage, {
            filename = filename,
            baseDir = system.TemporaryDirectory,
            isFullResolution = true,
        })
        print("SCREENSHOT: " .. system.pathForFile(filename, system.TemporaryDirectory))
    end)
end

local function nextPage()
    if currentPage < #pages then showPage(currentPage + 1) end
end
local function prevPage()
    if currentPage > 1 then showPage(currentPage - 1) end
end

-- Nav arrows
local arrowLeft = display.newText("<", 20, safeTop + 12, native.systemFontBold, 24)
arrowLeft:setFillColor(1, 1, 0)
arrowLeft:addEventListener("tap", function() prevPage(); return true end)
local arrowRight = display.newText(">", W - 20, safeTop + 12, native.systemFontBold, 24)
arrowRight:setFillColor(1, 1, 0)
arrowRight:addEventListener("tap", function() nextPage(); return true end)

-- ═══════════════════════════════════════════════
-- PAGE 1: P0 — Alpha & Transparency
-- ═══════════════════════════════════════════════
pages[1] = function(g)
    local title = display.newText(g, "P0: Alpha & Transparency", cx, safeTop + 35, native.systemFontBold, 16)
    title:setFillColor(1, 1, 0)

    -- Colored background strips to verify transparency
    local bgR = display.newRect(g, cx - 80, 100, 120, 350)
    bgR:setFillColor(0.8, 0.2, 0.2)
    local bgG = display.newRect(g, cx, 100, 40, 350)
    bgG:setFillColor(0.2, 0.8, 0.2)
    local bgB = display.newRect(g, cx + 80, 100, 120, 350)
    bgB:setFillColor(0.2, 0.2, 0.8)

    -- Test 1: SDF circle on colored bg — edges must blend, no white fringe
    local c1 = sdf.newCircle(cx, 100, 40)
    c1:setFillColor(1, 1, 1, 1)
    g:insert(c1._group)
    local t1 = display.newText(g, "white on color bg\n(no white fringe)", cx, 150, native.systemFont, 10)
    t1:setFillColor(1, 1, 1)

    -- Test 2: alpha = 0.5
    local c2 = sdf.newCircle(cx, 200, 40)
    c2:setFillColor(1, 1, 0)
    c2.alpha = 0.5
    g:insert(c2._group)
    local t2 = display.newText(g, "alpha=0.5 (see-through)", cx, 248, native.systemFont, 10)
    t2:setFillColor(1, 1, 1)

    check("alpha 0.5 readable", math.abs(c2.alpha - 0.5) < 0.01)

    -- Test 3: alpha = 0
    local c3 = sdf.newCircle(cx - 60, 300, 30)
    c3:setFillColor(1, 0, 0)
    c3.alpha = 0
    g:insert(c3._group)
    local t3a = display.newText(g, "alpha=0\n(invisible)", cx - 60, 340, native.systemFont, 9)
    t3a:setFillColor(0.7, 0.7, 0.7)

    check("alpha 0 invisible", c3.alpha == 0)

    -- Test 4: alpha = 1
    local c4 = sdf.newCircle(cx + 60, 300, 30)
    c4:setFillColor(0, 1, 0)
    c4.alpha = 1
    g:insert(c4._group)
    local t4 = display.newText(g, "alpha=1\n(opaque)", cx + 60, 340, native.systemFont, 9)
    t4:setFillColor(0.7, 0.7, 0.7)

    check("alpha 1 opaque", c4.alpha == 1)

    -- Test 5: dynamic color change
    local c5 = sdf.newCircle(cx, 400, 30)
    c5:setFillColor(1, 0, 0)
    g:insert(c5._group)
    local colorIdx = 0
    local colors = {{1,0,0},{0,1,0},{0,0,1},{1,1,0},{1,0,1},{0,1,1}}
    addTimer(timer.performWithDelay(500, function()
        colorIdx = colorIdx % #colors + 1
        if c5 and c5._group then c5:setFillColor(unpack(colors[colorIdx])) end
    end, 0))
    local t5 = display.newText(g, "color cycling (0.5s)", cx, 440, native.systemFont, 10)
    t5:setFillColor(0.7, 0.7, 0.7)
end

-- ═══════════════════════════════════════════════
-- PAGE 2: P0 — AA Quality Comparison
-- ═══════════════════════════════════════════════
pages[2] = function(g)
    local title = display.newText(g, "P0: AA Quality — SDF vs Native", cx, safeTop + 35, native.systemFontBold, 16)
    title:setFillColor(1, 1, 0)

    display.setDefault("background", 0.15, 0.15, 0.15)

    local y = 70

    -- Row 1: Side by side circles (various sizes)
    local sizes = {5, 10, 20, 35}
    local lNat = display.newText(g, "Native", 30, y, native.systemFont, 10)
    lNat:setFillColor(1, 0.5, 0.5)
    local lSdf = display.newText(g, "SDF", 30, y + 55, native.systemFont, 10)
    lSdf:setFillColor(0.5, 1, 0.5)

    local xOff = 75
    for i, r in ipairs(sizes) do
        local nc = display.newCircle(g, xOff, y, r)
        nc:setFillColor(0.3, 0.7, 1)
        local sc = sdf.newCircle(xOff, y + 55, r)
        sc:setFillColor(0.3, 0.7, 1)
        g:insert(sc._group)
        local sl = display.newText(g, r.."px", xOff, y + 55 + r + 8, native.systemFont, 8)
        sl:setFillColor(0.5, 0.5, 0.5)
        xOff = xOff + r * 2 + 18
    end

    -- Row 2: Rotated rects (test diagonal AA)
    y = 210
    local lbl2 = display.newText(g, "Rotated 45° — diagonal AA", cx, y - 15, native.systemFontBold, 12)
    lbl2:setFillColor(1, 1, 1)

    local natR = display.newRect(g, cx - 70, y + 40, 60, 60)
    natR:setFillColor(0.3, 0.7, 1)
    natR.rotation = 45
    local natL = display.newText(g, "Native", cx - 70, y + 85, native.systemFont, 10)
    natL:setFillColor(1, 0.5, 0.5)

    local sdfR = sdf.newRect(cx + 70, y + 40, 60, 60)
    sdfR:setFillColor(0.3, 0.7, 1)
    sdfR.rotation = 45
    g:insert(sdfR._group)
    local sdfL = display.newText(g, "SDF", cx + 70, y + 85, native.systemFont, 10)
    sdfL:setFillColor(0.5, 1, 0.5)

    -- Row 3: Scale test
    y = 310
    local lbl3 = display.newText(g, "Scale: 0.5x / 1x / 2x / 3x", cx, y - 15, native.systemFontBold, 12)
    lbl3:setFillColor(1, 1, 1)

    local scales = {0.5, 1, 2, 3}
    xOff = 40
    for i, s in ipairs(scales) do
        local sc = sdf.newCircle(xOff + 35, y + 30, 15)
        sc:setFillColor(1, 0.6, 0.2)
        sc.xScale = s; sc.yScale = s
        g:insert(sc._group)
        local sl = display.newText(g, s.."x", xOff + 35, y + 65, native.systemFont, 9)
        sl:setFillColor(0.5, 0.5, 0.5)
        xOff = xOff + 75
    end

    -- Row 4: Extreme sizes
    y = 400
    local lbl4 = display.newText(g, "Extreme: r=3 / r=80", cx, y - 10, native.systemFont, 11)
    lbl4:setFillColor(0.7, 0.7, 0.7)
    local tiny = sdf.newCircle(cx - 80, y + 25, 3)
    tiny:setFillColor(1, 0, 0)
    g:insert(tiny._group)
    local tinyL = display.newText(g, "r=3", cx - 80, y + 40, native.systemFont, 9)
    tinyL:setFillColor(0.5, 0.5, 0.5)
    local big = sdf.newCircle(cx + 50, y + 25, 40)
    big:setFillColor(0.3, 0.7, 1, 0.7)
    g:insert(big._group)
    local bigL = display.newText(g, "r=80", cx + 50, y + 70, native.systemFont, 9)
    bigL:setFillColor(0.5, 0.5, 0.5)
end

-- ═══════════════════════════════════════════════
-- PAGE 3: P1 — All 14 Shapes
-- ═══════════════════════════════════════════════
pages[3] = function(g)
    local title = display.newText(g, "P1: All Shapes", cx, safeTop + 35, native.systemFontBold, 16)
    title:setFillColor(1, 1, 0)

    display.setDefault("background", 0.12, 0.12, 0.14)

    local COL = 4
    local R = 28
    local SX, SY = 48, 70
    local DX, DY = 72, 78

    local function pos(col, row) return SX + col * DX, SY + row * DY end
    local function lbl(x, y, text)
        local t = display.newText(g, text, x, y + R + 8, native.systemFont, 8)
        t:setFillColor(0.5, 0.5, 0.5)
    end
    local function col(s) s:setFillColor(0.3, 0.7, 1) end

    local x, y
    local shapes = {}

    -- Row 0
    x,y = pos(0,0); shapes.circle = sdf.newCircle(x,y,R); col(shapes.circle); lbl(x,y,"circle")
    x,y = pos(1,0); shapes.ellipse = sdf.newEllipse(x,y,R*2,R*1.2); col(shapes.ellipse); lbl(x,y,"ellipse")
    x,y = pos(2,0); shapes.rect = sdf.newRect(x,y,R*2,R*1.4); col(shapes.rect); lbl(x,y,"rect")
    x,y = pos(3,0); shapes.rrect = sdf.newRoundedRect(x,y,R*2,R*1.4,8); col(shapes.rrect); lbl(x,y,"rndRect")

    -- Row 1
    x,y = pos(0,1); shapes.hex = sdf.newHexagon(x,y,R); col(shapes.hex); lbl(x,y,"hexagon")
    x,y = pos(1,1); shapes.pent = sdf.newPentagon(x,y,R); col(shapes.pent); lbl(x,y,"pentagon")
    x,y = pos(2,1); shapes.oct = sdf.newOctagon(x,y,R); col(shapes.oct); lbl(x,y,"octagon")
    x,y = pos(3,1); shapes.tri = sdf.newTriangle(x,y,R); col(shapes.tri); lbl(x,y,"triangle")

    -- Row 2
    x,y = pos(0,2); shapes.dia = sdf.newDiamond(x,y,R*1.5,R*2); col(shapes.dia); lbl(x,y,"diamond")
    x,y = pos(1,2); shapes.star5 = sdf.newStar(x,y,R,5,R*0.4); col(shapes.star5); lbl(x,y,"star5")
    x,y = pos(2,2); shapes.heart = sdf.newHeart(x,y,R); col(shapes.heart); lbl(x,y,"heart")
    x,y = pos(3,2); shapes.cresc = sdf.newCrescent(x,y,R,R*0.3); col(shapes.cresc); lbl(x,y,"crescent")

    -- Row 3
    x,y = pos(0,3); shapes.ring = sdf.newRing(x,y,R,R*0.6); col(shapes.ring); lbl(x,y,"ring")
    x,y = pos(1,3); shapes.cross = sdf.newCross(x,y,R); col(shapes.cross); lbl(x,y,"cross")

    -- Verify all created
    local count = 0
    for k, v in pairs(shapes) do
        g:insert(v._group)
        count = count + 1
    end
    check("14 shapes created", count == 14)

    -- Row 4: Edge cases
    y = SY + DY * 4
    local lbl4 = display.newText(g, "Edge: r=0 / corner=0 / star(3pt,8pt)", cx, y - 5, native.systemFont, 9)
    lbl4:setFillColor(0.6, 0.6, 0.6)
    g:insert(lbl4)

    local ok1, err1 = pcall(function()
        local ex, ey = pos(0, 4.3)
        local z = sdf.newCircle(ex, ey, 1); col(z); g:insert(z._group)
    end)
    if not ok1 then print("radius=1 error: " .. tostring(err1)) end
    check("radius=1 no crash", ok1)

    local ok2 = pcall(function()
        local ex, ey = pos(1, 4.3)
        local z = sdf.newRoundedRect(ex, ey, 40, 30, 0); col(z); g:insert(z._group)
    end)
    check("cornerRadius=0 no crash", ok2)

    local ok3 = pcall(function()
        local ex, ey = pos(2, 4.3)
        local z = sdf.newStar(ex, ey, R, 3, R*0.3); col(z); g:insert(z._group)
    end)
    check("star 3pt no crash", ok3)

    local ok4 = pcall(function()
        local ex, ey = pos(3, 4.3)
        local z = sdf.newStar(ex, ey, R, 8, R*0.35); col(z); g:insert(z._group)
    end)
    check("star 8pt no crash", ok4)
end

-- ═══════════════════════════════════════════════
-- PAGE 4: P1 — Stroke
-- ═══════════════════════════════════════════════
pages[4] = function(g)
    local title = display.newText(g, "P1: Stroke", cx, safeTop + 35, native.systemFontBold, 16)
    title:setFillColor(1, 1, 0)

    display.setDefault("background", 0.12, 0.12, 0.14)

    local y = 75

    -- Stroke widths: 1, 2, 5, 10, 20
    local widths = {1, 2, 5, 10, 20}
    local xOff = 30
    for i, sw in ipairs(widths) do
        local c = sdf.newCircle(xOff + 30, y, 22)
        c:setFillColor(0.3, 0.7, 1)
        c:setStrokeColor(1, 1, 0)
        c.strokeWidth = sw
        g:insert(c._group)
        local l = display.newText(g, "sw="..sw, xOff + 30, y + 38, native.systemFont, 9)
        l:setFillColor(0.6, 0.6, 0.6)
        xOff = xOff + 60
    end

    -- Stroke color independent of fill
    y = 160
    local lbl1 = display.newText(g, "Stroke color != fill color", cx, y - 15, native.systemFont, 11)
    lbl1:setFillColor(0.8, 0.8, 0.8)

    local s1 = sdf.newCircle(cx - 80, y + 30, 30)
    s1:setFillColor(1, 0, 0); s1:setStrokeColor(0, 1, 0); s1.strokeWidth = 5
    g:insert(s1._group)
    local s1l = display.newText(g, "red+green", cx - 80, y + 68, native.systemFont, 9)
    s1l:setFillColor(0.5, 0.5, 0.5)

    local s2 = sdf.newRoundedRect(cx + 80, y + 30, 60, 50, 10)
    s2:setFillColor(0, 0, 1); s2:setStrokeColor(1, 1, 0); s2.strokeWidth = 4
    g:insert(s2._group)
    local s2l = display.newText(g, "blue+yellow", cx + 80, y + 68, native.systemFont, 9)
    s2l:setFillColor(0.5, 0.5, 0.5)

    -- Stroke only (transparent fill)
    y = 260
    local lbl2 = display.newText(g, "Stroke only (transparent fill)", cx, y - 15, native.systemFont, 11)
    lbl2:setFillColor(0.8, 0.8, 0.8)

    local shapes2 = {
        {"circle", sdf.newCircle(cx - 100, y + 35, 25)},
        {"hex", sdf.newHexagon(cx, y + 35, 25)},
        {"star", sdf.newStar(cx + 100, y + 35, 25, 5, 10)},
    }
    for _, pair in ipairs(shapes2) do
        pair[2]:setFillColor(0, 0, 0, 0) -- transparent fill
        pair[2]:setStrokeColor(0, 1, 1)
        pair[2].strokeWidth = 3
        g:insert(pair[2]._group)
        local l = display.newText(g, pair[1], pair[2].x, y + 68, native.systemFont, 9)
        l:setFillColor(0.5, 0.5, 0.5)
    end

    -- Dynamic stroke change
    y = 350
    local lbl3 = display.newText(g, "Dynamic: strokeWidth animating", cx, y - 15, native.systemFont, 11)
    lbl3:setFillColor(0.8, 0.8, 0.8)

    local dynC = sdf.newCircle(cx, y + 40, 30)
    dynC:setFillColor(0.2, 0.5, 0.8)
    dynC:setStrokeColor(1, 0.5, 0)
    dynC.strokeWidth = 1
    g:insert(dynC._group)

    local elapsed = 0
    local function onFrame()
        elapsed = elapsed + 1/60
        if dynC and dynC._group then
            local sw = 1 + 9 * (math.sin(elapsed * 2) + 1) * 0.5 -- 1..10
            dynC.strokeWidth = sw
        end
    end
    Runtime:addEventListener("enterFrame", onFrame)
    addListener(onFrame)
end

-- ═══════════════════════════════════════════════
-- PAGE 5: P1 — Proxy Properties
-- ═══════════════════════════════════════════════
pages[5] = function(g)
    local title = display.newText(g, "P1: Proxy System", cx, safeTop + 35, native.systemFontBold, 16)
    title:setFillColor(1, 1, 0)

    display.setDefault("background", 0.12, 0.12, 0.14)

    local y = 70
    local results = {}

    local function logResult(x, yy, name, ok)
        local color = ok and {0, 1, 0} or {1, 0.3, 0.3}
        local prefix = ok and "OK" or "FAIL"
        local t = display.newText(g, prefix .. " " .. name, x, yy, native.systemFont, 11)
        t.anchorX = 0
        t:setFillColor(unpack(color))
        check(name, ok)
    end

    -- x, y read/write
    local c = sdf.newCircle(100, y + 20, 15)
    c:setFillColor(0.3, 0.7, 1)
    g:insert(c._group)
    c.x = 50; c.y = y + 20
    logResult(80, y + 20, "x,y write+read", math.abs(c.x - 50) < 1 and math.abs(c.y - (y+20)) < 1)
    y = y + 25

    -- rotation
    local r = sdf.newRect(200, y + 10, 30, 30)
    r:setFillColor(1, 0.5, 0.2)
    r.rotation = 45
    g:insert(r._group)
    logResult(10, y + 10, "rotation=45", math.abs(r.rotation - 45) < 1)
    y = y + 25

    -- xScale, yScale
    local s = sdf.newCircle(200, y + 10, 15)
    s:setFillColor(0.5, 1, 0.3)
    s.xScale = 2; s.yScale = 0.5
    g:insert(s._group)
    logResult(10, y + 10, "xScale=2 yScale=0.5", math.abs(s.xScale - 2) < 0.1)
    y = y + 25

    -- alpha
    local a = sdf.newCircle(200, y + 10, 15)
    a:setFillColor(1, 1, 0)
    a.alpha = 0.3
    g:insert(a._group)
    logResult(10, y + 10, "alpha=0.3", math.abs(a.alpha - 0.3) < 0.05)
    y = y + 25

    -- isVisible
    local v = sdf.newCircle(200, y + 10, 15)
    v:setFillColor(1, 0, 0)
    v.isVisible = false
    g:insert(v._group)
    logResult(10, y + 10, "isVisible=false", v.isVisible == false)
    y = y + 25

    -- width/height
    local wh = sdf.newRect(200, y + 10, 60, 40)
    wh:setFillColor(0.7, 0.3, 1)
    g:insert(wh._group)
    logResult(10, y + 10, "width=60 height=40", wh.width == 60 and wh.height == 40)
    y = y + 25

    -- contentWidth/contentHeight
    logResult(10, y + 10, "contentWidth>0", (wh.contentWidth or 0) > 0)
    y = y + 25

    -- removeSelf
    local rm = sdf.newCircle(200, y + 10, 15)
    rm:setFillColor(1, 0, 0)
    g:insert(rm._group)
    local rmOk = pcall(function() rm:removeSelf() end)
    logResult(10, y + 10, "removeSelf no crash", rmOk)
    y = y + 25

    -- access after removeSelf
    local postOk = pcall(function() local _ = rm.x end)
    logResult(10, y + 10, "post-remove access no crash", postOk)
    y = y + 25

    -- addEventListener tap
    local tapC = sdf.newCircle(cx, y + 30, 30)
    tapC:setFillColor(0.2, 0.6, 0.2)
    g:insert(tapC._group)
    local tapOk = pcall(function()
        tapC:addEventListener("tap", function() return true end)
    end)
    logResult(10, y + 30, "addEventListener tap", tapOk)
    local tapL = display.newText(g, "tap the green circle", cx, y + 65, native.systemFont, 10)
    tapL:setFillColor(0.5, 0.5, 0.5)
    y = y + 50

    -- toFront/toBack
    local tf = sdf.newCircle(200, y + 20, 15)
    tf:setFillColor(1, 0.5, 0)
    g:insert(tf._group)
    local tfOk = pcall(function() tf:toFront(); tf:toBack() end)
    logResult(10, y + 20, "toFront/toBack", tfOk)
end

-- ═══════════════════════════════════════════════
-- PAGE 6: P2 — Shadow
-- ═══════════════════════════════════════════════
pages[6] = function(g)
    local title = display.newText(g, "P2: Shadow", cx, safeTop + 35, native.systemFontBold, 16)
    title:setFillColor(1, 1, 0)

    display.setDefault("background", 0.85, 0.85, 0.85)

    local y = 80

    -- Basic shadow
    local c1 = sdf.newCircle(cx - 80, y, 35)
    c1:setFillColor(1, 1, 1)
    c1.shadow = {offsetX = 4, offsetY = 4, blur = 8, color = {0, 0, 0, 0.4}}
    g:insert(c1._group)
    local l1 = display.newText(g, "basic", cx - 80, y + 45, native.systemFont, 10)
    l1:setFillColor(0.3, 0.3, 0.3)

    -- Shadow + stroke
    local c2 = sdf.newRoundedRect(cx + 80, y, 70, 50, 10)
    c2:setFillColor(1, 1, 1)
    c2:setStrokeColor(0.2, 0.5, 0.8)
    c2.strokeWidth = 3
    c2.shadow = {offsetX = 3, offsetY = 5, blur = 10, color = {0, 0, 0, 0.3}}
    g:insert(c2._group)
    local l2 = display.newText(g, "shadow+stroke", cx + 80, y + 45, native.systemFont, 10)
    l2:setFillColor(0.3, 0.3, 0.3)

    -- Different offsets
    y = 190
    local offsets = {{-6,-6}, {6,-6}, {0,8}, {-8,0}}
    local labels = {"NW", "NE", "S", "W"}
    for i, off in ipairs(offsets) do
        local xx = 40 + (i-1) * 80
        local s = sdf.newCircle(xx, y, 25)
        s:setFillColor(1, 1, 1)
        s.shadow = {offsetX = off[1], offsetY = off[2], blur = 6, color = {0,0,0,0.4}}
        g:insert(s._group)
        local l = display.newText(g, labels[i], xx, y + 35, native.systemFont, 9)
        l:setFillColor(0.3, 0.3, 0.3)
    end

    -- Remove shadow
    y = 280
    local removable = sdf.newCircle(cx, y, 35)
    removable:setFillColor(0.9, 0.9, 1)
    removable.shadow = {offsetX = 4, offsetY = 4, blur = 8, color = {0,0,0,0.4}}
    g:insert(removable._group)
    local removeL = display.newText(g, "shadow removes in 2s", cx, y + 45, native.systemFont, 10)
    removeL:setFillColor(0.3, 0.3, 0.3)
    timer.performWithDelay(2000, function()
        removable.shadow = nil
        removeL.text = "shadow removed"
    end)

    -- Various shapes with shadow
    y = 370
    local lbl = display.newText(g, "Various shapes + shadow", cx, y - 15, native.systemFont, 11)
    lbl:setFillColor(0.3, 0.3, 0.3)

    local hex = sdf.newHexagon(cx - 100, y + 30, 28)
    hex:setFillColor(0.9, 0.95, 1)
    hex.shadow = {offsetX = 3, offsetY = 3, blur = 6, color = {0,0,0,0.3}}
    g:insert(hex._group)

    local star = sdf.newStar(cx, y + 30, 28, 5, 12)
    star:setFillColor(1, 0.95, 0.9)
    star.shadow = {offsetX = 3, offsetY = 3, blur = 6, color = {0,0,0,0.3}}
    g:insert(star._group)

    local tri = sdf.newTriangle(cx + 100, y + 30, 28)
    tri:setFillColor(0.9, 1, 0.9)
    tri.shadow = {offsetX = 3, offsetY = 3, blur = 6, color = {0,0,0,0.3}}
    g:insert(tri._group)
end

-- ═══════════════════════════════════════════════
-- PAGE 7: P2 — Gradient + Transition
-- ═══════════════════════════════════════════════
pages[7] = function(g)
    local title = display.newText(g, "P2: Gradient & Transition", cx, safeTop + 35, native.systemFontBold, 16)
    title:setFillColor(1, 1, 0)

    display.setDefault("background", 0.12, 0.12, 0.14)

    local y = 80

    -- Gradient fills
    local lbl1 = display.newText(g, "Gradient fills", cx, y - 10, native.systemFont, 12)
    lbl1:setFillColor(0.8, 0.8, 0.8)

    local g1 = sdf.newCircle(cx - 90, y + 40, 35)
    g1:setFillGradient({
        type = "gradient",
        color1 = {1, 0, 0}, color2 = {0, 0, 1},
        direction = "down",
    })
    g:insert(g1._group)
    local l1 = display.newText(g, "down", cx - 90, y + 82, native.systemFont, 9)
    l1:setFillColor(0.5, 0.5, 0.5)

    local g2 = sdf.newRoundedRect(cx + 90, y + 40, 70, 60, 12)
    g2:setFillGradient({
        type = "gradient",
        color1 = {0, 1, 0}, color2 = {1, 1, 0},
        direction = "right",
    })
    g:insert(g2._group)
    local l2 = display.newText(g, "right", cx + 90, y + 82, native.systemFont, 9)
    l2:setFillColor(0.5, 0.5, 0.5)

    -- Gradient + stroke
    local g3 = sdf.newHexagon(cx, y + 40, 32)
    g3:setFillGradient({
        type = "gradient",
        color1 = {1, 0, 1}, color2 = {0, 1, 1},
        direction = "down",
    })
    g3:setStrokeColor(1, 1, 1)
    g3.strokeWidth = 2
    g:insert(g3._group)
    local l3 = display.newText(g, "grad+stroke", cx, y + 82, native.systemFont, 9)
    l3:setFillColor(0.5, 0.5, 0.5)

    -- Transitions
    y = 210
    local lbl2 = display.newText(g, "Transitions", cx, y - 10, native.systemFont, 12)
    lbl2:setFillColor(0.8, 0.8, 0.8)

    -- Move
    local t1 = sdf.newCircle(40, y + 30, 20)
    t1:setFillColor(1, 0.4, 0.4)
    g:insert(t1._group)
    transition.to(t1, {x = W - 40, time = 2000, iterations = -1, transition = easing.inOutSine})
    local tl1 = display.newText(g, "position", cx, y + 55, native.systemFont, 9)
    tl1:setFillColor(0.5, 0.5, 0.5)

    -- Fade
    y = y + 70
    local t2 = sdf.newCircle(cx, y + 15, 25)
    t2:setFillColor(0.4, 1, 0.4)
    g:insert(t2._group)
    transition.to(t2, {alpha = 0, time = 1500, iterations = -1, transition = easing.continuousLoop})
    local tl2 = display.newText(g, "alpha fade", cx, y + 45, native.systemFont, 9)
    tl2:setFillColor(0.5, 0.5, 0.5)

    -- Scale
    y = y + 70
    local t3 = sdf.newStar(cx, y + 15, 20, 5, 8)
    t3:setFillColor(0.4, 0.4, 1)
    g:insert(t3._group)
    transition.to(t3, {xScale = 2.5, yScale = 2.5, time = 1500, iterations = -1, transition = easing.continuousLoop})
    local tl3 = display.newText(g, "scale", cx, y + 45, native.systemFont, 9)
    tl3:setFillColor(0.5, 0.5, 0.5)

    -- Rotation
    y = y + 70
    local t4 = sdf.newRect(cx, y + 15, 40, 40)
    t4:setFillColor(1, 0.8, 0.2)
    g:insert(t4._group)
    transition.to(t4, {rotation = 360, time = 3000, iterations = -1})
    local tl4 = display.newText(g, "rotation", cx, y + 45, native.systemFont, 9)
    tl4:setFillColor(0.5, 0.5, 0.5)
end

-- ═══════════════════════════════════════════════
-- PAGE 8: P2 — Group/Container/Mask/Snapshot
-- ═══════════════════════════════════════════════
pages[8] = function(g)
    local title = display.newText(g, "P2: Group/Container/Snapshot", cx, safeTop + 35, native.systemFontBold, 16)
    title:setFillColor(1, 1, 0)

    display.setDefault("background", 0.12, 0.12, 0.14)

    local y = 80

    -- Group rotation
    local lbl1 = display.newText(g, "Group rotate 30°", cx - 80, y - 12, native.systemFont, 11)
    lbl1:setFillColor(0.8, 0.8, 0.8)

    local grp = display.newGroup()
    g:insert(grp)
    grp.x, grp.y = cx - 80, y + 40
    local gc1 = sdf.newCircle(0, -15, 18); gc1:setFillColor(1, 0.3, 0.3); grp:insert(gc1._group)
    local gc2 = sdf.newCircle(0, 15, 18); gc2:setFillColor(0.3, 0.3, 1); grp:insert(gc2._group)
    grp.rotation = 30

    -- Group scale
    local lbl1b = display.newText(g, "Group scale 1.5x", cx + 80, y - 12, native.systemFont, 11)
    lbl1b:setFillColor(0.8, 0.8, 0.8)

    local grp2 = display.newGroup()
    g:insert(grp2)
    grp2.x, grp2.y = cx + 80, y + 40
    local gc3 = sdf.newHexagon(0, 0, 20); gc3:setFillColor(0.3, 1, 0.3); grp2:insert(gc3._group)
    grp2.xScale = 1.5; grp2.yScale = 1.5

    -- Container clipping
    y = 180
    local lbl2 = display.newText(g, "Container clipping", cx, y - 12, native.systemFont, 11)
    lbl2:setFillColor(0.8, 0.8, 0.8)

    local container = display.newContainer(g, 100, 60)
    container.x, container.y = cx, y + 35
    local cc = sdf.newCircle(0, 0, 45)
    cc:setFillColor(1, 0.6, 0.2)
    container:insert(cc._group)
    -- Circle is 90px but container is 100x60, so top/bottom clipped

    -- Border to show container bounds
    local border = display.newRect(g, cx, y + 35, 100, 60)
    border:setFillColor(0, 0, 0, 0)
    border.strokeWidth = 1
    border.stroke = {1, 1, 1, 0.5}

    -- Snapshot
    y = 280
    local lbl3 = display.newText(g, "Snapshot capture", cx, y - 12, native.systemFont, 11)
    lbl3:setFillColor(0.8, 0.8, 0.8)

    local snap = display.newSnapshot(g, 120, 80)
    snap.x, snap.y = cx, y + 45
    local sc1 = sdf.newCircle(-20, 0, 25); sc1:setFillColor(1, 0, 0, 0.8)
    local sc2 = sdf.newCircle(20, 0, 25); sc2:setFillColor(0, 0, 1, 0.8)
    snap.group:insert(sc1._group)
    snap.group:insert(sc2._group)
    snap:invalidate()
end

-- ═══════════════════════════════════════════════
-- PAGE 9: P3 — Performance
-- ═══════════════════════════════════════════════
pages[9] = function(g)
    local title = display.newText(g, "P3: Performance", cx, safeTop + 35, native.systemFontBold, 16)
    title:setFillColor(1, 1, 0)

    display.setDefault("background", 0.12, 0.12, 0.14)

    local resultText = display.newText(g, "Tap a button to run", cx, 70, native.systemFont, 12)
    resultText:setFillColor(1, 1, 1)

    local perfGroup = display.newGroup()
    g:insert(perfGroup)

    local function runPerfTest(count, useSDF, label)
        -- Clean previous
        while perfGroup.numChildren > 0 do perfGroup[1]:removeSelf() end
        collectgarbage("collect")

        resultText.text = "Creating " .. count .. " " .. label .. "..."

        timer.performWithDelay(50, function()
            local startTime = system.getTimer()

            if useSDF then
                for i = 1, count do
                    local c = sdf.newCircle(
                        math.random(20, W - 20),
                        math.random(120, H - 40),
                        math.random(5, 15)
                    )
                    c:setFillColor(math.random() * 0.5 + 0.3, math.random() * 0.5 + 0.3, 1)
                    perfGroup:insert(c._group)
                end
            else
                for i = 1, count do
                    local c = display.newCircle(
                        perfGroup,
                        math.random(20, W - 20),
                        math.random(120, H - 40),
                        math.random(5, 15)
                    )
                    c:setFillColor(math.random() * 0.5 + 0.3, math.random() * 0.5 + 0.3, 1)
                end
            end

            local createTime = system.getTimer() - startTime

            -- Measure FPS for 3 seconds
            local frames = 0
            local fpsStart = system.getTimer()
            local function onFrame()
                frames = frames + 1
                if system.getTimer() - fpsStart > 3000 then
                    Runtime:removeEventListener("enterFrame", onFrame)
                    local fps = frames / 3
                    resultText.text = string.format(
                        "%s x%d: Create %.0fms | FPS %.1f",
                        label, count, createTime, fps
                    )
                end
            end
            Runtime:addEventListener("enterFrame", onFrame)
        end)
    end

    -- Buttons
    local buttons = {
        {"SDF x100",    function() runPerfTest(100, true, "SDF") end},
        {"Native x100", function() runPerfTest(100, false, "Native") end},
        {"SDF x500",    function() runPerfTest(500, true, "SDF") end},
        {"Native x500", function() runPerfTest(500, false, "Native") end},
        {"SDF x1000",   function() runPerfTest(1000, true, "SDF") end},
        {"Nat x1000",   function() runPerfTest(1000, false, "Native") end},
    }

    for i, btn in ipairs(buttons) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local bx = cx - 75 + col * 150
        local by = 105 + row * 40

        local bg = display.newRoundedRect(g, bx, by, 130, 30, 8)
        bg:setFillColor(0.2, 0.4, 0.6)
        local bl = display.newText(g, btn[1], bx, by, native.systemFontBold, 12)
        bl:setFillColor(1, 1, 1)
        bg:addEventListener("tap", function() btn[2](); return true end)
    end
end

-- ═══════════════════════════════════════════════
-- PAGE 10: P3 — Edge Cases & Init
-- ═══════════════════════════════════════════════
pages[10] = function(g)
    local title = display.newText(g, "P3: Edge Cases", cx, safeTop + 35, native.systemFontBold, 16)
    title:setFillColor(1, 1, 0)

    display.setDefault("background", 0.12, 0.12, 0.14)

    local y = 70

    local function logResult(name, ok)
        local color = ok and {0, 1, 0} or {1, 0.3, 0.3}
        local prefix = ok and "OK" or "FAIL"
        local t = display.newText(g, prefix .. " " .. name, 15, y, native.systemFont, 12)
        t.anchorX = 0
        t:setFillColor(unpack(color))
        y = y + 22
        check(name, ok)
    end

    -- Double init
    local ok1 = pcall(function() sdf.init(); sdf.init() end)
    logResult("Double init() no crash", ok1)

    -- Zero/tiny dimensions
    local ok2 = pcall(function()
        local z = sdf.newRect(100, 400, 0.1, 0.1)
        z:removeSelf()
    end)
    logResult("Near-zero rect no crash", ok2)

    -- removeSelf then access
    local ok3 = pcall(function()
        local c = sdf.newCircle(100, 400, 20)
        c:removeSelf()
        local _ = c.x
        local _ = c.width
    end)
    logResult("Post-remove property access", ok3)

    -- removeSelf twice
    local ok4 = pcall(function()
        local c = sdf.newCircle(100, 400, 20)
        c:removeSelf()
        c:removeSelf()
    end)
    logResult("Double removeSelf no crash", ok4)

    -- Star with same params reuses shader
    local ok5 = pcall(function()
        local s1 = sdf.newStar(100, 400, 20, 5, 8)
        local s2 = sdf.newStar(150, 400, 30, 5, 12)
        s1:removeSelf()
        s2:removeSelf()
    end)
    logResult("Star same points reuses shader", ok5)

    -- Ring with zero angles
    local ok6 = pcall(function()
        local r = sdf.newRing(100, 400, 30, 10, 0, 0)
        r:removeSelf()
    end)
    logResult("Ring angle=0 no crash", ok6)

    -- Negative offset crescent
    local ok7 = pcall(function()
        local c = sdf.newCrescent(100, 400, 30, -10)
        c:removeSelf()
    end)
    logResult("Crescent negative offset", ok7)

    -- Large radius
    local ok8 = pcall(function()
        local c = sdf.newCircle(100, 400, 500)
        c:removeSelf()
    end)
    logResult("Radius=500 no crash", ok8)

    -- setFillColor after removeSelf
    local ok9 = pcall(function()
        local c = sdf.newCircle(100, 400, 20)
        c:removeSelf()
        c:setFillColor(1, 0, 0)
    end)
    logResult("setFillColor after remove", ok9)

    -- Summary
    y = y + 20
    local summary = display.newText(g,
        string.format("Total: %d pass / %d fail / %d tests", pass, fail, total),
        cx, y, native.systemFontBold, 14
    )
    summary:setFillColor(fail == 0 and 0 or 1, fail == 0 and 1 or 0, 0)
end

-- ═══════════════════════════════════════════════
-- Start
-- ═══════════════════════════════════════════════
showPage(1)
print(string.format("SDF Test Suite: %d pages loaded", #pages))

-- Auto-advance through all pages for screenshots
if autoScreenshot then
    for i = 2, #pages do
        timer.performWithDelay(800 * (i - 1), function()
            showPage(i)
            if i == #pages then
                timer.performWithDelay(500, function()
                    print("========================================")
                    print(string.format("TOTAL: %d pass / %d fail / %d tests", pass, fail, total))
                    print("========================================")
                    print("ALL SCREENSHOTS SAVED to: " .. screenshotDir)
                end)
            end
        end)
    end
end
