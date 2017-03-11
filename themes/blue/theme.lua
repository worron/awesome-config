-----------------------------------------------------------------------------------------------------------------------
--                                                Colorless theme                                                    --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

local theme = {}
local wa = mouse.screen.workarea

-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color = {
	main      = "#064E71",
	gray      = "#575757",
	bg        = "#161616",
	bg_second = "#181818",
	wibox     = "#202020",
	icon      = "#a0a0a0",
	text      = "#aaaaaa",
	urgent    = "#B32601",
	highlight = "#ffffff",

	border    = "#404040",
	shadow1   = "#141414",
	shadow2   = "#313131",
	shadow3   = "#1c1c1c",
	shadow4   = "#767676"
}

-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/blue"
theme.homedir = os.getenv("HOME")

-- Main config
------------------------------------------------------------

theme.panel_height        = 36 -- panel height
theme.border_width        = 4  -- window border width
theme.useless_gap         = 4  -- useless gap

theme.wallpaper = theme.path .. "/wallpaper/custom.png" -- wallpaper file

-- Fonts
------------------------------------------------------------
theme.fonts = {
	main     = "Roboto 13",      -- main font
	menu     = "Roboto 13",      -- main menu font
	tooltip  = "Roboto 13",      -- tooltip font
	notify   = "Play bold 14",   -- redflat notify popup font
	clock    = "Play bold 12",   -- textclock widget font
	title    = "Roboto bold 13", -- widget titles font
	titlebar = "Roboto bold 13", -- client titlebar font
	hotkeys = {
		main  = "Roboto 14",             -- hotkeys helper main font
		key   = "Iosevka Term Light 14", -- hotkeys helper key font (use monospace for align)
		title = "Roboto bold 16",        -- hotkeys helper group title font
	},
}

theme.cairo_fonts = {
	tag         = { font = "Play", size = 16, face = 1 }, -- tag widget font
	appswitcher = { font = "Play", size = 20, face = 1 }, -- appswitcher widget font
	navigator   = {
		title = { font = "Play", size = 28, face = 1, slant = 0 }, -- window navigation title font
		main  = { font = "Play", size = 22, face = 1, slant = 0 }  -- window navigation  main font
	},
}

-- Shared icons
--------------------------------------------------------------------------------
theme.icon = {
	check    = theme.path .. "/common/check.svg",
	blank    = theme.path .. "/common/blank.svg",
	warning  = theme.path .. "/common/warning.svg",
	awesome  = theme.path .. "/common/awesome.svg",
}

-- Widget icons
--------------------------------------------------------------------------------
theme.icon.widget = {
	battery  = theme.path .. "/widget/battery.svg",
	wireless = theme.path .. "/widget/wireless.svg",
	monitor  = theme.path .. "/widget/monitor.svg",
}


-- Desktop config
-----------------------------------------------------------------------------------------------------------------------
theme.desktop = { common = {} }

-- Common
--------------------------------------------------------------------------------
theme.desktop.line_height = 18

theme.desktop.color = {
	main  = theme.color.main,
	gray  = theme.color.gray_desktop or "#404040",
	wibox = theme.color.bg .. "00"
}

-- Textbox
------------------------------------------------------------
theme.desktop.common.textbox = {
	font = { font = "prototype", size = 24, face = 0 }
}

-- Dashbar
------------------------------------------------------------
theme.desktop.common.dashbar = {
	bar = { width = 6, gap = 6 }
}

-- Barpack
------------------------------------------------------------
theme.desktop.common.barpack = {
	label_style = { width = 80, draw = "by_width" },
	text_style  = { width = 92, draw = "by_edges" },
	line_height = theme.desktop.line_height,
	text_gap    = 22,
	label_gap   = 16,
	color       = theme.desktop.color
}

-- Widgets
--------------------------------------------------------------------------------

-- Network speed
------------------------------------------------------------
theme.desktop.speedmeter = {
	label            = { height = theme.desktop.line_height },
	dashbar          = { bar = { width = 16, gap = 6 }, height = 6 },
	chart            = { bar = { width = 6, gap = 3 }, height = 40, zero_height = 4 },
	barvalue_height  = 32,
	fullchart_height = 80,
	images           = { theme.path .. "/desktop/up.svg", theme.path .. "/desktop/down.svg" },
	image_gap        = 16,
	color            = theme.desktop.color
}

-- CPU and memory
------------------------------------------------------------
theme.desktop.multim = {
	corner       = { width = 34, corner = { height = 17, num = 10, line = 4 } },
	state_height = 58,
	prog_height  = 80,
	image_gap    = 16,
	image        = theme.path .. "/desktop/bstar.svg",
	color        = theme.desktop.color
}

-- Disks
------------------------------------------------------------
theme.desktop.dashpack = {
	color = theme.desktop.color
}

-- Thermal
------------------------------------------------------------
theme.desktop.sline = {
	digit_num = 2,
	lbox      = { draw = "by_width", width = 50 },
	rbox      = { draw = "by_edges", width = 60 },
	icon      = theme.path .. "/desktop/star.svg",
	iwidth    = 142,
	color     = theme.desktop.color
}

-- Widgets placement
--------------------------------------------------------------------------------
theme.desktop.grid = {
	width  = { 520, 520, 520 },
	height = { 180, 160, 160, 138, 18 },
	edge   = { width = { 60, 60 }, height = { 40, 40 } }
}

theme.desktop.places = {
	netspeed = { 1, 1 },
	ssdspeed = { 2, 1 },
	hddspeed = { 3, 1 },
	cpumem   = { 1, 2 },
	transm   = { 1, 3 },
	disks    = { 1, 4 },
	thermal  = { 1, 5 }
}


-- Service utils config
-----------------------------------------------------------------------------------------------------------------------
theme.service = {}

-- Window control mode appearance
--------------------------------------------------------------------------------
theme.service.navigator = {
	border_width = 0,
	gradstep     = 60,
	marksize     = { width = 160, height = 80, r = 20 },
	linegap      = 32,
	titlefont    = theme.cairo_fonts.navigator.title,
	font         = theme.cairo_fonts.navigator.main,
	color        = { border = theme.color.main, mark = theme.color.gray, text = theme.color.wibox,
	                 fbg1 = theme.color.main .. "40", fbg2 = theme.color.main .. "20",
	                 bg1  = theme.color.gray .. "40", bg2  = theme.color.gray .. "20" }
}

-- Desktop file parser
--------------------------------------------------------------------------------
theme.service.dfparser = {
	desktop_file_dirs = {
		'/usr/share/applications/',
		'/usr/local/share/applications/',
		'~/.local/share/applications',
	},
	icons = {
		df_icon       = theme.homedir .. "/.icons/ACYLS/scalable/mimetypes/application-x-executable.svg",
		theme         = theme.homedir .. "/.icons/ACYLS",
		custom_only   = true,
		scalable_only = true
	}
}


-- Menu config
-----------------------------------------------------------------------------------------------------------------------
theme.menu = {
	border_width = 4,
	screen_gap   = theme.useless_gap + theme.border_width,
	height       = 32,
	width        = 250,
	icon_margin  = { 4, 7, 7, 8 },
	ricon_margin = { 9, 9, 9, 9 },
	font         = theme.fonts.menu,
	keytip       = { geometry = { width = 400, height = 460 } },
	hide_timeout = 1,
	submenu_icon = theme.path .. "/common/submenu.svg"
}

theme.menu.color = {
	border       = theme.color.wibox,
	text         = theme.color.text,
	highlight    = theme.color.highlight,
	main         = theme.color.main,
	wibox        = theme.color.wibox,
	submenu_icon = theme.color.icon
}


-- Gauge style
-----------------------------------------------------------------------------------------------------------------------
theme.gauge = { tag = {}, task = {}}

-- Separator
------------------------------------------------------------
theme.gauge.separator = {
	marginv = { 2, 2, 4, 4 },
	marginh = { 6, 6, 3, 3 },
	color  = theme.color
}

-- Icon indicator
------------------------------------------------------------
theme.gauge.gicon = {
	color  = theme.color
}

-- Monitor
--------------------------------------------------------------
theme.gauge.doublemonitor = {
	width    = 90,
	line     = { v_gap = 6 },
	dmargin  = { 10, 0, 0, 0 },
	color    = theme.color
}

-- Tag
------------------------------------------------------------
theme.gauge.tag.blue = {
	width    = 103,
	font     = theme.cairo_fonts.tag,
	point    = { width = 80, height = 3, gap = 27, dx = 5 },
	text_gap = 20,
	color    = theme.color
}

-- Task
------------------------------------------------------------
theme.gauge.task.blue = {
	width    = 80,
	show_min = true,
	font     = theme.cairo_fonts.tag,
	point    = { width = 70, height = 3, gap = 27, dx = 5 },
	text_gap = 20,
	color    = theme.color
}

-- Dotcount
------------------------------------------------------------
theme.gauge.dotcount = {
	column_num   = { 3, 5 }, -- { min, max }
	row_num      = 3,
	dot_size     = 5,
	dot_gap_h    = 4,
	color        = theme.color
}

-- Volume indicator
------------------------------------------------------------
theme.gauge.audio = {}

theme.gauge.audio.blue = {
	width   = 75,
	dash    = { bar = { num = 5, width = 4 }, color = theme.color },
	dmargin = { 10, 0, 2, 2 },
	icon    = theme.path .. "/widget/headphones.svg",
	color = { icon = theme.color.icon, mute = theme.color.urgent },
}


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------
theme.widget = {}

-- individual margins for palnel widgets
------------------------------------------------------------
theme.widget.wrapper = {
	layoutbox   = { 14, 10, 6, 6 },
	textclock   = { 12, 12, 0, 0 },
	volume      = { 12, 12, 5, 5 },
	network     = { 12, 12, 5, 5 },
	cpuram      = { 12, 12, 5, 5 },
	keyboard    = { 12, 12, 4, 4 },
	mail        = { 12, 12, 4, 4 },
	battery     = { 8, 10, 6, 6 },
	tray        = { 12, 12, 7, 7 },
}

-- Pulseaudio volume control
------------------------------------------------------------
theme.widget.pulse = {
	notify_icon = theme.path .. "/widget/audio.svg"
}

-- Brightness control
------------------------------------------------------------
theme.widget.brightness = {
	notify_icon = theme.path .. "/widget/brightness.svg"
}

-- Textclock
------------------------------------------------------------
theme.widget.textclock = {
	font  = theme.fonts.clock,
	color = { text = theme.color.icon }
}

-- Keyboard layout indicator
------------------------------------------------------------
theme.widget.keyboard = {
	icon         = theme.path .. "/widget/keyboard.svg",
	micon        = theme.icon,
	layout_color = { theme.color.icon, theme.color.main }
}

theme.widget.keyboard.menu = {
	width        = 180,
	color        = { right_icon = theme.color.icon },
	nohide       = true
}

-- Upgrades
------------------------------------------------------------
theme.widget.upgrades = {
	notify_icon = theme.path .. "/widget/upgrades.svg",
	color       = theme.color
}

-- Mail
------------------------------------------------------------
theme.widget.mail = {
	icon        = theme.path .. "/widget/mail.svg",
	notify_icon = theme.path .. "/widget/mail.svg",
	color       = theme.color,
}


-- Minitray
------------------------------------------------------------
theme.widget.minitray = {
	border_width = 0,
	geometry     = { height = 40 },
	screen_gap   = 2 * theme.useless_gap,
	color        = { wibox = theme.color.wibox, border = theme.color.wibox },
	set_position = function()
		return { x = mouse.screen.workarea.x + mouse.screen.workarea.width,
		         y = mouse.screen.workarea.y + mouse.screen.workarea.height }
	end,
}


-- Layoutbox
------------------------------------------------------------
theme.widget.layoutbox = {
	micon = theme.icon,
	color = theme.color
}

theme.widget.layoutbox.icon = {
	floating          = theme.path .. "/layouts/floating.svg",
	max               = theme.path .. "/layouts/max.svg",
	fullscreen        = theme.path .. "/layouts/fullscreen.svg",
	tilebottom        = theme.path .. "/layouts/tilebottom.svg",
	tileleft          = theme.path .. "/layouts/tileleft.svg",
	tile              = theme.path .. "/layouts/tile.svg",
	tiletop           = theme.path .. "/layouts/tiletop.svg",
	fairv             = theme.path .. "/layouts/fair.svg",
	grid              = theme.path .. "/layouts/grid.svg",
	usermap           = theme.path .. "/layouts/map.svg",
	unknown           = theme.path .. "/layouts/unknown.svg",
}

theme.widget.layoutbox.menu = {
	icon_margin  = { 8, 12, 8, 8 },
	width        = 260,
	auto_hotkey  = true,
	nohide       = false,
	color        = { right_icon = theme.color.icon, left_icon = theme.color.icon }
}

theme.widget.layoutbox.name_alias = {
	floating          = "Floating",
	fullscreen        = "Fullscreen",
	max               = "Maximized",
	grid              = "Grid",
	usermap           = "User Map",
	tile              = "Right Tile",
	fairv             = "Fair Tile",
	tileleft          = "Left Tile",
	tiletop           = "Top Tile",
	tilebottom        = "Bottom Tile",
}

-- Tasklist
------------------------------------------------------------
theme.widget.tasklist = {
	width       = 70,
	char_digit  = 5,
	task        = theme.gauge.task.blue
}

-- main
theme.widget.tasklist.winmenu = {
	micon          = theme.icon,
	titleline      = { font = theme.fonts.title, height = 30 },
	menu           = { width = 240, color = { right_icon = theme.color.icon }, ricon_margin = { 9, 9, 9, 9 } },
	tagmenu        = { width = 180, color = { right_icon = theme.color.icon, left_icon = theme.color.icon } },
	state_iconsize = { width = 18, height = 18 },
	layout_icon    = theme.widget.layoutbox.icon,
	color          = theme.color
}

-- tasktip
theme.widget.tasklist.tasktip = {
	color = theme.color
}

-- menu
theme.widget.tasklist.winmenu.icon = {
	floating             = theme.path .. "/common/window_control/floating.svg",
	sticky               = theme.path .. "/common/window_control/pin.svg",
	ontop                = theme.path .. "/common/window_control/ontop.svg",
	below                = theme.path .. "/common/window_control/below.svg",
	close                = theme.path .. "/common/window_control/close.svg",
	minimize             = theme.path .. "/common/window_control/minimize.svg",
	maximize             = theme.path .. "/common/window_control/maximize.svg",
	maximized_horizontal = theme.path .. "/common/window_control/maxh.svg",
	maximized_vertical   = theme.path .. "/common/window_control/maxv.svg",
}

-- task aliases
theme.widget.tasklist.appnames = {}
theme.widget.tasklist.appnames["Firefox"             ] = "FIFOX"
theme.widget.tasklist.appnames["Gnome-terminal"      ] = "GTERM"

-- Floating widgets
-----------------------------------------------------------------------------------------------------------------------
theme.float = {}

-- Application runner
------------------------------------------------------------
theme.float.apprunner = {
	itemnum       = 6,
	geometry      = { width = 620, height = 480 },
	border_margin = { 24, 24, 24, 24 },
	icon_margin   = { 8, 16, 0, 0 },
	title_height  = 48,
	prompt_height = 35,
	title_icon    = theme.path .. "/widget/search.svg",
	border_width  = 0,
	name_font     = theme.fonts.title,
	comment_font  = theme.fonts.main,
	color         = theme.color
}

-- Application switcher
------------------------------------------------------------
theme.float.appswitcher = {
	wibox_height   = 240,
	label_height   = 28,
	title_height   = 40,
	icon_size      = 96,
	border_margin  = { 10, 10, 0, 10 },
	preview_margin = { 15, 15, 15, 15 },
	preview_format = 16 / 10,
	title_font     = theme.fonts.title,
	border_width   = 0,
	update_timeout = 1 / 12,
	font           = theme.cairo_fonts.appswitcher,
	color          = theme.color
}

-- additional color
theme.float.appswitcher.color.preview_bg = theme.color.main .. "12"

-- hotkeys
theme.float.appswitcher.hotkeys = { "1",   "2",  "3",  "4",  "5",  "6",  "7",  "8",  "9",  "0",
                                    "F1",  "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10",
                                    "F11", "F12" }


-- Hotkeys helper
------------------------------------------------------------
theme.float.hotkeys = {
	geometry      = { width = wa.width * 0.9, height = wa.height * 0.9 },
	border_margin = { 20, 20, 10, 10 },
	border_width  = 0,
	is_align      = true,
	font          = theme.fonts.hotkeys.main,
	keyfont       = theme.fonts.hotkeys.key,
	titlefont     = theme.fonts.hotkeys.title,
	color         = theme.color
}

-- Tooltip
------------------------------------------------------------
theme.float.tooltip = {
	margin       = { 6, 6, 3, 3 },
	timeout      = 0,
	font         = theme.fonts.tooltip,
	border_width = 2,
	color        = theme.color
}

-- Floating prompt
------------------------------------------------------------
theme.float.prompt = {
	border_width = 0,
	color        = theme.color
}

-- Top processes
------------------------------------------------------------
theme.float.top = {
	geometry      = { width = 460, height = 400 },
	screen_gap    = 2 * theme.useless_gap,
	border_margin = { 20, 20, 10, 0 },
	button_margin = { 140, 140, 18, 18 },
	title_height  = 40,
	border_width  = 0,
	bottom_height = 70,
	title_font    = theme.fonts.title,
	color         = theme.color,
	set_position  = function()
		return { x = mouse.screen.workarea.x + mouse.screen.workarea.width,
		         y = mouse.screen.workarea.y + mouse.screen.workarea.height }
	end,
}


-- Notify
------------------------------------------------------------
theme.float.notify = {
	geometry     = { width = 484, height = 106 },
	screen_gap   = 2 * theme.useless_gap,
	font         = theme.fonts.notify,
	border_width = 0,
	color        = theme.color,
	progressbar  = { color = theme.color },
	set_position = function()
		return { x = mouse.screen.workarea.x + mouse.screen.workarea.width, y = mouse.screen.workarea.y }
	end,
}

-- Titlebar
-----------------------------------------------------------------------------------------------------------------------
theme.titlebar = {
	size          = 8,
	position      = "top",
	font          = theme.fonts.titlebar,
	icon          = { size = 30, gap = 10 },
	border_margin = { 0, 0, 0, 4 },
	color         = theme.color,
}

-- Default awesome theme vars
-----------------------------------------------------------------------------------------------------------------------

-- colors
theme.bg_normal     = theme.color.wibox
theme.bg_focus      = theme.color.main
theme.bg_urgent     = theme.color.urgent
theme.bg_minimize   = theme.color.gray

theme.fg_normal     = theme.color.text
theme.fg_focus      = theme.color.highlight
theme.fg_urgent     = theme.color.highlight
theme.fg_minimize   = theme.color.highlight

theme.border_normal = theme.color.wibox
theme.border_focus  = theme.color.wibox
theme.border_marked = theme.color.main

-- font
theme.font = theme.fonts.main

-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
