------------------------------------------------------------------------------
-- plugin.sdf Demo — All shapes use display.newXxx()
-- SDF toggle: ON = SDF rendering, OFF = native rendering
------------------------------------------------------------------------------

local sdf = require("plugin.sdf")
local widget = require("widget")

display.setStatusBar(display.HiddenStatusBar)

local W = display.contentWidth
local H = display.contentHeight
local cx = W * 0.5
local safeY = display.safeScreenOriginY or 0

local pages = {}
local currentPage = 0
local scrollView
local sdfMode = true
local BAR = 50

-- ═══════════════════════════════════════════════
-- Top bar
-- ═══════════════════════════════════════════════
local barY = safeY + BAR * 0.5
local topBar = display.newRect(cx, safeY, W, BAR + safeY)
topBar.anchorY = 0; topBar:setFillColor(0.06, 0.06, 0.08)

local pageTitle = display.newText("", cx * 0.55, barY, native.systemFontBold, 20)
pageTitle:setFillColor(1, 1, 0)

local navL = display.newText("◀", 30, barY, native.systemFontBold, 30)
navL:setFillColor(1, 1, 0, 0.8)
local navR = display.newText("▶", W - 30, barY, native.systemFontBold, 30)
navR:setFillColor(1, 1, 0, 0.8)

-- Toggle
local tgBtn = display.newRoundedRect(W * 0.82, barY, 100, 34, 17)
local tgLabel = display.newText("SDF ON", W * 0.82, barY, native.systemFontBold, 15)

local function updateToggle()
    if sdfMode then
        sdf.enable()
        tgBtn:setFillColor(0.15, 0.55, 0.25)
        tgLabel.text = "SDF ON"; tgLabel:setFillColor(1)
    else
        sdf.disable()
        tgBtn:setFillColor(0.55, 0.15, 0.15)
        tgLabel.text = "SDF OFF"; tgLabel:setFillColor(1)
    end
end

local function showPage(idx)
    transition.cancelAll()
    if scrollView then scrollView:removeSelf(); scrollView = nil end
    currentPage = idx
    pageTitle.text = idx .. "/" .. #pages .. " " .. pages[idx].title

    local wasOn = sdf.isEnabled()
    if wasOn then sdf.disable() end
    local svTop = safeY + BAR
    scrollView = widget.newScrollView({
        x = cx, y = svTop + (H - svTop) * 0.5,
        width = W, height = H - svTop,
        topPadding = 0,
        horizontalScrollDisabled = true,
        hideBackground = true,
    })
    if wasOn then sdf.enable() end

    pages[idx].fn(scrollView)
end

navL:addEventListener("tap", function() if currentPage > 1 then showPage(currentPage - 1) end; return true end)
navR:addEventListener("tap", function() if currentPage < #pages then showPage(currentPage + 1) end; return true end)
tgBtn:addEventListener("tap", function() sdfMode = not sdfMode; updateToggle(); showPage(currentPage); return true end)
updateToggle()

-- ═══════════════════════════════════════════════
-- Helpers — all use display.newXxx (affected by toggle)
-- ═══════════════════════════════════════════════
local function col3(i) return W * (i - 0.5) / 3 end  -- 3 columns
local function col4(i) return W * (i - 0.5) / 4 end  -- 4 columns
local function col5(i) return W * (i - 0.5) / 5 end  -- 5 columns

-- ═══════════════════════════════════════════════
-- PAGE 1: Circles + Rects + RoundedRects (standard API)
-- ═══════════════════════════════════════════════
pages[1] = { title = "Shapes", fn = function(sv)
    display.setDefault("background", 1, 1, 1)
    local y = 10

    -- Row: Circles
    display.newText(sv, "display.newCircle", W * 0.05, y, native.systemFontBold, 14)
        :setFillColor(0.2, 0.2, 0.2)
    y = y + 20

    local sizes = {12, 24, 45, 75}
    for i, r in ipairs(sizes) do
        local c = display.newCircle(col4(i), y + 80, r)
        c:setFillColor(0.3, 0.7, 1)
        if c._group then sv:insert(c._group) else sv:insert(c) end
        display.newText(sv, r.."px", col4(i), y + 80 + r + 14, native.systemFont, 13)
            :setFillColor(0.4, 0.4, 0.4)
    end

    -- Row: Rects
    y = y + 200
    display.newText(sv, "display.newRect", W * 0.05, y, native.systemFontBold, 14)
        :setFillColor(0.2, 0.2, 0.2)
    y = y + 20

    local rectSizes = {{90,60},{120,75},{150,90}}
    for i, s in ipairs(rectSizes) do
        local r = display.newRect(col3(i), y + 55, s[1], s[2])
        r:setFillColor(0.3, 1, 0.5)
        sv:insert(r._group or r)
    end

    -- Row: Rects rotated
    y = y + 140
    display.newText(sv, "display.newRect (rotated)", W * 0.05, y, native.systemFontBold, 14)
        :setFillColor(0.2, 0.2, 0.2)
    y = y + 20

    local angles = {15, 30, 45, 60}
    for i, a in ipairs(angles) do
        local r = display.newRect(col4(i), y + 65, 90, 90)
        r:setFillColor(0.3, 0.7, 1); r.rotation = a
        sv:insert(r._group or r)
        display.newText(sv, a.."°", col4(i), y + 125, native.systemFont, 13)
            :setFillColor(0.4, 0.4, 0.4)
    end

    -- Row: Rounded rects
    y = y + 160
    display.newText(sv, "display.newRoundedRect", W * 0.05, y, native.systemFontBold, 14)
        :setFillColor(0.2, 0.2, 0.2)
    y = y + 20

    local crs = {6, 15, 30, 50}
    for i, cr in ipairs(crs) do
        local rr = display.newRoundedRect(col4(i), y + 55, 150, 100, cr)
        rr:setFillColor(1, 0.5, 0.2)
        sv:insert(rr._group or rr)
        display.newText(sv, "r="..cr, col4(i), y + 115, native.systemFont, 13)
            :setFillColor(0.4, 0.4, 0.4)
    end

    -- Row: Mixed colors + alpha
    y = y + 150
    display.newText(sv, "Colors + Alpha", W * 0.05, y, native.systemFontBold, 14)
        :setFillColor(0.2, 0.2, 0.2)
    y = y + 20

    local c1 = display.newCircle(col4(1), y+55, 50); c1:setFillColor(1,0,0); sv:insert(c1._group or c1)
    local c2 = display.newCircle(col4(2), y+55, 50); c2:setFillColor(0,1,0); sv:insert(c2._group or c2)
    local c3 = display.newCircle(col4(3), y+55, 50); c3:setFillColor(0,0,1); sv:insert(c3._group or c3)
    local c4 = display.newCircle(col4(4), y+55, 50); c4:setFillColor(1,1,0,0.5); sv:insert(c4._group or c4)

    -- Row: Scaled
    y = y + 140
    display.newText(sv, "Scaled", W * 0.05, y, native.systemFontBold, 14)
        :setFillColor(0.2, 0.2, 0.2)
    y = y + 20

    local scales = {0.5, 1, 1.5, 2}
    for i, s in ipairs(scales) do
        local c = display.newCircle(col4(i), y + 55, 38)
        c:setFillColor(0.8, 0.3, 1); c.xScale = s; c.yScale = s
        if c._group then sv:insert(c._group) else sv:insert(c) end
        display.newText(sv, s.."x", col4(i), y + 105, native.systemFont, 13)
            :setFillColor(0.4, 0.4, 0.4)
    end
end}

-- ═══════════════════════════════════════════════
-- PAGE 2: Extended SDF Shapes (always SDF, not in standard API)
-- ═══════════════════════════════════════════════
pages[2] = { title = "Extended", fn = function(sv)
    display.setDefault("background", 1, 1, 1)

    local R = 44
    local cellH = R * 2 + 30
    local y = R + 4

    local shapes = {
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
        {"star8",     function(x,y) return sdf.newStar(x,y,R,8,R*0.35) end},
    }

    for i, s in ipairs(shapes) do
        local col = (i - 1) % 3
        local row = math.floor((i - 1) / 3)
        local xx = col3(col + 1)
        local yy = y + row * cellH
        local obj = s[2](xx, yy)
        obj:setFillColor(0.3, 0.7, 1)
        sv:insert(obj._group)
        display.newText(sv, s[1], xx, yy + R + 8, native.systemFont, 12)
            :setFillColor(0.4, 0.4, 0.4)
    end

    -- Stroke + Shadow section
    local secY = y + math.ceil(#shapes / 3) * cellH + 10
    display.newText(sv, "Stroke + Shadow + Gradient", cx, secY, native.systemFontBold, 16)
        :setFillColor(0.8, 0.8, 0.8)

    -- Stroke
    local s1 = sdf.newCircle(col3(1), secY + 70, 40)
    s1:setFillColor(1, 0.3, 0.3); s1:setStrokeColor(1, 1, 1); s1.strokeWidth = 4
    sv:insert(s1._group)

    -- Shadow (needs light bg)
    local bgRect = display.newRect(col3(2), secY + 70, W/3 - 10, 100)
    bgRect:setFillColor(0.85, 0.85, 0.85); sv:insert(bgRect)
    local s2 = sdf.newRoundedRect(col3(2), secY + 70, 90, 60, 12)
    s2:setFillColor(1, 1, 1)
    s2.shadow = {offsetX=4, offsetY=4, blur=10, color={0,0,0,0.35}}
    sv:insert(s2._group)

    -- Gradient
    local s3 = sdf.newHeart(col3(3), secY + 70, 40)
    s3:setFillGradient({type="gradient", color1={1,0,0}, color2={1,0.8,0.2}, direction="down"})
    sv:insert(s3._group)
end}

-- ═══════════════════════════════════════════════
-- PAGE 3: Side-by-side AA comparison (Native left, SDF right)
-- ═══════════════════════════════════════════════
pages[3] = { title = "AA Compare", fn = function(sv)
    display.setDefault("background", 1, 1, 1)

    local leftX = W * 0.25
    local rightX = W * 0.75
    local origCircle = display._originalNewCircle or display.newCircle
    local origRect = display._originalNewRect or display.newRect
    local origRRect = display._originalNewRoundedRect or display.newRoundedRect

    local y = 4
    display.newText(sv, "Native", leftX, y, native.systemFontBold, 16):setFillColor(1, 0.4, 0.4)
    display.newText(sv, "SDF", rightX, y, native.systemFontBold, 16):setFillColor(0.4, 1, 0.5)

    -- Divider
    display.newLine(sv, cx, 20, cx, 1200):setStrokeColor(0.25, 0.25, 0.25)

    -- Circles
    y = 25
    local sizes = {6, 12, 25, 50}
    for _, r in ipairs(sizes) do
        y = y + r + 6
        local nc = origCircle(leftX, y, r); nc:setFillColor(0.3, 0.7, 1); sv:insert(nc)
        local sc = sdf.newCircle(rightX, y, r); sc:setFillColor(0.3, 0.7, 1); sv:insert(sc._group)
        display.newText(sv, r.."px", cx, y, native.systemFont, 10):setFillColor(0.2, 0.2, 0.2)
        y = y + r + 4
    end

    -- Rounded rects
    y = y + 15
    display.newText(sv, "RoundedRect", cx, y, native.systemFont, 12):setFillColor(0.4, 0.4, 0.4)
    y = y + 15
    local crs = {4, 12, 28}
    for _, cr in ipairs(crs) do
        y = y + 40
        local nr = origRRect(leftX, y, W*0.35, 55, cr); nr:setFillColor(1, 0.5, 0.2); sv:insert(nr)
        local sr = sdf.newRoundedRect(rightX, y, W*0.35, 55, cr); sr:setFillColor(1, 0.5, 0.2); sv:insert(sr._group)
        display.newText(sv, "r="..cr, cx, y, native.systemFont, 10):setFillColor(0.2, 0.2, 0.2)
        y = y + 40
    end

    -- Rotated rects
    y = y + 15
    display.newText(sv, "Rotated", cx, y, native.systemFont, 12):setFillColor(0.4, 0.4, 0.4)
    y = y + 15
    local angles = {15, 30, 45}
    for _, a in ipairs(angles) do
        y = y + 45
        local nr = origRect(leftX, y, 60, 60); nr:setFillColor(0.3, 0.7, 1); nr.rotation = a; sv:insert(nr)
        local sr = sdf.newRect(rightX, y, 60, 60); sr:setFillColor(0.3, 0.7, 1); sr.rotation = a; sv:insert(sr._group)
        display.newText(sv, a.."°", cx, y, native.systemFont, 10):setFillColor(0.2, 0.2, 0.2)
        y = y + 45
    end
end}

-- ═══════════════════════════════════════════════
-- PAGE 4: Benchmark
-- ═══════════════════════════════════════════════
pages[4] = { title = "Benchmark", fn = function(sv)
    display.setDefault("background", 1, 1, 1)

    -- Use original functions for UI elements to avoid SDF affecting buttons
    local origCircle = display._originalNewCircle or display.newCircle
    local origRRect = display._originalNewRoundedRect or display.newRoundedRect

    local statusText = display.newText(sv, "Tap a count to benchmark", cx, 8, native.systemFont, 15)
    statusText:setFillColor(0.2, 0.2, 0.2)

    -- Table header
    local hY = 35
    local c1, c2, c3, c4, c5 = W*0.1, W*0.28, W*0.44, W*0.62, W*0.82
    display.newText(sv, "N", c1, hY, native.systemFontBold, 13):setFillColor(0.3,0.3,0.3)
    display.newText(sv, "Nat ms", c2, hY, native.systemFontBold, 13):setFillColor(0.8,0.2,0.2)
    display.newText(sv, "Nat FPS", c3, hY, native.systemFontBold, 13):setFillColor(0.8,0.2,0.2)
    display.newText(sv, "SDF ms", c4, hY, native.systemFontBold, 13):setFillColor(0.2,0.6,0.2)
    display.newText(sv, "SDF FPS", c5, hY, native.systemFontBold, 13):setFillColor(0.2,0.6,0.2)

    local counts = {100, 200, 500, 1000}
    local labels = {}
    local benchGroup = display.newGroup(); sv:insert(benchGroup)

    for i, n in ipairs(counts) do
        local ry = hY + i * 32
        labels[n] = {
            nm = display.newText(sv, "—", c2, ry, native.systemFont, 13),
            nf = display.newText(sv, "—", c3, ry, native.systemFont, 13),
            sm = display.newText(sv, "—", c4, ry, native.systemFont, 13),
            sf = display.newText(sv, "—", c5, ry, native.systemFont, 13),
        }
        for _, l in pairs(labels[n]) do l:setFillColor(0.1, 0.1, 0.1) end

        -- Use original roundedRect for buttons (not SDF)
        local btn = origRRect(c1, ry, 60, 26, 8)
        btn:setFillColor(0.2, 0.35, 0.5); sv:insert(btn)
        display.newText(sv, n, c1, ry, native.systemFontBold, 13):setFillColor(1)
        btn:addEventListener("tap", function()
            local L = labels[n]
            L.nm.text = "..."; L.nf.text = "..."; L.sm.text = "..."; L.sf.text = "..."
            statusText.text = "Native x" .. n .. "..."

            -- Run native
            while benchGroup.numChildren > 0 do benchGroup[1]:removeSelf() end
            collectgarbage("collect")
            timer.performWithDelay(50, function()
                local t0 = system.getTimer()
                for i = 1, n do
                    local o = origCircle(math.random(20,W-20), math.random(350,750), math.random(4,14))
                    o:setFillColor(math.random()*0.5+0.3, math.random()*0.5+0.3, 1)
                    benchGroup:insert(o)
                end
                local natMs = system.getTimer() - t0
                local fr, ft = 0, system.getTimer()
                local function f1()
                    fr = fr + 1
                    if system.getTimer() - ft > 2000 then
                        Runtime:removeEventListener("enterFrame", f1)
                        local natFps = fr / 2
                        L.nm.text = string.format("%.0f", natMs)
                        L.nf.text = string.format("%.1f", natFps)

                        -- Run SDF
                        while benchGroup.numChildren > 0 do benchGroup[1]:removeSelf() end
                        collectgarbage("collect")
                        statusText.text = "SDF x" .. n .. "..."
                        timer.performWithDelay(50, function()
                            local t1 = system.getTimer()
                            for i = 1, n do
                                local o = sdf.newCircle(math.random(20,W-20), math.random(350,750), math.random(4,14))
                                o:setFillColor(math.random()*0.5+0.3, math.random()*0.5+0.3, 1)
                                benchGroup:insert(o._group)
                            end
                            local sdfMs = system.getTimer() - t1
                            local fr2, ft2 = 0, system.getTimer()
                            local function f2()
                                fr2 = fr2 + 1
                                if system.getTimer() - ft2 > 2000 then
                                    Runtime:removeEventListener("enterFrame", f2)
                                    local sdfFps = fr2 / 2
                                    L.sm.text = string.format("%.0f", sdfMs)
                                    L.sf.text = string.format("%.1f", sdfFps)
                                    -- Color: green=better
                                    L.nm:setFillColor(natMs<=sdfMs and 0.3 or 1, natMs<=sdfMs and 1 or 0.4, 0.3)
                                    L.sm:setFillColor(sdfMs<=natMs and 0.3 or 1, sdfMs<=natMs and 1 or 0.4, 0.3)
                                    L.nf:setFillColor(natFps>=sdfFps and 0.3 or 1, natFps>=sdfFps and 1 or 0.4, 0.3)
                                    L.sf:setFillColor(sdfFps>=natFps and 0.3 or 1, sdfFps>=natFps and 1 or 0.4, 0.3)
                                    statusText.text = "x" .. n .. " done"
                                    while benchGroup.numChildren > 0 do benchGroup[1]:removeSelf() end
                                end
                            end
                            Runtime:addEventListener("enterFrame", f2)
                        end)
                    end
                end
                Runtime:addEventListener("enterFrame", f1)
            end)
            return true
        end)
    end
end}

-- ═══════════════════════════════════════════════
showPage(1)
