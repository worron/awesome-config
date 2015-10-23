-----------------------------------------------------------------------------------------------------------------------
--                                              Window titlebar config                                               --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local redflat = require("redflat")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local titlebar = {}

-- Support functions
--------------------------------------------------------------------------------
local function titlebar_action(c, action)
	return function()
		client.focus = c
		c:raise()
		action(c)
	end
end

local function on_maximize(c)
	if c.maximized_vertical then
		redflat.titlebar.hide(c)
	else
		redflat.titlebar.show(c)
	end
end

-- Build titlebar object
-----------------------------------------------------------------------------------------------------------------------
function titlebar:init(args)

	local args = args or {}
	self.enabled = args.enable or false
	self.exceptions = args.exceptions or {}

	-- Function to check if titlebar needed for given window
	--------------------------------------------------------------------------------
	self.allowed = function(c)
		return self.enabled and (c.type == "normal")
		       and not awful.util.table.hasitem(self.exceptions, c.class)
	end

	-- Function to construct titlebar
	--------------------------------------------------------------------------------
	self.create = function(c)

		-- Create titlebar
		------------------------------------------------------------
		local full_style =  { size = 28, icon = { gap = 0, size = 25, angle = 0.50 } }
		local model = redflat.titlebar.model(c, { "floating", "sticky", "ontop" }, nil, full_style)
		redflat.titlebar(c, model):set_widget(model.widget)

		-- Mouse actions setup
		------------------------------------------------------------
		model.widget:buttons(awful.util.table.join(
			awful.button({}, 1, titlebar_action(c, redflat.service.mouse.move)),
			awful.button({}, 3, titlebar_action(c, redflat.service.mouse.resize))
		))

		-- Hide titlebar when window maximized
		------------------------------------------------------------
		if c.maximized_vertical then redflat.titlebar.hide(c) end
		c:connect_signal("property::maximized_vertical", on_maximize)
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return titlebar
