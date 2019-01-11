-----------------------------------------------------------------------------------------------------------------------
--                                               Desktop widgets config                                              --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local tonumber = tonumber
local string = string

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

	ssdspeed.style = beautiful.desktop.speedmeter_drive

	-- HDD speed
	--------------------------------------------------------------------------------
	local hddspeed = { geometry = wgeometry(grid, places.hddspeed, workarea) }

	hddspeed.args = {
		interface = "sda",
		meter_function = system.disk_speed,
		timeout = 2,
		label = "HARD DRIVE"
	}

	hddspeed.style = beautiful.desktop.speedmeter_drive

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

	cpumem.style = beautiful.desktop.multimeter_cpumem

	-- Transmission info
	--------------------------------------------------------------------------------
	local transm = { geometry = wgeometry(grid, places.transm, workarea) }

	transm.args = {
		topbars    = { num = 8, maxm = 100 },
		-- TODO: move unit to style
		lines      = { { maxm = 6*1024, unit = { { "SEED", - 1 } } }, { maxm = 6*1024, unit = { { "DNLD", - 1 } } } },
		meter      = { func = system.transmission_parse },
		timeout    = 10,
		async      = "transmission-remote -l"
	}

	-- TODO: rework transmission seed/download info
	transm.style = beautiful.desktop.multimeter_transmission

	-- Disks
	--------------------------------------------------------------------------------
	local disks1 = { geometry = wgeometry(grid, places.disks, workarea) }
	local qemu_image1 = "/home/vmdrive/win10-gvt/win10-gvt-base.qcow2"
	local qemu_image2 = "/home/vmdrive/win10-gvt/snap/win10-gvt-current.qcow2"

	disks1.args = {
		sensors  = {
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/home" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/opt" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/mnt/media" },
			--{ meter_function = system.qemu_image_size, maxm = 100, crit = 100, args = qemu_image1 },
			--{ meter_function = system.qemu_image_size, maxm = 100, crit = 60, args = qemu_image2 },
		},
		--names   = {"root", "home", "storage", "media", "qemu-w10igpu-base", "qemu-w10igpu-snap"},
		names   = { "root", "home", "storage", "media" },
		timeout = 300
	}

	disks1.style = beautiful.desktop.multiline_storage

	-- tricky widget placement
	local disks2 = {}
	local dy = disks1.geometry.height
	           - (beautiful.desktop.multimeter.upright_height + beautiful.desktop.multimeter.lines_height)
	disks1.geometry.height = beautiful.desktop.multimeter.upright_height

	disks2.geometry = {
		x      = disks1.geometry.x,
		y      = disks1.geometry.y + disks1.geometry.height + dy,
		width  = disks1.geometry.width,
		height = beautiful.desktop.multimeter.lines_height,
	}

	disks2.args = {
		sensors  = {
			{ meter_function = system.qemu_image_size, maxm = 100, crit = 100, args = qemu_image1 },
			{ meter_function = system.qemu_image_size, maxm = 100, crit = 60, args = qemu_image2 },
		},
		names   = { "qemu-w10gvt-base", "qemu-w10gvt-snap" },
		timeout = 600
	}

	disks2.style = beautiful.desktop.multiline_images

	-- Temperature indicator
	--------------------------------------------------------------------------------

	-- ln sensors parser setup
	system.thermal.lmsensors.delay = 5
	system.thermal.lmsensors.patterns = {
		cpu  = { match = "CPU:%s+%+(%d+)%.%d°[CF]" },
		ram  = { match = "SODIMM:%s+%+(%d+)%.%d°[CF]" },
		fan1 = { match = "Processor%sFan:%s+(%d+)%sRPM" },
		fan2 = { match = "Video%sFan:%s+(%d+)%sRPM" },
		wifi = { match = "iwlwifi%-virtual%-0\r?\nAdapter:%sVirtual%sdevice\r?\ntemp1:%s+%+(%d+)%.%d°[CF]" },
		--chip = { match = "pch_skylake%-virtual%-0\r?\nAdapter:%sVirtual%sdevice\r?\ntemp1:%s+%+(%d+)%.%d°[CF]" },
	}

	-- tepmerature widgets
	local thermal1 = { geometry = wgeometry(grid, places.thermal1, workarea) }

	thermal1.args = {
		sensors = {
			--{ meter_function = system.thermal.lmsensors.get, args = "chip", maxm = 100, crit = 75 },
			{ meter_function = system.thermal.lmsensors.get, args = "cpu", maxm = 100, crit = 75 },
			{ meter_function = system.thermal.lmsensors.get, args = "wifi", maxm = 100, crit = 75 },
			{ meter_function = system.thermal.nvoptimus, maxm = 105, crit = 80 }
		},
		names   = { "cpu", "wifi", "gpu" },
		timeout = 10
	}

	thermal1.style = beautiful.desktop.multiline_thermal

	----
	local thermal2 = { geometry = wgeometry(grid, places.thermal2, workarea) }

	local function hdd_smart_check(setup)
		awful.spawn.easy_async("smartctl --attributes /dev/sda",
			function(output)
				local value = tonumber(string.match(output, "194.+%s(%d+)%s%(.+%)\r?\n"))
				setup(value and { value } or { 0 })
			end
		)
	end

	local function ssd_smart_check(setup)
		awful.spawn.easy_async("smartctl --attributes /dev/nvme0n1",
			function(output)
				local value = tonumber(string.match(output, "Temperature:%s+(%d+)%sCelsius"))
				setup(value and { value } or { 0 })
			end
		)
	end

	thermal2.args = {
		sensors = {
			{ acync_function = hdd_smart_check, maxm = 50, crit = 45 },
			{ acync_function = ssd_smart_check, maxm = 80, crit = 70 },
			{ meter_function = system.thermal.lmsensors.get, args = "ram", maxm = 100, crit = 75 },
		},
		names   = { "hdd", "ssd", "ram" },
		timeout = 30
	}

	thermal2.style = thermal1.style

	-- fan widgets
	local fan1 = { geometry = wgeometry(grid, places.fan1, workarea) }
	fan1.args = {
		sensors = { { meter_function = system.thermal.lmsensors.get, args = "fan1", maxm = 5000, crit = 4000 } },
		names   = { "fan1" },
		timeout = 10
	}
	fan1.style = beautiful.desktop.multiline_fan

	local fan2 = { geometry = wgeometry(grid, places.fan2, workarea) }
	fan2.args = {
		sensors = { { meter_function = system.thermal.lmsensors.get, args = "fan2", maxm = 5000, crit = 4000 } },
		names   = { "fan2" },
		timeout = 10
	}
	fan2.style = fan1.style

	-- Calendar
	--------------------------------------------------------------------------------
	local calendar = {
		args     = { timeout = 60 },
		geometry = { x = 1920 - 100, y = 20, width = 100, height = 1000 }
	}


	-- Initialize all desktop widgets
	--------------------------------------------------------------------------------
	netspeed.widget = redflat.desktop.speedmeter.compact(netspeed.args, netspeed.geometry, netspeed.style)
	ssdspeed.widget = redflat.desktop.speedmeter.compact(ssdspeed.args, ssdspeed.geometry, ssdspeed.style)
	hddspeed.widget = redflat.desktop.speedmeter.compact(hddspeed.args, hddspeed.geometry, hddspeed.style)

	cpumem.widget = redflat.desktop.multimeter(cpumem.args, cpumem.geometry, cpumem.style)
	transm.widget = redflat.desktop.multimeter(transm.args, transm.geometry, transm.style)

	disks1.widget  = redflat.desktop.multiline(disks1.args, disks1.geometry, disks1.style)
	disks2.widget  = redflat.desktop.multiline(disks2.args, disks2.geometry, disks2.style)

	thermal1.widget = redflat.desktop.multiline(thermal1.args, thermal1.geometry, thermal1.style)
	thermal2.widget = redflat.desktop.multiline(thermal2.args, thermal2.geometry, thermal2.style)

	fan1.widget = redflat.desktop.multiline(fan1.args, fan1.geometry, fan1.style)
	fan2.widget = redflat.desktop.multiline(fan2.args, fan2.geometry, fan2.style)

	calendar.widget = redflat.desktop.calendar(calendar.args, calendar.geometry)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return desktop
