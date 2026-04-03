------------------------------------------------------------------------------
-- plugin.sdf — Interactive Demo
------------------------------------------------------------------------------

local sdf = require("plugin.sdf")
local widget = require("widget")

display.setStatusBar(display.HiddenStatusBar)

local W = display.contentWidth
local H = display.contentHeight
local cx = W * 0.5
local safeY = display.safeScreenOriginY or 0  -- iPhone notch/dynamic island offset

local pages = {}
local currentPage = 0
local scrollView
local sdfMode = true

-- ═══════════════════════════════════════════════
-- Top bar (70px, bigger toggle)
-- ═══════════════════════════════════════════════
local BAR = 70

local barTop = safeY
local barMid = barTop + BAR * 0.5

local topBar = display.newRect(cx, barTop + BAR * 0.5, W, BAR + safeY * 2)
topBar:setFillColor(0.06, 0.06, 0.08)
topBar.anchorY = 1
topBar.y = barTop + BAR

local pageTitle = display.newText("", cx * 0.7, barMid, native.systemFontBold, 22)
pageTitle:setFillColor(1, 1, 0)

local navL = display.newText("◀", 35, barMid, native.systemFontBold, 32)
navL:setFillColor(1, 1, 0, 0.8)
local navR = display.newText("▶", W - 35, barMid, native.systemFontBold, 32)
navR:setFillColor(1, 1, 0, 0.8)

-- Toggle button
local tgBtn = display.newRoundedRect(W * 0.78, barMid, 110, 36, 18)
local tgLabel = display.newText("SDF ON", W * 0.78, barMid, native.systemFontBold, 16)

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

    local svTop = barTop + BAR
    local svH = H - svTop
    scrollView = widget.newScrollView({
        x = cx, y = svTop + svH * 0.5,
        width = W, height = svH,
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
-- PAGE 3: AA Comparison — Native (left) vs SDF (right) side by side
-- ═══════════════════════════════════════════════
pages[3] = { title = "AA Compare", fn = function(sv)
    display.setDefault("background", 0.15, 0.15, 0.15)

    local leftX = W * 0.25   -- native column center
    local rightX = W * 0.75  -- SDF column center

    -- Column headers
    local y = 4
    display.newText(sv, "Native", leftX, y, native.systemFontBold, 18):setFillColor(1, 0.4, 0.4)
    display.newText(sv, "SDF", rightX, y, native.systemFontBold, 18):setFillColor(0.4, 1, 0.5)
    display.newText(sv, "vs", cx, y, native.systemFont, 14):setFillColor(0.4, 0.4, 0.4)

    -- Divider line
    local div = display.newLine(sv, cx, 20, cx, 2000)
    div:setStrokeColor(0.3, 0.3, 0.3); div.strokeWidth = 1

    -- Use original display functions for native column
    local origCircle = display._originalNewCircle or display.newCircle
    local origRect = display._originalNewRect or display.newRect
    local origRRect = display._originalNewRoundedRect or display.newRoundedRect

    -- === Circles ===
    y = 30
    display.newText(sv, "Circles", cx, y, native.systemFontBold, 14):setFillColor(0.6, 0.6, 0.6)

    local sizes = {5, 10, 20, 40, 70}
    local rowY = y + 20
    for _, r in ipairs(sizes) do
        rowY = rowY + r + 8
        -- Native (left)
        local nc = origCircle(leftX, rowY, r)
        nc:setFillColor(0.3, 0.7, 1); sv:insert(nc)
        -- SDF (right)
        local sc = sdf.newCircle(rightX, rowY, r)
        sc:setFillColor(0.3, 0.7, 1); sv:insert(sc._group)
        -- Label
        display.newText(sv, r.."px", cx, rowY, native.systemFont, 10):setFillColor(0.4, 0.4, 0.4)
        rowY = rowY + r + 4
    end

    -- === Rounded Rects ===
    y = rowY + 20
    display.newText(sv, "Rounded Rects", cx, y, native.systemFontBold, 14):setFillColor(0.6, 0.6, 0.6)

    local crs = {4, 10, 20, 40}
    rowY = y + 20
    for _, cr in ipairs(crs) do
        rowY = rowY + 45
        local nrr = origRRect(leftX, rowY, 120, 70, cr)
        nrr:setFillColor(1, 0.5, 0.2); sv:insert(nrr)
        local srr = sdf.newRoundedRect(rightX, rowY, 120, 70, cr)
        srr:setFillColor(1, 0.5, 0.2); sv:insert(srr._group)
        display.newText(sv, "r="..cr, cx, rowY, native.systemFont, 10):setFillColor(0.4, 0.4, 0.4)
        rowY = rowY + 45
    end

    -- === Rotated Rects ===
    y = rowY + 20
    display.newText(sv, "Rotated Rects", cx, y, native.systemFontBold, 14):setFillColor(0.6, 0.6, 0.6)

    local angles = {15, 30, 45}
    rowY = y + 20
    for _, a in ipairs(angles) do
        rowY = rowY + 50
        local nr = origRect(leftX, rowY, 70, 70)
        nr:setFillColor(0.3, 0.7, 1); nr.rotation = a; sv:insert(nr)
        local sr = sdf.newRect(rightX, rowY, 70, 70)
        sr:setFillColor(0.3, 0.7, 1); sr.rotation = a; sv:insert(sr._group)
        display.newText(sv, a.."°", cx, rowY, native.systemFont, 10):setFillColor(0.4, 0.4, 0.4)
        rowY = rowY + 50
    end
end}

-- ═══════════════════════════════════════════════
-- PAGE 4: Benchmark — auto runs Native then SDF, shows comparison
-- ═══════════════════════════════════════════════
pages[4] = { title = "Benchmark", fn = function(sv)
    display.setDefault("background", 0.1, 0.1, 0.12)

    local origCircle = display._originalNewCircle or display.newCircle

    local statusText = display.newText(sv, "Tap count to run benchmark", cx, 8, native.systemFont, 16)
    statusText:setFillColor(0.7, 0.7, 0.7)

    -- Results table
    local resultLabels = {}
    local headerY = 40
    display.newText(sv, "Count", 70, headerY, native.systemFontBold, 14):setFillColor(0.6,0.6,0.6)
    display.newText(sv, "Native Create", 220, headerY, native.systemFontBold, 14):setFillColor(1,0.5,0.5)
    display.newText(sv, "Native FPS", 370, headerY, native.systemFontBold, 14):setFillColor(1,0.5,0.5)
    display.newText(sv, "SDF Create", 520, headerY, native.systemFontBold, 14):setFillColor(0.5,1,0.5)
    display.newText(sv, "SDF FPS", 660, headerY, native.systemFontBold, 14):setFillColor(0.5,1,0.5)

    local counts = {100, 200, 500, 1000}
    for i, count in ipairs(counts) do
        local ry = headerY + i * 36
        resultLabels[count] = {
            natCreate = display.newText(sv, "—", 220, ry, native.systemFont, 14),
            natFPS    = display.newText(sv, "—", 370, ry, native.systemFont, 14),
            sdfCreate = display.newText(sv, "—", 520, ry, native.systemFont, 14),
            sdfFPS    = display.newText(sv, "—", 660, ry, native.systemFont, 14),
        }
        for _, l in pairs(resultLabels[count]) do l:setFillColor(1, 1, 1) end
    end

    local benchGroup = display.newGroup()
    sv:insert(benchGroup)

    -- Run a single benchmark, return results via callback
    local function runSingle(count, useSDF, callback)
        while benchGroup.numChildren > 0 do benchGroup[1]:removeSelf() end
        collectgarbage("collect")

        timer.performWithDelay(50, function()
            local t0 = system.getTimer()
            if useSDF then
                for i = 1, count do
                    local obj = sdf.newCircle(math.random(20,W-20), math.random(250,700), math.random(4,16))
                    obj:setFillColor(math.random()*0.5+0.3, math.random()*0.5+0.3, 1)
                    benchGroup:insert(obj._group)
                end
            else
                for i = 1, count do
                    local obj = origCircle(math.random(20,W-20), math.random(250,700), math.random(4,16))
                    obj:setFillColor(math.random()*0.5+0.3, math.random()*0.5+0.3, 1)
                    benchGroup:insert(obj)
                end
            end
            local createMs = system.getTimer() - t0
            -- Measure FPS for 2 seconds
            local frames, t1 = 0, system.getTimer()
            local function onFrame()
                frames = frames + 1
                if system.getTimer() - t1 > 2000 then
                    Runtime:removeEventListener("enterFrame", onFrame)
                    callback(createMs, frames / 2.0)
                end
            end
            Runtime:addEventListener("enterFrame", onFrame)
        end)
    end

    -- Run comparison: Native first, then SDF, update table
    local function runComparison(count)
        local labels = resultLabels[count]
        labels.natCreate.text = "..."
        labels.natFPS.text = "..."
        labels.sdfCreate.text = "..."
        labels.sdfFPS.text = "..."
        statusText.text = "Running Native x" .. count .. "..."

        runSingle(count, false, function(natMs, natFps)
            labels.natCreate.text = string.format("%.0fms", natMs)
            labels.natFPS.text = string.format("%.1f", natFps)
            statusText.text = "Running SDF x" .. count .. "..."

            runSingle(count, true, function(sdfMs, sdfFps)
                labels.sdfCreate.text = string.format("%.0fms", sdfMs)
                labels.sdfFPS.text = string.format("%.1f", sdfFps)

                -- Color code: green = better, red = worse
                local function colorize(label, val, ref, lowerIsBetter)
                    if lowerIsBetter then
                        label:setFillColor(val <= ref and 0.3 or 1, val <= ref and 1 or 0.4, 0.3)
                    else
                        label:setFillColor(val >= ref and 0.3 or 1, val >= ref and 1 or 0.4, 0.3)
                    end
                end
                colorize(labels.natCreate, natMs, sdfMs, true)
                colorize(labels.sdfCreate, sdfMs, natMs, true)
                colorize(labels.natFPS, natFps, sdfFps, false)
                colorize(labels.sdfFPS, sdfFps, natFps, false)

                statusText.text = "x" .. count .. " done. Tap another count."
                -- Clean up
                while benchGroup.numChildren > 0 do benchGroup[1]:removeSelf() end
            end)
        end)
    end

    -- Buttons
    for i, count in ipairs(counts) do
        local ry = headerY + i * 36
        local btn = display.newRoundedRect(sv, 70, ry, 100, 30, 8)
        btn:setFillColor(0.2, 0.35, 0.5)
        display.newText(sv, "x"..count, 70, ry, native.systemFontBold, 14):setFillColor(1)
        btn:addEventListener("tap", function() runComparison(count); return true end)
    end

    -- "Run All" button
    local runAllBtn = display.newRoundedRect(sv, cx, headerY + #counts * 36 + 50, 200, 44, 12)
    runAllBtn:setFillColor(0.3, 0.5, 0.2)
    display.newText(sv, "Run All", cx, headerY + #counts * 36 + 50, native.systemFontBold, 18):setFillColor(1)

    runAllBtn:addEventListener("tap", function()
        local idx = 1
        local function runNext()
            if idx > #counts then
                statusText.text = "All benchmarks complete!"
                return
            end
            runComparison(counts[idx])
            -- Wait for completion (Native 2s + SDF 2s + overhead)
            timer.performWithDelay(5000, function()
                idx = idx + 1
                runNext()
            end)
        end
        runNext()
        return true
    end)
end}

-- ═══════════════════════════════════════════════
showPage(1)
