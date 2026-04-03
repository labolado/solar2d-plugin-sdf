------------------------------------------------------------------------------
-- plugin.sdf — Interactive Demo
-- Tap ◀ ▶ to switch pages, tap SDF toggle to compare
-- sdf.enable() patches display.newCircle/newRect/newRoundedRect
------------------------------------------------------------------------------

local sdf = require("plugin.sdf")
local widget = require("widget")

display.setStatusBar(display.HiddenStatusBar)

local W = display.contentWidth
local H = display.contentHeight
local cx = W * 0.5

-- ═══════════════════════════════════════════════
-- State
-- ═══════════════════════════════════════════════
local pages = {}
local currentPage = 0
local scrollView
local sdfMode = true

-- ═══════════════════════════════════════════════
-- Top bar (60px)
-- ═══════════════════════════════════════════════
local BAR = 50

local topBar = display.newRect(cx, BAR * 0.5, W, BAR)
topBar:setFillColor(0.06, 0.06, 0.08)

local pageTitle = display.newText("", cx, BAR * 0.5, native.systemFontBold, 22)
pageTitle:setFillColor(1, 1, 0)

local navL = display.newText("◀", 30, BAR * 0.5, native.systemFontBold, 28)
navL:setFillColor(1, 1, 0, 0.8)
local navR = display.newText("▶", W - 30, BAR * 0.5, native.systemFontBold, 28)
navR:setFillColor(1, 1, 0, 0.8)

-- Toggle
local tgBg = display.newRoundedRect(W - 90, BAR * 0.5, 40, 22, 11)
local tgKnob = display.newCircle(W - 90, BAR * 0.5, 8)
tgKnob:setFillColor(1)
local tgLabel = display.newText("SDF", W - 150, BAR * 0.5, native.systemFontBold, 13)

local function updateToggle()
    if sdfMode then
        sdf.enable()
        tgBg:setFillColor(0.2, 0.7, 0.3)
        tgKnob.x = tgBg.x + 10
        tgLabel.text = "SDF ON"; tgLabel:setFillColor(0.3, 1, 0.5)
    else
        sdf.disable()
        tgBg:setFillColor(0.5, 0.3, 0.3)
        tgKnob.x = tgBg.x - 10
        tgLabel.text = "SDF OFF"; tgLabel:setFillColor(1, 0.4, 0.4)
    end
end

local function showPage(idx)
    transition.cancelAll()
    if scrollView then scrollView:removeSelf(); scrollView = nil end
    currentPage = idx
    pageTitle.text = idx .. "/" .. #pages .. "  " .. pages[idx].title

    -- Ensure SDF is disabled while building UI (widget safety)
    local wasEnabled = sdf.isEnabled()
    if wasEnabled then sdf.disable() end

    scrollView = widget.newScrollView({
        x = cx, y = BAR + (H - BAR) * 0.5,
        width = W, height = H - BAR,
        horizontalScrollDisabled = true,
        hideBackground = true,
    })

    -- Restore SDF state before building page content
    if wasEnabled then sdf.enable() end

    pages[idx].fn(scrollView)
end

navL:addEventListener("tap", function() if currentPage > 1 then showPage(currentPage - 1) end; return true end)
navR:addEventListener("tap", function() if currentPage < #pages then showPage(currentPage + 1) end; return true end)
tgBg:addEventListener("tap", function() sdfMode = not sdfMode; updateToggle(); showPage(currentPage); return true end)
updateToggle()

-- helper: insert SDF proxy or native into scrollview
local function ins(sv, obj)
    if obj._group then sv:insert(obj._group) else sv:insert(obj) end
end

-- ═══════════════════════════════════════════════
-- PAGE 1: All 15 Shapes
-- ═══════════════════════════════════════════════
pages[1] = { title = "Shapes", fn = function(sv)
    display.setDefault("background", 0.1, 0.1, 0.12)

    local R = 44
    local COL, ROW = 5, 3
    local padX, padY = 16, 10
    local cellW = (W - padX * 2) / COL
    local cellH = R * 2 + 36
    local startY = 0

    local shapes = {
        {"circle",    function(x,y) return sdf.newCircle(x,y,R) end},
        {"ellipse",   function(x,y) return sdf.newEllipse(x,y,R*1.8,R*1.1) end},
        {"rect",      function(x,y) return sdf.newRect(x,y,R*1.7,R*1.3) end},
        {"rndRect",   function(x,y) return sdf.newRoundedRect(x,y,R*1.7,R*1.3,10) end},
        {"hexagon",   function(x,y) return sdf.newHexagon(x,y,R) end},
        {"pentagon",  function(x,y) return sdf.newPentagon(x,y,R) end},
        {"octagon",   function(x,y) return sdf.newOctagon(x,y,R) end},
        {"triangle",  function(x,y) return sdf.newTriangle(x,y,R) end},
        {"diamond",   function(x,y) return sdf.newDiamond(x,y,R*1.1,R*1.5) end},
        {"cross",     function(x,y) return sdf.newCross(x,y,R) end},
        {"heart",     function(x,y) return sdf.newHeart(x,y,R) end},
        {"crescent",  function(x,y) return sdf.newCrescent(x,y,R,R*0.3) end},
        {"ring",      function(x,y) return sdf.newRing(x,y,R,R*0.5) end},
        {"star",      function(x,y) return sdf.newStar(x,y,R,5,R*0.4) end},
        {"pill",      function(x,y) return sdf.newPill(x,y,R*2,R*0.8) end},
    }

    for i, s in ipairs(shapes) do
        local col = (i - 1) % COL
        local row = math.floor((i - 1) / COL)
        local xx = padX + cellW * (col + 0.5)
        local yy = startY + cellH * row + R + 4
        local obj = s[2](xx, yy)
        obj:setFillColor(0.3, 0.7, 1)
        ins(sv, obj)
        display.newText(sv, s[1], xx, yy + R + 10, native.systemFont, 11):setFillColor(0.5, 0.5, 0.5)
    end

    -- Stroke + Colors section
    local secY = startY + cellH * 3 + 20
    display.newText(sv, "Stroke + Colors", cx, secY, native.systemFontBold, 18):setFillColor(0.8, 0.8, 0.8)

    local cols = {{1,0.3,0.3},{0.3,1,0.3},{0.3,0.5,1},{1,0.8,0.2},{1,0.3,0.8}}
    local sMakers = {
        function(x,y) return sdf.newCircle(x,y,36) end,
        function(x,y) return sdf.newRoundedRect(x,y,80,54,10) end,
        function(x,y) return sdf.newHexagon(x,y,36) end,
        function(x,y) return sdf.newStar(x,y,38,5,15) end,
        function(x,y) return sdf.newHeart(x,y,36) end,
    }
    for i = 1, 5 do
        local xx = padX + cellW * (i - 0.5)
        local obj = sMakers[i](xx, secY + 60)
        obj:setFillColor(cols[i][1], cols[i][2], cols[i][3])
        obj:setStrokeColor(1, 1, 1); obj.strokeWidth = 3
        ins(sv, obj)
    end

    -- Animation section
    local animY = secY + 140
    display.newText(sv, "Animation", cx, animY, native.systemFontBold, 18):setFillColor(0.8, 0.8, 0.8)

    local a1 = sdf.newStar(cx-180, animY+60, 32, 6, 13); a1:setFillColor(1,0.8,0.2); ins(sv, a1)
    transition.to(a1, {rotation=360, time=3000, iterations=-1})
    local a2 = sdf.newCircle(cx, animY+60, 28); a2:setFillColor(0.3,0.8,1); ins(sv, a2)
    transition.to(a2, {xScale=1.6, yScale=1.6, time=1200, iterations=-1, transition=easing.continuousLoop})
    local a3 = sdf.newHeart(cx+180, animY+60, 30); a3:setFillColor(1,0.3,0.3); ins(sv, a3)
    transition.to(a3, {alpha=0, time=1500, iterations=-1, transition=easing.continuousLoop})
end}

-- ═══════════════════════════════════════════════
-- PAGE 2: Shadow & Gradient
-- ═══════════════════════════════════════════════
pages[2] = { title = "Shadow & Gradient", fn = function(sv)
    local y = 0

    -- Light bg for shadow
    local fn = display._originalNewRect or display.newRect
    local bg = fn(cx, y + 160, W, 280); bg:setFillColor(0.88, 0.88, 0.88); sv:insert(bg)

    display.newText(sv, "Drop Shadow", cx, y + 4, native.systemFontBold, 18):setFillColor(0.3, 0.3, 0.3)

    local s1 = sdf.newCircle(120, y+90, 48); s1:setFillColor(1,1,1)
    s1.shadow={offsetX=5,offsetY=5,blur=12,color={0,0,0,0.35}}; ins(sv,s1)
    local s2 = sdf.newRoundedRect(350, y+90, 110,75,14); s2:setFillColor(1,1,1)
    s2.shadow={offsetX=5,offsetY=5,blur=12,color={0,0,0,0.35}}; ins(sv,s2)
    local s3 = sdf.newStar(570, y+90, 46, 5, 18); s3:setFillColor(1,1,1)
    s3.shadow={offsetX=5,offsetY=5,blur=12,color={0,0,0,0.35}}; ins(sv,s3)

    -- Shadow + Stroke
    display.newText(sv, "Shadow + Stroke", cx, y+195, native.systemFontBold, 18):setFillColor(0.3, 0.3, 0.3)

    local ss1 = sdf.newCircle(180, y+280, 52); ss1:setFillColor(1,1,1)
    ss1:setStrokeColor(0.2,0.5,0.9); ss1.strokeWidth=5
    ss1.shadow={offsetX=4,offsetY=4,blur=10,color={0,0,0,0.3}}; ins(sv,ss1)

    local ss2 = sdf.newRoundedRect(500, y+280, 130,85,18); ss2:setFillColor(1,1,1)
    ss2:setStrokeColor(0.8,0.2,0.4); ss2.strokeWidth=4
    ss2.shadow={offsetX=4,offsetY=4,blur=10,color={0,0,0,0.3}}; ins(sv,ss2)

    -- Gradient
    y = y + 370
    display.newText(sv, "Gradient Fill", cx, y, native.systemFontBold, 18):setFillColor(0.8, 0.8, 0.8)

    local g1 = sdf.newCircle(100,y+75,48); g1:setFillGradient({type="gradient",color1={1,0,0},color2={0,0,1},direction="down"}); ins(sv,g1)
    local g2 = sdf.newRoundedRect(290,y+75,100,70,12); g2:setFillGradient({type="gradient",color1={0,1,0},color2={1,1,0},direction="right"}); ins(sv,g2)
    local g3 = sdf.newHexagon(460,y+75,44); g3:setFillGradient({type="gradient",color1={1,0,1},color2={0,1,1},direction="down"})
    g3:setStrokeColor(1,1,1); g3.strokeWidth=2; ins(sv,g3)
    local g4 = sdf.newHeart(620,y+75,44); g4:setFillGradient({type="gradient",color1={1,0.2,0.2},color2={1,0.8,0.2},direction="down"}); ins(sv,g4)
end}

-- ═══════════════════════════════════════════════
-- PAGE 3: AA Comparison — toggle to see difference
-- ═══════════════════════════════════════════════
pages[3] = { title = "AA Compare", fn = function(sv)
    display.setDefault("background", 0.15, 0.15, 0.15)

    local y = 0
    display.newText(sv, "Toggle SDF switch to compare!", cx, y + 4, native.systemFontBold, 18):setFillColor(1, 0.8, 0.3)
    local mt = sdfMode and "SDF ON (smooth)" or "SDF OFF (native)"
    display.newText(sv, mt, cx, y + 26, native.systemFontBold, 16):setFillColor(sdfMode and 0.3 or 1, sdfMode and 1 or 0.4, 0.4)

    -- Circles
    y = 50
    display.newText(sv, "display.newCircle", 20, y, native.systemFontBold, 16):setFillColor(0.7, 0.7, 0.7)
    local sizes = {8, 16, 30, 50, 70}
    local xOff = 60
    for _, r in ipairs(sizes) do
        local c = display.newCircle(sv, xOff, y + 65, r)
        c:setFillColor(0.3, 0.7, 1)
        display.newText(sv, r.."px", xOff, y + 65 + r + 10, native.systemFont, 11):setFillColor(0.4, 0.4, 0.4)
        xOff = xOff + r * 2 + 24
    end

    -- Rounded rects
    y = 230
    display.newText(sv, "display.newRoundedRect", 20, y, native.systemFontBold, 16):setFillColor(0.7, 0.7, 0.7)
    local radii = {2, 8, 16, 32}
    xOff = 80
    for _, cr in ipairs(radii) do
        local rr = display.newRoundedRect(sv, xOff, y + 55, 100, 65, cr)
        rr:setFillColor(1, 0.5, 0.2)
        display.newText(sv, "r="..cr, xOff, y + 100, native.systemFont, 11):setFillColor(0.4, 0.4, 0.4)
        xOff = xOff + 140
    end

    -- Rects rotated
    y = 380
    display.newText(sv, "display.newRect rotated", 20, y, native.systemFontBold, 16):setFillColor(0.7, 0.7, 0.7)
    local angles = {10, 25, 45, 60}
    xOff = 80
    for _, a in ipairs(angles) do
        local r = display.newRect(sv, xOff, y + 60, 60, 60)
        r:setFillColor(0.3, 0.7, 1); r.rotation = a
        display.newText(sv, a.."°", xOff, y + 110, native.systemFont, 11):setFillColor(0.4, 0.4, 0.4)
        xOff = xOff + 140
    end

    -- Scaled
    y = 530
    display.newText(sv, "Scaled circles", 20, y, native.systemFontBold, 16):setFillColor(0.7, 0.7, 0.7)
    local scales = {0.5, 1, 2, 3}
    xOff = 80
    for _, s in ipairs(scales) do
        local c = display.newCircle(sv, xOff, y + 55, 22)
        c:setFillColor(0.8, 0.3, 1); c.xScale=s; c.yScale=s
        display.newText(sv, s.."x", xOff, y + 100, native.systemFont, 11):setFillColor(0.4, 0.4, 0.4)
        xOff = xOff + 140
    end
end}

-- ═══════════════════════════════════════════════
-- PAGE 4: Benchmark
-- ═══════════════════════════════════════════════
pages[4] = { title = "Benchmark", fn = function(sv)
    display.setDefault("background", 0.1, 0.1, 0.12)

    local origCircle = display._originalNewCircle or display.newCircle

    local resultText = display.newText(sv, "Tap a button to start", cx, 8, native.systemFont, 18)
    resultText:setFillColor(1, 1, 1)

    local benchGroup = display.newGroup()
    sv:insert(benchGroup)

    local function runBench(count, useSDF, label)
        while benchGroup.numChildren > 0 do benchGroup[1]:removeSelf() end
        collectgarbage("collect")
        resultText.text = "Creating " .. count .. " " .. label .. "..."
        timer.performWithDelay(100, function()
            local t0 = system.getTimer()
            if useSDF then
                for i = 1, count do
                    local obj = sdf.newCircle(math.random(20,W-20), math.random(220,700), math.random(4,16))
                    obj:setFillColor(math.random()*0.5+0.3, math.random()*0.5+0.3, 1)
                    benchGroup:insert(obj._group)
                end
            else
                for i = 1, count do
                    local obj = origCircle(benchGroup, math.random(20,W-20), math.random(220,700), math.random(4,16))
                    obj:setFillColor(math.random()*0.5+0.3, math.random()*0.5+0.3, 1)
                end
            end
            local ms = system.getTimer() - t0
            local frames, t1 = 0, system.getTimer()
            local function onFrame()
                frames = frames + 1
                if system.getTimer() - t1 > 3000 then
                    Runtime:removeEventListener("enterFrame", onFrame)
                    resultText.text = string.format("%s x%d — Create: %.0fms | FPS: %.1f", label, count, ms, frames/3)
                end
            end
            Runtime:addEventListener("enterFrame", onFrame)
        end)
    end

    local function btn(x, y, text, color, fn)
        local bg = display.newRoundedRect(sv, x, y, 220, 44, 10)
        bg:setFillColor(unpack(color))
        display.newText(sv, text, x, y, native.systemFontBold, 16):setFillColor(1)
        bg:addEventListener("tap", function() fn(); return true end)
    end

    local bx1, bx2 = cx * 0.55, cx * 1.45
    btn(bx1, 50,  "Native x200",  {0.5,0.3,0.2}, function() runBench(200,false,"Native") end)
    btn(bx2, 50,  "SDF x200",     {0.2,0.4,0.6}, function() runBench(200,true,"SDF") end)
    btn(bx1, 105, "Native x500",  {0.5,0.3,0.2}, function() runBench(500,false,"Native") end)
    btn(bx2, 105, "SDF x500",     {0.2,0.4,0.6}, function() runBench(500,true,"SDF") end)
    btn(bx1, 160, "Native x1000", {0.5,0.3,0.2}, function() runBench(1000,false,"Native") end)
    btn(bx2, 160, "SDF x1000",    {0.2,0.4,0.6}, function() runBench(1000,true,"SDF") end)
end}

-- ═══════════════════════════════════════════════
showPage(1)
