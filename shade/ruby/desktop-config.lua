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
		autoscale    = false,
		label        = "NET"
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

	ssdspeed.style = {
		unit   = { { "B", -1 }, { "KB", 2 }, { "MB", 2048 } },
	}

	-- HDD speed
	--------------------------------------------------------------------------------
	local hddspeed = { geometry = wgeometry(grid, places.hddspeed, workarea) }

	hddspeed.args = {
		interface = "sda",
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
		topbars = { num = 8, maxm = 100, crit = 90 },
		lines   = { { maxm = 100, crit = 80 }, { maxm = 100, crit = 80 } },
		meter   = { args = cpu_storage },
		timeout = 5
	}

	cpumem.style = {
		labels = { "RAM", "SWAP" },
		lines = { show_label = false, show_tooltip = true, show_text = false },
		icon  = { image = env.themedir .. "/desktop/cpu.svg", full = true, margin = { 0, 4, 0, 0 } }
	}

	-- Transmission info
	--------------------------------------------------------------------------------
	local transm = { geometry = wgeometry(grid, places.transm, workarea) }

	transm.args = {
		topbars    = { num = 8, maxm = 100 },
		lines      = { { maxm = 6*1024, unit = { { "SEED", - 1 } } }, { maxm = 6*1024, unit = { { "DNLD", - 1 } } } },
		meter      = { func = system.transmission_parse },
		timeout    = 10,
		async      = "transmission-remote -l"
	}

	transm.style = {
		digit_num = 1,
		lines = { show_label = false, show_tooltip = true, show_text = false },
		icon  = { image = env.themedir .. "/desktop/cpu.svg", full = true, margin = { 0, 4, 0, 0 } }
		--icon      = env.themedir .. "/desktop/skull.svg"
	}

	-- Disks
	--------------------------------------------------------------------------------
	local disks = { geometry = wgeometry(grid, places.disks, workarea) }
	local qemu_image1 = "/home/vmdrive/win10-vgpu/win10-vgpu-current.qcow2"
	local qemu_image2 = "/home/vmdrive/win10-vgpu/snap/win10-vgpu-testing.qcow2"

	disks.args = {
		sensors  = {
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/home" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/opt" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/mnt/media" },
			{ meter_function = system.qemu_image_size, maxm = 100, crit = 100, args = qemu_image1 },
			{ meter_function = system.qemu_image_size, maxm = 100, crit = 60, args = qemu_image2 },
		},
		names   = {"root", "home", "storage", "media", "qemu-w10igpu-base", "qemu-w10igpu-snap"},
		timeout = 300
	}

	disks.style = {
		unit      = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } },
		icon      = { image = env.themedir .. "/desktop/storage.svg", margin = { 0, 4, 0, 0 } },
		lines     = { show_label = false, show_tooltip = true, show_text = false },
	}

	-- Temperature indicator
	--------------------------------------------------------------------------------
	local thermal = { geometry = wgeometry(grid, places.thermal, workarea) }

	thermal.args = {
		sensors = {
			{ meter_function = system.thermal.sensors, args = "'Package id 0'", maxm = 100, crit = 75 },
			{ meter_function = system.thermal.hddtemp, args = { disk = "/dev/sda" }, maxm = 60, crit = 45 },
			{ meter_function = system.thermal.nvoptimus, maxm = 105, crit = 80 }
		},
		names   = { "cpu", "hdd", "gpu" },
		timeout = 5
	}

	thermal.style = {
		unit      = { { "°C", -1 } },
	}

	-- Calendar
	--------------------------------------------------------------------------------
	local calendar = {
		args     = { timeout = 60 },
		geometry = { x = 1920 - 86, y = 20, width = 86, height = 1000 }
	}


	-- Initialize all desktop widgets
	--------------------------------------------------------------------------------
	netspeed.widget = redflat.desktop.speedmeter.compact(netspeed.args, netspeed.geometry, netspeed.style)
	ssdspeed.widget = redflat.desktop.speedmeter.compact(ssdspeed.args, ssdspeed.geometry, ssdspeed.style)
	hddspeed.widget = redflat.desktop.speedmeter.compact(hddspeed.args, hddspeed.geometry, hddspeed.style)
	cpumem.widget = redflat.desktop.multimeter(cpumem.args, cpumem.geometry, cpumem.style)
	transm.widget = redflat.desktop.multimeter(transm.args, transm.geometry, transm.style)
	disks.widget = redflat.desktop.multiline(disks.args, disks.geometry, disks.style)
	--thermal.widget = redflat.desktop.singleline(thermal.args, thermal.geometry, thermal.style)
	calendar.widget = redflat.desktop.calendar(calendar.args, calendar.geometry)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return desktop
