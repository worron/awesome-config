-----------------------------------------------------------------------------------------------------------------------
--                                                  Ruby theme                                                       --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- This theme was inherited from another with overwriting some values
-- Check parent theme to find full settings list and its description
local theme = require("themes/colored/theme")


-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color.main   = "#b20d1d"
theme.color.urgent = "#087465"


-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/ruby"

-- Main config
--------------------------------------------------------------------------------
theme.panel_height = 38 -- panel height
theme.wallpaper    = theme.path .. "/wallpaper/custom.png"

-- Setup parent theme settings
--------------------------------------------------------------------------------
theme:update()


-- Desktop config
-----------------------------------------------------------------------------------------------------------------------

-- Desktop widgets placement
--------------------------------------------------------------------------------
theme.desktop.grid = {
	width  = { 440, 440 },
	height = { 100, 100, 100, 66, 50 },
	edge   = { width = { 100, 840 }, height = { 100, 100 } }
}

theme.desktop.places = {
	netspeed = { 2, 1 },
	ssdspeed = { 2, 2 },
	hddspeed = { 2, 3 },
	cpumem   = { 1, 1 },
	transm   = { 1, 2 },
	disks    = { 1, 3 },
	thermal1 = { 1, 4 },
	thermal2 = { 2, 4 },
	fan      = { 2, 5 },
	vnstat   = { 1, 5 },
}

-- Desktop widgets
--------------------------------------------------------------------------------
-- individual widget settings doesn't used by redflat module
-- but grab directly from rc-files to rewrite base style
theme.desktop.individual = { speedmeter = {}, multimeter = {}, multiline = {} }

-- Lines (common part)
theme.desktop.common.pack.lines.line.height = 5
theme.desktop.common.pack.lines.progressbar.chunk = { gap = 6, width = 16 }
theme.desktop.common.pack.lines.tooltip.set_position = function()
	local coords = mouse.coords()
	return { x = coords.x, y = coords.y - 40 }
end

-- Speedmeter (base widget)
theme.desktop.speedmeter.compact.icon = {
	up = theme.path .. "/desktop/up.svg",
	down = theme.path .. "/desktop/down.svg",
	margin = { 0, 4, 0, 0}
}
theme.desktop.speedmeter.compact.height.chart = 46
theme.desktop.speedmeter.compact.label.width = 72
theme.desktop.speedmeter.compact.label.height = 15 -- manually set after font size
theme.desktop.speedmeter.compact.label.font = { font = "Play", size = 22, face = 1, slant = 0 }
theme.desktop.speedmeter.compact.margins.label = { 10, 10, 0, 0 }
theme.desktop.speedmeter.compact.margins.chart = { 0, 0, 3, 3 }
theme.desktop.speedmeter.compact.chart = { bar = { width = 6, gap = 3 }, height = nil, zero_height = 0 }
theme.desktop.speedmeter.compact.progressbar = { chunk = { width = 6, gap = 3 }, height = 3 }

-- Speedmeter drive (individual widget)
theme.desktop.individual.speedmeter.drive = {
	unit   = { { "B", -1 }, { "KB", 2 }, { "MB", 2048 } },
}

-- Multimeter (base widget)
theme.desktop.multimeter.upbar          = { width = 32, chunk = { num = 8, line = 4 }, shape = "plain" }
theme.desktop.multimeter.lines.show     = { label = false, tooltip = true, text = false }
theme.desktop.multimeter.icon.full      = false
theme.desktop.multimeter.icon.margin    = { 0, 8, 0, 0 }
theme.desktop.multimeter.height.upright = 66
theme.desktop.multimeter.height.lines   = 20

-- Multimeter cpu and ram (individual widget)
theme.desktop.individual.multimeter.cpumem = {
	labels = { "RAM", "SWAP" },
	icon  = { image = theme.path .. "/desktop/cpu.svg" }
}

-- Multimeter transmission info (individual widget)
theme.desktop.individual.multimeter.transmission = {
	labels = { "SEED", "DNLD" },
	unit   = { { "KB", -1 }, { "MB", 1024^1 } },
	upbar  = { width = 20, chunk = { num = 8, line = 4 }, shape = "plain" },
	icon   = { image = theme.path .. "/desktop/transmission.svg" }
}

-- Multilines (base widget)
theme.desktop.multiline.lines.show     = { label = false, tooltip = true, text = false }
theme.desktop.multiline.icon.margin    = theme.desktop.multimeter.icon.margin

-- Multilines storage (individual widget)
theme.desktop.individual.multiline.storage = {
	unit      = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } },
	icon      = { image = theme.path .. "/desktop/storage.svg" },
	lines     = {
		line        = { height = 10 },
		progressbar = { chunk = { gap = 6, width = 4 } },
	},
}

-- Multilines qemu drive images (individual widget)
theme.desktop.individual.multiline.images = {
	unit = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } },
}

-- Multilines temperature (individual widget)
theme.desktop.individual.multiline.thermal = {
	digits    = 1,
	icon      = { image = theme.path .. "/desktop/thermometer.svg", margin = { 0, 8, 0, 0 } },
	lines     = {
		line        = { height = 13 },
		text        = { font = { font = "Play", size = 18, face = 1, slant = 0 }, width = 44 },
		label       = { font = { font = "Play", size = 18, face = 1, slant = 0 } },
		gap         = { text = 10 },
		progressbar = { chunk = { gap = 6, width = 4 } },
		show        = { text = true, label = false, tooltip = true },
	},
	unit      = { { "°C", -1 } },
}

-- Multilines fan (individual widget)
theme.desktop.individual.multiline.fan = {
		digits    = 1,
		icon      = { image = theme.path .. "/desktop/fan.svg", margin = { 8, 16, 0, 0 } },
		lines     = {
			line        = { height = 16 },
			progressbar = { chunk = { gap = 6, width = 4 } },
			show        = { text = false, label = false, tooltip = true },
		},
		unit      = { { "RPM", -1 }, { "R", 1 } },
}

-- Multilines traffic (individual widget)
theme.desktop.individual.multiline.vnstat = {
		digits    = 3,
		icon      = { image = theme.path .. "/desktop/traffic.svg", margin = { 8, 16, 0, 0 } },
		lines     = {
			line        = { height = 16 },
			progressbar = { chunk = { gap = 6, width = 4 } },
			show        = { text = false, label = false, tooltip = true },
		},
		unit = { { "B", 1 }, { "KiB", 1024 }, { "MiB", 1024^2 }, { "GiB", 1024^3 } },
}

-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- individual margins for panel widgets
------------------------------------------------------------
theme.widget.wrapper = {
	layoutbox   = { 12, 9, 6, 6 },
	textclock   = { 10, 10, 0, 0 },
	volume      = { 6, 10, 3, 3 },
	keyboard    = { 9, 9, 3, 3 },
	mail        = { 9, 9, 3, 3 },
	tray        = { 8, 8, 7, 7 },
	cpu         = { 9, 3, 7, 7 },
	ram         = { 2, 2, 7, 7 },
	battery     = { 3, 9, 7, 7 },
	network     = { 4, 4, 7, 7 },
	upgrades    = { 6, 6, 6, 6 },
	taglist     = { 4, 4, 5, 4 },
	tasklist    = { 0, 30, 0, 0 }, -- centering tasklist widget
}

-- Various widgets style tuning
------------------------------------------------------------

-- Dotcount
--theme.gauge.graph.dots.dot_gap_h = 5

-- System updates indicator
theme.widget.upgrades.icon = theme.path .. "/widget/upgrades.svg"

-- Audio
theme.gauge.audio.blue.dash.plain = true
theme.gauge.audio.blue.dash.bar.num = 8
theme.gauge.audio.blue.dash.bar.width = 3
theme.gauge.audio.blue.dmargin = { 5, 0, 9, 9 }
theme.gauge.audio.blue.width = 86
theme.gauge.audio.blue.icon = theme.path .. "/widget/audio.svg"

-- Dash
theme.gauge.monitor.dash.width = 11

-- Tasklist
theme.widget.tasklist.char_digit = 5
theme.widget.tasklist.task = theme.gauge.task.ruby


-- Floating widgets
-----------------------------------------------------------------------------------------------------------------------

-- Set hotkey helper size according current fonts and keys scheme
--------------------------------------------------------------------------------
theme.float.appswitcher.keytip = { geometry = { width = 400, height = 320 }, exit = true }
theme.float.keychain.keytip = { geometry = { width = 1020, height = 510 }, column = 2 }

-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
