-----------------------------------------------------------------------------------------------------------------------
--                                                Colorless theme                                                    --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

local theme = {}
--local wa = mouse.screen.workarea

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
	highlight = "#e0e0e0",

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
	system   = theme.path .. "/common/system.svg",
}


-- Main theme settings
-- Make it updatabele since it may depends on common
-----------------------------------------------------------------------------------------------------------------------
function theme:update()
	-- Service utils config
	----------------------------------------------------------------------------------
	self.service = {}

	-- Window control mode appearance
	--------------------------------------------------------------------------------
	self.service.navigator = {
		border_width = 0,  -- window placeholder border width
		gradstep     = 60, -- window placeholder background stripes width
		marksize = {       -- window information plate size
			width  = 160, -- width
			height = 80,  -- height
			r      = 20   -- corner roundness
		},
		linegap   = 32, -- gap between two lines on window information plate
		timeout   = 1,  -- highlight duration
		notify    = {}, -- redflat notify style
		titlefont = self.cairo_fonts.navigator.title, -- first line font on window information plate
		font      = self.cairo_fonts.navigator.main,  -- second line font on window information plate

		-- array of hot key marks for window placeholders
		num = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "F1", "F3", "F4", "F5" },

		-- colors
		color = {
			border = self.color.main,         -- window placeholder border color
			mark = self.color.gray,           -- window information plate background color
			text = self.color.wibox,          -- window information plate text color
			fbg1 = self.color.main .. "40",   -- first background color for focused window placeholder
			fbg2 = self.color.main .. "20",   -- second background color for focused window placeholder
			hbg1 = self.color.urgent .. "40", -- first background color for highlighted window placeholder
			hbg2 = self.color.urgent .. "20", -- second background color for highlighted window placeholder
			bg1  = self.color.gray .. "40",   -- first background color for window placeholder
			bg2  = self.color.gray .. "20"    -- second background color for window placeholder
		}
	}

	-- layout hotkeys helper styles
	self.service.navigator.keytip = {}

	-- this one used as fallback when style for certain layout missed
	self.service.navigator.keytip["base"] = { geometry = { width = 600, height = 600 }, exit = true }

	-- styles for certain layouts
	self.service.navigator.keytip["fairv"] = { geometry = { width = 600, height = 360 }, exit = true }
	self.service.navigator.keytip["fairh"] = self.service.navigator.keytip["fairv"]
	self.service.navigator.keytip["spiral"] = self.service.navigator.keytip["fairv"]
	self.service.navigator.keytip["dwindle"] = self.service.navigator.keytip["fairv"]

	self.service.navigator.keytip["tile"] = { geometry = { width = 600, height = 480 }, exit = true }
	self.service.navigator.keytip["tileleft"]   = self.service.navigator.keytip["tile"]
	self.service.navigator.keytip["tiletop"]    = self.service.navigator.keytip["tile"]
	self.service.navigator.keytip["tilebottom"] = self.service.navigator.keytip["tile"]

	self.service.navigator.keytip["cornernw"] = { geometry = { width = 600, height = 440 }, exit = true }
	self.service.navigator.keytip["cornerne"] = self.service.navigator.keytip["cornernw"]
	self.service.navigator.keytip["cornerse"] = self.service.navigator.keytip["cornernw"]
	self.service.navigator.keytip["cornersw"] = self.service.navigator.keytip["cornernw"]

	self.service.navigator.keytip["magnifier"] = { geometry = { width = 600, height = 360 }, exit = true }

	self.service.navigator.keytip["grid"] = { geometry = { width = 1400, height = 440 }, column = 2, exit = true }
	self.service.navigator.keytip["usermap"] = { geometry = { width = 1400, height = 480 }, column = 2, exit = true }

	-- Desktop file parser
	--------------------------------------------------------------------------------
	self.service.dfparser = {
		-- list of path to check desktop files
		desktop_file_dirs = {
			'/usr/share/applications/',
			'/usr/local/share/applications/',
			'~/.local/share/applications',
		},
		-- icon theme settings
		icons = {
			 theme         = nil, -- user icon theme path
			-- theme         = "/usr/share/icons/ACYLS", -- for example
			df_icon       = self.icon.system, -- default (fallback) icon
			custom_only   = false, -- use icons from user theme (no system fallback like 'hicolor' allowed) only
			scalable_only = false  -- use vector(svg) icons (no raster icons allowed) only
		},
		wm_name = nil -- window manager name
	}


---- Menu config
-------------------------------------------------------------------------------------------------------------------------
--theme.menu = {
--	border_width = 4,
--	screen_gap   = theme.useless_gap + theme.border_width,
--	height       = 32,
--	width        = 250,
--	icon_margin  = { 8, 8, 8, 8 },
--	ricon_margin = { 9, 9, 9, 9 },
--	font         = theme.fonts.menu,
--	keytip       = { geometry = { width = 400, height = 460 } },
--	hide_timeout = 1,
--	submenu_icon = theme.path .. "/common/submenu.svg"
--}
--
--theme.menu.color = {
--	border       = theme.color.wibox,
--	text         = theme.color.text,
--	highlight    = theme.color.highlight,
--	main         = theme.color.main,
--	wibox        = theme.color.wibox,
--	submenu_icon = theme.color.icon
--}
--
--
---- Gauge style
-------------------------------------------------------------------------------------------------------------------------
--theme.gauge = { tag = {}, task = {}, graph = {}}
--
---- Separator
--------------------------------------------------------------
--theme.gauge.separator = {
--	marginv = { 2, 2, 4, 4 },
--	marginh = { 6, 6, 3, 3 },
--	color  = theme.color
--}
--
---- Tag
--------------------------------------------------------------
--theme.gauge.tag.orange = {
--	width        = 38,
--	line_width   = 4,
--	iradius      = 5,
--	radius       = 11,
--	hilight_min  = false,
--	color        = theme.color
--}
--
---- Task
--------------------------------------------------------------
--theme.gauge.task.blue = {
--	width    = 70,
--	show_min = true,
--	font     = theme.cairo_fonts.tag,
--	point    = { width = 70, height = 3, gap = 27, dx = 5 },
--	text_gap = 20,
--	color    = theme.color
--}
--
---- Dotcount
--------------------------------------------------------------
--theme.gauge.graph.dots = {
--	column_num   = { 3, 5 }, -- { min, max }
--	row_num      = 3,
--	dot_size     = 5,
--	dot_gap_h    = 4,
--	color        = theme.color
--}
--
--
---- Panel widgets
-------------------------------------------------------------------------------------------------------------------------
--theme.widget = {}
--
---- individual margins for palnel widgets
--------------------------------------------------------------
--theme.widget.wrapper = {
--	mainmenu    = { 12, 10, 6, 6 },
--	layoutbox   = { 10, 10, 6, 6 },
--	textclock   = { 12, 12, 0, 0 },
--	taglist     = { 4, 4, 0, 0 },
--	tray        = { 10, 12, 7, 7 },
--	-- tasklist    = { 0, 70, 0, 0 }, -- centering tasklist widget
--}
--
---- Textclock
--------------------------------------------------------------
--theme.widget.textclock = {
--	font  = theme.fonts.clock,
--	color = { text = theme.color.icon }
--}
--
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
--	spiral            = theme.path .. "/layouts/spiral.svg",
--	cornerne          = theme.path .. "/layouts/cornerne.svg",
--	cornernw          = theme.path .. "/layouts/cornernw.svg",
--	cornerse          = theme.path .. "/layouts/cornerse.svg",
--	cornersw          = theme.path .. "/layouts/cornersw.svg",
--	unknown           = theme.path .. "/common/unknown.svg",
--}
--
--theme.widget.layoutbox.menu = {
--	icon_margin  = { 8, 12, 8, 8 },
--	width        = 260,
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
--	spiral            = "Spiral",
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
--	titleline      = { font = theme.fonts.title, height = 30 },
--	menu           = { width = 220, color = { right_icon = theme.color.icon }, ricon_margin = { 9, 9, 10, 10 } },
--	tagmenu        = { width = 160, color = { right_icon = theme.color.icon, left_icon = theme.color.icon },
--	                   icon_margin = { 8, 10, 8, 8 } },
--	state_iconsize = { width = 18, height = 18 },
--	layout_icon    = theme.widget.layoutbox.icon,
--	color          = theme.color
--}
--
---- tasktip
--theme.widget.tasklist.tasktip = {
--	color = theme.color
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
---- task aliases
--theme.widget.tasklist.appnames = {}
--theme.widget.tasklist.appnames["Firefox"             ] = "FIFOX"
--theme.widget.tasklist.appnames["Gnome-terminal"      ] = "GTERM"
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
---- Application runner
--------------------------------------------------------------
--theme.float.apprunner = {
--	itemnum       = 6,
--	geometry      = { width = 620, height = 480 },
--	border_margin = { 24, 24, 24, 24 },
--	icon_margin   = { 8, 16, 0, 0 },
--	title_height  = 48,
--	prompt_height = 35,
--	keytip        = { geometry = { width = 400, height = 260 } },
--	title_icon    = theme.path .. "/widget/search.svg",
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
--	keytip         = { geometry = { width = 400, height = 320 }, exit = true },
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
--	keytip        = { geometry = { width = 600, height = 260 } },
--	label_font    = theme.fonts.qlaunch,
--	color         = theme.color,
--}
--
---- Hotkeys helper
--------------------------------------------------------------
--theme.float.hotkeys = {
--	geometry      = { width = 1400, height = 600 },
--	border_margin = { 20, 20, 10, 10 },
--	border_width  = 0,
--	is_align      = true,
--	separator     = { marginh = { 0, 0, 2, 6 } },
--	font          = theme.fonts.hotkeys.main,
--	keyfont       = theme.fonts.hotkeys.key,
--	titlefont     = theme.fonts.hotkeys.title,
--	color         = theme.color
--}
--
---- Key sequence tip
--------------------------------------------------------------
--theme.float.keychain = {
--	geometry        = { width = 250, height = 54 },
--	font            = theme.fonts.keychain,
--	-- border_width    = 0,
--	keytip          = { geometry = { width = 600, height = 400 }, column = 1 },
--	color           = theme.color,
--}
--
---- Tooltip
--------------------------------------------------------------
--theme.float.tooltip = {
--	margin       = { 6, 6, 4, 4 },
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
---- Notify
--------------------------------------------------------------
--theme.float.notify = {
--	geometry     = { width = 484, height = 106 },
--	screen_gap   = 2 * theme.useless_gap,
--	font         = theme.fonts.notify,
--	icon         = theme.icon.warning,
--	border_width = 0,
--	color        = theme.color,
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
-- Default awesome theme vars
-----------------------------------------------------------------------------------------------------------------------

	-- colors
	self.bg_normal     = self.color.wibox
	self.bg_focus      = self.color.main
	self.bg_urgent     = self.color.urgent
	self.bg_minimize   = self.color.gray

	self.fg_normal     = self.color.text
	self.fg_focus      = self.color.highlight
	self.fg_urgent     = self.color.highlight
	self.fg_minimize   = self.color.highlight

	self.border_normal = self.color.wibox
	self.border_focus  = self.color.wibox
	self.border_marked = self.color.main

	-- font
	self.font = self.fonts.main
end

theme:update()


-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
