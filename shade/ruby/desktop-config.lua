-----------------------------------------------------------------------------------------------------------------------
--                                               Desktop widgets config                                              --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local beautiful = require("beautiful")
--local awful = require("awful")
local redflat = require("redflat")
local timer = require("gears.timer")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local desktop = {}

-- desktop aliases
local wgeometry = redflat.util.desktop.wgeometry
local workarea = screen[mouse.screen].workarea
local system = redflat.system

local wa = mouse.screen.workarea

-- Desktop widgets
-----------------------------------------------------------------------------------------------------------------------
function desktop:init(_)
	if not beautiful.desktop then return end

	--local args = args or {}
	--local env = args.env

	-- placement
	local grid = beautiful.desktop.grid
	local places = beautiful.desktop.places

	-- Network speed
	--------------------------------------------------------------------------------
	local netspeed = { geometry = wgeometry(grid, places.netspeed, workarea) }

	netspeed.args = {
		meter_function = system.net_speed,
		interface      = "wlp60s0",
		maxspeed       = { up = 6*1024^2, down = 6*1024^2 },
		crit           = { up = 6*1024^2, down = 6*1024^2 },
		timeout        = 2,
		autoscale      = false,
		label          = "NET"
	}

	netspeed.style  = {}

	-- SSD speed
	--------------------------------------------------------------------------------
	local ssdspeed = { geometry = wgeometry(grid, places.ssdspeed, workarea) }

	ssdspeed.args = {
		interface      = "nvme0n1",
		meter_function = system.disk_speed,
		timeout        = 2,
		label          = "SOLID DRIVE"
	}

	ssdspeed.style = beautiful.desktop.individual.speedmeter.drive

	-- HDD speed
	--------------------------------------------------------------------------------
	local hddspeed = { geometry = wgeometry(grid, places.hddspeed, workarea) }

	hddspeed.args = {
		interface      = "sda",
		meter_function = system.disk_speed,
		timeout        = 2,
		label          = "HARD DRIVE"
	}

	hddspeed.style = beautiful.desktop.individual.speedmeter.drive

	-- CPU and memory usage
	--------------------------------------------------------------------------------
	local cpu_storage = { cpu_total = {}, cpu_active = {} }
	local cpumem = { geometry = wgeometry(grid, places.cpumem, workarea) }

	cpumem.args = {
		topbars = { num = 8, maxm = 100, crit = 90 },
		lines   = { { maxm = 100, crit = 80 }, { maxm = 100, crit = 80 } },
		meter   = { args = cpu_storage, func = system.dformatted.cpumem },
		timeout = 5
	}

	cpumem.style = beautiful.desktop.individual.multimeter.cpumem

	-- Transmission info
	--------------------------------------------------------------------------------
	local transm = { geometry = wgeometry(grid, places.transm, workarea) }

	transm.args = {
		topbars    = { num = 12, maxm = 100 },
		lines      = { { maxm = 6*1024 }, { maxm = 6*1024 } },
		meter      = { async = system.transmission.info, args = { speed_only = true } },
		timeout    = 10,
	}

	transm.style = beautiful.desktop.individual.multimeter.transmission

	-- Disks
	--------------------------------------------------------------------------------
	local disks = { geometry = wgeometry(grid, places.disks, workarea) }
	local disks_original_height = disks.geometry.height
	disks.geometry.height = beautiful.desktop.multimeter.upright_height

	disks.args = {
		sensors  = {
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/home" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/opt" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/mnt/media" },
		},
		names   = { "root", "home", "storage", "media" },
		timeout = 300
	}

	disks.style = beautiful.desktop.individual.multiline.storage

	-- QEMU image (placed along with disks)
	--------------------------------------------------------------------------------
	local qemu_image1 = "/home/vmdrive/win10-gvt/win10-gvt-base.qcow2"
	local qemu_image2 = "/home/vmdrive/win10-gvt/snap/win10-gvt-current.qcow2"

	local bms = beautiful.desktop.multimeter -- base multimeter style
	local dy = disks_original_height - (bms.upright_height + bms.lines_height)

	local qemu = { geometry = {} }

	-- triky placement
	qemu.geometry.x      = disks.geometry.x
	qemu.geometry.y      = disks.geometry.y + disks.geometry.height + dy
	qemu.geometry.width  = disks.geometry.width
	qemu.geometry.height = beautiful.desktop.multimeter.lines_height

	--setup
	qemu.args = {
		sensors  = {
			{ meter_function = system.qemu_image_size, maxm = 100, crit = 90, args = qemu_image1 },
			{ meter_function = system.qemu_image_size, maxm = 100, crit = 80, args = qemu_image2 },
		},
		names   = { "qemu-w10gvt-base", "qemu-w10gvt-snap" },
		timeout = 600
	}

	qemu.style = beautiful.desktop.individual.multiline.images

	-- Sensors parser setup
	--------------------------------------------------------------------------------
	local sensors_base_timeout = 10

	system.lmsensors.delay = 2
	system.lmsensors.patterns = {
		cpu       = { match = "CPU:%s+%+(%d+)%.%d°[CF]" },
		ram       = { match = "SODIMM:%s+%+(%d+)%.%d°[CF]" },
		wifi      = { match = "iwlwifi%-virtual%-0\r?\nAdapter:%sVirtual%sdevice\r?\ntemp1:%s+%+(%d+)%.%d°[CF]" },
		--chip      = { match = "pch_skylake%-virtual%-0\r?\nAdapter:%sVirtual%sdevice\r?\ntemp1:%s+%+(%d+)%.%d°[CF]" },
		cpu_fan   = { match = "Processor%sFan:%s+(%d+)%sRPM" },
		video_fan = { match = "Video%sFan:%s+(%d+)%sRPM" },
	}

	-- start auto async lmsensors check
	system.lmsensors:soft_start(sensors_base_timeout)

	-- Temperature indicator for chips
	--------------------------------------------------------------------------------
	local thermal_chips = { geometry = wgeometry(grid, places.thermal1, workarea) }

	thermal_chips.args = {
		sensors = {
			--{ meter_function = system.lmsensors.get, args = "chip", maxm = 100, crit = 75 },
			{ meter_function = system.lmsensors.get, args = "cpu", maxm = 100, crit = 75 },
			{ meter_function = system.lmsensors.get, args = "wifi", maxm = 100, crit = 75 },
			{ async_function = system.thermal.nvoptimus, maxm = 105, crit = 80 }
		},
		names   = { "cpu", "wifi", "gpu" },
		timeout = sensors_base_timeout,
	}

	thermal_chips.style = beautiful.desktop.individual.multiline.thermal

	-- Temperature indicator for storage devices
	--------------------------------------------------------------------------------
	local thermal_storage = { geometry = wgeometry(grid, places.thermal2, workarea) }

	local hdd_smart_check = system.simple_async("smartctl --attributes /dev/sda", "194.+%s(%d+)%s%(.+%)\r?\n")
	local ssd_smart_check = system.simple_async("smartctl --attributes /dev/nvme0n1", "Temperature:%s+(%d+)%sCelsius")

	thermal_storage.args = {
		sensors = {
			{ async_function = hdd_smart_check, maxm = 60, crit = 45 },
			{ async_function = ssd_smart_check, maxm = 80, crit = 70 },
			{ meter_function = system.lmsensors.get, args = "ram", maxm = 100, crit = 75 },
		},
		names   = { "hdd", "ssd", "ram" },
		timeout = 3 * sensors_base_timeout,
	}

	thermal_storage.style = thermal_chips.style

	-- Fan 1
	--------------------------------------------------------------------------------
	local cpu_fan = { geometry = wgeometry(grid, places.fan1, workarea) }
	cpu_fan.args = {
		sensors = { { meter_function = system.lmsensors.get, args = "cpu_fan", maxm = 5000, crit = 4000 } },
		names   = { "fan" },
		timeout = sensors_base_timeout,
	}
	cpu_fan.style = beautiful.desktop.individual.multiline.fan

	-- Fan 2
	--------------------------------------------------------------------------------
	local video_fan = { geometry = wgeometry(grid, places.fan2, workarea) }
	video_fan.args = {
		sensors = { { meter_function = system.lmsensors.get, args = "video_fan", maxm = 5000, crit = 4000 } },
		names   = { "fan" },
		timeout = sensors_base_timeout,
	}
	video_fan.style = beautiful.desktop.individual.multiline.fan

	-- Calendar
	--------------------------------------------------------------------------------
	local cwidth = 100 -- calendar widget width
	local cy = 21      -- calendar widget upper margin
	local cheight = wa.height - 2*cy

	local calendar = {
		args     = { timeout = 60 },
		geometry = { x = wa.width - cwidth, y = cy, width = cwidth, height = cheight }
	}


	-- Initialize all desktop widgets
	--------------------------------------------------------------------------------
	netspeed.widget = redflat.desktop.speedmeter.compact(netspeed.args, netspeed.geometry, netspeed.style)
	ssdspeed.widget = redflat.desktop.speedmeter.compact(ssdspeed.args, ssdspeed.geometry, ssdspeed.style)
	hddspeed.widget = redflat.desktop.speedmeter.compact(hddspeed.args, hddspeed.geometry, hddspeed.style)

	cpumem.widget = redflat.desktop.multimeter(cpumem.args, cpumem.geometry, cpumem.style)
	transm.widget = redflat.desktop.multimeter(transm.args, transm.geometry, transm.style)

	disks.widget  = redflat.desktop.multiline(disks.args, disks.geometry, disks.style)
	qemu.widget  = redflat.desktop.multiline(qemu.args, qemu.geometry, qemu.style)

	thermal_chips.widget = redflat.desktop.multiline(thermal_chips.args, thermal_chips.geometry, thermal_chips.style)
	thermal_storage.widget = redflat.desktop.multiline(
		thermal_storage.args, thermal_storage.geometry, thermal_storage.style
	)

	cpu_fan.widget   = redflat.desktop.multiline(cpu_fan.args, cpu_fan.geometry, cpu_fan.style)
	video_fan.widget = redflat.desktop.multiline(video_fan.args, video_fan.geometry, video_fan.style)

	calendar.widget = redflat.desktop.calendar(calendar.args, calendar.geometry)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return desktop
