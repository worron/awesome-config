-----------------------------------------------------------------------------------------------------------------------
--                                               Titlebar config                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful      = require("awful")
local wibox      = require("wibox")
local beautiful  = require("beautiful")
local color      = require("gears.color")

-- local redflat = require("redflat")
local redtitle   = require("redflat.titlebar")
local redutil    = require("redflat.util")
local clientmenu = require("redflat.float.clientmenu")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local titlebar = {}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function construct_move_buttons(c, btn)
	return awful.button({ }, btn or 1, function() client.focus = c; c:raise() awful.mouse.client.move(c) end)
end
local function construct_menu_buttons(c, btn)
	return awful.button({ }, btn or 1, function() client.focus = c; c:raise() clientmenu:show(c) end)
end
local function construct_all_buttons(c, move_btn, menu_btn)
	return awful.util.table.join(construct_move_buttons(c, move_btn), construct_menu_buttons(c, menu_btn))
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
		if is_max then
			c.y = c.screen.workarea.y
		end
	end
end

-- Custom titlebar elements
-----------------------------------------------------------------------------------------------------------------------
local compact_focus = function(c, style)
	local focus = redtitle.mark.focus(c, style)

	function focus:draw(_, cr, width, height)
		local d = math.tan(self._style.angle) * height

		cr:set_source(color(self._data.color))
		cr:move_to(0, height)
		cr:rel_line_to(d, -height)
		cr:rel_line_to(width - d, 0)
		cr:rel_line_to(0, height)
		cr:close_path()
		cr:fill()
	end

	return focus
end

-- Connect titlebar building signal
-----------------------------------------------------------------------------------------------------------------------
function titlebar:init()

	local style = {}

	-- titlebar schemes
	style.base    = redutil.table.merge(redutil.table.check(beautiful, "titlebar.base") or {}, { size = 8 })
	style.compact = redutil.table.merge(style.base, { size = 16 })
	style.iconic  = redutil.table.merge(style.base, { size = 24 })

	-- titlebar elements styles
	style.mark_mini = redutil.table.merge(
		redutil.table.check(beautiful, "titlebar.mark") or {},
		{ size = 30, gap = 10, angle = 0 }
	)
	style.mark_compact = redutil.table.merge(
		style.mark_mini,
		{ size = 20, gap = 6, angle = 0.707 }
	)
	style.icon_full = redutil.table.merge(
		redutil.table.check(beautiful, "titlebar.icon") or {},
		{ gap = 10 }
	)

	style.icon_compact = redutil.table.merge(
		redutil.table.check(beautiful, "titlebar.icon_compact") or style.icon_full,
		{ gap = 8 }
	)

	redtitle._index    = 1 -- choose default titlebar model

	-- titlebar setup for clients
	client.connect_signal(
		"request::titlebars",
		function(c)
			-- build titlebar and mouse buttons for it
			local menu_buttons = construct_menu_buttons(c)
			local move_buttons = construct_move_buttons(c)
			local all_buttons = construct_all_buttons(c, 1, 3)
			redtitle(c, style.base)

			-- build mini titlebar model
			local base  = wibox.widget({
				nil,
				{
					right  = style.mark_mini.gap,
					redtitle.mark.focus(c, style.mark_mini),
					layout = wibox.container.margin,
				},
				{
					redtitle.mark.property(c, "floating", style.mark_mini),
					redtitle.mark.property(c, "sticky", style.mark_mini),
					redtitle.mark.property(c, "ontop", style.mark_mini),
					spacing = style.mark_mini.gap,
					layout  = wibox.layout.fixed.horizontal()
				},
				buttons = all_buttons,
				layout  = wibox.layout.align.horizontal,
			})

			-- build compact titlebar model
			local focus = redtitle.button.focus(c, style.icon_compact)
			focus:buttons(menu_buttons)

			local compact = wibox.widget({
				{
					focus,
					{
						{
							{
								redtitle.mark.property(c, "floating", style.mark_compact),
								redtitle.mark.property(c, "sticky", style.mark_compact),
								redtitle.mark.property(c, "ontop", style.mark_compact),
								redtitle.mark.property(c, "below", style.mark_compact),
								spacing = style.mark_compact.gap,
								layout  = wibox.layout.fixed.horizontal
							},
							{
								compact_focus(c, style.mark_compact),
								left = style.mark_compact.gap,
								layout = wibox.container.margin,
							},

							layout  = wibox.layout.align.horizontal
						},
						top = 3, bottom = 3, right = style.icon_compact.gap + 2, left = style.icon_compact.gap + 2,
						layout = wibox.container.margin,
					},
					{
						redtitle.button.property(c, "minimized", style.icon_compact),
						redtitle.button.property(c, "maximized", style.icon_compact),
						redtitle.button.close(c, style.icon_compact),
						spacing = style.icon_compact.gap,
						layout  = wibox.layout.fixed.horizontal()
					},
					buttons = move_buttons,
					layout  = wibox.layout.align.horizontal,

				},
				left = 4, right = 4,
				widget = wibox.container.margin
			})

			-- build titlebar model with control buttons
			local title = redtitle.label(c, style.iconic, true)
			title:buttons(move_buttons)

			local menu = redtitle.button.base("menu", style.icon_full)
			menu:buttons(menu_buttons)

			local iconic = wibox.widget({
				{
					{
						menu,
						redtitle.button.property(c, "floating", style.icon_full),
						redtitle.button.property(c, "sticky", style.icon_full),
						spacing = style.icon_full.gap,
						layout  = wibox.layout.fixed.horizontal()
					},
					top = 2, bottom = 2, left = 4,
					widget = wibox.container.margin
				},
				title,
				{
					{
						redtitle.button.property(c, "minimized", style.icon_full),
						redtitle.button.property(c, "maximized", style.icon_full),
						redtitle.button.close(c, style.icon_full),
						spacing = style.icon_full.gap,
						layout  = wibox.layout.fixed.horizontal()
					},
					top = 2, bottom = 2, right = 4,
					widget = wibox.container.margin
				},

				layout = wibox.layout.align.horizontal,
			})

			-- Set both models to titlebar
			redtitle.add_layout(c, nil, base, style.base.size)
			redtitle.add_layout(c, nil, compact, style.compact.size)
			redtitle.add_layout(c, nil, iconic, style.iconic.size)
			redtitle.switch(c, nil, redtitle._index)

			-- hide titlebar when window maximized
			if c.maximized_vertical or c.maximized then
				on_maximize(c)
			end

			c:connect_signal("property::maximized_vertical", on_maximize)
			c:connect_signal("property::maximized", on_maximize)
		end
	)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return titlebar
