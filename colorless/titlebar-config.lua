-----------------------------------------------------------------------------------------------------------------------
--                                               Titlebar config                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local wibox = require("wibox")

-- local redflat = require("redflat")
local redtitle = require("redflat.titlebar")

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
	end
end

-- Connect titlebar building signal
-----------------------------------------------------------------------------------------------------------------------
function titlebar:init(args)

	local args = args or {}
	local style = {}

	style.light = args.light or redtitle.get_style()
	style.full = args.full or { size = 28, icon = { size = 25, gap = 0, angle = 0.5 } }

	client.connect_signal(
		"request::titlebars",
		function(c)
			-- build titlebar and mouse buttons for it
			local buttons = title_buttons(c)
			local bar = redtitle(c)

			-- build light titlebar model
			local light = wibox.widget({
				nil,
				{
					right = style.light.icon.gap,
					redtitle.icon.focus(c),
					layout = wibox.container.margin,
				},
				{
					redtitle.icon.property(c, "floating"),
					redtitle.icon.property(c, "sticky"),
					redtitle.icon.property(c, "ontop"),
					spacing = style.light.icon.gap,
					layout = wibox.layout.fixed.horizontal()
				},
				buttons = buttons,
				layout  = wibox.layout.align.horizontal,
			})

			-- build full titlebar model
			local full = wibox.widget({
				redtitle.icon.focus(c, style.full),
				redtitle.icon.label(c, style.full),
				{
					redtitle.icon.property(c, "floating", style.full),
					redtitle.icon.property(c, "sticky", style.full),
					redtitle.icon.property(c, "ontop", style.full),
					spacing = style.full.icon.gap,
					layout = wibox.layout.fixed.horizontal()
				},
				buttons = buttons,
				layout  = wibox.layout.align.horizontal,
			})

			-- Set both models to titlebar
			redtitle.add_layout(c, nil, light)
			redtitle.add_layout(c, nil, full, style.full.size)

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
