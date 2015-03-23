-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat keyboard actions util                                          --
-----------------------------------------------------------------------------------------------------------------------
-- Move and resize windows by keyboard
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local common = require("redflat.layout.common")
local navigator = require("redflat.service.navigator")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local keyboard = { handler = {}, notify = {} }

keyboard.ignored = { "dock", "splash", "desktop"}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
function get_handler(lay)
	return lay.key_handler or common.keyboard.key_handler[lay]
end

-- Start key handler
-----------------------------------------------------------------------------------------------------------------------
function keyboard.handler()
	local c = client.focus

	if not c or c.fullscreen or awful.util.table.hasitem(keyboard.ignored, c.type) then
		return
	end

	local lay = awful.layout.get(c.screen)
	local handler = get_handler(lay)

	if handler then
		navigator:run(true)
		return handler(c, function() navigator:close(true) end)
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return keyboard
