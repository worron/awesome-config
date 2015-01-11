-----------------------------------------------------------------------------------------------------------------------
--                                               RedFlat time stamp                                                  --
-----------------------------------------------------------------------------------------------------------------------
-- Make time stamp on every awesome exit or restart
-- It still working if user config was broken and default rc loaded
-- Time stamp may be useful for making diffrence between awesome wm first run or restart
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local timestamp = {}

timestamp.path = "/tmp/awesome-stamp"

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")
local redutil = require("redflat.util")

-- Stamp functions
-----------------------------------------------------------------------------------------------------------------------

-- make time stamp
function timestamp.make()
	local file = io.open(timestamp.path, "w")
	file:write(os.time())
	file:close()
end

-- get time stamp
function timestamp.get()
	return redutil.read_ffile(timestamp.path)
end

-- Connect exit signal on module initialization
-----------------------------------------------------------------------------------------------------------------------
awesome.connect_signal("exit",
	function()
		timestamp.make()
		awful.util.spawn_with_shell(
			"sleep 2 && echo"
			.. " 'if timestamp == nil then timestamp = require(\"redflat.timestamp\") end'"
			.. " | awesome-client &"
		)
	end
)

-----------------------------------------------------------------------------------------------------------------------
return timestamp
