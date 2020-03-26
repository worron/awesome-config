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
		interface      = "eno1",
		maxspeed       = { up = 6*1024^2, down = 6*1024^2 },
		crit           = { up = 6*1024^2, down = 6*1024^2 },
		timeout        = 2,
		autoscale      = false,
		label          = "NET"
	}

	netspeed.style  = {}

	-- SSD1 speed
	--------------------------------------------------------------------------------
	local ssdspeedm = { geometry = wgeometry(grid, places.ssdspeedm, workarea) }

	ssdspeedm.args = {
		interface      = "sdb",
		meter_function = system.disk_speed,
		timeout        = 2,
		label          = "MAIN SSD"
	}

	ssdspeedm.style = beautiful.individual.desktop.speedmeter.drive

	-- SSD2 speed
	--------------------------------------------------------------------------------
	local ssdspeedw = { geometry = wgeometry(grid, places.ssdspeedw, workarea) }

	ssdspeedw.args = {
		interface      = "sda",
		meter_function = system.disk_speed,
		timeout        = 2,
		label          = "WINDOWS SSD"
	}

	ssdspeedw.style = beautiful.individual.desktop.speedmeter.drive

	-- HDD speed
	--------------------------------------------------------------------------------
	local hddspeed = { geometry = wgeometry(grid, places.hddspeed, workarea) }

	hddspeed.args = {
		interface      = "sdc",
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
	local qm1 = "/mnt/storage/vmdrive/win10-gvt/win10-gvt-base.qcow2"
	local qm2 = "/mnt/storage/vmdrive/win10-gvt/win10-gvt-current.qcow2"

	local bms = beautiful.desktop.multimeter -- base multimeter style
	local dy = disks_original_height - (bms.height.upright + bms.height.lines)

	local qemu = { geometry = {} }

	-- tricky placement
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
		cpu0      = { match = "Core%s0:%s+%+(%d+)%.%d°[CF]" },
		cpu1      = { match = "Core%s1:%s+%+(%d+)%.%d°[CF]" },
		cpu2      = { match = "Core%s2:%s+%+(%d+)%.%d°[CF]" },
		cpu3      = { match = "Core%s3:%s+%+(%d+)%.%d°[CF]" },
		gpu       = { match = "edge:%s+%+(%d+)%.%d°[CF]" },
		ram       = { match = "SODIMM:%s+%+(%d+)%.%d°[CF]" },
		wifi      = { match = "iwlwifi%-virtual%-0\r?\nAdapter:%sVirtual%sdevice\r?\ntemp1:%s+%+(%d+)%.%d°[CF]" },
		--chip      = { match = "pch_skylake%-virtual%-0\r?\nAdapter:%sVirtual%sdevice\r?\ntemp1:%s+%+(%d+)%.%d°[CF]" },
		chip      = { match = "it8728%-isa%-0a30.-temp1:%s+%+(%d+)%.%d°[CF]" },
		cpu_fan   = { match = "it8728%-isa%-0a30.-fan1:%s+(%d+)%sRPM" },
		video_fan = { match = "amdgpu%-pci%-0100.-fan1:%s+(%d+)%sRPM" },
		--video_fan = { match = "Video%sFan:%s+(%d+)%sRPM" },
	}

	-- start auto async lmsensors check
	system.lmsensors:soft_start(sensors_base_timeout)

	-- Temperature indicator for cpu
	--------------------------------------------------------------------------------
	local thermal_cpu = { geometry = wgeometry(grid, places.thermal1, workarea) }
	--local thermal_cpu_original_height = thermal_cpu.geometry.height
	thermal_cpu.geometry.height = beautiful.desktop.multimeter.height.upright

	thermal_cpu.args = {
		sensors = {
			{ meter_function = system.lmsensors.get, args = "cpu0",  maxm = 100, crit = 75, name = "core0"  },
			{ meter_function = system.lmsensors.get, args = "cpu1",  maxm = 100, crit = 75, name = "core1"  },
			{ meter_function = system.lmsensors.get, args = "cpu2",  maxm = 100, crit = 75, name = "core2"  },
			{ meter_function = system.lmsensors.get, args = "cpu3",  maxm = 100, crit = 75, name = "core3"  },
		},
		timeout = sensors_base_timeout,
	}

	thermal_cpu.style = beautiful.individual.desktop.multiline.thermal

	-- Temperature indicator for chips (placed along with cpu thermal)
	--------------------------------------------------------------------------------
	--local dy = thermal_cpu_original_height - (bms.height.upright + bms.height.lines)

	local thermal_chip = { geometry = {} }

	-- tricky placement
	thermal_chip.geometry.x      = thermal_cpu.geometry.x
	thermal_chip.geometry.y      = thermal_cpu.geometry.y + thermal_cpu.geometry.height + dy
	thermal_chip.geometry.width  = thermal_cpu.geometry.width
	thermal_chip.geometry.height = beautiful.desktop.multimeter.height.lines

	--setup
	thermal_chip.args = {
		sensors  = {
			{ meter_function = system.lmsensors.get, args = "gpu", maxm = 100, crit = 75, name = "gpu" },
			{ meter_function = system.lmsensors.get, args = "chip", maxm = 100, crit = 75, name = "mb" },
		},
		timeout = 600
	}

	thermal_chip.style = beautiful.individual.desktop.multiline.thermal_chip

	-- Fans
	--------------------------------------------------------------------------------
	local fan = { geometry = wgeometry(grid, places.fan, workarea) }
	fan.args = {
		sensors = {
			{ meter_function = system.lmsensors.get, args = "cpu_fan",   maxm = 5000, crit = 4000, name = "cpu" },
			{ meter_function = system.lmsensors.get, args = "video_fan", maxm = 5000, crit = 4000, name = "gpu" }
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
			{ async_function = vnstat_daily,   maxm = 5 * 1024^3,   name = "daily" },
			{ async_function = vnstat_monthly, maxm = 75 * 1024^3,  name = "monthly" },
		},
		timeout = 900,
	}
	vnstat.style = beautiful.individual.desktop.multiline.vnstat

	-- Calendar
	--------------------------------------------------------------------------------
	local cwidth = 180 -- calendar widget width
	local cy = 30      -- calendar widget upper margin
	local cheight = wa.height - 2*cy

	local calendar = {
		args     = { timeout = 60 },
		geometry = { x = wa.width - cwidth, y = cy, width = cwidth, height = cheight }
	}


	-- Initialize all desktop widgets
	--------------------------------------------------------------------------------
	netspeed.body = redflat.desktop.speedmeter.compact(netspeed.args, netspeed.style)
	ssdspeedm.body = redflat.desktop.speedmeter.compact(ssdspeedm.args, ssdspeedm.style)
	ssdspeedw.body = redflat.desktop.speedmeter.compact(ssdspeedw.args, ssdspeedw.style)
	hddspeed.body = redflat.desktop.speedmeter.compact(hddspeed.args, hddspeed.style)

	cpumem.body = redflat.desktop.multimeter(cpumem.args, cpumem.style)
	transm.body = redflat.desktop.multimeter(transm.args, transm.style)

	disks.body  = redflat.desktop.multiline(disks.args, disks.style)
	qemu.body  = redflat.desktop.multiline(qemu.args, qemu.style)

	thermal_cpu.body = redflat.desktop.multiline(thermal_cpu.args, thermal_cpu.style)
	thermal_chip.body = redflat.desktop.multiline(thermal_chip.args, thermal_chip.style)
	--thermal_storage.body = redflat.desktop.multiline(thermal_storage.args, thermal_storage.style)

	fan.body   = redflat.desktop.multiline(fan.args, fan.style)
	vnstat.body = redflat.desktop.multiline(vnstat.args, vnstat.style)

	calendar.body = redflat.desktop.calendar(calendar.args, calendar.style)

	-- Desktop setup
	--------------------------------------------------------------------------------
	local desktop_objects = {
		calendar, netspeed, hddspeed, ssdspeedm, transm, cpumem,
		disks, qemu, vnstat, fan, thermal_cpu, ssdspeedw, thermal_chip
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
