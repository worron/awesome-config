-----------------------------------------------------------------------------------------------------------------------
--                                     Shared settings for colored themes                                            --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- This theme was inherited from another with overwriting some values
-- Check parent theme to find full settings list and its description
local theme = require("themes/colorless/theme")


-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/colored"

-- Main config
------------------------------------------------------------
theme.panel_height        = 36 -- panel height
theme.border_width        = 4  -- window border width
theme.useless_gap         = 4  -- useless gap

-- Fonts
------------------------------------------------------------
theme.fonts = {
	main     = "Roboto 13",      -- main font
	menu     = "Roboto 13",      -- main menu font
	tooltip  = "Roboto 13",      -- tooltip font
	notify   = "Play bold 14",   -- redflat notify popup font
	clock    = "Play bold 12",   -- textclock widget font
	qlaunch  = "Play bold 14",   -- quick launch key label font
	logout   = "Play bold 14",   -- logout screen labels
	keychain = "Play bold 16",   -- key sequence tip font
	title    = "Roboto bold 13", -- widget titles font
	tiny     = "Roboto bold 10", -- smallest font for widgets
	titlebar = "Roboto bold 13", -- client titlebar font
	logout   = {
		label   = "Play bold 14", -- logout option labels
		counter = "Play bold 24", -- logout counter
	},
	hotkeys  = {
		main  = "Roboto 14",             -- hotkeys helper main font
		key   = "Iosevka Term Light 14", -- hotkeys helper key font (use monospace for align)
		title = "Roboto bold 16",        -- hotkeys helper group title font
	},
	player   = {
		main = "Play bold 13", -- player widget main font
		time = "Play bold 15", -- player widget current time font
	},
	-- very custom calendar fonts
	calendar = {
		clock = "Play bold 28", date = "Play 16", week_numbers = "Play 12", weekdays_header = "Play 12",
		days  = "Play 14", default = "Play 14", focus = "Play 12 Bold", controls = "Play bold 16"
	},
}

theme.cairo_fonts = {
	tag         = { font = "Play", size = 16, face = 1 }, -- tag widget font
	appswitcher = { font = "Play", size = 20, face = 1 }, -- appswitcher widget font
	navigator   = {
		title = { font = "Play", size = 28, face = 1, slant = 0 }, -- window navigation title font
		main  = { font = "Play", size = 22, face = 1, slant = 0 }  -- window navigation  main font
	},

	desktop = {
		textbox = { font = "prototype", size = 24, face = 0 },
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
	package    = theme.path .. "/widget/package.svg",
	search     = theme.path .. "/widget/search.svg",
	mute       = theme.path .. "/widget/mute.svg",
	up         = theme.path .. "/widget/up.svg",
	down       = theme.path .. "/widget/down.svg",
	onscreen   = theme.path .. "/widget/onscreen.svg",
	resize     = {
		full       = theme.path .. "/widget/resize/full.svg",
		horizontal = theme.path .. "/widget/resize/horizontal.svg",
		vertical   = theme.path .. "/widget/resize/vertical.svg",
	},
	updates    = {
		normal = theme.path .. "/widget/updates/normal.svg",
		silent = theme.path .. "/widget/updates/silent.svg",
		weekly = theme.path .. "/widget/updates/weekly.svg",
		daily = theme.path .. "/widget/updates/daily.svg", },
	logout = {
		logout = theme.path .. "/widget/logout/logout.svg",
		lock = theme.path .. "/widget/logout/lock.svg",
		poweroff = theme.path .. "/widget/logout/poweroff.svg",
		suspend = theme.path .. "/widget/logout/suspend.svg",
		reboot = theme.path .. "/widget/logout/reboot.svg",
		switch = theme.path .. "/widget/logout/switch.svg",
	},
}


-- Main theme settings
-- Make it updatabele since it may depends on common and ancestor theme settings
-----------------------------------------------------------------------------------------------------------------------

-- overwrite ancestor update settings with current theme values
function theme:update()

	-- setup parent theme settings
	self:init()

	-- Set hotkey helper size according current fonts and keys scheme
	--------------------------------------------------------------------------------
	self.service.navigator.keytip["fairv"] = { geometry = { width = 600 }, exit = true }
	self.service.navigator.keytip["fairh"] = self.service.navigator.keytip["fairv"]

	self.service.navigator.keytip["tile"]       = { geometry = { width = 600 }, exit = true }
	self.service.navigator.keytip["tileleft"]   = self.service.navigator.keytip["tile"]
	self.service.navigator.keytip["tiletop"]    = self.service.navigator.keytip["tile"]
	self.service.navigator.keytip["tilebottom"] = self.service.navigator.keytip["tile"]

	self.service.navigator.keytip["grid"]    = { geometry = { width = 1400 }, column = 2, exit = true }
	self.service.navigator.keytip["usermap"] = { geometry = { width = 1400 }, column = 2, exit = true }

	-- Desktop file parser
	--------------------------------------------------------------------------------
	self.service.dfparser.icons.theme         = self.homedir .. "/.icons/ACYLS"
	self.service.dfparser.icons.custom_only   = true
	self.service.dfparser.icons.scalable_only = true

	-- Log out screen
	--------------------------------------------------------------------------------
	self.service.logout.icons.logout = self.wicon.logout.logout
	self.service.logout.icons.lock = self.wicon.logout.lock
	self.service.logout.icons.poweroff = self.wicon.logout.poweroff
	self.service.logout.icons.suspend = self.wicon.logout.suspend
	self.service.logout.icons.reboot = self.wicon.logout.reboot
	self.service.logout.icons.switch = self.wicon.logout.switch

	-- Menu config
	--------------------------------------------------------------------------------
	self.menu.icon_margin  = { 4, 7, 7, 8 }
	self.menu.keytip       = { geometry = { width = 400 } }

	-- Panel widgets
	--------------------------------------------------------------------------------

	-- Double icon indicator
	------------------------------------------------------------
	self.gauge.icon.double.icon1 = self.wicon.down
	self.gauge.icon.double.icon2 = self.wicon.up
	self.gauge.icon.double.igap  = -6

	-- Volume control
	------------------------------------------------------------
	self.gauge.audio.red.icon = { volume = self.wicon.audio, mute = self.wicon.mute }
	self.gauge.audio.blue.icon = self.wicon.headphones

	-- Pulseaudio volume control
	------------------------------------------------------------
	self.widget.pulse.notify = { icon = self.wicon.audio }

	-- Keyboard layout indicator
	------------------------------------------------------------
	self.widget.keyboard.icon = self.wicon.keyboard

	-- Mail indicator
	------------------------------------------------------------
	self.widget.mail.icon = self.wicon.mail
	self.widget.mail.notify = { icon = self.wicon.mail }

	-- System updates indicator
	------------------------------------------------------------
	self.widget.updates.notify = { icon = self.wicon.package }
	self.widget.updates.wibox.icon.package = self.wicon.package
	self.widget.updates.wibox.icon.normal = self.wicon.updates.normal
	self.widget.updates.wibox.icon.silent = self.wicon.updates.silent
	self.widget.updates.wibox.icon.weekly = self.wicon.updates.weekly
	self.widget.updates.wibox.icon.daily = self.wicon.updates.daily

	-- Layoutbox
	------------------------------------------------------------
	self.widget.layoutbox.menu.icon_margin  = { 8, 12, 9, 9 }
	self.widget.layoutbox.menu.width = 200

	-- Tasklist
	------------------------------------------------------------
	self.widget.tasklist.winmenu.hide_action = { min = false, move = false }
	self.widget.tasklist.tasktip.margin = { 8, 8, 4, 4 }
	self.widget.tasklist.winmenu.tagmenu.width = 150
	self.widget.tasklist.winmenu.enable_tagline = true
	self.widget.tasklist.winmenu.tagline = { height = 30 }
	self.widget.tasklist.winmenu.tag_iconsize = { width = 16, height = 16 }

	-- Floating widgets
	--------------------------------------------------------------------------------

	-- Client menu
	------------------------------------------------------------
	self.float.clientmenu.enable_tagline = true
	self.float.clientmenu.hide_action = { min = false, move = false }

	-- Top processes
	------------------------------------------------------------
	self.float.top.set_position  = function(wibox)
		local geometry = { x = mouse.screen.workarea.x + mouse.screen.workarea.width,
		                   y = mouse.screen.workarea.y + mouse.screen.workarea.height }
		wibox:geometry(geometry)
	end

	-- Application runner
	------------------------------------------------------------
	self.float.apprunner.title_icon = self.wicon.search
	self.float.apprunner.keytip = { geometry = { width = 400 } }

	-- Application switcher
	------------------------------------------------------------
	self.float.appswitcher.keytip = { geometry = { width = 400 }, exit = true }

	-- Quick launcher
	------------------------------------------------------------
	self.float.qlaunch.keytip = { geometry = { width = 600 } }

	-- Hotkeys helper
	------------------------------------------------------------
	self.float.hotkeys.geometry = { width = 1800 }
	self.float.hotkeys.heights = { key = 26, title = 32 }

	-- Key sequence tip
	------------------------------------------------------------
	self.float.keychain.border_width = 0
	self.float.keychain.keytip = { geometry = { width = 1200 }, column = 2 }

	-- Brightness control
	------------------------------------------------------------
	self.float.brightness.notify = { icon = self.wicon.brightness }

	-- Floating calendar
	------------------------------------------------------------
	self.float.calendar.geometry = { width = 364, height = 460 }
	self.float.calendar.border_width = 0
	self.float.calendar.show_week_numbers = false
	self.float.calendar.calendar_item_margin = { 4, 8, 2, 2 }
	self.float.calendar.spacing = { separator = 26, datetime = 5, controls = 5, calendar = 12 }
	self.float.calendar.separator = { marginh = { 0, 0, 12, 12 } }

	-- dirty colors correction
	self.float.calendar.color = {
		border    = self.color.border,
		wibox     = self.color.wibox,
		icon      = self.color.icon,
		main      = "transparent",
		highlight = self.color.main,
		gray      = self.color.gray,
		text      = self.color.text,
	}

	-- Floating window control helper
	------------------------------------------------------------
	self.float.control.icon = {
		onscreen = self.wicon.onscreen,
		resize = {
			self.wicon.resize.full,
			self.wicon.resize.horizontal,
			self.wicon.resize.vertical,
		},
	}

	-- Default awesome theme vars
	--------------------------------------------------------------------------------
	self.enable_spawn_cursor = false
end

-- End
-----------------------------------------------------------------------------------------------------------------------
theme:update()

return theme
