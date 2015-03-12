-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat keyboard actions util                                          --
-----------------------------------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")
local redutil = require("redflat.util")
local common = require("redflat.layout.common")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local keyboard = { handler = {}, handler_list = {} }

keyboard.ignored = { "dock", "splash", "desktop"}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
function get_handler(lay)
	return lay.key_handler or common.keyboard.key_handler[lay]
end

-- Start key handler
-----------------------------------------------------------------------------------------------------------------------
function keyboard.handler(c)
	local c = c or client.focus

	if not c or c.fullscreen or awful.util.table.hasitem(keyboard.ignored, c.type) then
		return
	end

	local lay = awful.layout.get(c.screen)
	local handler = get_handler(lay)

	if handler then
		return handler(c)
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return keyboard
