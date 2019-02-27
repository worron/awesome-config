-----------------------------------------------------------------------------------------------------------------------
--                                               Titlebar config                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- local redflat = require("redflat")
local redtitle = require("redflat.titlebar")
local redutil = require("redflat.util")
local clientmenu = require("redflat.float.clientmenu")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local titlebar = {}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function title_buttons(c)
	return awful.util.table.join(
		awful.button(
			{ }, 1,
			function()
				client.focus = c;  c:raise()
				awful.mouse.client.move(c)
			end
		),
		awful.button(
			{ }, 3,
			function()
				client.focus = c;  c:raise()
				clientmenu:show(c)
			end
		)
	)
end

local function on_maximize(c)
	-- hide/show title bar
	local is_max = c.maximized_vertical or c.maximized
	local action = is_max and "cut_all" or "restore_all"
	redtitle[action]({ c })

	-- dirty size correction
	local model = redtitle.get_model(c)
	if model and not model.hidden then
		c.height = c:geometry().height + (is_max and model.size or -model.size)
		if is_max then c.y = c.screen.workarea.y end
	end
end

-- Connect titlebar building signal
-----------------------------------------------------------------------------------------------------------------------
function titlebar:init()

	local style     = {}

	-- titlebar schemes
	style.base   = redutil.table.check(beautiful, "titlebar") and beautiful.titlebar.base or {}
	style.full   = redutil.table.merge(style.base, { size = 28 })
	style.iconic = redutil.table.merge(style.base, { size = 28 })

	-- titlebar elements styles
	style.mark_mini = redutil.table.check(beautiful, "titlebar") and beautiful.titlebar.mark or { gap = 10 }
	style.mark_full = redutil.table.merge(style.mark_mini, { size = 25, gap = 0, angle = 0.5 })
	style.icon      = redutil.table.check(beautiful, "titlebar") and beautiful.titlebar.icon or { gap = 10 }

	-- titlebar setup for clients
	client.connect_signal(
		"request::titlebars",
		function(c)
			-- build titlebar and mouse buttons for it
			local buttons = title_buttons(c)
			redtitle(c, style.base)

			-- build mini titlebar model
			local base  = wibox.widget({
				nil,
				{
					right = style.mark_mini.gap,
					redtitle.mark.focus(c, style.mark_mini),
					layout = wibox.container.margin,
				},
				{
					redtitle.mark.property(c, "floating", style.mark_mini),
					redtitle.mark.property(c, "sticky", style.mark_mini),
					redtitle.mark.property(c, "ontop", style.mark_mini),
					spacing = style.mark_mini.gap,
					layout = wibox.layout.fixed.horizontal()
				},
				buttons = buttons,
				layout  = wibox.layout.align.horizontal,
			})

			-- build full sized titlebar model
			local full  = wibox.widget({
				redtitle.mark.focus(c, style.mark_full),
				redtitle.label(c, style.full),
				{
					redtitle.mark.property(c, "floating", style.mark_full),
					redtitle.mark.property(c, "sticky", style.mark_full),
					redtitle.mark.property(c, "ontop", style.mark_full),
					spacing = style.mark_full.gap,
					layout = wibox.layout.fixed.horizontal()
				},
				buttons = buttons,
				layout  = wibox.layout.align.horizontal,
			})

			-- build titlebar model with control buttons
			local title = redtitle.label(c, style.iconic)
			title:buttons(buttons)

			local focus_icon = redtitle.button.focus(c, style.icon)
			focus_icon:buttons(buttons)

			local iconic = wibox.widget({
				{
					focus_icon,
					title,
					{
						redtitle.button.property(c, "floating", style.icon),
						redtitle.button.property(c, "sticky", style.icon),
						redtitle.button.property(c, "minimized", style.icon),
						redtitle.button.property(c, "maximized", style.icon),
						redtitle.button.close(c, style.icon),
						spacing = style.icon.gap,
						layout = wibox.layout.fixed.horizontal()
					},
					--buttons = buttons,
					layout = wibox.layout.align.horizontal,
				},
				top = 2, bottom = 2, left = 4, right = 4,
				widget = wibox.container.margin
			})

			-- Set both models to titlebar
			redtitle.add_layout(c, nil, base, style.base.size)
			redtitle.add_layout(c, nil, full, style.full.size)
			redtitle.add_layout(c, nil, iconic, style.iconic.size)
			redtitle.switch(c, nil, redtitle._index)

			-- hide titlebar when window maximized
			if c.maximized_vertical or c.maximized then on_maximize(c) end

			c:connect_signal("property::maximized_vertical", on_maximize)
			c:connect_signal("property::maximized", on_maximize)
		end
	)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return titlebar
