-----------------------------------------------------------------------------------------------------------------------
--                                               Desktop widgets config                                              --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local beautiful = require("beautiful")
--local awful = require("awful")
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

	args = args or {}
	local env = args.env or {}
	local autohide = env.desktop_autohide or false

	-- placement
	local grid = beautiful.desktop.grid
	local places = beautiful.desktop.places

	-- Network speed
	--------------------------------------------------------------------------------
	local netspeed = { geometry = wgeometry(grid, places.netspeed, workarea) }

	netspeed.args = {
		interface    = "wlp60s0",
		maxspeed     = { up = 6*1024^2, down = 6*1024^2 },
		crit         = { up = 6*1024^2, down = 6*1024^2 },
		timeout      = 2,
		autoscale    = false
	}

	netspeed.style  = {}

	-- SSD speed
	--------------------------------------------------------------------------------
	local ssdspeed = { geometry = wgeometry(grid, places.ssdspeed, workarea) }

	ssdspeed.args = {
		interface = "nvme0n1",
		meter_function = system.disk_speed,
		timeout   = 2,
		label     = "SOLID DRIVE"
	}

	ssdspeed.style = beautiful.individual.desktop.speedmeter.drive

	-- HDD speed
	--------------------------------------------------------------------------------
	local hddspeed = { geometry = wgeometry(grid, places.hddspeed, workarea) }

	hddspeed.args = {
		interface = "sda",
		meter_function = system.disk_speed,
		timeout = 2,
		label = "HARD DRIVE"
	}

	hddspeed.style = beautiful.individual.desktop.speedmeter.drive

	-- CPU and memory usage
	--------------------------------------------------------------------------------
	local cpu_storage = { cpu_total = {}, cpu_active = {} }
	local cpumem = { geometry = wgeometry(grid, places.cpumem, workarea) }

	cpumem.args = {
		topbars = { num = 8, maxm = 100, crit = 90 },
		lines   = { { maxm = 100, crit = 80 }, { maxm = 100, crit = 80 } },
		meter   = { args = cpu_storage, func = system.dformatted.cpumem },
		timeout = 2
	}

	cpumem.style = beautiful.individual.desktop.multimeter.cpumem

	-- Transmission info
	--------------------------------------------------------------------------------
	local transm = { geometry = wgeometry(grid, places.transm, workarea) }

	transm.args = {
		topbars    = { num = 8, maxm = 100 },
		lines      = { { maxm = 6*1024 }, { maxm = 6*1024 } },
		meter      = { async = system.transmission.info, args = { speed_only = true } },
		timeout    = 5,
	}

	transm.style = beautiful.individual.desktop.multimeter.transmission

	-- Disks
	--------------------------------------------------------------------------------
	local disks = { geometry = wgeometry(grid, places.disks, workarea) }

	disks.args = {
		sensors  = {
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "root", args = "/"            },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "home", args = "/home"        },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "misc", args = "/mnt/storage" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "data", args = "/mnt/media"   },
		},
		timeout = 300
	}

	disks.style = beautiful.individual.desktop.multiline.disks

	-- Sensors parser setup
	--------------------------------------------------------------------------------
	local sensors_base_timeout = 5

	system.lmsensors.delay = 2
	system.lmsensors.patterns = {
		cpu       = { match = "CPU:%s+%+(%d+)%.%d°[CF]" },
	}

	-- start auto async lmsensors check
	system.lmsensors:soft_start(sensors_base_timeout)

	-- Temperature indicator
	--------------------------------------------------------------------------------
	local thermal = { geometry = wgeometry(grid, places.thermal, workarea) }

	local hdd_smart_check = system.simple_async("smartctl --attributes /dev/sda", "194.+%s(%d+)%s%(.+%)\r?\n")

	thermal.args = {
		sensors = {
			{ meter_function = system.lmsensors.get, args = "cpu", maxm = 100, crit = 75, name = "cpu" },
			{ async_function = hdd_smart_check, maxm = 60, crit = 45, name = "hdd" },
			{ async_function = system.thermal.nvoptimus, maxm = 105, crit = 80, name = "gpu" }
		},
		timeout = sensors_base_timeout,
	}

	thermal.style = beautiful.individual.desktop.singleline.thermal


	-- Initialize all desktop widgets
	--------------------------------------------------------------------------------
	netspeed.body = redflat.desktop.speedmeter.normal(netspeed.args, netspeed.style)
	ssdspeed.body = redflat.desktop.speedmeter.normal(ssdspeed.args, ssdspeed.style)
	hddspeed.body = redflat.desktop.speedmeter.normal(hddspeed.args, hddspeed.style)
	cpumem.body   = redflat.desktop.multimeter(cpumem.args, cpumem.style)
	transm.body   = redflat.desktop.multimeter(transm.args, transm.style)
	disks.body    = redflat.desktop.multiline(disks.args, disks.style)
	thermal.body  = redflat.desktop.singleline(thermal.args, thermal.style)

	-- Desktop setup
	--------------------------------------------------------------------------------
	local desktop_objects = { netspeed, hddspeed, ssdspeed, transm, cpumem, disks, thermal }

	if not autohide then
		redflat.util.desktop.build.static(desktop_objects)
	else
		redflat.util.desktop.build.dynamic(desktop_objects, nil, beautiful.desktopbg, args.buttons)
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return desktop
