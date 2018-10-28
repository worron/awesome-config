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

---- Application runner
--------------------------------------------------------------
--theme.float.apprunner = {
--	itemnum       = 6,
--	geometry      = { width = 620, height = 480 },
--	border_margin = { 24, 24, 24, 24 },
--	icon_margin   = { 8, 16, 0, 0 },
--	title_height  = 48,
--	prompt_height = 35,
--	title_icon    = theme.path .. "/widget/search.svg",
--	keytip        = { geometry = { width = 400, height = 250 } },
--	border_width  = 0,
--	name_font     = theme.fonts.title,
--	comment_font  = theme.fonts.main,
--	color         = theme.color
--}
--
---- Application switcher
--------------------------------------------------------------
--theme.float.appswitcher = {
--	wibox_height   = 240,
--	label_height   = 28,
--	title_height   = 40,
--	icon_size      = 96,
--	border_margin  = { 10, 10, 0, 10 },
--	preview_margin = { 15, 15, 15, 15 },
--	preview_format = 16 / 10,
--	title_font     = theme.fonts.title,
--	border_width   = 0,
--	update_timeout = 1 / 12,
--	keytip         = { geometry = { width = 400, height = 360 }, exit = true },
--	font           = theme.cairo_fonts.appswitcher,
--	color          = theme.color
--}
--
---- additional color
--theme.float.appswitcher.color.preview_bg = theme.color.main .. "12"
--
---- hotkeys
--theme.float.appswitcher.hotkeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
--                                    "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12" }
--
---- Quick launcher
--------------------------------------------------------------
--theme.float.qlaunch = {
--	geometry      = { width = 1400, height = 170 },
--	border_margin = { 5, 5, 12, 15 },
--	border_width  = 0,
--	appline       = { iwidth = 140, im = { 5, 5, 0, 0 }, igap = { 0, 0, 5, 15 }, lheight = 26 },
--	state         = { gap = 5, radius = 5, size = 10,  height = 14 },
--	df_icon       = theme.path .. "/common/system.svg",
--	no_icon       = theme.path .. "/common/unknown.svg",
--	recoloring    = true,
--	keytip        = { geometry = { width = 600, height = 320 } },
--	label_font    = theme.fonts.qlaunch,
--	color         = theme.color,
--}
--
---- Hotkeys helper
--------------------------------------------------------------
--theme.float.hotkeys = {
--	geometry      = { width = 1800, height = 1000 },
--	border_margin = { 20, 20, 8, 10 },
--	border_width  = 0,
--	is_align      = true,
--	separator     = { marginh = { 0, 0, 3, 6 } },
--	font          = theme.fonts.hotkeys.main,
--	keyfont       = theme.fonts.hotkeys.key,
--	titlefont     = theme.fonts.hotkeys.title,
--	color         = theme.color
--}
--
---- Tooltip
--------------------------------------------------------------
--theme.float.tooltip = {
--	margin       = { 6, 6, 3, 3 },
--	timeout      = 0,
--	font         = theme.fonts.tooltip,
--	border_width = 2,
--	color        = theme.color
--}
--
---- Floating prompt
--------------------------------------------------------------
--theme.float.prompt = {
--	border_width = 0,
--	color        = theme.color
--}
--
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
---- Key sequence tip
--------------------------------------------------------------
--theme.float.keychain = {
--	geometry        = { width = 250, height = 56 },
--	font            = theme.fonts.keychain,
--	border_width    = 0,
--	keytip          = { geometry = { width = 1200, height = 580 }, column = 2 },
--	color           = theme.color,
--}
--
---- Notify
--------------------------------------------------------------
--theme.float.notify = {
--	geometry     = { width = 484, height = 106 },
--	screen_gap   = 2 * theme.useless_gap,
--	font         = theme.fonts.notify,
--	border_width = 0,
--	icon         = theme.icon.warning,
--	color        = theme.color,
--	progressbar  = { color = theme.color },
--	set_position = function()
--		return { x = mouse.screen.workarea.x + mouse.screen.workarea.width, y = mouse.screen.workarea.y }
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
