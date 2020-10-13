-----------------------------------------------------------------------------------------------------------------------
--                                              Autostart app list                                                   --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local autostart = {}

-- Application list function
--------------------------------------------------------------------------------
function autostart.run()
	-- environment
	awful.spawn.with_shell("python ~/scripts/env/pa-setup.py")
	awful.spawn.with_shell("python ~/scripts/env/color-profile-setup.py")
	awful.spawn.with_shell("python ~/scripts/env/kbd-setup.py")

	-- gnome environment
	awful.spawn.with_shell("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

	-- firefox sync
	awful.spawn.with_shell("python ~/scripts/firefox/ff-sync.py")

	-- utils
	awful.spawn.with_shell("compton")
	awful.spawn.with_shell("nm-applet")

	-- apps
	awful.spawn.with_shell("gpaste-client start")
	awful.spawn.with_shell("transmission-gtk -m")
	awful.spawn.with_shell("pragha --toggle_view")
end

-- Read and commands from file and spawn them
--------------------------------------------------------------------------------
function autostart.run_from_file(file_)
	local f = io.open(file_)
	for line in f:lines() do
		if line:sub(1, 1) ~= "#" then awful.spawn.with_shell(line) end
	end
	f:close()
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return autostart
