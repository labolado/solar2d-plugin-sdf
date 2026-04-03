------------------------------------------------------------------------------
-- plugin.sdf — Interactive Demo
-- Scroll, tap ◀ ▶ to switch pages, tap SDF toggle to compare
------------------------------------------------------------------------------

local sdf = require("plugin.sdf")
local widget = require("widget")

display.setStatusBar(display.HiddenStatusBar)
display.setDefault("background", 0.1, 0.1, 0.12)

local cx = display.contentCenterX
local W = display.contentWidth
local H = display.contentHeight

-- ═══════════════════════════════════════════════
-- State
-- ═══════════════════════════════════════════════
local pages = {}
local currentPage = 0
local scrollView
local sdfMode = true

local NAV_HEIGHT = 80

-- ═══════════════════════════════════════════════
-- Top bar
-- ═══════════════════════════════════════════════
local topBar = display.newRect(cx, NAV_HEIGHT / 2, W, NAV_HEIGHT)
topBar:setFillColor(0.08, 0.08, 0.1)

local pageTitle = display.newText("", cx, NAV_HEIGHT / 2, native.systemFontBold, 28)
pageTitle:setFillColor(1, 1, 0)

local navL = display.newText("◀", 40, NAV_HEIGHT / 2, native.systemFontBold, 36)
navL:setFillColor(1, 1, 0, 0.8)
local navR = display.newText("▶", W - 40, NAV_HEIGHT / 2, native.systemFontBold, 36)
navR:setFillColor(1, 1, 0, 0.8)

-- Toggle
local toggleBg = display.newRoundedRect(W - 130, NAV_HEIGHT / 2, 50, 28, 14)
local toggleKnob = display.newCircle(W - 130, NAV_HEIGHT / 2, 11)
toggleKnob:setFillColor(1)
local toggleLabel = display.newText("SDF", W - 190, NAV_HEIGHT / 2, native.systemFontBold, 16)

local function updateToggle()
    if sdfMode then
        sdf.enable()
        toggleBg:setFillColor(0.2, 0.7, 0.3)
        toggleKnob.x = toggleBg.x + 13
        toggleLabel.text = "SDF ON"
        toggleLabel:setFillColor(0.3, 1, 0.5)
    else
        sdf.disable()
        toggleBg:setFillColor(0.5, 0.3, 0.3)
        toggleKnob.x = toggleBg.x - 13
        toggleLabel.text = "SDF OFF"
        toggleLabel:setFillColor(1, 0.4, 0.4)
    end
end

local function showPage(idx)
    transition.cancelAll()
    if scrollView then scrollView:removeSelf(); scrollView = nil end
    currentPage = idx
    pageTitle.text = idx .. "/" .. #pages .. "  " .. pages[idx].title

    scrollView = widget.newScrollView({
        x = cx, y = NAV_HEIGHT + (H - NAV_HEIGHT) / 2,
        width = W, height = H - NAV_HEIGHT,
        horizontalScrollDisabled = true,
        hideBackground = true,
    })
    pages[idx].fn(scrollView)
end

navL:addEventListener("tap", function() if currentPage > 1 then showPage(currentPage - 1) end; return true end)
navR:addEventListener("tap", function() if currentPage < #pages then showPage(currentPage + 1) end; return true end)
toggleBg:addEventListener("tap", function()
    sdfMode = not sdfMode
    updateToggle()
    showPage(currentPage)
    return true
end)
updateToggle()

-- ═══════════════════════════════════════════════
-- PAGE 1: All 15 Shapes (always SDF, direct API)
-- ═══════════════════════════════════════════════
pages[1] = { title = "Shapes", fn = function(sv)
    local R = 60
    local SX, SY = 130, 60
    local DX, DY = 250, 210

    local function pos(c, r) return SX + c * DX, SY + r * DY end
    local function lbl(x, y, t)
        display.newText(sv, t, x, y + R + 16, native.systemFontBold, 18):setFillColor(0.5, 0.5, 0.5)
    end
    local function add(obj, x, y, name)
        obj:setFillColor(0.3, 0.7, 1); sv:insert(obj._group); lbl(x, y, name)
    end

    local x, y
    x,y=pos(0,0); add(sdf.newCircle(x,y,R),x,y,"circle")
    x,y=pos(1,0); add(sdf.newEllipse(x,y,R*2.2,R*1.3),x,y,"ellipse")
    x,y=pos(2,0); add(sdf.newRect(x,y,R*2,R*1.5),x,y,"rect")
    x,y=pos(0,1); add(sdf.newRoundedRect(x,y,R*2,R*1.5,14),x,y,"roundedRect")
    x,y=pos(1,1); add(sdf.newHexagon(x,y,R),x,y,"hexagon")
    x,y=pos(2,1); add(sdf.newPentagon(x,y,R),x,y,"pentagon")
    x,y=pos(0,2); add(sdf.newOctagon(x,y,R),x,y,"octagon")
    x,y=pos(1,2); add(sdf.newTriangle(x,y,R),x,y,"triangle")
    x,y=pos(2,2); add(sdf.newDiamond(x,y,R*1.4,R*1.8),x,y,"diamond")
    x,y=pos(0,3); add(sdf.newCross(x,y,R),x,y,"cross")
    x,y=pos(1,3); add(sdf.newHeart(x,y,R),x,y,"heart")
    x,y=pos(2,3); add(sdf.newCrescent(x,y,R,R*0.3),x,y,"crescent")
    x,y=pos(0,4); add(sdf.newRing(x,y,R,R*0.5),x,y,"ring")
    x,y=pos(1,4); add(sdf.newStar(x,y,R,5,R*0.4),x,y,"star")
    x,y=pos(2,4); add(sdf.newPill(x,y,R*2.5,R),x,y,"pill")

    -- Stroke + Colors
    local y6 = SY + DY * 5 + 20
    display.newText(sv, "Stroke + Colors", cx, y6, native.systemFontBold, 24):setFillColor(0.8, 0.8, 0.8)
    local cols = {{1,0.3,0.3},{0.3,1,0.3},{0.3,0.5,1},{1,0.8,0.2},{1,0.3,0.8}}
    local makers = {
        function(xx,yy) return sdf.newCircle(xx,yy,50) end,
        function(xx,yy) return sdf.newRoundedRect(xx,yy,110,70,14) end,
        function(xx,yy) return sdf.newHexagon(xx,yy,50) end,
        function(xx,yy) return sdf.newStar(xx,yy,52,5,20) end,
        function(xx,yy) return sdf.newHeart(xx,yy,50) end,
    }
    for i = 1, 5 do
        local obj = makers[i](80 + (i-1)*150, y6 + 80)
        obj:setFillColor(cols[i][1], cols[i][2], cols[i][3])
        obj:setStrokeColor(1, 1, 1); obj.strokeWidth = 4
        sv:insert(obj._group)
    end

    -- Animation
    local y7 = y6 + 210
    display.newText(sv, "Animation", cx, y7, native.systemFontBold, 24):setFillColor(0.8, 0.8, 0.8)
    local a1 = sdf.newStar(cx-200,y7+80,45,6,18); a1:setFillColor(1,0.8,0.2); sv:insert(a1._group)
    transition.to(a1, {rotation=360, time=3000, iterations=-1})
    local a2 = sdf.newCircle(cx,y7+80,40); a2:setFillColor(0.3,0.8,1); sv:insert(a2._group)
    transition.to(a2, {xScale=1.8, yScale=1.8, time=1200, iterations=-1, transition=easing.continuousLoop})
    local a3 = sdf.newHeart(cx+200,y7+80,42); a3:setFillColor(1,0.3,0.3); sv:insert(a3._group)
    transition.to(a3, {alpha=0, time=1500, iterations=-1, transition=easing.continuousLoop})
end}

-- ═══════════════════════════════════════════════
-- PAGE 2: Shadow & Gradient (always SDF, direct API)
-- ═══════════════════════════════════════════════
pages[2] = { title = "Shadow & Gradient", fn = function(sv)
    local y = 40
    display.newText(sv, "Drop Shadow", cx, y, native.systemFontBold, 24):setFillColor(0.3, 0.3, 0.3)
    local bg1 = display.newRect(sv, cx, y + 200, W, 350); bg1:setFillColor(0.88, 0.88, 0.88); bg1:toBack()

    local sdefs = {{sdf.newCircle,{150,y+130,65}},{sdf.newRoundedRect,{400,y+130,140,100,18}},{sdf.newStar,{650,y+130,60,5,24}}}
    for _, d in ipairs(sdefs) do
        local obj = d[1](unpack(d[2])); obj:setFillColor(1,1,1)
        obj.shadow = {offsetX=6, offsetY=6, blur=14, color={0,0,0,0.35}}
        sv:insert(obj._group)
    end

    y = 340
    display.newText(sv, "Shadow + Stroke", cx, y, native.systemFontBold, 24):setFillColor(0.3, 0.3, 0.3)
    local ss1 = sdf.newCircle(200,y+100,70); ss1:setFillColor(1,1,1); ss1:setStrokeColor(0.2,0.5,0.9); ss1.strokeWidth=6
    ss1.shadow = {offsetX=5,offsetY=5,blur=12,color={0,0,0,0.3}}; sv:insert(ss1._group)
    local ss2 = sdf.newRoundedRect(550,y+100,160,110,22); ss2:setFillColor(1,1,1); ss2:setStrokeColor(0.8,0.2,0.4); ss2.strokeWidth=5
    ss2.shadow = {offsetX=5,offsetY=5,blur=12,color={0,0,0,0.3}}; sv:insert(ss2._group)

    y = 570
    display.newText(sv, "Gradient Fill", cx, y, native.systemFontBold, 24):setFillColor(0.8, 0.8, 0.8)
    local gd1 = sdf.newCircle(130,y+100,60); gd1:setFillGradient({type="gradient",color1={1,0,0},color2={0,0,1},direction="down"}); sv:insert(gd1._group)
    local gd2 = sdf.newRoundedRect(350,y+100,130,90,16); gd2:setFillGradient({type="gradient",color1={0,1,0},color2={1,1,0},direction="right"}); sv:insert(gd2._group)
    local gd3 = sdf.newHexagon(550,y+100,58); gd3:setFillGradient({type="gradient",color1={1,0,1},color2={0,1,1},direction="down"}); gd3:setStrokeColor(1,1,1); gd3.strokeWidth=3; sv:insert(gd3._group)
    local gd4 = sdf.newHeart(700,y+100,58); gd4:setFillGradient({type="gradient",color1={1,0.2,0.2},color2={1,0.8,0.2},direction="down"}); sv:insert(gd4._group)
end}

-- ═══════════════════════════════════════════════
-- PAGE 3: AA Comparison — toggle SDF on/off
-- Uses sdf.enable() which now returns NATIVE objects + SDF shader
-- ═══════════════════════════════════════════════
pages[3] = { title = "AA Comparison", fn = function(sv)
    local y = 20
    display.newText(sv, "Toggle SDF switch to compare!", cx, y, native.systemFontBold, 22):setFillColor(1, 0.8, 0.3)
    local modeText = sdfMode and "SDF ON (smooth edges)" or "SDF OFF (native rendering)"
    local modeLabel = display.newText(sv, modeText, cx, y + 35, native.systemFontBold, 20)
    modeLabel:setFillColor(sdfMode and 0.3 or 1, sdfMode and 1 or 0.4, sdfMode and 0.5 or 0.4)

    -- Circles: display.newCircle responds to toggle
    y = 90
    display.newText(sv, "display.newCircle", 60, y, native.systemFontBold, 22):setFillColor(0.8, 0.8, 0.8)
    local sizes = {10, 20, 40, 70}
    local xOff = 100
    for _, r in ipairs(sizes) do
        local c = display.newCircle(sv, xOff, y + 80, r)
        c:setFillColor(0.3, 0.7, 1)
        display.newText(sv, r.."px", xOff, y + 80 + r + 16, native.systemFont, 16):setFillColor(0.4, 0.4, 0.4)
        xOff = xOff + r * 2 + 50
    end

    -- Rounded rects: display.newRoundedRect responds to toggle
    y = 320
    display.newText(sv, "display.newRoundedRect", 60, y, native.systemFontBold, 22):setFillColor(0.8, 0.8, 0.8)
    local radii = {4, 10, 20, 40}
    xOff = 100
    for _, cr in ipairs(radii) do
        local rr = display.newRoundedRect(sv, xOff, y + 70, 120, 80, cr)
        rr:setFillColor(1, 0.5, 0.2)
        display.newText(sv, "r="..cr, xOff, y + 130, native.systemFont, 16):setFillColor(0.4, 0.4, 0.4)
        xOff = xOff + 170
    end

    -- Rotated circles
    y = 500
    display.newText(sv, "Rotated + Scaled", 60, y, native.systemFontBold, 22):setFillColor(0.8, 0.8, 0.8)
    local c1 = display.newCircle(sv, 150, y + 80, 50); c1:setFillColor(0.8, 0.3, 1)
    local c2 = display.newCircle(sv, 350, y + 80, 30); c2:setFillColor(0.8, 0.3, 1); c2.xScale=2; c2.yScale=2
    local c3 = display.newCircle(sv, 550, y + 80, 20); c3:setFillColor(0.8, 0.3, 1); c3.xScale=3; c3.yScale=3
    display.newText(sv, "1x", 150, y+150, native.systemFont, 16):setFillColor(0.4,0.4,0.4)
    display.newText(sv, "2x", 350, y+150, native.systemFont, 16):setFillColor(0.4,0.4,0.4)
    display.newText(sv, "3x", 550, y+150, native.systemFont, 16):setFillColor(0.4,0.4,0.4)
end}

-- ═══════════════════════════════════════════════
-- PAGE 4: Benchmark
-- ═══════════════════════════════════════════════
pages[4] = { title = "Benchmark", fn = function(sv)
    local resultText = display.newText(sv, "Tap a button to start", cx, 40, native.systemFont, 22)
    resultText:setFillColor(1, 1, 1)

    local benchGroup = display.newGroup()
    sv:insert(benchGroup)

    local origCircle = display._originalNewCircle or display.newCircle

    local function runBench(count, useSDF, label)
        while benchGroup.numChildren > 0 do benchGroup[1]:removeSelf() end
        collectgarbage("collect")
        resultText.text = "Creating " .. count .. " " .. label .. "..."
        timer.performWithDelay(100, function()
            local t0 = system.getTimer()
            if useSDF then
                for i = 1, count do
                    local obj = sdf.newCircle(math.random(30,W-30), math.random(300,800), math.random(5,20))
                    obj:setFillColor(math.random()*0.5+0.3, math.random()*0.5+0.3, 1)
                    benchGroup:insert(obj._group)
                end
            else
                for i = 1, count do
                    local obj = origCircle(benchGroup, math.random(30,W-30), math.random(300,800), math.random(5,20))
                    obj:setFillColor(math.random()*0.5+0.3, math.random()*0.5+0.3, 1)
                end
            end
            local createMs = system.getTimer() - t0
            local frames, fpsStart = 0, system.getTimer()
            local function onFrame()
                frames = frames + 1
                if system.getTimer() - fpsStart > 3000 then
                    Runtime:removeEventListener("enterFrame", onFrame)
                    resultText.text = string.format("%s x%d — Create: %.0fms | FPS: %.1f", label, count, createMs, frames/3)
                    print(resultText.text)
                end
            end
            Runtime:addEventListener("enterFrame", onFrame)
        end)
    end

    local function btn(x, y, text, color, fn)
        local bg = display.newRoundedRect(sv, x, y, 300, 60, 14)
        bg:setFillColor(unpack(color))
        display.newText(sv, text, x, y, native.systemFontBold, 22):setFillColor(1)
        bg:addEventListener("tap", function() fn(); return true end)
    end

    local bx1, bx2 = cx - 170, cx + 170
    btn(bx1, 110, "Native x200",  {0.5,0.3,0.2}, function() runBench(200,false,"Native") end)
    btn(bx2, 110, "SDF x200",     {0.2,0.4,0.6}, function() runBench(200,true,"SDF") end)
    btn(bx1, 185, "Native x500",  {0.5,0.3,0.2}, function() runBench(500,false,"Native") end)
    btn(bx2, 185, "SDF x500",     {0.2,0.4,0.6}, function() runBench(500,true,"SDF") end)
    btn(bx1, 260, "Native x1000", {0.5,0.3,0.2}, function() runBench(1000,false,"Native") end)
    btn(bx2, 260, "SDF x1000",    {0.2,0.4,0.6}, function() runBench(1000,true,"SDF") end)
end}

-- ═══════════════════════════════════════════════
showPage(1)
