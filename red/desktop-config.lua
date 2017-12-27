-----------------------------------------------------------------------------------------------------------------------
--                                               Desktop widgets config                                              --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local beautiful = require("beautiful")
local awful = require("awful")
local redflat = require("redflat")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local desktop = {}

-- desktop aliases
local wgeometry = redflat.util.desktop.wgeometry
local workarea = screen[mouse.screen].workarea
local system = redflat.system

-- Desktop widgets
-----------------------------------------------------------------------------------------------------------------------
function desktop:init(args)
	if not beautiful.desktop then return end

	local args = args or {}
	local env = args.env
	-- local args = args or {}
	-- local theme_path = args.tpath or "/usr/share/awesome/themes/default"

	-- placement
	local grid = beautiful.desktop.grid
	local places = beautiful.desktop.places

	-- Network speed
	--------------------------------------------------------------------------------
	local netspeed = { geometry = wgeometry(grid, places.netspeed, workarea) }

	netspeed.args = {
		interface    = "wlp3s0",
		maxspeed     = { up = 5*1024^2, down = 5*1024^2 },
		crit         = { up = 5*1024^2, down = 5*1024^2 },
		timeout      = 2,
		autoscale    = true
	}

	netspeed.style  = {}

	-- SSD speed
	--------------------------------------------------------------------------------
	local ssdspeed = { geometry = wgeometry(grid, places.ssdspeed, workarea) }

	ssdspeed.args = {
		interface = "sdb",
		meter_function = system.disk_speed,
		timeout   = 2,
		label     = "SOLID DRIVE"
	}

	ssdspeed.style = { unit = { { "B", -1 }, { "KB", 2 }, { "MB", 2048 } } }

	-- HDD speed
	--------------------------------------------------------------------------------
	local hddspeed = { geometry = wgeometry(grid, places.hddspeed, workarea) }

	hddspeed.args = {
		interface = "sdc",
		meter_function = system.disk_speed,
		timeout = 2,
		label = "HARD DRIVE"
	}

	hddspeed.style = awful.util.table.clone(ssdspeed.style)

	-- CPU and memory usage
	--------------------------------------------------------------------------------
	local cpu_storage = { cpu_total = {}, cpu_active = {} }
	local cpumem = { geometry = wgeometry(grid, places.cpumem, workarea) }

	cpumem.args = {
		corners = { num = 8, maxm = 100, crit = 90 },
		lines   = { { maxm = 100, crit = 80 }, { maxm = 100, crit = 80 } },
		meter   = { args = cpu_storage },
		timeout = 2
	}

	cpumem.style = {}

	-- Transmission info
	--------------------------------------------------------------------------------
	local transm = { geometry = wgeometry(grid, places.transm, workarea) }

	transm.args = {
		corners    = { num = 8, maxm = 100 },
		lines      = { { maxm = 55, unit = { { "SEED", - 1 } } }, { maxm = 600, unit = { { "DNLD", - 1 } } } },
		meter      = { func = system.transmission_parse },
		timeout    = 5,
		async      = "transmission-remote -l"
	}

	transm.style = {
		digit_num = 1,
		image     = env.themedir .. "/desktop/ed1.svg"
	}

	-- Disks
	--------------------------------------------------------------------------------
	local disks = { geometry = wgeometry(grid, places.disks, workarea) }

	disks.args = {
		sensors  = {
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/home" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/opt" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/mnt/media" }
		},
		names   = {"root", "home", "misc", "data"},
		timeout = 300
	}

	disks.style = {
		unit      = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } },
		show_text = true
	}

	-- Temperature indicator
	--------------------------------------------------------------------------------

	-- cpu cores
	local thermalc = { geometry = wgeometry(grid, places.thermalc, workarea) }

	thermalc.args = {
		sensors = {
			{ meter_function = system.thermal.sensors_core, args = { index = 0, main = true }, maxm = 100, crit = 75 },
			{ meter_function = system.thermal.sensors_core, args = { index = 1 }, maxm = 100, crit = 75 },
			{ meter_function = system.thermal.sensors_core, args = { index = 2 }, maxm = 100, crit = 75 },
			{ meter_function = system.thermal.sensors_core, args = { index = 3 }, maxm = 100, crit = 75 },
		},
		names   = { "core1", "core2", "core3", "core4" },
		timeout = 10
	}

	thermalc.style = {
		unit      = { { "°C", -1 } },
		show_text = true
	}

	-- hdd
	local thermald = { geometry = wgeometry(grid, places.thermald, workarea) }

	thermald.args = {
		sensors = { { meter_function = system.thermal.hddtemp, args = { disk = "/dev/sdc" }, maxm = 60, crit = 45 } },
		names   = { "hdd" },
		timeout = 10
	}

	thermald.style = thermalc.style

	-- gpu
	local thermalg = { geometry = wgeometry(grid, places.thermalg, workarea) }
	thermalg.args = {
		sensors = { { meter_function = system.thermal.nvoptimus, maxm = 105, crit = 80 } },
		names   = { "gpu" },
		timeout = 10
	}

	thermalg.style = thermalc.style

	-- Initialize all desktop widgets
	--------------------------------------------------------------------------------
	netspeed.widget = redflat.desktop.speedgraph(netspeed.args, netspeed.geometry, netspeed.style)
	ssdspeed.widget = redflat.desktop.speedgraph(ssdspeed.args, ssdspeed.geometry, ssdspeed.style)
	hddspeed.widget = redflat.desktop.speedgraph(hddspeed.args, hddspeed.geometry, hddspeed.style)

	cpumem.widget = redflat.desktop.multim(cpumem.args, cpumem.geometry, cpumem.style)
	transm.widget = redflat.desktop.multim(transm.args, transm.geometry, transm.style)

	disks.widget   = redflat.desktop.dashpack(disks.args, disks.geometry, disks.style)
	thermalc.widget = redflat.desktop.dashpack(thermalc.args, thermalc.geometry, thermalc.style)
	thermald.widget = redflat.desktop.dashpack(thermald.args, thermald.geometry, thermald.style)
	thermalg.widget = redflat.desktop.dashpack(thermalg.args, thermalg.geometry, thermalg.style)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return desktop
