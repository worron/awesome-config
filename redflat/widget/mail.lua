-----------------------------------------------------------------------------------------------------------------------
--                                               RedFlat mail widget                                                 --
-----------------------------------------------------------------------------------------------------------------------
-- Check if new mail available using python scripts
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table = table
local tonumber = tonumber

local beautiful = require("beautiful")

local rednotify = require("redflat.float.notify")
local tooltip = require("redflat.float.tooltip")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")
local asyncshell = require("redflat.asyncshell")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local mail = { objects = {}, mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon        = nil,
		notify_icon = nil,
		need_notify = true,
		firstrun    = false,
		color       = { main = "#b1222b", icon = "#a0a0a0" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "widget.mail") or {})
end

-- Create a new mail widget
-- @param style Table containing colors and geometry parameters for all elemets
-- @param args.update_timeout Update interval
-- @param args.path Folder with mail scripts
-- @param args.scripts Table with scripts name
-----------------------------------------------------------------------------------------------------------------------
function mail.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local args = args or {}
	local count
	local object = {}
	local update_timeout = args.update_timeout or 3600
	local scripts = args.scripts or {}
	local path = args.path or "~/.config/awesome/scripts/"

	local style = redutil.table.merge(default_style(), style or {})

	-- Create widget
	--------------------------------------------------------------------------------
	object.widget = svgbox(style.icon)
	object.widget:set_color(style.color.icon)
	table.insert(mail.objects, object)

	-- Set tooltip
	--------------------------------------------------------------------------------
	object.tp = tooltip({ object.widget }, style.tooltip)

	-- Update info function
	--------------------------------------------------------------------------------
	local function mail_count(output)
		local c = tonumber(output)
		if not c then return end

		count = count + c
		object.tp:set_text(count .. " new messages")

		local color = count > 0 and style.color.main or style.color.icon
		object.widget:set_color(color)

		if style.need_notify and count > 0 then
			rednotify:show({ text = count .. " new messages", icon = style.notify_icon })
		end
	end

	function object.update()
		count = 0
		for _, script in ipairs(scripts) do
			asyncshell.request(path .. script, mail_count, 60)
		end
	end

	-- Set update timer
	--------------------------------------------------------------------------------
	local t = timer({ timeout = update_timeout })
	t:connect_signal("timeout", object.update)
	t:start()

	if style.firstrun then t:emit_signal("timeout") end

	--------------------------------------------------------------------------------
	return object.widget
end

-- Update mail info for every widget
-----------------------------------------------------------------------------------------------------------------------
function mail:update()
	for _, o in ipairs(mail.objects) do o.update() end
end

-- Config metatable to call mail module as function
-----------------------------------------------------------------------------------------------------------------------
function mail.mt:__call(...)
	return mail.new(...)
end

return setmetatable(mail, mail.mt)
