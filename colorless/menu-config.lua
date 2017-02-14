-----------------------------------------------------------------------------------------------------------------------
--                                                  Menu config                                                      --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local beautiful = require("beautiful")
local redflat = require("redflat")
local awful = require("awful")
local naughty = require("naughty")


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local menu = {}

-- Build function
--------------------------------------------------------------------------------
function menu.build(args)

	local args = args or {}
	local env = args.env or {} -- fix this?
	local separator = args.separator or { widget = redflat.gauge.separator.horizontal() }
	local theme = args.theme or { auto_hotkey = true }
	local icon_style = args.icon_style or {}

	-- Application submenu
	------------------------------------------------------------
	local appmenu = redflat.service.dfparser.menu({ icons = icon_style, wm_name = "awesome" })

	-- Main menu
	------------------------------------------------------------
	local mainmenu = redflat.menu({ theme = theme,
		items = {
			{ "Applications",  appmenu,      },
			{ "Terminal",      env.terminal, },
			separator,
			{ "Test Item 0", function() naughty.notify({ text = "Test menu 0" }) end,           },
			{ "Test Item 1", function() naughty.notify({ text = "Test menu 1" }) end, key = "i" },
			{ "Test Item 2", function() naughty.notify({ text = "Test menu 2" }) end, key = "m" },
			separator,
			{ "Restart", awesome.restart, },
			{ "Exit", awesome.quit, },
		}
	})

	return mainmenu
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return menu
