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
local function fit_cell(g, cell)
	local g = {
		x = round(g.x, cell.x),
		y = round(g.y, cell.y),
		width = round(g.width, cell.x),
		height = round(g.height, cell.y)
	}

	return g
end

-- Tile function
-----------------------------------------------------------------------------------------------------------------------
function grid.arrange(p)

    -- theme vars
	local cellnum = beautiful.cellnum or { x = 100, y = 60 }

    -- aliases
    local wa = p.workarea
    local cls = p.clients

    -- nothing to tile here
    if #cls == 0 then return end

	-- calculate cell
	grid.cell = {
		x = wa.width  / cellnum.x,
		y = wa.height / cellnum.y
	}

	-- tile
	for i, c in ipairs(cls) do
		local g = c:geometry()

		size_correction(c, g, true)
		g = fit_cell(g, grid.cell)
		size_correction(c, g, false)

		c:geometry(g)
	end
end

-- Mouse moving function
-----------------------------------------------------------------------------------------------------------------------
function grid.mouse_move_handler(c, _mouse, dist)
	local g = c:geometry()

	for _, crd in ipairs({ "x", "y" }) do
		local d = _mouse[crd] - g[crd] - dist[crd]
		if math.abs(d) >= grid.cell[crd] then
			g[crd] = g[crd] + d
		end
	end

	c:geometry(g)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return grid
