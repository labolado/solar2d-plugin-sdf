------------------------------------------------------------------------------
-- plugin.sdf — Interactive Demo
------------------------------------------------------------------------------

local sdf = require("plugin.sdf")
local widget = require("widget")

display.setStatusBar(display.HiddenStatusBar)

local W = display.contentWidth
local H = display.contentHeight
local cx = W * 0.5

local pages = {}
local currentPage = 0
local scrollView
local sdfMode = true

-- ═══════════════════════════════════════════════
-- Top bar (70px, bigger toggle)
-- ═══════════════════════════════════════════════
local BAR = 70

local topBar = display.newRect(cx, BAR * 0.5, W, BAR)
topBar:setFillColor(0.06, 0.06, 0.08)

local pageTitle = display.newText("", cx, BAR * 0.5, native.systemFontBold, 24)
pageTitle:setFillColor(1, 1, 0)

local navL = display.newText("◀", 35, BAR * 0.5, native.systemFontBold, 32)
navL:setFillColor(1, 1, 0, 0.8)
local navR = display.newText("▶", W - 35, BAR * 0.5, native.systemFontBold, 32)
navR:setFillColor(1, 1, 0, 0.8)

-- Big toggle button (easy to tap)
local tgBtn = display.newRoundedRect(W - 100, BAR * 0.5, 140, 44, 22)
local tgLabel = display.newText("SDF ON", W - 100, BAR * 0.5, native.systemFontBold, 20)

local function updateToggle()
    if sdfMode then
        sdf.enable()
        tgBtn:setFillColor(0.15, 0.55, 0.25)
        tgLabel.text = "SDF ON"
        tgLabel:setFillColor(1, 1, 1)
    else
        sdf.disable()
        tgBtn:setFillColor(0.55, 0.2, 0.2)
        tgLabel.text = "SDF OFF"
        tgLabel:setFillColor(1, 1, 1)
    end
end

-- Helper: insert SDF proxy or native object into parent
local function ins(parent, obj)
    if obj._group then parent:insert(obj._group) else parent:insert(obj) end
end

-- Helper: create shape (SDF or native based on sdfMode), insert into parent
-- Always creates without parent arg, then inserts manually → consistent positioning
local function makeCircle(parent, x, y, r)
    local obj
    if sdfMode then
        obj = sdf.newCircle(x, y, r)
        parent:insert(obj._group)
    else
        obj = display.newCircle(x, y, r)
        parent:insert(obj)
    end
    return obj
end

local function makeRect(parent, x, y, w, h)
    local obj
    if sdfMode then
        obj = sdf.newRect(x, y, w, h)
        parent:insert(obj._group)
    else
        obj = display.newRect(x, y, w, h)
        parent:insert(obj)
    end
    return obj
end

local function makeRoundedRect(parent, x, y, w, h, cr)
    local obj
    if sdfMode then
        obj = sdf.newRoundedRect(x, y, w, h, cr)
        parent:insert(obj._group)
    else
        obj = display.newRoundedRect(x, y, w, h, cr)
        parent:insert(obj)
    end
    return obj
end

local function showPage(idx)
    transition.cancelAll()
    if scrollView then scrollView:removeSelf(); scrollView = nil end
    currentPage = idx
    pageTitle.text = idx .. "/" .. #pages .. "  " .. pages[idx].title

    -- Disable SDF while creating widget
    local wasEnabled = sdf.isEnabled()
    if wasEnabled then sdf.disable() end

    scrollView = widget.newScrollView({
        x = cx, y = BAR + (H - BAR) * 0.5,
        width = W, height = H - BAR,
        topPadding = 0,
        horizontalScrollDisabled = true,
        hideBackground = true,
    })

    if wasEnabled then sdf.enable() end
    pages[idx].fn(scrollView)
end

navL:addEventListener("tap", function() if currentPage > 1 then showPage(currentPage - 1) end; return true end)
navR:addEventListener("tap", function() if currentPage < #pages then showPage(currentPage + 1) end; return true end)
tgBtn:addEventListener("tap", function() sdfMode = not sdfMode; updateToggle(); showPage(currentPage); return true end)
updateToggle()

-- ═══════════════════════════════════════════════
-- PAGE 1: All 15 Shapes (always SDF direct API)
-- ═══════════════════════════════════════════════
pages[1] = { title = "Shapes", fn = function(sv)
    display.setDefault("background", 0.1, 0.1, 0.12)

    local R = 44
    local COL = 5
    local padX = 16
    local cellW = (W - padX * 2) / COL
    local cellH = R * 2 + 36
    local startY = R + 4

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
        local yy = startY + cellH * row
        local obj = s[2](xx, yy)
        obj:setFillColor(0.3, 0.7, 1)
        ins(sv, obj)
        display.newText(sv, s[1], xx, yy + R + 10, native.systemFont, 11):setFillColor(0.5, 0.5, 0.5)
    end

    -- Stroke + Colors
    local secY = startY + cellH * 3 + 10
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
        local obj = sMakers[i](xx, secY + 55)
        obj:setFillColor(cols[i][1], cols[i][2], cols[i][3])
        obj:setStrokeColor(1, 1, 1); obj.strokeWidth = 3
        ins(sv, obj)
    end

    -- Animation
    local animY = secY + 130
    display.newText(sv, "Animation", cx, animY, native.systemFontBold, 18):setFillColor(0.8, 0.8, 0.8)
    local a1 = sdf.newStar(cx-180,animY+55,32,6,13); a1:setFillColor(1,0.8,0.2); ins(sv,a1)
    transition.to(a1, {rotation=360, time=3000, iterations=-1})
    local a2 = sdf.newCircle(cx,animY+55,28); a2:setFillColor(0.3,0.8,1); ins(sv,a2)
    transition.to(a2, {xScale=1.6, yScale=1.6, time=1200, iterations=-1, transition=easing.continuousLoop})
    local a3 = sdf.newHeart(cx+180,animY+55,30); a3:setFillColor(1,0.3,0.3); ins(sv,a3)
    transition.to(a3, {alpha=0, time=1500, iterations=-1, transition=easing.continuousLoop})
end}

-- ═══════════════════════════════════════════════
-- PAGE 2: Shadow & Gradient (always SDF direct API)
-- ═══════════════════════════════════════════════
pages[2] = { title = "Shadow & Gradient", fn = function(sv)
    local y = 0
    local fn = display._originalNewRect or display.newRect
    local bg = fn(cx, 155, W, 260); bg:setFillColor(0.88, 0.88, 0.88); sv:insert(bg)

    display.newText(sv, "Drop Shadow", cx, y + 4, native.systemFontBold, 18):setFillColor(0.3, 0.3, 0.3)

    local s1 = sdf.newCircle(120,y+80,48); s1:setFillColor(1,1,1)
    s1.shadow={offsetX=5,offsetY=5,blur=12,color={0,0,0,0.35}}; ins(sv,s1)
    local s2 = sdf.newRoundedRect(350,y+80,110,75,14); s2:setFillColor(1,1,1)
    s2.shadow={offsetX=5,offsetY=5,blur=12,color={0,0,0,0.35}}; ins(sv,s2)
    local s3 = sdf.newStar(570,y+80,46,5,18); s3:setFillColor(1,1,1)
    s3.shadow={offsetX=5,offsetY=5,blur=12,color={0,0,0,0.35}}; ins(sv,s3)

    display.newText(sv, "Shadow + Stroke", cx, y+180, native.systemFontBold, 18):setFillColor(0.3, 0.3, 0.3)
    local ss1 = sdf.newCircle(180,y+260,52); ss1:setFillColor(1,1,1)
    ss1:setStrokeColor(0.2,0.5,0.9); ss1.strokeWidth=5
    ss1.shadow={offsetX=4,offsetY=4,blur=10,color={0,0,0,0.3}}; ins(sv,ss1)
    local ss2 = sdf.newRoundedRect(500,y+260,130,85,18); ss2:setFillColor(1,1,1)
    ss2:setStrokeColor(0.8,0.2,0.4); ss2.strokeWidth=4
    ss2.shadow={offsetX=4,offsetY=4,blur=10,color={0,0,0,0.3}}; ins(sv,ss2)

    y = 350
    display.newText(sv, "Gradient Fill", cx, y, native.systemFontBold, 18):setFillColor(0.8, 0.8, 0.8)
    local g1 = sdf.newCircle(100,y+70,48); g1:setFillGradient({type="gradient",color1={1,0,0},color2={0,0,1},direction="down"}); ins(sv,g1)
    local g2 = sdf.newRoundedRect(290,y+70,100,70,12); g2:setFillGradient({type="gradient",color1={0,1,0},color2={1,1,0},direction="right"}); ins(sv,g2)
    local g3 = sdf.newHexagon(460,y+70,44); g3:setFillGradient({type="gradient",color1={1,0,1},color2={0,1,1},direction="down"})
    g3:setStrokeColor(1,1,1); g3.strokeWidth=2; ins(sv,g3)
    local g4 = sdf.newHeart(620,y+70,44); g4:setFillGradient({type="gradient",color1={1,0.2,0.2},color2={1,0.8,0.2},direction="down"}); ins(sv,g4)
end}

-- ═══════════════════════════════════════════════
-- PAGE 3: AA Comparison — toggle SDF ON/OFF
-- Uses makeCircle/makeRect/makeRoundedRect which create without
-- parent arg then manually insert → consistent positioning
-- ═══════════════════════════════════════════════
pages[3] = { title = "AA Compare", fn = function(sv)
    display.setDefault("background", 0.15, 0.15, 0.15)

    local y = 4
    local mt = sdfMode and "SDF ON — smooth edges" or "SDF OFF — native (aliased)"
    local col = sdfMode and {0.3, 1, 0.5} or {1, 0.4, 0.4}
    local modeLabel = display.newText(sv, mt, cx, y, native.systemFontBold, 20)
    modeLabel:setFillColor(unpack(col))

    -- Small circles (aliasing most visible here)
    y = 40
    display.newText(sv, "Small Circles (zoom in to see edges)", 10, y, native.systemFontBold, 14):setFillColor(0.7,0.7,0.7)

    local sizes = {3, 5, 8, 12, 18, 25, 35, 50}
    local xOff = 30
    for _, r in ipairs(sizes) do
        local c = makeCircle(sv, xOff + r, y + 40 + r, r)
        c:setFillColor(0.3, 0.7, 1)
        display.newText(sv, r, xOff + r, y + 42 + r * 2 + 8, native.systemFont, 10):setFillColor(0.4,0.4,0.4)
        xOff = xOff + r * 2 + 16
    end

    -- Medium circles row
    y = 160
    display.newText(sv, "Medium Circles", 10, y, native.systemFontBold, 14):setFillColor(0.7,0.7,0.7)
    local medSizes = {40, 60, 80}
    xOff = 80
    for _, r in ipairs(medSizes) do
        local c = makeCircle(sv, xOff, y + 30 + r, r)
        c:setFillColor(0.3, 0.7, 1)
        display.newText(sv, r.."px", xOff, y + 32 + r*2 + 8, native.systemFont, 11):setFillColor(0.4,0.4,0.4)
        xOff = xOff + r * 2 + 40
    end

    -- Rounded rects
    y = 370
    display.newText(sv, "Rounded Rects", 10, y, native.systemFontBold, 14):setFillColor(0.7,0.7,0.7)
    local crs = {2, 6, 14, 30}
    xOff = 80
    for _, cr in ipairs(crs) do
        local rr = makeRoundedRect(sv, xOff, y + 55, 100, 65, cr)
        rr:setFillColor(1, 0.5, 0.2)
        display.newText(sv, "r="..cr, xOff, y + 100, native.systemFont, 11):setFillColor(0.4,0.4,0.4)
        xOff = xOff + 140
    end

    -- Rotated rects
    y = 490
    display.newText(sv, "Rotated Rects (diagonal AA)", 10, y, native.systemFontBold, 14):setFillColor(0.7,0.7,0.7)
    local angles = {10, 25, 45, 60}
    xOff = 80
    for _, a in ipairs(angles) do
        local r = makeRect(sv, xOff, y + 55, 60, 60)
        r:setFillColor(0.3, 0.7, 1)
        r.rotation = a
        display.newText(sv, a.."°", xOff, y + 105, native.systemFont, 11):setFillColor(0.4,0.4,0.4)
        xOff = xOff + 145
    end

    -- 1px lines comparison (native lines have bad aliasing)
    y = 620
    display.newText(sv, "Thin Lines at Angles", 10, y, native.systemFontBold, 14):setFillColor(0.7,0.7,0.7)
    for i = 0, 8 do
        local angle = math.rad(i * 5 + 2)  -- 2° to 42°
        local len = 200
        local x1 = cx - len * math.cos(angle)
        local y1 = y + 50 + i * 16
        local x2 = cx + len * math.cos(angle)
        local y2 = y + 50 + i * 16 + len * math.sin(angle) * 0.3
        local line = display.newLine(sv, x1, y1, x2, y2)
        line:setStrokeColor(1, 1, 1)
        line.strokeWidth = 1
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
                    local obj = sdf.newCircle(math.random(20,W-20), math.random(200,700), math.random(4,16))
                    obj:setFillColor(math.random()*0.5+0.3, math.random()*0.5+0.3, 1)
                    benchGroup:insert(obj._group)
                end
            else
                for i = 1, count do
                    local obj = origCircle(math.random(20,W-20), math.random(200,700), math.random(4,16))
                    obj:setFillColor(math.random()*0.5+0.3, math.random()*0.5+0.3, 1)
                    benchGroup:insert(obj)
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
