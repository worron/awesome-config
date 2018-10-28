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

-- Widget icons
--------------------------------------------------------------------------------
theme.icon.widget = {
	battery    = theme.path .. "/widget/battery.svg",
	wireless   = theme.path .. "/widget/wireless.svg",
	monitor    = theme.path .. "/widget/monitor.svg",
	audio      = theme.path .. "/widget/audio.svg",
	headphones = theme.path .. "/widget/headphones.svg",
	brightness = theme.path .. "/widget/brightness.svg",
	keyboard   = theme.path .. "/widget/keyboard.svg",
	mail       = theme.path .. "/widget/mail.svg",
	upgrades   = theme.path .. "/widget/upgrades.svg",
}

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

-- Pulseaudio volume control
--------------------------------------------------------------------------------
theme.widget.pulse.audio  = { icon = theme.icon.widget.headphones }
theme.widget.pulse.notify = { icon = theme.icon.widget.audio }

-- Keyboard layout indicator
--------------------------------------------------------------------------------
theme.widget.keyboard.icon = theme.icon.widget.keyboard

-- Mail indicator
--------------------------------------------------------------------------------
theme.widget.mail.icon = theme.icon.widget.mail

-- System updates indicator
------------------------------------------------------------
theme.widget.upgrades.notify = { icon = theme.icon.widget.upgrades }

-- Floating widgets
-----------------------------------------------------------------------------------------------------------------------

-- Brightness control
--------------------------------------------------------------------------------
theme.float.brightness.notify = { icon = theme.icon.widget.brightness }

---- Minitray
--------------------------------------------------------------
--theme.widget.minitray = {
--	border_width = 0,
--	geometry     = { height = 40 },
--	screen_gap   = 2 * theme.useless_gap,
--	color        = { wibox = theme.color.wibox, border = theme.color.wibox },
--	set_position = function()
--		return { x = mouse.screen.workarea.x + mouse.screen.workarea.width,
--		         y = mouse.screen.workarea.y + mouse.screen.workarea.height }
--	end,
--}
--
---- Layoutbox
--------------------------------------------------------------
--theme.widget.layoutbox = {
--	micon = theme.icon,
--	color = theme.color
--}
--
--theme.widget.layoutbox.icon = {
--	floating          = theme.path .. "/layouts/floating.svg",
--	max               = theme.path .. "/layouts/max.svg",
--	fullscreen        = theme.path .. "/layouts/fullscreen.svg",
--	tilebottom        = theme.path .. "/layouts/tilebottom.svg",
--	tileleft          = theme.path .. "/layouts/tileleft.svg",
--	tile              = theme.path .. "/layouts/tile.svg",
--	tiletop           = theme.path .. "/layouts/tiletop.svg",
--	fairv             = theme.path .. "/layouts/fair.svg",
--	fairh             = theme.path .. "/layouts/fair.svg",
--	grid              = theme.path .. "/layouts/grid.svg",
--	usermap           = theme.path .. "/layouts/map.svg",
--	magnifier         = theme.path .. "/layouts/magnifier.svg",
--	cornerne          = theme.path .. "/layouts/cornerne.svg",
--	cornernw          = theme.path .. "/layouts/cornernw.svg",
--	cornerse          = theme.path .. "/layouts/cornerse.svg",
--	cornersw          = theme.path .. "/layouts/cornersw.svg",
--	unknown           = theme.path .. "/common/unknown.svg",
--}
--
--theme.widget.layoutbox.menu = {
--	icon_margin  = { 8, 12, 9, 9 },
--	width        = 220,
--	auto_hotkey  = true,
--	nohide       = false,
--	color        = { right_icon = theme.color.icon, left_icon = theme.color.icon }
--}
--
--theme.widget.layoutbox.name_alias = {
--	floating          = "Floating",
--	fullscreen        = "Fullscreen",
--	max               = "Maximized",
--	grid              = "Grid",
--	usermap           = "User Map",
--	tile              = "Right Tile",
--	fairv             = "Fair Tile",
--	tileleft          = "Left Tile",
--	tiletop           = "Top Tile",
--	tilebottom        = "Bottom Tile",
--	magnifier         = "Magnifier",
--	cornerne          = "Corner NE",
--	cornernw          = "Corner NW",
--	cornerse          = "Corner SE",
--	cornersw          = "Corner SW",
--}
--
---- Tasklist
--------------------------------------------------------------
--theme.widget.tasklist = {
--	char_digit  = 5,
--	task        = theme.gauge.task.blue
--}
--
---- main
--theme.widget.tasklist.winmenu = {
--	micon          = theme.icon,
--	titleline      = { font = theme.fonts.title, height = 25 },
--	menu           = { width = 220, color = { right_icon = theme.color.icon }, ricon_margin = { 9, 9, 9, 9 } },
--	state_iconsize = { width = 18, height = 18 },
--	layout_icon    = theme.widget.layoutbox.icon,
--	hide_action    = { min = false, move = false },
--	color          = theme.color
--}
--
---- tasktip
--theme.widget.tasklist.tasktip = {
--	margin = { 8, 8, 4, 4 },
--	color  = theme.color
--}
--
---- tags submenu
--theme.widget.tasklist.winmenu.tagmenu = {
--	width       = 180,
--	icon_margin = { 9, 9, 9, 9 },
--	color       = { right_icon = theme.color.icon, left_icon = theme.color.icon },
--}
--
---- menu
--theme.widget.tasklist.winmenu.icon = {
--	floating             = theme.path .. "/common/window_control/floating.svg",
--	sticky               = theme.path .. "/common/window_control/pin.svg",
--	ontop                = theme.path .. "/common/window_control/ontop.svg",
--	below                = theme.path .. "/common/window_control/below.svg",
--	close                = theme.path .. "/common/window_control/close.svg",
--	minimize             = theme.path .. "/common/window_control/minimize.svg",
--	maximized            = theme.path .. "/common/window_control/maximized.svg",
--}
--
--
---- Floating widgets
-------------------------------------------------------------------------------------------------------------------------
--theme.float = { decoration = {} }
--
---- Client menu
--------------------------------------------------------------
--theme.float.clientmenu = {
--	micon          = theme.icon,
--	color          = theme.color,
--	actionline     = { height = 28 },
--	layout_icon    = theme.widget.layoutbox.icon,
--	menu           = theme.widget.tasklist.winmenu.menu,
--	state_iconsize = theme.widget.tasklist.winmenu.state_iconsize,
--	tagmenu        = theme.widget.tasklist.winmenu.tagmenu,
--	icon           = theme.widget.tasklist.winmenu.icon,
--}
--
---- Audio player
--------------------------------------------------------------
--theme.float.player = {
--	geometry     = { width = 490, height = 130 },
--	screen_gap   = 2 * theme.useless_gap,
--	border_gap   = { 15, 15, 15, 15 },
--	elements_gap = { 15, 0, 0, 0 },
--	control_gap  = { 0, 0, 14, 6 },
--	line_height  = 26,
--	bar_width    = 6,
--	titlefont    = theme.fonts.player.main,
--	artistfont   = theme.fonts.player.main,
--	timefont     = theme.fonts.player.time,
--	dashcontrol  = { color = theme.color, bar = { num = 7 } },
--	progressbar  = { color = theme.color },
--	border_width = 0,
--	timeout      = 1,
--	color        = theme.color
--}
--
--theme.float.player.icon = {
--	cover   = theme.path .. "/common/player/cover.svg",
--	next_tr = theme.path .. "/common/player/next.svg",
--	prev_tr = theme.path .. "/common/player/previous.svg",
--	play    = theme.path .. "/common/player/play.svg",
--	pause   = theme.path .. "/common/player/pause.svg"
--}
--
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
