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

local wa = mouse.screen.workarea

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

	ssdspeed.style = beautiful.individual.desktop.speedmeter.drive

	-- HDD speed
	--------------------------------------------------------------------------------
	local hddspeed = { geometry = wgeometry(grid, places.hddspeed, workarea) }

	hddspeed.args = {
		interface      = "sda",
		meter_function = system.disk_speed,
		timeout        = 2,
		label          = "HARD DRIVE"
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
		timeout = 5
	}

	cpumem.style = beautiful.individual.desktop.multimeter.cpumem

	-- Transmission info
	--------------------------------------------------------------------------------
	local transm = { geometry = wgeometry(grid, places.transm, workarea) }

	transm.args = {
		topbars    = { num = 12, maxm = 100 },
		lines      = { { maxm = 6*1024 }, { maxm = 6*1024 } },
		meter      = { async = system.transmission.info, args = { speed_only = true } },
		timeout    = 10,
	}

	transm.style = beautiful.individual.desktop.multimeter.transmission

	-- Disks
	--------------------------------------------------------------------------------
	local disks = { geometry = wgeometry(grid, places.disks, workarea) }
	local disks_original_height = disks.geometry.height
	disks.geometry.height = beautiful.desktop.multimeter.height.upright

	disks.args = {
		sensors  = {
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "root",    args = "/"            },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "home",    args = "/home"        },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "storage", args = "/mnt/storage" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "media",   args = "/mnt/media"   },
		},
		timeout = 300
	}

	disks.style = beautiful.individual.desktop.multiline.storage

	-- QEMU image (placed along with disks)
	--------------------------------------------------------------------------------
	local qm1 = "/mnt/storage/vmdrive/win10-gvt/win10-work-base.qcow2"
	local qm2 = "/mnt/storage/vmdrive/win10-gvt/win10-work-current.qcow2"

	local bms = beautiful.desktop.multimeter -- base multimeter style
	local dy = disks_original_height - (bms.height.upright + bms.height.lines)

	local qemu = { geometry = {} }

	-- triky placement
	qemu.geometry.x      = disks.geometry.x
	qemu.geometry.y      = disks.geometry.y + disks.geometry.height + dy
	qemu.geometry.width  = disks.geometry.width
	qemu.geometry.height = beautiful.desktop.multimeter.height.lines

	--setup
	qemu.args = {
		sensors  = {
			{ meter_function = system.qemu_image_size, maxm = 100, crit = 90, name = "qemu-w10-base", args = qm1 },
			{ meter_function = system.qemu_image_size, maxm = 100, crit = 80, name = "qemu-w10-snap", args = qm2 },
		},
		timeout = 600
	}

	qemu.style = beautiful.individual.desktop.multiline.images

	-- Sensors parser setup
	--------------------------------------------------------------------------------
	local sensors_base_timeout = 10

	system.lmsensors.delay = 2
	system.lmsensors.patterns = {
		cpu       = { match = "CPU:%s+%+(%d+)%.%d°[CF]" },
		ram       = { match = "SODIMM:%s+%+(%d+)%.%d°[CF]" },
		wifi      = { match = "iwlwifi_1%-virtual%-0\r?\nAdapter:%sVirtual%sdevice\r?\ntemp1:%s+%+(%d+)%.%d°[CF]" },
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
			{ meter_function = system.lmsensors.get, args = "cpu",  maxm = 100, crit = 75, name = "cpu"  },
			{ meter_function = system.lmsensors.get, args = "wifi", maxm = 100, crit = 75, name = "wifi" },
			{ async_function = system.thermal.nvoptimus, maxm = 105, crit = 80, name = "gpu" }
		},
		timeout = sensors_base_timeout,
	}

	thermal_chips.style = beautiful.individual.desktop.multiline.thermal

	-- Temperature indicator for storage devices
	--------------------------------------------------------------------------------
	local thermal_storage = { geometry = wgeometry(grid, places.thermal2, workarea) }

	local hdd_smart_check = system.simple_async("smartctl --attributes /dev/sda", "194.+%s(%d+)%s%(.+%)\r?\n")
	local ssd_smart_check = system.simple_async("smartctl --attributes /dev/nvme0n1", "Temperature:%s+(%d+)%sCelsius")

	thermal_storage.args = {
		sensors = {
			{ async_function = hdd_smart_check, maxm = 60, crit = 45, name = "hdd" },
			{ async_function = ssd_smart_check, maxm = 80, crit = 70, name = "ssd" },
			{ meter_function = system.lmsensors.get, args = "ram", maxm = 100, crit = 75, name = "ram" },
		},
		timeout = 3 * sensors_base_timeout,
	}

	thermal_storage.style = thermal_chips.style

	-- Fans
	--------------------------------------------------------------------------------
	local fan = { geometry = wgeometry(grid, places.fan, workarea) }
	fan.args = {
		sensors = {
			{ meter_function = system.lmsensors.get, args = "cpu_fan",   maxm = 5000, crit = 4000, name = "fan1" },
			{ meter_function = system.lmsensors.get, args = "video_fan", maxm = 5000, crit = 4000, name = "fan2" }
		},
		timeout = sensors_base_timeout,
	}
	fan.style = beautiful.individual.desktop.multiline.fan

	-- traffic stat
	--------------------------------------------------------------------------------
	local vnstat = { geometry = wgeometry(grid, places.vnstat, workarea) }

	local vnstat_daily   = system.vnstat_check({ options = '-d', traffic = 'rx' })
	local vnstat_monthly = system.vnstat_check({ options = '-m', traffic = 'rx' })

	vnstat.args = {
		sensors = {
			{ async_function = vnstat_daily,   maxm = 5 * 1024^3, name = "daily" },
			{ async_function = vnstat_monthly, maxm = 75 * 1024^3,  name = "monthly" },
		},
		timeout = 900,
	}
	vnstat.style = beautiful.individual.desktop.multiline.vnstat

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
	netspeed.body = redflat.desktop.speedmeter.compact(netspeed.args, netspeed.style)
	ssdspeed.body = redflat.desktop.speedmeter.compact(ssdspeed.args, ssdspeed.style)
	hddspeed.body = redflat.desktop.speedmeter.compact(hddspeed.args, hddspeed.style)

	cpumem.body = redflat.desktop.multimeter(cpumem.args, cpumem.style)
	transm.body = redflat.desktop.multimeter(transm.args, transm.style)

	disks.body  = redflat.desktop.multiline(disks.args, disks.style)
	qemu.body  = redflat.desktop.multiline(qemu.args, qemu.style)

	thermal_chips.body = redflat.desktop.multiline(thermal_chips.args, thermal_chips.style)
	thermal_storage.body = redflat.desktop.multiline(thermal_storage.args, thermal_storage.style)

	fan.body   = redflat.desktop.multiline(fan.args, fan.style)
	vnstat.body = redflat.desktop.multiline(vnstat.args, vnstat.style)

	calendar.body = redflat.desktop.calendar(calendar.args, calendar.style)

	-- Desktop setup
	--------------------------------------------------------------------------------
	local desktop_objects = {
		calendar, netspeed, hddspeed, ssdspeed, transm, cpumem,
		disks, qemu, vnstat, fan, thermal_chips, thermal_storage
	}

	if not autohide then
		redflat.util.desktop.build.static(desktop_objects)
	else
		redflat.util.desktop.build.dynamic(desktop_objects, nil, beautiful.desktopbg, args.buttons)
	end

	calendar.body:activate_wibox(calendar.wibox)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return desktop
