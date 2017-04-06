-----------------------------------------------------------------------------------------------------------------------
--                                                Colorless theme                                                    --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

local theme = {}
local wa = mouse.screen.workarea

-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color = {
	main      = "#02606D",
	gray      = "#575757",
	bg        = "#161616",
	bg_second = "#181818",
	wibox     = "#202020",
	icon      = "#a0a0a0",
	text      = "#aaaaaa",
	urgent    = "#B25500",
	highlight = "#ffffff",

	border    = "#404040",
	shadow1   = "#141414",
	shadow2   = "#313131",
	shadow3   = "#1c1c1c",
	shadow4   = "#767676"
}

-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/colorless"
theme.homedir = os.getenv("HOME")

-- Main config
------------------------------------------------------------

theme.panel_height        = 36 -- panel height
theme.border_width        = 4  -- window border width
theme.useless_gap         = 4  -- useless gap

theme.wallpaper = theme.path .. "/wallpaper/primary.png" -- wallpaper file

-- Fonts
------------------------------------------------------------
theme.fonts = {
	main     = "sans 12",      -- main font
	menu     = "sans 12",      -- main menu font
	tooltip  = "sans 12",      -- tooltip font
	notify   = "sans bold 14", -- redflat notify popup font
	clock    = "sans bold 12", -- textclock widget font
	qlaunch  = "sans bold 14", -- quick launch key label font
	title    = "sans bold 12", -- widget titles font
	keychain = "sans bold 14", -- key sequence tip font
	titlebar = "sans bold 12", -- client titlebar font
	hotkeys = {
		main  = "sans 12",      -- hotkeys helper main font
		key   = "mono 12",      -- hotkeys helper key font (use monospace for align)
		title = "sans bold 14", -- hotkeys helper group title font
	},
}

theme.cairo_fonts = {
	tag         = { font = "Sans", size = 16, face = 1 }, -- tag widget font
	appswitcher = { font = "Sans", size = 22, face = 1 }, -- appswitcher widget font
	navigator   = {
		title = { font = "Sans", size = 28, face = 1, slant = 0 }, -- window navigation title font
		main  = { font = "Sans", size = 22, face = 1, slant = 0 }  -- window navigation  main font
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
	                 fbg1 = theme.color.main .. "40",   fbg2 = theme.color.main .. "20",
	                 hbg1 = theme.color.urgent .. "40", hbg2 = theme.color.urgent .. "20",
	                 bg1  = theme.color.gray .. "40",   bg2  = theme.color.gray .. "20" }
}

-- layout hotkeys helper size
theme.service.navigator.keytip = {}
theme.service.navigator.keytip["fairv"] = { geometry = { width = 600, height = 360 }, exit = true }
theme.service.navigator.keytip["fairh"] = theme.service.navigator.keytip["fairv"]
theme.service.navigator.keytip["spiral"] = theme.service.navigator.keytip["fairv"]
theme.service.navigator.keytip["dwindle"] = theme.service.navigator.keytip["fairv"]

theme.service.navigator.keytip["tile"] = { geometry = { width = 600, height = 480 }, exit = true }
theme.service.navigator.keytip["tileleft"]   = theme.service.navigator.keytip["tile"]
theme.service.navigator.keytip["tiletop"]    = theme.service.navigator.keytip["tile"]
theme.service.navigator.keytip["tilebottom"] = theme.service.navigator.keytip["tile"]

theme.service.navigator.keytip["cornernw"] = { geometry = { width = 600, height = 440 }, exit = true }
theme.service.navigator.keytip["cornerne"] = theme.service.navigator.keytip["cornernw"]
theme.service.navigator.keytip["cornerse"] = theme.service.navigator.keytip["cornernw"]
theme.service.navigator.keytip["cornersw"] = theme.service.navigator.keytip["cornernw"]

theme.service.navigator.keytip["magnifier"] = { geometry = { width = 600, height = 360 }, exit = true }

theme.service.navigator.keytip["grid"] = { geometry = { width = 1400, height = 440 }, column = 2, exit = true }
theme.service.navigator.keytip["usermap"] = { geometry = { width = 1400, height = 480 }, column = 2, exit = true }

-- Desktop file parser
--------------------------------------------------------------------------------
theme.service.dfparser = {
	desktop_file_dirs = {
		'/usr/share/applications/',
		'/usr/local/share/applications/',
		'~/.local/share/applications',
	},
	icons = {
		-- df_icon       = "/usr/share/icons/ACYLS/scalable/mimetypes/application-x-executable.svg",
		-- theme         = "/usr/share/icons/ACYLS",
		custom_only   = false,
		scalable_only = false
	}
}


-- Menu config
-----------------------------------------------------------------------------------------------------------------------
theme.menu = {
	border_width = 4,
	screen_gap   = theme.useless_gap + theme.border_width,
	height       = 32,
	width        = 250,
	icon_margin  = { 8, 8, 8, 8 },
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
theme.gauge = { tag = {}, task = {}, graph = {}}

-- Separator
------------------------------------------------------------
theme.gauge.separator = {
	marginv = { 2, 2, 4, 4 },
	marginh = { 6, 6, 3, 3 },
	color  = theme.color
}

-- Tag
------------------------------------------------------------
theme.gauge.tag.orange = {
	width        = 38,
	line_width   = 4,
	iradius      = 5,
	radius       = 11,
	hilight_min  = false,
	color        = theme.color
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
theme.gauge.graph.dots = {
	column_num   = { 3, 5 }, -- { min, max }
	row_num      = 3,
	dot_size     = 5,
	dot_gap_h    = 4,
	color        = theme.color
}


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------
theme.widget = {}

-- individual margins for palnel widgets
------------------------------------------------------------
theme.widget.wrapper = {
	mainmenu    = { 12, 10, 6, 6 },
	layoutbox   = { 10, 10, 6, 6 },
	textclock   = { 12, 12, 0, 0 },
	taglist     = { 4, 4, 0, 0 },
	tray        = { 10, 12, 7, 7 },
	-- tasklist    = { 0, 70, 0, 0 }, -- centering tasklist widget
}

-- Textclock
------------------------------------------------------------
theme.widget.textclock = {
	font  = theme.fonts.clock,
	color = { text = theme.color.icon }
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
	fairh             = theme.path .. "/layouts/fair.svg",
	grid              = theme.path .. "/layouts/grid.svg",
	usermap           = theme.path .. "/layouts/map.svg",
	magnifier         = theme.path .. "/layouts/magnifier.svg",
	spiral            = theme.path .. "/layouts/spiral.svg",
	cornerne          = theme.path .. "/layouts/cornerne.svg",
	cornernw          = theme.path .. "/layouts/cornernw.svg",
	cornerse          = theme.path .. "/layouts/cornerse.svg",
	cornersw          = theme.path .. "/layouts/cornersw.svg",
	unknown           = theme.path .. "/common/unknown.svg",
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
	magnifier         = "Magnifier",
	spiral            = "Spiral",
	cornerne          = "Corner NE",
	cornernw          = "Corner NW",
	cornerse          = "Corner SE",
	cornersw          = "Corner SW",
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
	menu           = { width = 220, color = { right_icon = theme.color.icon }, ricon_margin = { 9, 9, 10, 10 } },
	tagmenu        = { width = 160, color = { right_icon = theme.color.icon, left_icon = theme.color.icon },
	                   icon_margin = { 8, 10, 8, 8 } },
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
	maximized            = theme.path .. "/common/window_control/maximized.svg",
}

-- task aliases
theme.widget.tasklist.appnames = {}
theme.widget.tasklist.appnames["Firefox"             ] = "FIFOX"
theme.widget.tasklist.appnames["Gnome-terminal"      ] = "GTERM"

-- Floating widgets
-----------------------------------------------------------------------------------------------------------------------
theme.float = { decoration = {} }

-- Application runner
------------------------------------------------------------
theme.float.apprunner = {
	itemnum       = 6,
	geometry      = { width = 620, height = 480 },
	border_margin = { 24, 24, 24, 24 },
	icon_margin   = { 8, 16, 0, 0 },
	title_height  = 48,
	prompt_height = 35,
	keytip        = { geometry = { width = 400, height = 260 } },
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
	keytip         = { geometry = { width = 400, height = 320 }, exit = true },
	font           = theme.cairo_fonts.appswitcher,
	color          = theme.color
}

-- additional color
theme.float.appswitcher.color.preview_bg = theme.color.main .. "12"

-- hotkeys
theme.float.appswitcher.hotkeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
                                    "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12" }

-- Quick launcher
------------------------------------------------------------
theme.float.qlaunch = {
	geometry      = { width = 1400, height = 170 },
	border_margin = { 5, 5, 12, 15 },
	border_width  = 0,
	appline       = { iwidth = 140, im = { 5, 5, 0, 0 }, igap = { 0, 0, 5, 15 }, lheight = 26 },
	state         = { gap = 5, radius = 5, size = 10,  height = 14 },
	-- df_icon       = theme.homedir .. "/.icons/ACYLS/scalable/mimetypes/application-x-executable.svg",
	-- no_icon       = theme.homedir .. "/.icons/ACYLS/scalable/apps/question.svg",
	df_icon       = theme.icon.warning,
	keytip        = { geometry = { width = 600, height = 260 } },
	no_icon       = theme.path .. "/common/unknown.svg",
	label_font    = theme.fonts.qlaunch,
	color         = theme.color,
}

-- Hotkeys helper
------------------------------------------------------------
theme.float.hotkeys = {
	geometry      = { width = 1400, height = 600 },
	border_margin = { 20, 20, 10, 10 },
	border_width  = 0,
	is_align      = true,
	separator     = { marginh = { 0, 0, 2, 6 } },
	font          = theme.fonts.hotkeys.main,
	keyfont       = theme.fonts.hotkeys.key,
	titlefont     = theme.fonts.hotkeys.title,
	color         = theme.color
}

-- Key sequence tip
------------------------------------------------------------
theme.float.keychain = {
	geometry        = { width = 250, height = 54 },
	font            = theme.fonts.keychain,
	-- border_width    = 0,
	keytip          = { geometry = { width = 600, height = 400 }, column = 1 },
	color           = theme.color,
}

-- Tooltip
------------------------------------------------------------
theme.float.tooltip = {
	margin       = { 6, 6, 4, 4 },
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

-- Notify
------------------------------------------------------------
theme.float.notify = {
	geometry     = { width = 484, height = 106 },
	screen_gap   = 2 * theme.useless_gap,
	font         = theme.fonts.notify,
	icon         = theme.icon.warning,
	border_width = 0,
	color        = theme.color,
	set_position = function()
		return { x = mouse.screen.workarea.x + mouse.screen.workarea.width, y = mouse.screen.workarea.y }
	end,
}

-- Decoration elements
------------------------------------------------------------
theme.float.decoration.button = {
	color = theme.color
}

theme.float.decoration.button.color.text = "#cccccc"
theme.float.decoration.button.color.shadow_down = theme.color.gray

theme.float.decoration.field = {
	color = theme.color
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

-- Naughty config
-----------------------------------------------------------------------------------------------------------------------
theme.naughty = {}

theme.naughty.base = {
	timeout      = 10,
	margin       = 12,
	icon_size    = 80,
	font         = theme.fonts.main,
	bg           = theme.color.wibox,
	fg           = theme.color.text,
	height       = theme.float.notify.geometry.height,
	width        = theme.float.notify.geometry.width,
	border_width = 4,
	border_color = theme.color.wibox
}

theme.naughty.normal = {}
theme.naughty.critical = { timeout = 0, border_color = theme.color.main }
theme.naughty.low = { timeout = 5 }

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
