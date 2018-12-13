-----------------------------------------------------------------------------------------------------------------------
--                                           Active screen edges config                                              --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local redflat = require("redflat")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local edges = {}

local switcher = redflat.float.appswitcher
local currenttags = redflat.widget.tasklist.filter.currenttags
local allscreen   = redflat.widget.tasklist.filter.allscreen

-- Active screen edges
-----------------------------------------------------------------------------------------------------------------------
function edges:init(args)

	local args = args or {}
	local ew = args.width or 1 -- edge width
	local workarea = args.workarea or screen[mouse.screen].workarea

	-- edge geometry
	local egeometry = {
		top   = { width = workarea.width - 2 * ew, height = ew , x = ew, y = 0 },
		right = { width = ew, height = workarea.height - ew, x = workarea.width - ew, y = ew },
		left  = { width = ew, height = workarea.height, x = 0, y = 0 }
	}

	-- Top
	--------------------------------------------------------------------------------
	local top = redflat.util.desktop.edge("horizontal")
	top.wibox:geometry(egeometry["top"])

	top.layout:buttons(awful.util.table.join(
		awful.button({}, 1,
			function()
				if client.focus then client.focus.maximized = not client.focus.maximized end
			end
		)
	))

	-- Right
	--------------------------------------------------------------------------------
	local right = redflat.util.desktop.edge("vertical")
	right.wibox:geometry(egeometry["right"])

	right.layout:buttons(awful.util.table.join(
		awful.button({}, 5, function() awful.tag.viewnext(mouse.screen) end),
		awful.button({}, 4, function() awful.tag.viewprev(mouse.screen) end)
	))

	-- Left
	--------------------------------------------------------------------------------
	local left = redflat.util.desktop.edge("vertical", { ew, workarea.height - ew })
	left.wibox:geometry(egeometry["left"])

	left.area[1]:buttons(awful.util.table.join(
		awful.button({}, 4, function() switcher:show({ filter = allscreen })                 end),
		awful.button({}, 5, function() switcher:show({ filter = allscreen, reverse = true }) end)
	))

	left.area[2]:buttons(awful.util.table.join(
		awful.button({}, 9, function() if client.focus then client.focus.minimized = true end  end),
		awful.button({}, 4, function() switcher:show({ filter = currenttags })                 end),
		awful.button({}, 5, function() switcher:show({ filter = currenttags, reverse = true }) end)
	))

	left.wibox:connect_signal("mouse::leave", function() redflat.float.appswitcher:hide() end)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return edges
