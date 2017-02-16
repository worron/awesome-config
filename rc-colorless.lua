-----------------------------------------------------------------------------------------------------------------------
--                                                Colorless config                                                   --
-----------------------------------------------------------------------------------------------------------------------

-- Load modules
-----------------------------------------------------------------------------------------------------------------------

-- Standard awesome library
------------------------------------------------------------
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- make this global temporary, fix later
naughty = require("naughty")

-- require("debian.menu")
require("awful.autofocus")

-- User modules
------------------------------------------------------------
local redflat = require("redflat")

-- Error handling
-----------------------------------------------------------------------------------------------------------------------
require("colorless.ercheck-config") -- load file with error handling

-- Common functions variables
-----------------------------------------------------------------------------------------------------------------------

-- vars
local env = {
	terminal = "x-terminal-emulator",
	mod = "Mod4",
	fm = "nautilus",
	home = os.getenv("HOME"),
}

env.editor_cmd = env.terminal .. " -e " .. (os.getenv("EDITOR") or "editor")
-- env.themedir = env.home .. "/.config/awesome/themes/colorless"
env.themedir = awful.util.get_configuration_dir() .. "themes/colorless"

-- wallpaper setup
env.wallpaper = function(s)
	if beautiful.wallname then
		local wallpaper = env.themedir .. "/wallpaper/" .. beautiful.wallname

		if awful.util.file_readable(wallpaper) then
			gears.wallpaper.maximized(wallpaper, s, true)
		else
			gears.wallpaper.set(beautiful.color.bg)
		end
	end
end

-- panel widgets wrapper
env.wrapper = function(widget, name, buttons)
	local margin = { 0, 0, 0, 0 }

	if redflat.util.check(beautiful, "widget.wrapper") and beautiful.widget.wrapper[name] then
		margin = beautiful.widget.wrapper[name]
	end
	if buttons then
		widget:buttons(buttons)
	end

	return wibox.container.margin(widget, unpack(margin))
end

-- load theme
beautiful.init(env.themedir .. "/theme.lua")

-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
}

-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("colorless.menu-config") -- load file with menu configuration
local mainmenu = mymenu:build({ env = env })

local launcher = {}
launcher.widget = redflat.gauge.svgbox(mymenu.icon, nil, mymenu.color)
launcher.buttons = awful.util.table.join(
	awful.button({ }, 1, function () mainmenu:toggle() end)
)


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separator
--------------------------------------------------------------------------------
local separator = redflat.gauge.separator.vertical()

-- Tasklist
--------------------------------------------------------------------------------
-- local function client_menu_toggle_fn()
-- 	local instance = nil

-- 	return function ()
-- 		if instance and instance.wibox.visible then
-- 			instance:hide()
-- 			instance = nil
-- 		else
-- 			instance = awful.menu.clients({ theme = { width = 250 } })
-- 		end
-- 	end
-- end


local tasklist_buttons = awful.util.table.join(
	awful.button({ }, 1,
		function (c)
			if c == client.focus then
				c.minimized = true
			else
				c.minimized = false
				if not c:isvisible() and c.first_tag then c.first_tag:view_only() end
				client.focus = c
				c:raise()
			end
		end
	),
	-- awful.button({ }, 3, client_menu_toggle_fn()),
	awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
	awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

-- Taglist widget
--------------------------------------------------------------------------------
local taglist = {}
taglist.style = { separator = separator, widget = redflat.gauge.tag.blue.new, show_tip = true }
taglist.buttons = awful.util.table.join(
	awful.button({         }, 1, function(t) t:view_only() end),
	awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({         }, 2, awful.tag.viewtoggle),
	awful.button({         }, 3, function(t) redflat.widget.layoutbox:toggle_menu(t) end),
	awful.button({ env.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({         }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({         }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Textclock widget
--------------------------------------------------------------------------------
local textclock = {}
textclock.widget = redflat.widget.textclock({ timeformat = "%H:%M", dateformat = "%b  %d  %a" })

-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
	awful.button({ }, 1, function () awful.layout.inc( 1) end),
	awful.button({ }, 3, function () redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)
)


-- Screen setup
-----------------------------------------------------------------------------------------------------------------------
awful.screen.connect_for_each_screen(
	function(s)
		-- wallpaper
		env.wallpaper(s)

		-- tags
		awful.tag({ "Tag1", "Tag2", "Tag3", "Tag4", "Tag5" }, s, awful.layout.layouts[1])

		-- Create a promptbox for each screen
		s.mypromptbox = awful.widget.prompt()

		-- layoutbox
		layoutbox[s] = redflat.widget.layoutbox({ screen = s })

		-- taglist widget
		taglist[s] = redflat.widget.taglist({screen = s, buttons = taglist.buttons}, taglist.style)

		-- tasklist widget
		s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

		-- panel wibox
		s.panel = awful.wibar({ position = "bottom", screen = s, height = beautiful.panel_height or 36 })

		-- add widgets to the wibox
		s.panel:setup {
			layout = wibox.layout.align.horizontal,
			{ -- left widgets
				layout = wibox.layout.fixed.horizontal,

				env.wrapper(launcher.widget, "mainmenu", launcher.buttons),
				separator,
				env.wrapper(taglist[s], "taglist"),
				-- taglist[s],
				separator,
				s.mypromptbox,
			},
			s.mytasklist, -- middle widget
			{ -- right widgets
				layout = wibox.layout.fixed.horizontal,

				wibox.widget.systray(),
				env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
				separator,
				env.wrapper(textclock.widget, "textclock"),
			},
		}
	end
)
-- }}}

-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = require("colorless.keys-config") -- load file with hotkeys configuration

hotkeys:init({ env = env, menu = mainmenu })

-- set global keys
root.keys(hotkeys.keys.root)

-- set global(desktop) mouse buttons
root.buttons(hotkeys.mouse.root)


-- Rules
-----------------------------------------------------------------------------------------------------------------------
local rules = require("colorless.rules-config") -- load file with rules configuration
rules:init({ hotkeys = hotkeys})

awful.rules.rules = rules.rules


-- Signals setup
-----------------------------------------------------------------------------------------------------------------------
client.connect_signal("manage", function (c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup
	   and not c.size_hints.user_position
	   and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- -- Add a titlebar if titlebars_enabled is set to true in the rules.
-- client.connect_signal("request::titlebars", function(c)
--     -- buttons for the titlebar
--     local buttons = awful.util.table.join(
--         awful.button({ }, 1, function()
--             client.focus = c
--             c:raise()
--             awful.mouse.client.move(c)
--         end),
--         awful.button({ }, 3, function()
--             client.focus = c
--             c:raise()
--             awful.mouse.client.resize(c)
--         end)
--     )

--     awful.titlebar(c) : setup {
--         { -- Left
--             awful.titlebar.widget.iconwidget(c),
--             buttons = buttons,
--             layout  = wibox.layout.fixed.horizontal
--         },
--         { -- Middle
--             { -- Title
--                 align  = "center",
--                 widget = awful.titlebar.widget.titlewidget(c)
--             },
--             buttons = buttons,
--             layout  = wibox.layout.flex.horizontal
--         },
--         { -- Right
--             awful.titlebar.widget.floatingbutton (c),
--             awful.titlebar.widget.maximizedbutton(c),
--             awful.titlebar.widget.stickybutton   (c),
--             awful.titlebar.widget.ontopbutton    (c),
--             awful.titlebar.widget.closebutton    (c),
--             layout = wibox.layout.fixed.horizontal()
--         },
--         layout = wibox.layout.align.horizontal
--     }
-- end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
		and awful.client.focus.filter(c) then
		client.focus = c
	end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

screen.connect_signal("property::geometry", env.wallpaper)
