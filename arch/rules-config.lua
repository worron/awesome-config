-----------------------------------------------------------------------------------------------------------------------
--                                                Rules config                                                       --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful =require("awful")
local beautiful = require("beautiful")
local redtitle = require("redflat.titlebar")

-- Initialize tables and vars for the module
-----------------------------------------------------------------------------------------------------------------------
local rules = {}

rules.base_properties = {
	border_width     = beautiful.border_width,
	border_color     = beautiful.border_normal,
	focus            = awful.client.focus.filter,
	raise            = true,
	size_hints_honor = false,
	screen           = awful.screen.preferred,
}

rules.floating_any = {
	class = {
		"Clipflap", "Run.py",
	},
	role = { "AlarmWindow", "pop-up", },
	type = { "dialog" }
}

rules.titlebar_exceptions = {
	class = { "Cavalcade", "Clipflap", "Steam", "Qemu-system-x86_64" }
}

rules.maximized = {
	-- class = { "TelegramDesktop" }
}

rules.minimized = {
	class = { "TelegramDesktop" }
}

-- Build rule table
-----------------------------------------------------------------------------------------------------------------------
function rules:init(args)

	args = args or {}
	self.base_properties.keys = args.hotkeys.keys.client
	self.base_properties.buttons = args.hotkeys.mouse.client
	self.env = args.env or {}


	-- Build rules
	--------------------------------------------------------------------------------
	self.rules = {
		{
			rule       = {},
			properties = args.base_properties or self.base_properties
		},
		{
			rule_any   = args.floating_any or self.floating_any,
			properties = { floating = true }
		},
		{
			rule_any = self.maximized,
			callback = function(c)
				c.maximized = true
				redtitle.cut_all({ c })
				c.height = c.screen.workarea.height - 2 * c.border_width
			end
		},
		{
			rule_any   = { type = { "normal", "dialog" }},
			except_any = self.titlebar_exceptions,
			properties = { titlebars_enabled = true }
		},
		{
			rule_any   = { type = { "normal" }},
			properties = { placement = awful.placement.no_overlap + awful.placement.no_offscreen }
		},

		-- Tags placement
		{
			rule_any = { class = { "TelegramDesktop" } },
			properties = { tag = "Free", minimized = true }
		},

		-- Jetbrains splash screen fix
		{
			rule_any = { class = { "jetbrains-%w+", "java-lang-Thread" } },
			callback = function(jetbrains)
				if jetbrains.skip_taskbar then jetbrains.floating = true end
			end
		}
	}


	-- Set rules
	--------------------------------------------------------------------------------
	awful.rules.rules = rules.rules
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return rules