-----------------------------------------------------------------------------------------------------------------------
--                                                Signals config                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local beautiful = require("beautiful")

local redutil  = require("redflat.util")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local signals = {}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function do_sloppy_focus(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
		client.focus = c
	end
end

local function fixed_maximized_geometry(c, context)
	if c.maximized and context ~= "fullscreen" then
		c:geometry({
			x = c.screen.workarea.x,
			y = c.screen.workarea.y,
			height = c.screen.workarea.height - 2 * c.border_width,
			width = c.screen.workarea.width - 2 * c.border_width
		})
	end
end

-- Build  table
-----------------------------------------------------------------------------------------------------------------------
function signals:init(args)

	args = args or {}
	local env = args.env

	-- actions on every application start
	client.connect_signal(
		"manage",
		function(c)
			-- put client at the end of list
			if env.set_slave then awful.client.setslave(c) end

			-- startup placement
			if awesome.startup
			   and not c.size_hints.user_position
			   and not c.size_hints.program_position
			then
				awful.placement.no_offscreen(c)
			end

			-- put new floating windows to the center of screen
			if env.set_center and c.floating and not (c.maximized or c.fullscreen) then
				redutil.placement.centered(c, nil, mouse.screen.workarea)
			end
		end
	)

	-- add missing borders to windows that get unmaximized
	client.connect_signal(
		"property::maximized",
		function(c)
			if not c.maximized then
				c.border_width = beautiful.border_width
			end
		end
	)

	-- don't allow maximized windows move/resize themselves
	client.connect_signal(
		"request::geometry", fixed_maximized_geometry
	)

	-- enable sloppy focus, so that focus follows mouse
	if env.sloppy_focus then
		client.connect_signal("mouse::enter", do_sloppy_focus)
	end

	-- hilight border of focused window
	-- can be disabled since focus indicated by titlebars in current config
	if env.color_border_focus then
		client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus end)
		client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
	end

	-- wallpaper update on screen geometry change
	screen.connect_signal("property::geometry", env.wallpaper)

	-- Awesome v4.0 introduce screen handling without restart.
	-- All redflat panel widgets was designed in old fashioned way and doesn't support this fature properly.
	-- Since I'm using single monitor setup I have no will to rework panel widgets by now,
	-- so restart signal added here is simple and dirty workaround.
	-- You can disable it on your own risk.
	screen.connect_signal("list", awesome.restart)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return signals
