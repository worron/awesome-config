-----------------------------------------------------------------------------------------------------------------------
--                                               RedFlat grid layout                                                 --
-----------------------------------------------------------------------------------------------------------------------
-- Floating layout with discrete geometry
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local beautiful = require("beautiful")

local ipairs = ipairs
local pairs = pairs
local math = math

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local grid = {}
grid.name = "grid"

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Calculate cell geometry
local function cell(wa, cellnum)
	local cell = {
		x = wa.width  / cellnum.x,
		y = wa.height / cellnum.y
	}

	cell.width = cell.x
	cell.height = cell.y

	return cell
end

-- Grid rounding
local function round(a, n)
	return n * math.floor((a + n / 2) / n)
end

-- Client geometry correction by border width
local function size_correction(c, geometry, restore)
	local sign = restore and - 1 or 1
	local bg = sign * 2 * c.border_width

    if geometry.width  then geometry.width  = geometry.width  - bg end
    if geometry.height then geometry.height = geometry.height - bg end
end

-- Fit client into grid
local function fit_cell(g, cell)
	local ng = {}

	for k, v in pairs(g) do
		ng[k] = math.ceil(round(v, cell[k]))
	end

	return ng
end

-- Check geometry difference
local function is_diff(g1, g2, cell)
	for k, v in pairs(g1) do
		if math.abs(g2[k] - v) >= cell[k] then return true end
	end

	return false
end

-- Place mouse pointer on window corner
local function set_mouse_on_corner(g, corner)
	local mc = {}

	if     corner == "bottom_right" then mc = { x = g.x + g.width, y = g.y + g.height }
	elseif corner == "bottom_left"  then mc = { x = g.x          , y = g.y + g.height }
	elseif corner == "top_right"    then mc = { x = g.x + g.width, y = g.y }
	elseif corner == "top_left"     then mc = { x = g.x          , y = g.y }
	end

	mouse.coords(mc)
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
	grid.cell = cell(wa, cellnum)

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

-- Mouse moving function
-----------------------------------------------------------------------------------------------------------------------
function grid.mouse_resize_handler(c, corner, x, y)
	local g = c:geometry()
	local cg = g

	size_correction(c, g, true)
	set_mouse_on_corner(g, corner)

	mousegrabber.run(
		function (_mouse)
			 for k, v in ipairs(_mouse.buttons) do
				if v then
					local ng
					if corner == "bottom_right" then
						ng = {
							width  = _mouse.x - g.x,
							height = _mouse.y - g.y
						}
					elseif corner == "bottom_left" then
						ng = {
							x = _mouse.x,
							width  = (g.x + g.width) - _mouse.x,
							height = _mouse.y - g.y
						}
					elseif corner == "top_left" then
						ng = {
							x = _mouse.x,
							y = _mouse.y,
							width  = (g.x + g.width)  - _mouse.x,
							height = (g.y + g.height) - _mouse.y
						}
					else
						ng = {
							y = _mouse.y,
							width  = _mouse.x - g.x,
							height = (g.y + g.height) - _mouse.y
						}
					end

					if ng.width  <= 0 then ng.width  = nil end
					if ng.height <= 0 then ng.height = nil end
					if c.maximized_horizontal then ng.width  = g.width  ng.x = g.x end
					if c.maximized_vertical   then ng.height = g.height ng.y = g.y end

					size_correction(c, ng, false)
					if is_diff(ng, cg, grid.cell) then
						cg = c:geometry(ng)
					end

					return true
				end
			end
			return false
		end,
		corner .. "_corner"
	)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return grid
