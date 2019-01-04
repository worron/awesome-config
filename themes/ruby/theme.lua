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
	width  = { 460, 460 },
	height = { 100, 100, 100, 66, 18 },
	edge   = { width = { 80, 840 }, height = { 80, 80 } }
}

theme.desktop.places = {
	netspeed = { 2, 1 },
	ssdspeed = { 2, 2 },
	hddspeed = { 2, 3 },
	cpumem   = { 1, 1 },
	transm   = { 1, 2 },
	disks    = { 1, 3 },
	thermal  = { 1, 4 },
	fan1     = { 1, 5 },
	fan2     = { 2, 5 },
}

-- Desktop widgets
--------------------------------------------------------------------------------

-- Lines
------------------------------------------------------------
theme.desktop.common.pack.lines.line_height = 5
theme.desktop.common.pack.lines.progressbar.chunk = { gap = 6, width = 16 }
theme.desktop.common.pack.lines.tooltip.set_position = function()
	local coords = mouse.coords()
	return { x = coords.x, y = coords.y - 40 }
end

-- Speedmeter
------------------------------------------------------------
theme.desktop.speedmeter.compact.icon = {
	up = theme.path .. "/desktop/up.svg",
	down = theme.path .. "/desktop/down.svg",
	margin = { 0, 4, 0, 0}
}
theme.desktop.speedmeter.compact.height.chart = 46
theme.desktop.speedmeter.compact.label.width = 80
theme.desktop.speedmeter.compact.label.font = { font = "prototype", size = 22, face = 1, slant = 0 }
theme.desktop.speedmeter.compact.margins.label = { 10, 10, 11, 11 }
theme.desktop.speedmeter.compact.margins.chart = { 0, 0, 3, 3 }
theme.desktop.speedmeter.compact.chart = { bar = { width = 6, gap = 3 }, height = nil, zero_height = 0 }
theme.desktop.speedmeter.compact.progressbar = { chunk = { width = 6, gap = 3 }, height = 3 }

-- Multimeter
------------------------------------------------------------
theme.desktop.multimeter.upbar          = { width = 32, chunk = { num = 8, line = 4 }, shape = "plain" }
theme.desktop.multimeter.upright_height = 66
theme.desktop.multimeter.lines_height   = 20


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
	taglist     = { 4, 4, 5, 4 },
	tasklist    = { 0, 72, 0, 0 }, -- centering tasklist widget
}

-- Dotcount
------------------------------------------------------------
--theme.gauge.graph.dots.dot_gap_h = 5

-- Audio
------------------------------------------------------------
theme.gauge.audio.blue.dash.plain = true
theme.gauge.audio.blue.dash.bar.num = 8
theme.gauge.audio.blue.dash.bar.width = 3
theme.gauge.audio.blue.dmargin = { 5, 0, 9, 9 }
theme.gauge.audio.blue.width = 86
theme.gauge.audio.blue.icon = theme.path .. "/widget/audio.svg"

-- Dash
------------------------------------------------------------
theme.gauge.monitor.dash.width = 11

-- Tag (base element of taglist)
------------------------------------------------------------

-- Tasklist
------------------------------------------------------------
theme.widget.tasklist.char_digit = 5
theme.widget.tasklist.task = theme.gauge.task.ruby

-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
