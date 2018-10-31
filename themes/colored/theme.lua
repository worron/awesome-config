-----------------------------------------------------------------------------------------------------------------------
--                                     Shared settings for colored themes                                            --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- This theme inherited from colorless with overwriting some values
local theme = require("themes/colorless/theme")


-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/colored"

-- Main config
------------------------------------------------------------

theme.panel_height        = 36 -- panel height
theme.border_width        = 4  -- window border width
theme.useless_gap         = 4  -- useless gap

theme.cellnum = { x = 96, y = 58 } -- grid layout property

-- Fonts
------------------------------------------------------------
theme.fonts = {
	main     = "Roboto 13",      -- main font
	menu     = "Roboto 13",      -- main menu font
	tooltip  = "Roboto 13",      -- tooltip font
	notify   = "Play bold 14",   -- redflat notify popup font
	clock    = "Play bold 12",   -- textclock widget font
	qlaunch  = "Play bold 14",   -- quick launch key label font
	keychain = "Play bold 16",   -- key sequence tip font
	title    = "Roboto bold 13", -- widget titles font
	titlebar = "Roboto bold 13", -- client titlebar font
	hotkeys  = {
		main  = "Roboto 14",             -- hotkeys helper main font
		key   = "Iosevka Term Light 14", -- hotkeys helper key font (use monospace for align)
		title = "Roboto bold 16",        -- hotkeys helper group title font
	},
	player   = {
		main = "Play bold 13", -- player widget main font
		time = "Play bold 15", -- player widget current time font
	},
}

theme.cairo_fonts = {
	tag         = { font = "Play", size = 16, face = 1 }, -- tag widget font
	appswitcher = { font = "Play", size = 20, face = 1 }, -- appswitcher widget font
	navigator   = {
		title = { font = "Play", size = 28, face = 1, slant = 0 }, -- window navigation title font
		main  = { font = "Play", size = 22, face = 1, slant = 0 }  -- window navigation  main font
	},
}

-- Widget icons
--------------------------------------------------------------------------------
theme.wicon = {
	battery    = theme.path .. "/widget/battery.svg",
	wireless   = theme.path .. "/widget/wireless.svg",
	monitor    = theme.path .. "/widget/monitor.svg",
	audio      = theme.path .. "/widget/audio.svg",
	headphones = theme.path .. "/widget/headphones.svg",
	brightness = theme.path .. "/widget/brightness.svg",
	keyboard   = theme.path .. "/widget/keyboard.svg",
	mail       = theme.path .. "/widget/mail.svg",
	upgrades   = theme.path .. "/widget/upgrades.svg",
	search     = theme.path .. "/widget/search.svg",
}

-- Main theme settings
-- Make it updatabele since it may depends on common and ancestor theme settings
-----------------------------------------------------------------------------------------------------------------------

-- overwrite ancestor update settings with current theme values
function theme:update()

	-- setup ancestor settings
	self:init()

	-- Set hotkey helper size according current fonts
	--------------------------------------------------------------------------------
	self.service.navigator.keytip["fairv"] = { geometry = { width = 600, height = 440 }, exit = true }
	self.service.navigator.keytip["fairh"] = self.service.navigator.keytip["fairv"]

	self.service.navigator.keytip["tile"]       = { geometry = { width = 600, height = 660 }, exit = true }
	self.service.navigator.keytip["tileleft"]   = self.service.navigator.keytip["tile"]
	self.service.navigator.keytip["tiletop"]    = self.service.navigator.keytip["tile"]
	self.service.navigator.keytip["tilebottom"] = self.service.navigator.keytip["tile"]

	self.service.navigator.keytip["grid"]    = { geometry = { width = 1400, height = 520 }, column = 2, exit = true }
	self.service.navigator.keytip["usermap"] = { geometry = { width = 1400, height = 580 }, column = 2, exit = true }

	-- Desktop file parser
	--------------------------------------------------------------------------------
	self.service.dfparser.icons.theme         = self.homedir .. "/.icons/ACYLS"
	self.service.dfparser.icons.custom_only   = true
	self.service.dfparser.icons.scalable_only = true

	-- Menu config
	--------------------------------------------------------------------------------
	self.menu.icon_margin  = { 4, 7, 7, 8 }
	self.menu.keytip       = { geometry = { width = 400, height = 380 } }


	-- Panel widgets
	--------------------------------------------------------------------------------

	-- Pulseaudio volume control
	------------------------------------------------------------
	self.widget.pulse.audio  = { icon = self.wicon.headphones }
	self.widget.pulse.notify = { icon = self.wicon.audio }

	-- Keyboard layout indicator
	------------------------------------------------------------
	self.widget.keyboard.icon = self.wicon.keyboard

	-- Mail indicator
	------------------------------------------------------------
	self.widget.mail.icon = self.wicon.mail

	-- System updates indicator
	------------------------------------------------------------
	self.widget.upgrades.notify = { icon = self.wicon.upgrades }

	-- Layoutbox
	------------------------------------------------------------
	self.widget.layoutbox.menu.icon_margin  = { 8, 12, 9, 9 }
	self.widget.layoutbox.menu.width = 200

	-- Tasklist
	------------------------------------------------------------
	self.widget.tasklist.winmenu.hide_action = { min = false, move = false }
	self.widget.tasklist.tasktip.margin = { 8, 8, 4, 4 }
	self.widget.tasklist.winmenu.tagmenu.width = 150

	-- Floating widgets
	--------------------------------------------------------------------------------

	-- Top processes
	------------------------------------------------------------
	self.float.top.set_position  = function()
		return { x = mouse.screen.workarea.x + mouse.screen.workarea.width,
		         y = mouse.screen.workarea.y + mouse.screen.workarea.height }
	end

	-- Application runner
	------------------------------------------------------------
	self.float.apprunner.title_icon = self.wicon.search
	self.float.apprunner.keytip = { geometry = { width = 400, height = 250 } }

	-- Application switcher
	------------------------------------------------------------
	self.float.appswitcher.keytip = { geometry = { width = 400, height = 360 }, exit = true }

	-- Quick launcher
	------------------------------------------------------------
	self.float.qlaunch.keytip = { geometry = { width = 600, height = 320 } }

	-- Hotkeys helper
	------------------------------------------------------------
	self.float.hotkeys.geometry = { width = 1800, height = 1000 }

	-- Key sequence tip
	------------------------------------------------------------
	self.float.keychain.border_width = 0
	self.float.keychain.keytip = { geometry = { width = 1200, height = 580 }, column = 2 }

	-- Brightness control
	------------------------------------------------------------
	self.float.brightness.notify = { icon = self.wicon.brightness }

	-- Default awesome theme vars
	--------------------------------------------------------------------------------
	self.enable_spawn_cursor = false
end

-- End
-----------------------------------------------------------------------------------------------------------------------
theme:update()

return theme
