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
	-- utils
	awful.spawn.with_shell("compton")
	awful.spawn.with_shell("pulseaudio")
	awful.spawn.with_shell("nm-applet")
	awful.spawn.with_shell("sleep 0.5 && bash ~/Documents/scripts/ff-sync.sh")

	-- gnome setting deamon
	awful.spawn.with_shell("/usr/lib/gnome-settings-daemon/gsd-xsettings")

	-- keyboard layouts
	awful.spawn.with_shell("kbdd")
	awful.spawn.with_shell("sleep 1 && bash ~/Documents/scripts/kbdd-setup.sh")

	-- apps
	awful.spawn.with_shell("clipflap")
	awful.spawn.with_shell("sleep 0.5 && transmission-gtk -m")
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return autostart
