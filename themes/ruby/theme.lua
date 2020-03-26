-----------------------------------------------------------------------------------------------------------------------
--                                                  Ruby theme                                                       --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- This theme was inherited from another with overwriting some values
-- Check parent theme to find full settings list and its description
local theme = require("themes/colored/theme")


-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color.main   = "#A30817"
theme.color.urgent = "#016B84"


-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/ruby"

-- Main config
--------------------------------------------------------------------------------
theme.panel_height = 64 -- panel height
theme.wallpaper    = theme.path .. "/wallpaper/custom.png"
theme.desktopbg    = theme.path .. "/wallpaper/transparent.png"

-- Setup parent theme settings
--------------------------------------------------------------------------------
theme:update()


-- Desktop config
-----------------------------------------------------------------------------------------------------------------------

-- Desktop widgets placement
--------------------------------------------------------------------------------
theme.desktop.grid = {
	width  = { 880, 880 },
	height = { 200, 200, 200, 200, 100 },
	edge   = { width = { 200, 1680 }, height = { 200, 200 } }
}

theme.desktop.places = {
	netspeed  = { 2, 1 },
	ssdspeedm = { 2, 2 },
	hddspeed  = { 2, 3 },
	ssdspeedw = { 2, 4 },
	cpumem    = { 1, 1 },
	transm    = { 1, 2 },
	disks     = { 1, 3 },
	thermal1  = { 1, 4 },
	fan       = { 2, 5 },
	vnstat    = { 1, 5 },
}

-- Desktop widgets
--------------------------------------------------------------------------------
-- individual widget settings doesn't used by redflat module
-- but grab directly from rc-files to rewrite base style
theme.individual.desktop = { speedmeter = {}, multimeter = {}, multiline = {} }

-- Lines (common part)
theme.desktop.common.pack.lines.line.height = 10
theme.desktop.common.pack.lines.progressbar.chunk = { gap = 12, width = 32 }
theme.desktop.common.pack.lines.tooltip.set_position = function(wibox)
	awful.placement.under_mouse(wibox)
	wibox.y = wibox.y - 30
end

-- Upright bar (common part)
theme.desktop.common.bar.shaped.show.tooltip = true
theme.desktop.common.bar.shaped.tooltip.set_position = theme.desktop.common.pack.lines.tooltip.set_position

-- Speedmeter (base widget)
theme.desktop.speedmeter.compact.icon = {
	up = theme.path .. "/desktop/up.svg",
	down = theme.path .. "/desktop/down.svg",
	margin = { 0, 8, 0, 0}
}
theme.desktop.speedmeter.compact.height.chart = 92
theme.desktop.speedmeter.compact.label.width = 152
theme.desktop.speedmeter.compact.label.height = 30 -- manually set after font size
theme.desktop.speedmeter.compact.label.font = { font = "Play", size = 36, face = 1, slant = 0 }
theme.desktop.speedmeter.compact.margins.label = { 20, 20, 0, 0 }
theme.desktop.speedmeter.compact.margins.chart = { 0, 0, 6, 6 }
theme.desktop.speedmeter.compact.chart = { bar = { width = 12, gap = 6 }, height = nil, zero_height = 0 }
theme.desktop.speedmeter.compact.progressbar = { chunk = { width = 12, gap = 6 }, height = 6 }

-- Speedmeter drive (individual widget)
theme.individual.desktop.speedmeter.drive = {
	unit   = { { "B", -1 }, { "KB", 2 }, { "MB", 2048 } },
}

-- Multimeter (base widget)
theme.desktop.multimeter.upbar          = { width = 64, chunk = { num = 8, line = 8 }, shape = "plain" }
theme.desktop.multimeter.lines.show     = { label = false, tooltip = true, text = false }
theme.desktop.multimeter.icon.full      = false
theme.desktop.multimeter.icon.margin    = { 0, 8, 0, 0 }
theme.desktop.multimeter.height.upright = 132
theme.desktop.multimeter.height.lines   = 40

-- Multimeter cpu and ram (individual widget)
theme.individual.desktop.multimeter.cpumem = {
	labels = { "RAM", "SWAP" },
	icon  = { image = theme.path .. "/desktop/cpu.svg" }
}

-- Multimeter transmission info (individual widget)
theme.individual.desktop.multimeter.transmission = {
	labels = { "SEED", "DNLD" },
	unit   = { { "KB", -1 }, { "MB", 1024^1 } },
	upbar  = { width = 40, chunk = { num = 8, line = 8 }, shape = "plain" },
	icon   = { image = theme.path .. "/desktop/transmission.svg" }
}

-- Multilines (base widget)
theme.desktop.multiline.lines.show     = { label = false, tooltip = true, text = false }
theme.desktop.multiline.icon.margin    = theme.desktop.multimeter.icon.margin

-- Multilines storage (individual widget)
theme.individual.desktop.multiline.storage = {
	unit      = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } },
	icon      = { image = theme.path .. "/desktop/storage.svg" },
	lines     = {
		line        = { height = 20 },
		progressbar = { chunk = { gap = 12, width = 8 } },
	},
}

-- Multilines qemu drive images (individual widget)
theme.individual.desktop.multiline.images = {
	unit = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } },
}

-- Multilines temperature (individual widget)
theme.individual.desktop.multiline.thermal = {
	digits    = 1,
	unit      = { { "°C", -1 } },
	icon      = { image = theme.path .. "/desktop/thermometer.svg", margin = { 0, 8, 0, 0 } },
	lines     = {
		line        = { height = 20 },
		progressbar = { chunk = { gap = 12, width = 8 } },
	},
}

theme.individual.desktop.multiline.thermal_chip = {
	digits = 1,
	unit = { { "°C", -1 } },
}

-- Multilines fan (individual widget)
theme.individual.desktop.multiline.fan = {
		digits    = 1,
		margin    = { 0, 0, 10, 10 },
		icon      = { image = theme.path .. "/desktop/fan.svg", margin = { 16, 26, 0, 0 } },
		lines     = {
			line        = { height = 26 },
			progressbar = { chunk = { gap = 12, width = 8 } },
			show        = { text = false, label = false, tooltip = true },
		},
		unit      = { { "RPM", -1 }, { "R", 1 } },
}

-- Multilines traffic (individual widget)
theme.individual.desktop.multiline.vnstat = {
		digits    = 3,
		margin    = { 0, 0, 10, 10 },
		icon      = { image = theme.path .. "/desktop/traffic.svg", margin = { 16, 26, 0, 0 } },
		lines     = {
			line        = { height = 26 },
			progressbar = { chunk = { gap = 12, width = 8 } },
			show        = { text = false, label = false, tooltip = true },
		},
		unit = { { "B", 1 }, { "KiB", 1024 }, { "MiB", 1024^2 }, { "GiB", 1024^3 } },
}

-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- individual margins for panel widgets
------------------------------------------------------------
theme.widget.wrapper = {
	layoutbox   = { 14, 12, 11, 11 },
	textclock   = { 16, 16, 0, 0 },
	volume      = { 4, 12, 7, 7 },
	microphone  = { 6, 5, 10, 10 },
	keyboard    = { 12, 12, 5, 5 },
	mail        = { 12, 12, 5, 5 },
	tray        = { 12, 12, 12, 12 },
	cpu         = { 12, 5, 12, 12 },
	ram         = { 3, 3, 12, 12 },
	battery     = { 5, 12, 12, 12 },
	network     = { 5, 5, 11, 11 },
	updates     = { 8, 8, 10, 10 },
	taglist     = { 6, 6, 8, 8 },
	tasklist    = { 10, 0, 0, 0 }, -- centering tasklist widget
}

-- Various widgets style tuning
------------------------------------------------------------

-- Dotcount
--theme.gauge.graph.dots.dot_gap_h = 5

-- System updates indicator
theme.widget.updates.icon = theme.path .. "/widget/updates.svg"

-- Audio
theme.gauge.audio.blue.dash.plain = true
theme.gauge.audio.blue.dash.bar.num = 8
theme.gauge.audio.blue.dash.bar.width = 5
theme.gauge.audio.blue.dmargin = { 4, 0, 13, 13 }
theme.gauge.audio.blue.width = 136
theme.gauge.audio.blue.icon = theme.path .. "/widget/audio.svg"

-- Dash
theme.gauge.monitor.dash.width = 16

-- Tasklist
theme.widget.tasklist.char_digit = 5
theme.widget.tasklist.task = theme.gauge.task.ruby

-- KB layout indicator
theme.widget.keyboard.icon = theme.path .. "/widget/keyboard.svg"

-- Mail
theme.widget.mail.icon = theme.path .. "/widget/mail.svg"

-- Battery
theme.widget.battery.notify = { icon = theme.path .. "/widget/battery.svg", color = theme.color.main }
theme.widget.battery.levels = { 0.05, 0.1, 0.15, 0.2, 0.25, 0.30 }

-- Individual styles
------------------------------------------------------------
theme.individual.microphone_audio = {
	width   = 46,
	--dmargin = { 4, 3, 1, 1 },
	--dash    = { line = { num = 3, height = 5 } },
	icon    = theme.path .. "/widget/microphone.svg",
	color   = { icon = theme.color.main, mute = theme.color.icon }
}

-- Floating widgets
-----------------------------------------------------------------------------------------------------------------------

-- Titlebar helper
theme.float.bartip.names = { "Mini", "Compact", "Full" }

-- Set hotkey helper size according current fonts and keys scheme
--------------------------------------------------------------------------------
theme.float.hotkeys.geometry   = { width = 1920 }
theme.float.appswitcher.keytip = { geometry = { width = 560 }, exit = true }
theme.float.keychain.keytip    = { geometry = { width = 1600 }, column = 2 }
theme.float.top.keytip         = { geometry = { width = 560 } }
theme.float.apprunner.keytip   = { geometry = { width = 560 } }
theme.widget.updates.keytip    = { geometry = { width = 560 } }
theme.menu.keytip              = { geometry = { width = 560 } }

-- Titlebar
-----------------------------------------------------------------------------------------------------------------------
theme.titlebar.icon_compact = {
	color        = { icon = theme.color.gray, main = theme.color.main, urgent = theme.color.main },
	list         = {
		maximized = theme.path .. "/titlebar/maximized.svg",
		minimized = theme.path .. "/titlebar/minimize.svg",
		close     = theme.path .. "/titlebar/close.svg",
		focus     = theme.path .. "/titlebar/focus.svg",
		unknown   = theme.icon.unknown,
	}
}

-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
