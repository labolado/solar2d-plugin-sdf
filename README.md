# plugin.sdf

Anti-aliased vector shapes for Solar2D via GLSL signed distance fields.

Drop-in replacement for `display.newCircle`, `display.newRect`, `display.newRoundedRect` with pixel-perfect anti-aliasing on all platforms. Plus 11 bonus shapes: hexagon, pentagon, octagon, triangle, diamond, cross, heart, crescent, ring, star, pill.

## Quick Start

```lua
local sdf = require("plugin.sdf")

-- Use directly
local circle = sdf.newCircle(160, 240, 50)
circle:setFillColor(1, 0, 0)

-- Or enable transparent replacement
sdf.enable()
-- Now display.newCircle() automatically uses SDF rendering
local c = display.newCircle(160, 240, 50)  -- SDF, not native
```

## Install

### Option A: Local (for development)

Clone this repo and open with Solar2D Simulator — the root directory is a working example.

### Option B: Plugin (for production)

Add to `build.settings`:

```lua
local sdf_base = "https://github.com/labolado/solar2d-plugin-sdf/releases/download/v1/"

settings = {
    plugins = {
        ["plugin.sdf"] = {
            publisherId = "com.labolado",
            supportedPlatforms = {
                iphone         = { url = sdf_base .. "plugin.sdf-iphone.tgz" },
                ["iphone-sim"] = { url = sdf_base .. "plugin.sdf-iphone-sim.tgz" },
                ["mac-sim"]    = { url = sdf_base .. "plugin.sdf-mac-sim.tgz" },
                android        = { url = sdf_base .. "plugin.sdf-android.tgz" },
                ["win32-sim"]  = { url = sdf_base .. "plugin.sdf-win32-sim.tgz" },
            },
        },
    },
}
```

## API

### Core

```lua
local sdf = require("plugin.sdf")

-- Transparent replacement (patches display.newCircle/newRect/newRoundedRect)
sdf.enable()
sdf.disable()
sdf.isEnabled()
```

### Shapes

All shapes return proxy objects compatible with standard Solar2D display objects.

```lua
sdf.newCircle(x, y, radius)
sdf.newEllipse(x, y, width, height)
sdf.newRect(x, y, width, height)
sdf.newRoundedRect(x, y, width, height, cornerRadius)
sdf.newHexagon(x, y, radius)
sdf.newPentagon(x, y, radius)
sdf.newOctagon(x, y, radius)
sdf.newTriangle(x, y, radius)
sdf.newDiamond(x, y, width, height)
sdf.newCross(x, y, size [, thickness])
sdf.newHeart(x, y, radius)
sdf.newCrescent(x, y, radius, offset)
sdf.newRing(x, y, outerRadius, innerRadius [, startAngle, endAngle])
sdf.newStar(x, y, radius, points, innerRadius)
sdf.newPill(x, y, width, height)
```

### Properties

```lua
obj:setFillColor(r, g, b [, a])
obj:setStrokeColor(r, g, b [, a])
obj.strokeWidth = 3

obj.shadow = { offsetX=3, offsetY=3, blur=8, color={0,0,0,0.4} }
obj.shadow = nil  -- remove shadow

obj:setFillGradient({ type="gradient", color1={1,0,0}, color2={0,0,1}, direction="down" })

-- Standard display object properties
obj.x, obj.y, obj.rotation, obj.alpha, obj.isVisible
obj.xScale, obj.yScale, obj.width, obj.height
obj:toFront(), obj:toBack()
obj:addEventListener("tap", handler)
obj:removeSelf()
```

### Compatibility

Works with:
- `transition.to()` animations
- `display.newGroup()` / `display.newContainer()`
- `display.newSnapshot()`
- Touch/tap events
- All standard display object properties

## How It Works

Each shape is rendered as a white rectangle with a custom GLSL fragment shader that computes the signed distance field. The SDF determines exact pixel coverage, producing mathematically perfect anti-aliased edges regardless of size, rotation, or scale.

## License

MIT
