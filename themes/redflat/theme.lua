-----------------------------------------------------------------------------------------------------------------------
--                                                  RedFlat theme                                                    --
-----------------------------------------------------------------------------------------------------------------------

local theme = {}

-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color = {
	main      = "#b1222b",
	--main      = "#246b99",
	gray      = "#575757",
	bg        = "#161616",
	bg_second = "#181818",
	wibox     = "#202020",
	icon      = "#a0a0a0",
	text      = "#aaaaaa",
	urgent    = "#32882d",
	highlight = "#ffffff",

	border    = "#404040",
	shadow1   = "#141414",
	shadow2   = "#313131",
	shadow3   = "#1c1c1c",
	shadow4   = "#767676"
}

-- colors for defaults widgets
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


-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = os.getenv("HOME") .. "/.config/awesome/themes/redflat"

-- Main config
--------------------------------------------------------------------------------

-- fonts
theme.font        = "Play 14"      -- main theme font
theme.font_title  = "Play bold 14" -- title font for widgets
theme.font_clock  = "Play bold 12" -- font for textclock widget
theme.font_notify = "Play bold 16" -- font for notify widget

theme.font_exaile_main = "Play bold 14" -- main font for exaile widget
theme.font_exaile_time = "Play bold 16" -- time status font for exaile widget

-- cairo formated fonts
theme.cf_appswitcher = { font = "Play", size = 22, face = 1 } -- application switcher font
theme.cf_monitor     = { font = "Play", size = 20, face = 1 } -- monitoring widget font

-- environment vars
theme.panel_heigh         = 50 -- window border width
theme.border_width        = 4  -- window border width
theme.useless_gap_width   = 12 -- Lain useless gap
theme.global_border_width = 0  -- Lain global border gap

-- Shared icons
--------------------------------------------------------------------------------
theme.icon = {
	check = theme.path .. "/common/check.svg",
	blank = theme.path .. "/common/blank.svg"
}


-- Desktop config
-----------------------------------------------------------------------------------------------------------------------
theme.desktop = { common = {} }

theme.wallpaper = theme.path .. "/wallpaper/forwidgets.png"

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
	label_style = { width = 78, draw = "by_width" },
	text_style  = { width = 88, draw = "by_edges" },
	line_height = theme.desktop.line_height,
	text_gap    = 20,
	label_gap   = 20,
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
	fullchart_height = 78,
	images           = { theme.path .. "/desktop/up.svg", theme.path .. "/desktop/down.svg" },
	image_gap        = 20,
	color            = theme.desktop.color
}

-- CPU and memory
------------------------------------------------------------
theme.desktop.multim = {
	corner       = { width = 34, corner = { height = 17, num = 10, line = 5 } },
	state_height = 60,
	prog_height  = 98,
	image_gap    = 0,
	image        = theme.path .. "/desktop/cpu.svg",
	color        = theme.desktop.color
}

-- Disks
------------------------------------------------------------
theme.desktop.dashpack = {
	color = theme.desktop.color
}

-- Widgets placement
--------------------------------------------------------------------------------
theme.desktop.grid = {
	width  = { 500, 500, 500 },
	height = { 180, 182, 102, 144 },
	edge   = { width = { 60, 60 }, height = { 60, 60 } }
}

theme.desktop.places = {
	netspeed = { 1, 1 },
	ssdspeed = { 2, 1 },
	hddspeed = { 3, 1 },
	cpumem   = { 1, 2 },
	transm   = { 2, 2 },
	disks    = { 1, 4 },
	thermal  = { 1, 3 }
}

-- Naughty config
-----------------------------------------------------------------------------------------------------------------------
theme.naughty_preset = {}

theme.naughty_preset.normal = {
	timeout      = 5,
	margin       = 12,
	icon_size    = 80,
	font         = theme.font,
	bg           = theme.color.wibox,
	fg           = theme.color.text,
	height       = 102,
	width        = 480,
	border_width = 2,
	border_color = theme.color.wibox
}

theme.naughty_preset.critical = {
	timeout      = 15,
	margin       = 12,
	icon_size    = 80,
	font         = theme.font,
	bg           = theme.color.wibox,
	fg           = theme.color.text,
	border_width = 2,
	border_color = theme.color.main
}


-- Menu config
-----------------------------------------------------------------------------------------------------------------------
theme.menu = {
	border_width = 4,
	screen_gap   = theme.useless_gap_width + theme.global_border_width,
	height       = 35,
	width        = 300,
	icon_margin  = { 10, 10, 10, 10 },
	ricon_margin = { 10, 10, 10, 10 },
	font         = theme.font,
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

-- Titlebar
-----------------------------------------------------------------------------------------------------------------------
theme.titlebar = {
	color = theme.color
}

-- Gauge style
-----------------------------------------------------------------------------------------------------------------------
theme.gauge = {}

-- Audio
------------------------------------------------------------
theme.gauge.audio = {
	icon = {
		ready = theme.path .. "/widget/audio.svg",
		mute  = theme.path .. "/widget/mute.svg"
	}
}

theme.gauge.audio.color = {
	main = theme.color.main,
	icon = theme.color.icon,
	mute = theme.color.gray
}

-- Progressbar
------------------------------------------------------------
theme.gauge.progressbar = {
	color = theme.color
}

-- Volume controll indicator
------------------------------------------------------------
theme.gauge.dashcontrol = {
	bar   = { width = 5, num = 6 },
	color = theme.color
}

-- Dotcount
------------------------------------------------------------
theme.gauge.dotcount = {
	border_gap_v = 7,
	column_num   = { 2, 3 },  -- { min, max }
	row_num      = 4,
	dot_size     = 5,
	dot_gap_h    = 5,
	color        = theme.color
}

-- Doublebar
------------------------------------------------------------
theme.gauge.doublebar = {
	line  = { width = 4, gap = 5 },
	v_gap = 8,
	color = theme.color
}

-- Monitor
------------------------------------------------------------
theme.gauge.monitor = {
	font     = theme.cf_monitor,
	text_gap = 28,
	line     = { width = 4, v_gap = 36 },
	color    = theme.color
}

-- Tag
------------------------------------------------------------
theme.gauge.tag = {
	width        = 100,
	font         = theme.gauge.monitor.font,
	text_gap     = theme.gauge.monitor.text_gap,
	counter      = { size = 13, gap = 3, coord = { 50, 38 } },
	show_counter = false,
	color        = theme.color
}

-- geometry for state marks
theme.gauge.tag.geometry = {
	active   = {         y = 36,             height = 4  },
	focus    = { x = 4,  y = 14, width = 13, height = 13 },
	occupied = { x = 85, y = 8,  width = 9,  height = 15 }
}


-- Task
------------------------------------------------------------
theme.gauge.task = {
	width    = 50,
	font     = theme.gauge.monitor.font,
	text_gap = theme.gauge.monitor.text_gap,
	line     = { width = 4, v_gap = 36 },
	counter  = { size = 13, gap = 3 },
	color    = theme.color
}

-- Separator
------------------------------------------------------------
theme.gauge.separator = {
	color  = theme.color
}

-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------
theme.widget = {}

-- Widgets placement
--------------------------------------------------------------------------------
theme.widget.margin = {
	single_sep  = { 12, 12, 5, 5 },
	double_sep  = { { 12, 7, 5, 5 }, { 7, 12, 5, 5 } },
	taglist     = { 10, 0, 0, 0 },
	upgrades    = { 7, 7, 7, 7 },
	kbindicator = { 5, 5, 5, 5 },
	volume      = { 3, 3, 3, 3 },
	mail        = { 5, 5, 5, 5 },
	layoutbox   = { 8, 8, 8, 8 },
	textclock   = { 5, 15, 0, 0 }
}

-- Widgets
--------------------------------------------------------------------------------

-- Upgrades
------------------------------------------------------------
theme.widget.upgrades = {
	icon  = theme.path .. "/widget/fav.svg",
	color = theme.color
}

-- Pulseaudio volume control
------------------------------------------------------------
theme.widget.pulse = {
	notify_icon = theme.path .. "/widget/audio.svg"
}

-- Mail
------------------------------------------------------------
theme.widget.mail = {
	icon  = theme.path .. "/widget/mail.svg",
	color = theme.color,
}

-- Keyboard
------------------------------------------------------------
theme.widget.keyboard = {
	icon         = theme.path .. "/widget/keyboard.svg",
	layout_color = { theme.color.icon, theme.color.main }
}

theme.widget.keyboard.menu = {
	width        = 180,
	color        = { right_icon = theme.color.icon },
	nohide       = true
}

-- Layoutbox
------------------------------------------------------------
theme.widget.layoutbox = {
	color = theme.color
}

theme.widget.layoutbox.icon = {
	floating          = theme.path .. "/layouts/floating.svg",
	max               = theme.path .. "/layouts/max.svg",
	fullscreen        = theme.path .. "/layouts/fullscreen.svg",
	uselesstilebottom = theme.path .. "/layouts/tilebottom.svg",
	uselesstileleft   = theme.path .. "/layouts/tileleft.svg",
	uselesstile       = theme.path .. "/layouts/tile.svg",
	uselesstiletop    = theme.path .. "/layouts/tiletop.svg",
	uselessfair       = theme.path .. "/layouts/fair.svg",
	unknown           = theme.path .. "/layouts/unknown.svg",
}

theme.widget.layoutbox.menu = {
	icon_margin = { 10, 14, 10, 10 },
	width       = 260,
	auto_hotkey = true,
	nohide      = false,
	color =     { right_icon = theme.color.icon, left_icon = theme.color.icon }
}

theme.widget.layoutbox.name_alias = {
	floating          = "Floating",
	fullscreen        = "Fullscreen",
	max               = "Maximized",
	uselesstile       = "Right Tile",
	uselessfair       = "Fair Tile",
	uselesstileleft   = "Left Tile",
	uselesstiletop    = "Top Tile",
	uselesstilebottom = "Bottom Tile",
}

-- Tasklist
------------------------------------------------------------
theme.widget.tasklist = {
	width = 50
}

theme.widget.tasklist.winmenu = {
	titleline   = { font = theme.font_title, height = 35 },
	menu        = { width = 280, color = { right_icon = theme.color.icon } },
	tagmenu     = { width = 200, color = { right_icon = theme.color.icon, left_icon = theme.color.icon } },
	layout_icon = theme.widget.layoutbox.icon,
	color       = theme.color
}
theme.widget.tasklist.tasktip = {
	color = theme.color
}

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

-- Minitray
------------------------------------------------------------
theme.widget.minitray = {
	border_width = 4,
	geometry     = { x = 1530, y = 960, height = 50 },
	color        = { wibox = theme.color.wibox, border = theme.color.wibox }
}

-- Textclock
------------------------------------------------------------
theme.widget.textclock = {
	font  = theme.font_clock,
	color = { text = theme.color.icon }
}

-- Floating widgets
-----------------------------------------------------------------------------------------------------------------------
theme.float = {}

-- Tooltip
------------------------------------------------------------
theme.float.tooltip = {
	margin       = { 6, 6, 4, 4 },
	timeout      = 0,
	border_width = 2,
	color        = theme.color
}

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
	--icon_style    = { icons = { custom_only = true, scalable_only = true } },
	icon_style    = { wm_name = "awesome" },
	border_width  = 0,
	name_font     = theme.font_title,
	comment_font  = theme.font,
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
	title_font     = theme.font_title,
	--icon_style     = { icons = { custom_only = true, scalable_only = true } },
	icon_style     = { icons = { theme = os.getenv("HOME") .. "/.config/awesome/icons" } },
	border_width   = 0,
	update_timeout = 1 / 12,
	font           = theme.cf_appswitcher,
	color          = theme.color
}

-- additional color
theme.float.appswitcher.color.preview_bg = theme.color.main .. "12"

-- hotkeys
theme.float.appswitcher.hotkeys = { "1",   "2",  "3",  "4",  "5",  "6",  "7",  "8",  "9",  "0",
                                    "F1",  "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10",
                                    "F11", "F12" }

-- Exaile music player
------------------------------------------------------------
theme.float.exaile = {
	geometry     = { width = 520, height = 150, x = 580, y = 868},
	screen_gap   = theme.useless_gap_width + theme.global_border_width,
	titlefont    = theme.font_exaile_main,
	artistfont   = theme.font_exaile_main,
	timefont     = theme.font_exaile_time,
	border_width = 0,
	timeout      = 1,
	color        = theme.color
}

theme.float.exaile.icon = {
	cover   = theme.path .. "/widget/music.svg",
	next_tr = theme.path .. "/common/player_control/next.svg",
	prev_tr = theme.path .. "/common/player_control/previous.svg",
	play    = theme.path .. "/common/player_control/play.svg",
	pause   = theme.path .. "/common/player_control/pause.svg"
}

-- Notify
------------------------------------------------------------
theme.float.notify = {
	geometry     = { width = 484, height = 106, x =1424, y = 12 },
	screen_gap   = theme.useless_gap_width + theme.global_border_width,
	font         = theme.font_notify,
	border_width = 0,
	color        = theme.color
}

-- Brightness control
------------------------------------------------------------
theme.float.brightness = {
	notify_icon = theme.path .. "/widget/brightness.svg"
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
	geometry      = { width = 460, height = 400, x =1448, y = 618 },
	screen_gap    = theme.useless_gap_width + theme.global_border_width,
	border_margin = { 20, 20, 10, 0 },
	button_margin = { 140, 140, 18, 18 },
	title_height  = 40,
	border_width  = 0,
	bottom_height = 70,
	title_font    = theme.font_title,
	color         = theme.color
}

-- Decoration elements
-----------------------------------------------------------------------------------------------------------------------
theme.float.decoration = {}

theme.float.decoration.button = {
	color = theme.color
}

theme.float.decoration.button.color.text = "#cccccc"
theme.float.decoration.button.color.shadow_down = theme.color.gray

theme.float.decoration.field = {
	color = theme.color
}

-- Desktop file parser
-----------------------------------------------------------------------------------------------------------------------
theme.float.dfparser = {}

theme.float.dfparser.desktop_file_dirs = {
	'/usr/share/applications/',
	'/usr/local/share/applications/'
}

theme.float.dfparser.icons = {
	df_icon       = "/home/vorron/.icons/ACYL_Icon_Theme_0.9.4.3/scalable/mimetypes/application-x-executable.svg",
	theme         = "/home/vorron/.icons/ACYL_Icon_Theme_0.9.4.3",
	--theme         = os.getenv("HOME") .. "/.config/awesome/icons",
	custom_only   = false,
	scalable_only = false
}


-- Tasklist names
-----------------------------------------------------------------------------------------------------------------------
theme.appnames = {}
theme.appnames["Nemo"                ] = "NFM"
theme.appnames["Terminator"          ] = "TRM"
theme.appnames["Firefox"             ] = "FFX"
theme.appnames["Gnome-terminal"      ] = "TER"
theme.appnames["Gnome-system-monitor"] = "GSM"
theme.appnames["Gimp-2.8"            ] = "GMP"
theme.appnames["Gimp"                ] = "GMP"
theme.appnames["Goldendict"          ] = "DIC"
theme.appnames["Transmission-gtk"    ] = "TMN"
theme.appnames["Steam"               ] = "STM"
theme.appnames["Easytag"             ] = "TAG"
theme.appnames["Mcomix"              ] = "CMX"
theme.appnames["Claws-mail"          ] = "CML"


-----------------------------------------------------------------------------------------------------------------------
return theme
