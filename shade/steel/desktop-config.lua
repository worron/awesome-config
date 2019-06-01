-----------------------------------------------------------------------------------------------------------------------
--                                               Desktop widgets config                                              --
-----------------------------------------------------------------------------------------------------------------------

-- No desktop ready for steel
-- Some temporary mock up here

-- Grab environment
local beautiful = require("beautiful")
local wibox = require("wibox")
local timer = require("gears.timer")

local redflat = require("redflat")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local desktop = {}

-- desktop aliases
local system = redflat.system
local wa = mouse.screen.workarea

-- Desktop widgets
-----------------------------------------------------------------------------------------------------------------------
function desktop:init(args)
	if not beautiful.desktop then return end

	-- init vars
	args = args or {}
	local env = args.env or {}
	local autohide = env.desktop_autohide or false
	local font = "Furore 20"

	-- system info level settings
	local fs_levels = {
		{ color = beautiful.desktop.color.gray, text = "empty", value = -1 },
		{ color = beautiful.desktop.color.gray, text = "almost empty", value = 1 },
		{ color = beautiful.desktop.color.icon, text = "slightly filled", value = 25 },
		{ color = beautiful.desktop.color.main, text = "half filled", value = 50 },
		{ color = beautiful.desktop.color.urgent, text = "almost full", value = 75 },
	}

	local mem_levels = {
		{ color = beautiful.desktop.color.gray, text = "empty", value = -1 },
		{ color = beautiful.desktop.color.gray, text = "almost empty", value = 1 },
		{ color = beautiful.desktop.color.icon, text = "slightly flooded", value = 25 },
		{ color = beautiful.desktop.color.main, text = "half flooded", value = 50 },
		{ color = beautiful.desktop.color.urgent, text = "almost full", value = 75 },
	}

	local cpu_levels = {
		{ color = beautiful.desktop.color.gray, text = "on standby", value = -1 },
		{ color = beautiful.desktop.color.gray, text = "slightly loaded", value = 1 },
		{ color = beautiful.desktop.color.icon, text = "average loaded", value = 25 },
		{ color = beautiful.desktop.color.main, text = "decent loaded", value = 50 },
		{ color = beautiful.desktop.color.urgent, text = "heavy loaded", value = 75 },
	}

	-- suppot functions
	local function get_level(levels, value)
		local color, text
		for _, level in ipairs(levels) do
			if value > level.value then
				color, text = level.color, level.text
			end
		end

		return color, text
	end

	local function base_box(label, height)
		local box =  wibox.widget({
			text          = label,
			font          = font,
			valign        = "top",
			forced_height = height,
			widget        = wibox.widget.textbox,
		})

		box._label = label
		return box
	end

	local function storage_check(label, fs)
		local box = wibox.widget({
			text   = label,
			font   = font,
			widget = wibox.widget.textbox,
		})

		-- awesome v4.3 timer API used
		box._label = label
		box._timer = timer({
			timeout   = 60 * 10,
			call_now  = true,
			autostart = true,
			callback  = function()
				local data = system.fs_info(fs)
				local color, text = get_level(fs_levels, data[1])
				box:set_markup(string.format(
					'<span color="%s">%s</span> <span color="%s">%s</span>',
					beautiful.color.icon, box._label, color, text
				))
			end
		})

		return box
	end

	-- init widgets
	local boxes = { storage = {}, memory = {} }
	local main = { body = {} }

	boxes.cpu = base_box("Main processor unit")
	boxes.memory.ram = base_box("Base memory pool")
	boxes.memory.swap = base_box("Reserve memory pool", 60)

	boxes.storage.root = storage_check("system storage", "/")
	boxes.storage.home = storage_check("user storage", "/home")
	boxes.storage.misk = storage_check("application storage", "/mnt/storage")
	boxes.storage.media = storage_check("content storage", "/mnt/media")

	-- construct layout
	main.body.area = wibox.widget({
		boxes.cpu,
		boxes.memory.ram,
		boxes.memory.swap,

		boxes.storage.root,
		boxes.storage.home,
		boxes.storage.misk,
		boxes.storage.media,

		spacing = 20,
		layout  = wibox.layout.fixed.vertical
	})
	main.body.style = beautiful.desktop

	-- manul setup for some update timers
	 boxes.memory.timer = timer({
		timeout   = 15,
		call_now  = true,
		autostart = true,
		callback  = function()
			local data = system.memory_info()

			local ram_color, ram_text = get_level(mem_levels, data.usep)
			boxes.memory.ram:set_markup(string.format(
				'<span color="%s">%s</span> <span color="%s">%s</span>',
				beautiful.color.icon, boxes.memory.ram._label, ram_color, ram_text
			))

			local swap_color, swap_text = get_level(mem_levels, data.swp.usep)
			boxes.memory.swap:set_markup(string.format(
				'<span color="%s">%s</span> <span color="%s">%s</span>',
				beautiful.color.icon, boxes.memory.swap._label, swap_color, swap_text
			))
		end
	})

	local cpu_storage = { cpu_total = {}, cpu_active = {} }
	boxes.cpu.timer = timer({
		timeout   = 5,
		call_now  = true,
		autostart = true,
		callback  = function()
			local data = system.cpu_usage(cpu_storage)

			local color, text = get_level(cpu_levels, data.total)
			boxes.cpu:set_markup(string.format(
				'<span color="%s">%s</span> <span color="%s">%s</span>',
				beautiful.color.icon, boxes.cpu._label, color, text
			))
		end
	})

	-- calculate geometry
	local wibox_height = 360
	local wibox_x = 1080
	main.geometry = {
		x = wibox_x, y = wa.y + (wa.height - wibox_height) / 2,
		width = wa.width - wibox_x, height = wibox_height
	}

	-- Desktop setup
	--------------------------------------------------------------------------------
	local desktop_objects = { main }

	if not autohide then
		redflat.util.desktop.build.static(desktop_objects, args.buttons)
	else
		redflat.util.desktop.build.dynamic(desktop_objects, nil, beautiful.desktopbg, args.buttons)
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return desktop
