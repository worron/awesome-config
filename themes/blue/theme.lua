-----------------------------------------------------------------------------------------------------------------------
--                                                   Blue theme                                                      --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- This theme inherited from colorless with overwriting some values
local theme = require("themes/colored/theme")


-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color.main   = "#064E71"
theme.color.urgent = "#B32601"

-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/blue"

-- Main config
--------------------------------------------------------------------------------
theme.wallpaper = theme.path .. "/wallpaper/custom.png" -- wallpaper file

-- Setup ancestor settings
--------------------------------------------------------------------------------
theme:update()


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- individual margins for palnel widgets
--------------------------------------------------------------------------------
theme.widget.wrapper = {
	layoutbox   = { 12, 10, 6, 6 },
	textclock   = { 10, 10, 0, 0 },
	volume      = { 10, 10, 5, 5 },
	network     = { 10, 10, 5, 5 },
	cpuram      = { 10, 10, 5, 5 },
	keyboard    = { 10, 10, 4, 4 },
	mail        = { 10, 10, 4, 4 },
	battery     = { 8, 10, 7, 7 },
	tray        = { 8, 8, 7, 7 },
	tasklist    = { 4, 0, 0, 0 }, -- centering tasklist widget
}

-- Tasklist
--------------------------------------------------------------------------------
theme.widget.tasklist.char_digit = 5
theme.widget.tasklist.task = theme.gauge.task.blue


-- Floating widgets
-----------------------------------------------------------------------------------------------------------------------

---- Top processes
--------------------------------------------------------------
--theme.float.top = {
--	geometry      = { width = 460, height = 400 },
--	screen_gap    = 2 * theme.useless_gap,
--	border_margin = { 20, 20, 10, 0 },
--	button_margin = { 140, 140, 18, 18 },
--	title_height  = 40,
--	border_width  = 0,
--	bottom_height = 70,
--	title_font    = theme.fonts.title,
--	color         = theme.color,
--	set_position  = function()
--		return { x = mouse.screen.workarea.x + mouse.screen.workarea.width,
--		         y = mouse.screen.workarea.y + mouse.screen.workarea.height }
--	end,
--}
--

---- Decoration elements
--------------------------------------------------------------
--theme.float.decoration.button = {
--	color = {
--		shadow3 = theme.color.shadow3,
--		shadow4 = theme.color.shadow4,
--		gray    = theme.color.gray,
--		text    = "#cccccc"
--	},
--}
--
--theme.float.decoration.field = {
--	color = theme.color
--}
--
--
---- Titlebar
-------------------------------------------------------------------------------------------------------------------------
--theme.titlebar = {
--	size          = 8,
--	position      = "top",
--	font          = theme.fonts.titlebar,
--	icon          = { size = 30, gap = 10 },
--	border_margin = { 0, 0, 0, 4 },
--	color         = theme.color,
--}
--
---- Naughty config
-------------------------------------------------------------------------------------------------------------------------
--theme.naughty = {}
--
--theme.naughty.base = {
--	timeout      = 10,
--	margin       = 12,
--	icon_size    = 80,
--	font         = theme.fonts.main,
--	bg           = theme.color.wibox,
--	fg           = theme.color.text,
--	height       = theme.float.notify.geometry.height,
--	width        = theme.float.notify.geometry.width,
--	border_width = 4,
--	border_color = theme.color.wibox
--}
--
--theme.naughty.normal = {}
--theme.naughty.critical = { timeout = 0, border_color = theme.color.main }
--theme.naughty.low = { timeout = 5 }
--
---- Default awesome theme vars
-------------------------------------------------------------------------------------------------------------------------
--
---- colors
--theme.bg_normal     = theme.color.wibox
--theme.bg_focus      = theme.color.main
--theme.bg_urgent     = theme.color.urgent
--theme.bg_minimize   = theme.color.gray
--
--theme.fg_normal     = theme.color.text
--theme.fg_focus      = theme.color.highlight
--theme.fg_urgent     = theme.color.highlight
--theme.fg_minimize   = theme.color.highlight
--
--theme.border_normal = theme.color.wibox
--theme.border_focus  = theme.color.wibox
--theme.border_marked = theme.color.main
--
---- font
--theme.font = theme.fonts.main
--
---- misc
--theme.enable_spawn_cursor = false

-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
