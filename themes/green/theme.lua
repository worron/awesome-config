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

-- Setup parent theme settings
--------------------------------------------------------------------------------
theme:update()


-- Desktop config
-----------------------------------------------------------------------------------------------------------------------

---- Desktop widgets
----------------------------------------------------------------------------------
--theme.desktop.speedmeter.images = { theme.path .. "/desktop/up.svg", theme.path .. "/desktop/down.svg" }
--
---- Desktop widgets placement
----------------------------------------------------------------------------------
--theme.desktop.grid = {
--	width  = { 520, 520, 520 },
--	height = { 180, 160, 160, 138, 18 },
--	edge   = { width = { 60, 60 }, height = { 40, 40 } }
--}
--
--theme.desktop.places = {
--	netspeed = { 1, 1 },
--	ssdspeed = { 2, 1 },
--	hddspeed = { 3, 1 },
--	cpumem   = { 1, 2 },
--	transm   = { 1, 3 },
--	disks    = { 1, 4 },
--	thermal  = { 1, 5 }
--}


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- individual margins for palnel widgets
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

-- Dotcount
------------------------------------------------------------
theme.gauge.graph.dots.dot_gap_h = 5

-- Tasklist
------------------------------------------------------------
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
