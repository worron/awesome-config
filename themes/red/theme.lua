-----------------------------------------------------------------------------------------------------------------------
--                                                   Red theme                                                       --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- This theme was inherited from another with overwriting some values
-- Check parent theme to find full settings list and its description
local theme = require("themes/colored/theme")


-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color.main   = "#A90017"
theme.color.urgent = "#00725B"


-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/red"

-- Main config
--------------------------------------------------------------------------------
theme.panel_height = 50 -- panel height
theme.useless_gap  = 6  -- useless gap
theme.cellnum = { x = 80, y = 43 } -- grid layout property

theme.wallpaper    = theme.path .. "/wallpaper/custom.png"

-- Fonts
------------------------------------------------------------
theme.cairo_fonts.tag = { font = "Play", size = 20, face = 1 } -- taglist widget

-- Setup parent theme settings
--------------------------------------------------------------------------------
theme:update()


-- Desktop config
-----------------------------------------------------------------------------------------------------------------------

-- Desktop widgets placement
--------------------------------------------------------------------------------
theme.desktop.grid = {
	width  = { 520, 520, 520 },
	height = { 190, 188, 144, 18 },
	edge   = { width = { 80, 80 }, height = { 80, 60 } }
}

theme.desktop.places = {
	netspeed = { 1, 1 },
	ssdspeed = { 2, 1 },
	hddspeed = { 3, 1 },
	cpumem   = { 1, 2 },
	transm   = { 2, 2 },
	disks    = { 2, 3 },
	thermalc = { 1, 3 },
	thermald = { 1, 4 },
	thermalg = { 2, 4 },
}

-- Desktop widgets
--------------------------------------------------------------------------------
-- individual widget settings doesn't used by redflat module
-- but grab directly from rc-files to rewrite base style
theme.desktop.individual = { speedmeter = {}, multimeter = {}, multiline = {} }


-- Lines (common part)
theme.desktop.common.pack.lines.label_style = { width = 88, draw = "by_width" }
theme.desktop.common.pack.lines.text_style  = { width = 88, draw = "by_edges" }
theme.desktop.common.pack.lines.text_gap    = 20
theme.desktop.common.pack.lines.label_gap   = 20

-- Speedmeter (base widget)
theme.desktop.speedmeter.normal.label            = { height = theme.desktop.line_height }
theme.desktop.speedmeter.normal.progressbar      = { chunk = { width = 16, gap = 6 }, height = 6 }
theme.desktop.speedmeter.normal.chart            = { bar = { width = 6, gap = 3 }, height = 40, zero_height = 4 }
theme.desktop.speedmeter.normal.barvalue_height  = 32
theme.desktop.speedmeter.normal.fullchart_height = 78
theme.desktop.speedmeter.normal.image_gap        = 20
theme.desktop.speedmeter.normal.images           = {theme.path .. "/desktop/up.svg", theme.path .. "/desktop/down.svg"}

-- Speedmeter drive (individual widget)
theme.desktop.individual.speedmeter.drive = {
	unit   = { { "B", -1 }, { "KB", 2 }, { "MB", 2048 } },
}

-- Multimeter (base widget)
theme.desktop.multimeter.upbar          = { width = 34, chunk = { height = 17, num = 10, line = 5 } }
theme.desktop.multimeter.lines_height   = 60
theme.desktop.multimeter.upright_height = 98
theme.desktop.multimeter.icon.margin    = { 0, 20, 0, 0 }
theme.desktop.multimeter.lines          = { show_label = false, show_tooltip = false, show_text = true }

-- Multimeter cpu and ram (individual widget)
theme.desktop.individual.multimeter.cpumem = {
	labels = { "RAM", "SWAP" },
	icon   = { image = theme.path .. "/desktop/ed2.svg" }
}

-- Multimeter transmission info (individual widget)
theme.desktop.individual.multimeter.transmission = {
	labels = { "SEED", "DNLD" },
	unit   = { { "KB", -1 }, { "MB", 1024^1 } },
	icon   = { image = theme.path .. "/desktop/ed1.svg" }
}

-- Multilines disks (individual widget)
theme.desktop.individual.multiline.disks = {
	unit  = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } },
	lines = { show_text = true },
}

-- Multilines temperature (individual widget)
theme.desktop.individual.multiline.thermal = {
	lines = { show_text = true },
	unit  = { { "°C", -1 } },
}

-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- individual margins for panel widgets
--------------------------------------------------------------------------------
theme.widget.wrapper = {
	textclock   = { 4, 20, 0, 0 },
	layoutbox   = { 4, 4, 9, 9 },
	volume      = { 4, 4, 5, 5 },
	upgrades    = { 4, 4, 9, 9 },
	keyboard    = { 4, 4, 5, 5 },
	mail        = { 4, 4, 5, 5 },
	battery     = { 3, 3, 0, 0 },
	ram         = { 3, 3, 0, 0 },
	cpu         = { 3, 3, 0, 0 },
	tray        = { 1, 1, 8, 8 },
	network     = { 1, 1, 8, 8 },
	taglist     = { 12, 0, 0, 0 },
	tasklist    = { 4, 4, 0, 0 },
}

-- Various widgets style tuning
------------------------------------------------------------

-- Separator
theme.gauge.separator.marginv = { 12, 12, 5, 5 }
theme.gauge.separator.marginh = { 8, 8, 3, 3 }

-- Dotcount
theme.gauge.graph.dots.column_num   = { 2, 3 }
theme.gauge.graph.dots.row_num      = 4
theme.gauge.graph.dots.dot_size     = 5
theme.gauge.graph.dots.dot_gap_h    = 5

-- Tag
theme.gauge.tag.red.width        = 100
theme.gauge.tag.red.text_shift   = 28
theme.gauge.tag.red.counter      = { size = 13, margin = 3, coord = { 50, 38 } }
theme.gauge.tag.red.show_counter = false

theme.gauge.tag.red.geometry = {
	active   = {         y = 36,             height = 4  },
	focus    = { x = 4,  y = 14, width = 13, height = 13 },
	occupied = { x = 85, y = 8,  width = 9,  height = 15 }
}

-- Task
theme.gauge.task.red.width      = 50
theme.gauge.task.red.text_shift = theme.gauge.tag.red.text_shift
theme.gauge.task.red.line       = { height = 4, y = 36 }
theme.gauge.task.red.counter    = { size = 13, margin = 3 }

-- Monitor
theme.gauge.monitor.plain.text_shift = theme.gauge.tag.red.text_shift
theme.gauge.monitor.plain.line       = theme.gauge.task.red.line

-- Tasklist
theme.widget.tasklist.char_digit = 3
theme.widget.tasklist.task = theme.gauge.task.red

theme.widget.tasklist.appnames = {}
theme.widget.tasklist.appnames["Nemo"                ] = "NFM"
theme.widget.tasklist.appnames["Gvim"                ] = "VIM"
theme.widget.tasklist.appnames["Terminator"          ] = "TRM"
theme.widget.tasklist.appnames["Firefox"             ] = "FFX"
theme.widget.tasklist.appnames["Gnome-terminal"      ] = "TER"
theme.widget.tasklist.appnames["Gnome-system-monitor"] = "GSM"
theme.widget.tasklist.appnames["Gimp-2.8"            ] = "GMP"
theme.widget.tasklist.appnames["Gimp"                ] = "GMP"
theme.widget.tasklist.appnames["Goldendict"          ] = "DIC"
theme.widget.tasklist.appnames["Transmission-gtk"    ] = "TMN"
theme.widget.tasklist.appnames["Steam"               ] = "STM"
theme.widget.tasklist.appnames["Easytag"             ] = "TAG"
theme.widget.tasklist.appnames["Mcomix"              ] = "CMX"
theme.widget.tasklist.appnames["Claws-mail"          ] = "CML"

-- System updates indicator
theme.widget.upgrades.icon = theme.icon.awesome

-- Minitray
theme.widget.minitray.geometry = { height = 50 }

-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
