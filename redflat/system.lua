-----------------------------------------------------------------------------------------------------------------------
--                                                   RedFlat system                                                  --
-----------------------------------------------------------------------------------------------------------------------
-- System monitoring functions collected here
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ vicious module
------ (c) 2010, 2011 Adrian C. <anrxc@sysphere.org>
------ (c) 2009, Lucas de Vries <lucas@glacicle.com>
------ (c) 2011, Jörg T. <jthalheim@gmail.com>
------ (c) 2011, Adrian C. <anrxc@sysphere.org>
-----------------------------------------------------------------------------------------------------------------------


-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local tonumber = tonumber
local io = io
local os = os
local setmetatable = setmetatable
local string = string

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local system = { thermal = {}, dformatted = {}, pformatted = {} }

-- Disk usage
-----------------------------------------------------------------------------------------------------------------------
function system.fs_info(args)
	local fs_info = {}
	local args = args or "/"

	-- Get data from df
	------------------------------------------------------------
	local line = awful.util.pread("LC_ALL=C df -kP " .. args .. " | tail -1")

	-- Parse data
	------------------------------------------------------------
	fs_info.size  = string.match(line, "^.-[%s]([%d]+)")
	fs_info.mount = string.match(line, "%%[%s]([%p%w]+)")
	fs_info.used, fs_info.avail, fs_info.use_p = string.match(line, "([%d]+)[%D]+([%d]+)[%D]+([%d]+)%%")

	-- Format output special for redflat desktop widget
	------------------------------------------------------------
   return { tonumber(fs_info.use_p), tonumber(fs_info.used) }
end

-- Get network speed
-----------------------------------------------------------------------------------------------------------------------
function system.net_speed(interface, storage)
	local up, down = 0, 0

	-- Get network info
	--------------------------------------------------------------------------------
	for line in io.lines("/proc/net/dev") do

		-- Match wmaster0 as well as rt0 (multiple leading spaces)
		local name = string.match(line, "^[%s]?[%s]?[%s]?[%s]?([%w]+):")

		-- Calculate speed for given interface
		------------------------------------------------------------
		if name == interface then
			-- received bytes, first value after the name
			local recv = tonumber(string.match(line, ":[%s]*([%d]+)"))
			-- transmited bytes, 7 fields from end of the line
			local send = tonumber(string.match(line, "([%d]+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d$"))

			local now = os.time()

			if not storage[interface] then
				-- default values on the first run
				storage[interface] = { recv = 0, send = 0 }
			else
				-- net stats are absolute, substract our last reading
				local interval = now - storage[interface].time
				if interval <= 0 then interval = 1 end

				down = (recv - storage[interface].recv) / interval
				up   = (send - storage[interface].send) / interval
			end

			-- store totals
			storage[interface].time = now
			storage[interface].recv = recv
			storage[interface].send = send
		end
	end

	--------------------------------------------------------------------------------
	return { up, down }
end

-- Get disk speed
-----------------------------------------------------------------------------------------------------------------------
function system.disk_speed(disk, storage)
	local up, down = 0, 0

	-- Get i/o info
	--------------------------------------------------------------------------------
	for line in io.lines("/proc/diskstats") do

		-- parse info
		-- linux kernel documentation: Documentation/iostats.txt
		local device, read, write = string.match(line, "([^%s]+) %d+ %d+ (%d+) %d+ %d+ %d+ (%d+)")

		-- Calculate i/o for given device
		------------------------------------------------------------
		if device == disk then
			local now   = os.time()
			local stats = { read, write }

			if not storage[disk] then
				-- default values on the first run
				storage[disk] = { stats = stats }
			else
				-- check for overflows and counter resets (> 2^32)
				if stats[1] < storage[disk].stats[1] or stats[2] < storage[disk].stats[2] then
					storage[disk].stats[1], storage[disk].stats[2] = stats[1], stats[2]
				end

				-- diskstats are absolute, substract our last reading
				-- * divide by timediff because we don't know the timer value
				local interval = now - storage[disk].time
				if interval <= 0 then interval = 1 end

				up   = (stats[1] - storage[disk].stats[1]) / interval
				down = (stats[2] - storage[disk].stats[2]) / interval
			end

			-- store totals
			storage[disk].time = now
			storage[disk].stats = stats
		end
	end

	--------------------------------------------------------------------------------
	return { up, down }
end

-- Get MEM info
-----------------------------------------------------------------------------------------------------------------------
function system.memory_info()
	local mem = { buf = {}, swp = {} }

	-- Get MEM info
	------------------------------------------------------------
	for line in io.lines("/proc/meminfo") do
		for k, v in string.gmatch(line, "([%a]+):[%s]+([%d]+).+") do
			if     k == "MemTotal"  then mem.total = math.floor(v/1024)
			elseif k == "MemFree"   then mem.buf.f = math.floor(v/1024)
			elseif k == "Buffers"   then mem.buf.b = math.floor(v/1024)
			elseif k == "Cached"    then mem.buf.c = math.floor(v/1024)
			elseif k == "SwapTotal" then mem.swp.t = math.floor(v/1024)
			elseif k == "SwapFree"  then mem.swp.f = math.floor(v/1024)
			end
		end
	end

	-- Calculate memory percentage
	------------------------------------------------------------
	mem.free  = mem.buf.f + mem.buf.b + mem.buf.c
	mem.inuse = mem.total - mem.free
	mem.bcuse = mem.total - mem.buf.f
	mem.usep  = math.floor(mem.inuse / mem.total * 100)

	-- calculate swap percentage
	mem.swp.inuse = mem.swp.t - mem.swp.f
	mem.swp.usep  = math.floor(mem.swp.inuse / mem.swp.t * 100)

	------------------------------------------------------------
	return mem
end

-- Get cpu usage info
-----------------------------------------------------------------------------------------------------------------------
--local storage = { cpu_total = {}, cpu_active = {} } -- storage structure

function system.cpu_usage(storage)
	local cpu_lines = {}
	local cpu_usage = {}
	local diff_time_total

	-- Get CPU stats
	------------------------------------------------------------
	for line in io.lines("/proc/stat") do
		if string.sub(line, 1, 3) == "cpu" then
			local digits_in_line = {}

			for i in string.gmatch(line, "[%s]+([^%s]+)") do
				table.insert(digits_in_line, i)
			end

			table.insert(cpu_lines, digits_in_line)
		end
	end

	-- Calculate usage
	------------------------------------------------------------
	for i, line in ipairs(cpu_lines) do

		-- calculate totals
		local total_new = 0
		for _, value in ipairs(line) do total_new = total_new + value end

		local active_new = total_new - (line[4] + line[5])

		-- calculate percentage
		local diff_total  = total_new  - (storage.cpu_total[i]  or 0)
		local diff_active = active_new - (storage.cpu_active[i] or 0)

		if i == 1 then diff_time_total = diff_total end
		if diff_total == 0 then diff_total = 1E-6 end

		cpu_usage[i] = math.floor((diff_active / diff_total) * 100)

		-- store totals
		storage.cpu_total[i]  = total_new
		storage.cpu_active[i] = active_new
	end

	-- Format output special for redflat widgets and other system functions
	------------------------------------------------------------
	local total_usage = cpu_usage[1]
	local core_usage = awful.util.table.clone(cpu_usage)
	table.remove(core_usage, 1)

	return { total = total_usage, core = core_usage, diff = diff_time_total }
end

-- Get battery level and charging status
-----------------------------------------------------------------------------------------------------------------------
function system.battery(batname)
	if not batname then return end

	-- Initialzie vars
	--------------------------------------------------------------------------------
	local battery = {}
	local time = "N/A"

	local battery_state = {
		["Full\n"]        = "↯",
		["Unknown\n"]     = "⌁",
		["Charged\n"]     = "↯",
		["Charging\n"]    = "+",
		["Discharging\n"] = "-"
	}

	local files = {
		"present", "status", "charge_now",
		"charge_full", "energy_now", "energy_full",
		"current_now", "power_now"
	}

	-- Read info
	--------------------------------------------------------------------------------
	for _, v in pairs(files) do
		battery[v] = redutil.read_ffile("/sys/class/power_supply/" .. batname .. "/" .. v)
	end

	-- Check if the battery is present
	------------------------------------------------------------
	if battery.present ~= "1\n" then
		return { battery_state["Unknown\n"], 0, "N/A" }
	end

	-- Get state information
	------------------------------------------------------------
	local state = battery_state[battery.status] or battery_state["Unknown\n"]

	-- Get capacity information
	if     battery.charge_now then remaining, capacity = battery.charge_now, battery.charge_full
	elseif battery.energy_now then remaining, capacity = battery.energy_now, battery.energy_full
	else                           return {battery_state["Unknown\n"], 0, "N/A"}
	end

	-- Calculate percentage (but work around broken BAT/ACPI implementations)
	------------------------------------------------------------
	local percent = math.min(math.floor(remaining / capacity * 100), 100)

	-- Get charge information
	------------------------------------------------------------
	local rate

	if     battery.current_now then rate = tonumber(battery.current_now)
	elseif battery.power_now   then rate = tonumber(battery.power_now)
	else                            return {state, percent, "N/A"}
	end

	-- Calculate remaining (charging or discharging) time
	------------------------------------------------------------
	if rate ~= nil and rate ~= 0 then
		local timeleft

		if     state == "+" then timeleft = (tonumber(capacity) - tonumber(remaining)) / tonumber(rate)
		elseif state == "-" then timeleft = tonumber(remaining) / tonumber(rate)
		else                     return {state, percent, time}
		end

		-- calculate time
		local hoursleft   = math.floor(timeleft)
		local minutesleft = math.floor((timeleft - hoursleft) * 60 )

		time = string.format("%02d:%02d", hoursleft, minutesleft)
	end

	--------------------------------------------------------------------------------
	return { state, percent, time }
end

-- Temperature measure
-----------------------------------------------------------------------------------------------------------------------

-- Using lm-sensors
------------------------------------------------------------
function system.thermal.sensors(args)
	local args = args or "'Physical id 0'"
	local output = awful.util.pread("sensors | grep " .. args)

	local temp = string.match(output, "%+(%d+%.%d)°[CF]")

	return temp and { tonumber(temp) } or { 0 }
end

-- Using hddtemp
------------------------------------------------------------
function system.thermal.hddtemp(args)
	local args = args or {}
	local port = args.port or "7634"
	local disk = args.disk or "/dev/sda"

	local output = awful.util.pread(
		"echo | curl --connect-timeout 1 -fsm 3 telnet://127.0.0.1:" .. port .. " | grep " .. disk
	)
	local temp = string.match(output, "|(%d+)|[CF]|")

	return temp and { tonumber(temp) } or { 0 }
end

-- Using nvidia-settings on sysmem with optimus (bumblebee)
------------------------------------------------------------
function system.thermal.nvoptimus()
	local temp = 0
	local nvidia_on = string.find(awful.util.pread("cat /proc/acpi/bbswitch"), "ON")

	if nvidia_on ~= nil then
		temp = string.match(awful.util.pread("optirun -b none nvidia-settings -c :8 -q gpucoretemp -t"), "[^\n]+")
	end

	return { tonumber(temp), off = nvidia_on == nil }
end

-- Get info from transmission-remote client
-- This function adapted special for asyncshell
-----------------------------------------------------------------------------------------------------------------------

-- Check if transmission client running
--------------------------------------------------------------------------------
local function is_transmission_running(args)
	local t_client = args or "transmission-gtk"
	return awful.util.pread("pidof -x " .. t_client) ~= ""
end

-- Function for torrents sorting (downloading and paused first)
--------------------------------------------------------------------------------
local function sort_torrent(a, b)
	return a.status == "Downloading" and b.status ~= "Downloading"
	       or a.status == "Stopped" and b.status ~= "Stopped" and b.status ~= "Downloading"
end

-- Function to parse 'transmission-remote -l' output
--------------------------------------------------------------------------------
function system.transmission_parse(output)

	-- Empty output for redflat desktop widget if torrent client is not running
	------------------------------------------------------------
	if not is_transmission_running() then
		return { corners = {}, lines = { { 0, 0 }, { 0, 0 } }, alert = true }
	end

	-- Initialize vars
	------------------------------------------------------------
	local torrent = {
		seed  = { num = 0, speed = 0 },
		dnld  = { num = 0, speed = 0 },
		list  = {},
	}

	-- Find state and progress for every torrent
	-- and total upload and downoad speed
	------------------------------------------------------------
	local status_pos = string.find(output, "Status")

	-- assuming "Up & Down" and "Downloading" is the same thing
	output = string.gsub(output,"Up & Down","Downloading")

	-- parse every line
	for line in string.gmatch(output, "[^\n]+") do
		if string.sub(line, 1, 3) == "Sum" then
			-- get total speed
			torrent.seed.speed, torrent.dnld.speed = string.match(line,
				"Sum:%s+[%d%.]+%s+%a+%s+([%d%.]+)%s+([%d%.]+)"
			)
		else
			-- get torrent info
			local prog, status = string.match(line,
				"%s+%d+%s+(%d+)%%%s+[%d%.]+%s%a+%s+.+%s+[%d%.]+%s+[%d%.]+%s+[%d%.]+%s+(%a+)"
			)

			if prog and status then
				table.insert(torrent.list, { prog = prog, status = status })

				if     status == "Seeding"     then torrent.seed.num = torrent.seed.num + 1
				elseif status == "Downloading" then torrent.dnld.num = torrent.dnld.num + 1
				end
			end
		end
	end

	-- Sort torrents
	------------------------------------------------------------
	table.sort(torrent.list, sort_torrent)

	-- Format output special for redflat desktop widget
	------------------------------------------------------------
	local sorted_prog = {}
	for _, t in ipairs(torrent.list) do table.insert(sorted_prog , t.prog) end

	return {
		corners = sorted_prog,
		lines = { { torrent.seed.speed, torrent.seed.num }, { torrent.dnld.speed, torrent.dnld.num } },
		alert = false
	}
end

-- Get processes list and cpu and memory usage for every process
-- !!! Fixes is needed !!!
-----------------------------------------------------------------------------------------------------------------------
local storage = {}

function system.proc_info(cpu_storage)
	local process = {}
	local new_st = {}
	local mem_page_size = 4

	-- get processes list with ps utility
	-- !!! TODO: get processes list from fs directly !!!
	local output = awful.util.pread("ps -eo pid | tail -n +2")

	-- get total cpu time diff from previous call
	local cpu_diff = system.cpu_usage(cpu_storage).diff

	-- handle every line in ps output
	for line in string.gmatch(output, "[^\n]+") do
		local pid = tonumber(line)

		-- try to get info from /proc
		local stat = redutil.read_ffile("/proc/" .. pid .. "/stat")

		-- if process with given pid exist in /proc
		if stat then

			-- parse 'stat' file
			local proc_stat = {}
			for m in string.gmatch(stat, "[%s]+([^%s]+)") do
				table.insert(proc_stat, m)
			end

			-- get process name
			local name = string.match(proc_stat[1], "%((.+)%)")

			-- get memory usage (RSS)
			-- !!! RSS is a very crude approximation for memory usage !!!
			-- !!! TODO: find a more accurate method for real memory usage calculation !!!
			local mem = proc_stat[23] * mem_page_size

			-- calculate cpu usage for process
			local proc_time = proc_stat[13] + proc_stat[14]
			local pcpu = (proc_time - (storage[pid] or 0)) / cpu_diff

			-- save current cpu time for future
			storage[pid] = proc_time

			-- save results
			table.insert(process, { pid = pid, name = name, mem = mem, pcpu = pcpu })
		end
	end

	return process
end

-- Output format functions
-----------------------------------------------------------------------------------------------------------------------

-- CPU and memory usage formatted special for desktop widget
--------------------------------------------------------------------------------
function system.dformatted.cpumem(storage)
	local mem   = system.memory_info()
	local cores = system.cpu_usage(storage).core

	return {
		corners = cores,
		lines = { { mem.usep, mem.inuse }, { mem.swp.usep, mem.swp.inuse } }
	}
end

-- CPU usage formatted special for panel widget
--------------------------------------------------------------------------------
function system.pformatted.cpu(crit)
	local crit = crit or 75
	local storage = { cpu_total = {}, cpu_active = {} }

	return function()
		local usage = system.cpu_usage(storage).total
		return {
			value = usage / 100,
			text  = usage .. "%",
			alert = usage > crit
		}
	end
end

-- Memory usage formatted special for panel widget
--------------------------------------------------------------------------------
function system.pformatted.mem(crit)
	local crit = crit or 75

	return function()
		local usage = system.memory_info().usep
		return {
			value = usage / 100,
			text  = usage .. "%",
			alert = usage > crit
		}
	end
end

-- Battery state formatted special for panel widget
--------------------------------------------------------------------------------
function system.pformatted.bat(crit)
	local crit = crit or 15

	return function(arg)
		local state = system.battery(arg)
		return {
			value = state[2] / 100,
			text  = state[1] .. "  " .. state[2] .. "%  " .. state[3],
			alert = state[2] < crit
		}
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return system
