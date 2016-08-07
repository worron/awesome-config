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
	awful.util.spawn_with_shell("compton")
	awful.util.spawn_with_shell("pulseaudio")
	awful.util.spawn_with_shell("nm-applet")
	awful.util.spawn_with_shell("sleep 0.5 && bash ~/Documents/scripts/ff-sync.sh")
	awful.util.spawn_with_shell("xrdb -merge ~/.Xdefaults")

	-- gtk setting deamon
	awful.util.spawn_with_shell("unity-settings-daemon")

	-- keyboard layouts
	awful.util.spawn_with_shell("kbdd")
	awful.util.spawn_with_shell("sleep 1 && bash ~/Documents/scripts/kbdd-setup.sh")
	awful.util.spawn_with_shell("sleep 1.5 && bash ~/Documents/scripts/swap-ctrl-caps.sh")

	-- apps
	awful.util.spawn_with_shell("parcellite")
	awful.util.spawn_with_shell("sleep 0.5 && transmission-gtk -m")
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return autostart
