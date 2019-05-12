-----------------------------------------------------------------------------------------------------------------------
--                                                  Green theme                                                      --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- This theme was inherited from another with overwriting some values
-- Check parent theme to find full settings list and its description
local theme = require("themes/colored/theme")


-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color.main   = "#127e1f"
theme.color.urgent = "#a21e17"


-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/green"

-- Main config
--------------------------------------------------------------------------------
theme.panel_height = 40 -- panel height
theme.wallpaper    = theme.path .. "/wallpaper/custom.png"

-- Fonts
------------------------------------------------------------
theme.cairo_fonts.desktop.textbox = { font = "Germania One", size = 24, face = 0 }


-- Setup parent theme settings
--------------------------------------------------------------------------------
theme:update()


-- Desktop config
-----------------------------------------------------------------------------------------------------------------------

-- Desktop widgets placement
--------------------------------------------------------------------------------
theme.desktop.grid = {
	width  = { 480, 480, 480 },
	height = { 180, 146, 146, 132, 17 },
	edge   = { width = { 80, 80 }, height = { 50, 50 } }
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

-- Desktop widgets
--------------------------------------------------------------------------------
-- individual widget settings doesn't used by redflat module
-- but grab directly from rc-files to rewrite base style
theme.individual.desktop = { speedmeter = {}, multimeter = {}, multiline = {}, singleline = {} }

theme.desktop.line_height = 17

-- Lines (common part)
theme.desktop.common.pack.lines.label = { width = 60, draw = "by_width" }
theme.desktop.common.pack.lines.text  = { width = 80, draw = "by_edges" }
theme.desktop.common.pack.lines.gap   = { text = 14, label = 14 }
theme.desktop.common.pack.lines.line  = { height = theme.desktop.line_height }

-- Speedmeter (base widget)
--theme.desktop.speedmeter.normal.label = { height = theme.desktop.line_height }
theme.desktop.speedmeter.normal.images = { theme.path .. "/desktop/up.svg", theme.path .. "/desktop/down.svg" }

-- Speedmeter drive (individual widget)
theme.individual.desktop.speedmeter.drive = {
	unit   = { { "B", -1 }, { "KB", 2 }, { "MB", 2048 } },
}

-- Multimeter (base widget)
theme.desktop.multimeter.icon           = { image = false }
theme.desktop.multimeter.height.lines   = 54
theme.desktop.multimeter.height.upright = 70
theme.desktop.multimeter.upbar          = { width = 32, chunk = { num = 10, line = 3 }, shape = "plain" }
theme.desktop.multimeter.lines.show     = { label = true, tooltip = false, text = true }

-- Multimeter cpu and ram (individual widget)
theme.individual.desktop.multimeter.cpumem = {
	labels = { "RAM", "SWAP" },
}

-- Multimeter transmission info (individual widget)
theme.individual.desktop.multimeter.transmission = {
	labels = { "SEED", "DNLD" },
	unit   = { { "KB", -1 }, { "MB", 1024^1 } },
}

-- Multilines disks (individual widget)
theme.individual.desktop.multiline.disks = {
	unit  = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } },
	lines = { show = { text = false } },
}

-- Singleline temperature (individual widget)
theme.individual.desktop.singleline.thermal = {
	lbox = { draw = "by_width", width = 45 },
	rbox = { draw = "by_edges", width = 52 },
	iwidth = 125,
	icon = theme.path .. "/desktop/fire.svg",
	unit = { { "°C", -1 } },
}

-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- individual margins for panel widgets
------------------------------------------------------------
theme.widget.wrapper = {
	textclock   = { 10, 10, 0, 0 },
	volume      = { 12, 10, 3, 3 },
	network     = { 6, 6, 8, 8 },
	cpu         = { 10, 2, 8, 8 },
	ram         = { 2, 2, 8, 8 },
	battery     = { 2, 10, 8, 8 },
	keyboard    = { 10, 10, 5, 5 },
	mail        = { 10, 10, 5, 5 },
	tray        = { 10, 12, 8, 8 },
	taglist     = { 6, 6, 0, 0 },
	tasklist    = { 14, 0, 0, 0 }, -- centering tasklist widget
}

-- Various widgets style tuning
------------------------------------------------------------

-- Dotcount
theme.gauge.graph.dots.dot_gap_h = 5

-- Tasklist
theme.widget.tasklist.custom_icon = true
theme.widget.tasklist.need_group = false
theme.widget.tasklist.task = theme.gauge.task.green

theme.widget.tasklist.parser = {
	desktop_file_dirs = awful.util.table.join(
		theme.service.dfparser.desktop_file_dirs,
		{ '~/.local/share/applications-fake' }
	)
}

-- icon aliases
theme.widget.tasklist.iconnames = {}
theme.widget.tasklist.iconnames["jetbrains-pycharm-ce"] = "pycharm"
theme.widget.tasklist.iconnames["Qemu-system-x86_64"]   = "qemu"

-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
