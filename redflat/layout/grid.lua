-----------------------------------------------------------------------------------------------------------------------
--                                               RedFlat grid layout                                                 --
-----------------------------------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local beautiful = require("beautiful")

local ipairs = ipairs
local math = math

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local grid = {}
grid.name = "grid"

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Grid rounding
local function round(a, n)
	return n * math.floor((a + n / 2) / n)
end

-- Client geometry correction by border width
local function size_correction(c, geometry, restore)
	local sign = restore and - 1 or 1
	local bg = sign * 2 * c.border_width

    geometry.width  = geometry.width  - bg
    geometry.height = geometry.height - bg
end

-- Fit client into grid
local function fit(g, wa, cell)
	local g = {
		x = round(g.x, cell.x),
		y = round(g.y, cell.y),
		width = round(g.width, cell.x),
		height = round(g.height, cell.y)
	}

	if g.x < wa.x then g.x = wa.x end
	if g.y < wa.y then g.y = wa.y end
	if g.x + g.width > wa.x + wa.width then g.width = wa.x + wa.width - g.x end
	if g.y + g.height > wa.y + wa.height then g.height = wa.y + wa.height - g.y end

	return g
end

-- Tile function
-----------------------------------------------------------------------------------------------------------------------
function grid.arrange(p)

    -- theme vars
	local cellnum = beautiful.cellnum or { x = 100, y = 60, gap = 0 }

    -- aliases
    local wa = p.workarea
    local cls = p.clients

    -- nothing to tile here
    if #cls == 0 then return end

	-- calculate cell
	local cell = { x = wa.width / cellnum.x, y = wa.height / cellnum.y }

    -- workarea size correction
    wa.width  = wa.width -  2 * cell.x * cellnum.gap
    wa.height = wa.height - 2 * cell.y * cellnum.gap
    wa.x = wa.x + cell.x * cellnum.gap
    wa.y = wa.y + cell.y * cellnum.gap

	-- tile
	for i, c in ipairs(cls) do
		local g = c:geometry()

		size_correction(c, g, true)
		g = fit(g, wa, cell)
		size_correction(c, g, false)

		c:geometry(g)
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return grid
