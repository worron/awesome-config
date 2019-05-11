-----------------------------------------------------------------------------------------------------------------------
--                                               Titlebar config                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
--local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

-- local redflat = require("redflat")
local redtitle = require("redflat.titlebar")
local redutil = require("redflat.util")
--local clientmenu = require("redflat.float.clientmenu")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local titlebar = {}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function on_maximize(c)
	-- hide/show title bar
	local is_max = c.maximized_vertical or c.maximized
	local action = is_max and "cut_all" or "restore_all"
	redtitle[action]({ c })

	-- dirty size correction
	local model = redtitle.get_model(c)
	if model and not model.hidden then
		local size_shift = is_max and model.size or -model.size
		local g = c:geometry()
		c:geometry({ height = g.height + 2 * size_shift, width = g.width + 2 * size_shift })

		if is_max then
			c.y = c.screen.workarea.y
			c.x = c.screen.workarea.x
		end
	end
end

local focus_line_shape = function(cr, width, height)
	cr:move_to(0, height)
	cr:rel_line_to(height, - height)
	cr:rel_line_to(width - 2 * height, 0)
	cr:rel_line_to(height, height)
	cr:close_path()
end

local focus_line_style = {
	line  = { width = 3, dx = 30, dy = 20, subwidth = 6 },
	border = { width = 8 },
	color = { gray = "#404040", main = "#025A73", wibox = "#202020" },
}

local function focus_line(c, style, is_horizontal)
	-- build widget
	local widg = wibox.widget.base.make_widget()
	widg._style = redutil.table.merge(focus_line_style, style or {})
	widg._data = { color = widg._style.color.gray }

	-- widget setup
	function widg:fit(_, _, width, height)
		return width, height
	end

	function widg:draw(_, cr, width, height)
		local dy = self._style.line.subwidth - self._style.line.width
		local dw = is_horizontal and self._style.line.dx or self._style.line.dy

		cr:set_source(color(self._style.color.wibox))
		cr:rectangle(0, height, width, -self._style.border.width)
		cr:fill()

		cr:set_source(color(self._data.color))
		cr:rectangle(0, dy, width, self._style.line.width)
		cr:fill()

		cr:rectangle(0, 0, dw, self._style.line.subwidth)
		cr:rectangle(width, 0, -dw, self._style.line.subwidth)
		if is_horizontal then
			cr:rectangle(0, 0, self._style.line.subwidth, height)
			cr:rectangle(width, 0, -self._style.line.subwidth, height)
		end
		cr:fill()
	end

	-- user function
	function widg:set_active(active)
		self._data.color = active and self._style.color.main or self._style.color.gray
		self:emit_signal("widget::redraw_needed")
	end

	-- connect focus signal
	c:connect_signal("focus", function() widg:set_active(true) end)
	c:connect_signal("unfocus", function() widg:set_active(false) end)

	return widg
end


-- Connect titlebar building signal
-----------------------------------------------------------------------------------------------------------------------
function titlebar:init()

	local style = {}

	-- titlebar schemes
	local theme_base = redutil.table.check(beautiful, "titlebar.base") or { color = {} }

	style.base = redutil.table.merge(
		theme_base,
		{ size = 12, color = { wibox = "#00000000" }, border_margin = { 0, 0, 0, 0 } }
	)

	style.focus = { color = theme_base.color }

	local original_wibox_color = theme_base.color.wibox or "#202020"

	-- titlebar elements styles
	style.mark_mini = redutil.table.merge(
		redutil.table.check(beautiful, "titlebar.mark") or {},
		{ size = 30, gap = 10, angle = 0 }
	)

	-- titlebar setup for clients
	client.connect_signal(
		"request::titlebars",
		function(c)
			redtitle(c, redutil.table.merge(style.base, { position = "top" }))
			redtitle(c, redutil.table.merge(style.base, { position = "bottom" }))
			redtitle(c, redutil.table.merge(style.base, { position = "right" }))
			redtitle(c, redutil.table.merge(style.base, { position = "left" }))

			-- focus lines
			local hfocus = focus_line(c, style.focus, true)
			local vfocus = focus_line(c, style.focus)

			-- state marks
			local marks = wibox.widget({
				nil,
				{
					{
						{
							redtitle.mark.property(c, "floating", style.mark_mini),
							redtitle.mark.property(c, "sticky", style.mark_mini),
							redtitle.mark.property(c, "ontop", style.mark_mini),
							redtitle.mark.property(c, "below", style.mark_mini),
							spacing = style.mark_mini.gap,
							layout  = wibox.layout.fixed.horizontal
						},
						top = 4, bottom = 4, left = 20, right = 20,
						widget = wibox.container.margin,
					},
					bg = original_wibox_color,
					shape  = focus_line_shape,
					widget = wibox.container.background
				},
				nil,
				expand = 'outside',
				layout = wibox.layout.align.horizontal,
			})

			-- combine focus and stata marks for top title bar
			local title = wibox.widget {
				hfocus,
				marks,
				layout = wibox.layout.stack
			}

			-- Set models to titlebar
			redtitle.add_layout(c, "top", title, style.base.size)
			redtitle.add_layout(c, "bottom", wibox.container.rotate(hfocus, "south"), style.base.size)
			redtitle.add_layout(c, "right", wibox.container.rotate(vfocus, "west"), style.base.size)
			redtitle.add_layout(c, "left", wibox.container.rotate(vfocus, "east"), style.base.size)

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
