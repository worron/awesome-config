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
function menu:init(args)

	-- vars
	args = args or {}
	local env = args.env or {} -- fix this?
	local separator = args.separator or { widget = redflat.gauge.separator.horizontal() }
	local theme = args.theme or { auto_hotkey = true }
	local icon_style = args.icon_style or {}

	-- Application submenu
	------------------------------------------------------------

	-- WARNING!
	-- 'dfparser' module used to parse available desktop files for building application list and finding app icons,
	-- it may cause significant delay on wm start/restart due to the synchronous type of the scripts.
	-- This issue can be reduced by using additional settings like custom desktop files directory
	-- and user only icon theme. See colored configs for more details.

	-- At worst, you can give up all applications widgets (appmenu, applauncher, appswitcher, qlaunch) in your config
	local appmenu = redflat.service.dfparser.menu({ icons = icon_style, wm_name = "awesome" })

	-- Main menu
	------------------------------------------------------------
	self.mainmenu = redflat.menu({ theme = theme,
		items = {
			{ "Applications",  appmenu,      },
			{ "Terminal",      env.terminal, },
			separator,
			{ "Test Item 0", function() naughty.notify({ text = "Test menu 0" }) end,           },
			{ "Test Item 1", function() naughty.notify({ text = "Test menu 1" }) end, key = "i" },
			{ "Test Item 2", function() naughty.notify({ text = "Test menu 2" }) end, key = "m" },
			separator,
			{ "Restart", awesome.restart, },
			{ "Exit",    awesome.quit, },
		}
	})

	-- Menu panel widget
	------------------------------------------------------------

	-- theme vars
	local deficon = redflat.util.base.placeholder()
	local icon = redflat.util.table.check(beautiful, "icon.awesome") and beautiful.icon.awesome or deficon
	local color = redflat.util.table.check(beautiful, "color.icon") and beautiful.color.icon or nil

	-- widget
	self.widget = redflat.gauge.svgbox(icon, nil, color)
	self.buttons = awful.util.table.join(
		awful.button({ }, 1, function () self.mainmenu:toggle() end)
	)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return menu
