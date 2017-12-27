-----------------------------------------------------------------------------------------------------------------------
--                                               Desktop widgets config                                              --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local beautiful = require("beautiful")
local awful = require("awful")
local redflat = require("redflat")
local wibox = require("wibox")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local desktop = {}

-- desktop aliases
local workarea = screen[mouse.screen].workarea
local system = redflat.system

-- Desktop widgets
-----------------------------------------------------------------------------------------------------------------------
function desktop:init(args)
	if not beautiful.desktop then return end

	local args = args or {}
	local env = args.env
	local style = { color = beautiful.desktop.color }

	-- Setting and placement
	--------------------------------------------------------------------------------
	local gap = { x = { 680, 120 }, y = { 120, 80 } }
	local geometry = {
		width  = workarea.width  - (gap.x[1] + gap.x[2]), x = workarea.x + gap.x[1],
		height = workarea.height - (gap.y[1] + gap.y[2]), y = workarea.y + gap.y[1],
	}

	local desktopbox = wibox({ type = "desktop", visible = true, bg = style.color.wibox })
	desktopbox:geometry(geometry)

	local main_layout = wibox.layout.fixed.vertical()

	-- hilight settings
	local colset = { light = {}, base = {}, diskp = {}, diskpf = {}, tcpu = {}, tgpu = {}, thdd = {},
	                 sspeed = {}, hspeed = {}, tspeed = {}, cores = {}}

	colset.base[0] = style.color.icon
	colset.light[0] = style.color.main

	colset.diskp[0] = style.color.icon
	colset.diskp[75] = style.color.main

	colset.diskpf[0] = style.color.main
	colset.diskpf[25] = style.color.icon

	colset.tcpu[0] = style.color.icon
	colset.tcpu[75] = style.color.main

	colset.tgpu[0] = style.color.icon
	colset.tgpu[80] = style.color.main

	colset.thdd[0] = style.color.icon
	colset.thdd[40] = style.color.main

	colset.sspeed[-1] = style.color.icon
	colset.sspeed[80 * 2048] = style.color.main

	colset.hspeed[-1] = style.color.icon
	colset.hspeed[30 * 2048] = style.color.main

	colset.tspeed[-1] = style.color.icon
	colset.tspeed[2.5 * 1024] = style.color.main

	colset.cores[0] = style.color.icon
	colset.cores[3] = style.color.main

	-- Support functions
	--------------------------------------------------------------------------------
	local function get_order(t)
		local order = {}
		for i, _ in pairs(t) do order[#order + 1] = i end
		table.sort(order)
		return order
	end

	local function form_value(value, color_set, text_set, unit, dn)
		local color_set = color_set or colset.base
		local text_set = text_set or { "none" }
		local dn = dn or 3

		local hilight = style.color.gray
		local co = get_order(color_set)
		for _, i in ipairs(co) do
			if value > i then hilight = color_set[i] end
		end

		local txt = value
		if unit then
			txt = redflat.util.text.dformat(value, unit, dn, " ")
		else
			local to = get_order(text_set)

			for i = #to, 1, -1 do
				if value < to[i] then txt = text_set[to[i]] end
			end
		end

		return string.format('<span color="%s">%s</span>', hilight, txt)
	end

	local function form_text(sentences, values)
		local txt = ""
		for i, v in ipairs(values) do txt = txt .. string.format(sentences[i], unpack(v)) end
		return txt
	end

	local function recolor(txt, c)
		return string.format('<span color="%s">%s</span>', c, txt)
	end

	-- CPU and memory usage
	--------------------------------------------------------------------------------
	local cpu_storage = { cpu_total = {}, cpu_active = {} }
	local cpuset = { args = { timeout = { 5, 10 }, actions ={} }, height = 200 }
	cpuset.unit = { { "MB", - 1 }, { "GB", 1024 } }

	local cpu_sentences = {
		"%s",
		" %s percent of CPU. ",
		"In more detail %s of the %s available cores fully loaded ",
		"and %s %s half-used. ",
		-- "Furthermore %s %s used by more than ten percent.",
	}

	local cpu_intro = {}
	cpu_intro[11] = "Your system uses only"
	cpu_intro[50] = "Your system uses"
	cpu_intro[100] = "Warning! Your system uses only"

	-- cpu meter function
	cpuset.args.actions[1] = function()
		local usage = system.cpu_usage(cpu_storage)

		local core_load = { full = 0, half = 0, low = 0 }
		for _, core in ipairs(usage.core) do
			if     core > 90 then core_load.full = core_load.full + 1
			elseif core > 50 then core_load.half = core_load.half + 1
			elseif core > 10 then core_load.low  = core_load.low + 1 end
		end

		local values = {
			{ form_value(usage.total, {}, cpu_intro) },
			{ form_value(usage.total, colset.light, {}) },
			{ form_value(core_load.full, colset.cores), #usage.core },
			{ form_value(core_load.half, colset.cores, { "not even one" }), core_load.half > 1 and "are" or "is" },
			-- { form_value(core_load.low), core_load.low > 1 and "cores are" or "core is" },
		}

		return form_text(cpu_sentences, values)
	end

	-- memory meter function
	local mem_states = {}
	mem_states[10] = "less than a tenth of the total."
	mem_states[25] = "less than a quarter of total."
	mem_states[50] = "less then half of total."
	mem_states[75] = "more then half of total."
	mem_states[100] = "very close to limit."

	local mem_sentences = {
		" Meanwhile memory usage %s and that is %s",
		" As for the swap space %s is used now.",
	}

	cpuset.args.actions[2] = function()
		local mem = system.memory_info()

		local values = {
			{ form_value(mem.inuse, colset.light, nil, cpuset.unit), form_value(mem.usep, {}, mem_states) },
			{ form_value(mem.swp.inuse, colset.light, { "not a single byte" }, mem.swp.inuse > 0 and cpuset.unit or nil) },
		}

		return form_text(mem_sentences, values)
	end

	-- Disks
	--------------------------------------------------------------------------------
	local diskset = { args = { timeout = { 60 }, actions = {} }, height = 280 }
	diskset.unit = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } }

	local disks_points = { "/", "/home", "/opt", "/mnt/media" }
	local disk_sentences = {
		"Turning to the topic of drives %s of data was found on your system partition " ..
		"and %s%s percent of disk space remain free.",
		" Home partition filled with %s and %s percent of it is still free.",
		" Also separate partition was allocated for opt directory" ..
		" where %s used which is approximately %s percent of total,",
		" and for media subdir of mnt where %s used which is %s percent.",
	}

	-- disk usage meter function
	diskset.args.actions[1] = function()
		local data = {}
		for _, arg in ipairs(disks_points) do
			data[#data + 1] = system.fs_info(arg)
		end

		local values = {
			{
				form_value(data[1][2], colset.light, {}, diskset.unit),
				data[1][1] > 50 and "only " or "",
				form_value(100 - data[1][1], colset.diskpf)
			},
			{ form_value(data[2][2], colset.light, {}, diskset.unit), form_value(100 - data[2][1], colset.diskpf) },
			{ form_value(data[3][2], colset.light, {}, diskset.unit), form_value(data[3][1], colset.diskp ) },
			{ form_value(data[4][2], colset.light, {}, diskset.unit), form_value(data[4][1], colset.diskp ) },
		}

		return form_text(disk_sentences, values)
	end

	-- Temperature indicator
	--------------------------------------------------------------------------------
	local hardwareset = { args = { timeout = { 10, 10 }, actions = {} }, height = 240 }
	hardwareset.unit = { { "KBps", -1 }, { "MBps", 2048 } }

	local thermal_sentences = {
		"According to the sensor readings CPU temperature of %s degrees Celsius",
		" and hard disk drive of %s degrees.",
		" Discrete graphics card %s.",
	}

	-- temperature sensors
	hardwareset.args.actions[1] = function()
		local data = {}
		data[1] = system.thermal.sensors("'Package id 0'")
		data[2] = system.thermal.hddtemp({ disk = "/dev/sdc" })
		data[3] = system.thermal.nvoptimus()

		local values = {
			{ form_value(data[1][1], colset.tcpu, {}) },
			{ form_value(data[2][1], colset.thdd, {}) },
			{ data[3].off and "is currently disabled" or
			 string.format("has temperature of %s degrees", form_value(data[3][1], colset.tgpu, {})) },
		}

		return form_text(thermal_sentences, values)
	end

	-- disks i/o speed
	local speed_storage = { {}, {} }
	local speed_sentences = {
		" Seems like system solid disk drive %s%s.",
		" In its turn media hard disk drive %s%s.",
	}

	local rs_txt = recolor("read speed ", style.color.icon)
	local ws_txt = recolor(" write speed ", style.color.icon)

	local no_act_txt = { "shows no signs of even minimal activity lately", "shows no signs of activity" }

	hardwareset.args.actions[2] = function()
		local data = {}
		data[1] = system.disk_speed("sdb", speed_storage[1])
		data[2] = system.disk_speed("sdc", speed_storage[2])

		local values = {}
		for i, set in ipairs({colset.sspeed, colset.hspeed}) do
			if data[i][1] > 1 or data[i][2] > 1 then
				values[i] = { rs_txt .. form_value(data[i][1], set, {}, hardwareset.unit) .. " and",
				              ws_txt .. form_value(data[i][2], colset.sspeed, {}, hardwareset.unit) }
			else
				values[i] = { no_act_txt[i], (i == 2 and values[1][2] == "") and " either" or "" }
			end
		end

		return form_text(speed_sentences, values)
	end

	-- Transmission info
	--------------------------------------------------------------------------------
	local torrset = { args = { timeout = { 10 }, actions = {}, acync = { "transmission-remote -l" } }, height = 120 }
	torrset.nactive = 5

	local torrent_sentences = {
		"In conclusion, it should be mentioned that torrent client %s",
		" with %s active items at total.",
		" %s %s of them %s downloading now%s",
		" and %s %s seeding%s.",
		" Current downdload progress:%s",
	}

	local form_torr_speed = function(d)
		return " at speed of " .. form_value(tonumber(d), colset.tspeed, {}, { { "KBps", -1 } })
	end

	local tr_not_found = "does not running and information about your downloads is not available."

	torrset.args.actions[1] = function(output)
		data = system.transmission_parse(output)

		local values = {}
		values[1] = { data.alert and tr_not_found or "running" }
		if not data.alert then
			values[2] = { form_value(#data.corners) }
			values[3] = { (data.lines[1][2] > 0 or data.lines[2][2] > 0) and "Moreover" or "Unfortunately",
			              form_value(data.lines[2][2]), data.lines[2][2] > 1 and "are" or "is",
			              data.lines[2][2] > 0 and form_torr_speed(data.lines[2][1]) or "" }
			values[4] = { form_value(data.lines[1][2]), data.lines[1][2] > 1 and "are" or "is",
			              data.lines[1][2] > 0 and form_torr_speed(data.lines[1][1]) or "" }

			local tlist = ""
			for i, t in ipairs(data.corners) do
				if tonumber(t) < 100 then
					if i <= torrset.nactive then tlist = tlist .. " " .. t .. "%" end
				end
			end
			if tlist ~= "" then values[5] = { recolor(tlist, style.color.main) } end
		end

		return form_text(torrent_sentences, values)
	end

	-- Initialize all desktop widgets
	--------------------------------------------------------------------------------
	for _, field in ipairs({ cpuset, diskset, hardwareset, torrset }) do
		field.box = redflat.desktop.textset(field.args)
		field.box:set_forced_height(field.height)
		main_layout:add(field.box)
	end

	desktopbox:set_widget(main_layout)
	if args.buttons then main_layout:buttons(args.buttons) end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return desktop
