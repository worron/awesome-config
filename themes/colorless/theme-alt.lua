-----------------------------------------------------------------------------------------------------------------------
--                                                Colorless theme                                                    --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

local theme = {}
--local wa = mouse.screen.workarea

-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color = {
	main      = "#02606D",
	gray      = "#575757",
	bg        = "#161616",
	bg_second = "#181818",
	wibox     = "#202020",
	icon      = "#a0a0a0",
	text      = "#aaaaaa",
	urgent    = "#B25500",
	highlight = "#e0e0e0",

	border    = "#404040",
	shadow1   = "#141414",
	shadow2   = "#313131",
	shadow3   = "#1c1c1c",
	shadow4   = "#767676"
}

-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/colorless"
theme.homedir = os.getenv("HOME")

-- Main config
------------------------------------------------------------

theme.panel_height        = 36 -- panel height
theme.border_width        = 4  -- window border width
theme.useless_gap         = 4  -- useless gap

theme.wallpaper = theme.path .. "/wallpaper/primary.png" -- wallpaper file

-- Fonts
------------------------------------------------------------
theme.fonts = {
	main     = "sans 12",      -- main font
	menu     = "sans 12",      -- main menu font
	tooltip  = "sans 12",      -- tooltip font
	notify   = "sans bold 14", -- redflat notify popup font
	clock    = "sans bold 12", -- textclock widget font
	qlaunch  = "sans bold 14", -- quick launch key label font
	title    = "sans bold 12", -- widget titles font
	keychain = "sans bold 14", -- key sequence tip font
	titlebar = "sans bold 12", -- client titlebar font
	hotkeys = {
		main  = "sans 12",      -- hotkeys helper main font
		key   = "mono 12",      -- hotkeys helper key font (use monospace for align)
		title = "sans bold 14", -- hotkeys helper group title font
	},
}

theme.cairo_fonts = {
	tag         = { font = "Sans", size = 16, face = 1 }, -- tag widget font
	appswitcher = { font = "Sans", size = 22, face = 1 }, -- appswitcher widget font
	navigator   = {
		title = { font = "Sans", size = 28, face = 1, slant = 0 }, -- window navigation title font
		main  = { font = "Sans", size = 22, face = 1, slant = 0 }  -- window navigation  main font
	},
}

-- Shared icons
--------------------------------------------------------------------------------
theme.icon = {
	check    = theme.path .. "/common/check.svg",
	blank    = theme.path .. "/common/blank.svg",
	warning  = theme.path .. "/common/warning.svg",
	awesome  = theme.path .. "/common/awesome.svg",
	system   = theme.path .. "/common/system.svg",
}


-- Main theme settings
-- Make it updatabele since it may depends on common
-----------------------------------------------------------------------------------------------------------------------
function theme:update()

	-- Service utils config
	----------------------------------------------------------------------------------
	self.service = {}

	-- Window control mode appearance
	--------------------------------------------------------------------------------
	self.service.navigator = {
		border_width = 0,  -- window placeholder border width
		gradstep     = 60, -- window placeholder background stripes width
		marksize = {       -- window information plate size
			width  = 160, -- width
			height = 80,  -- height
			r      = 20   -- corner roundness
		},
		linegap   = 32, -- gap between two lines on window information plate
		timeout   = 1,  -- highlight duration
		notify    = {}, -- redflat notify style (see theme.float.notify)
		titlefont = self.cairo_fonts.navigator.title, -- first line font on window information plate
		font      = self.cairo_fonts.navigator.main,  -- second line font on window information plate

		-- array of hot key marks for window placeholders
		num = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "F1", "F3", "F4", "F5" },

		-- colors
		color = {
			border = self.color.main,         -- window placeholder border color
			mark = self.color.gray,           -- window information plate background color
			text = self.color.wibox,          -- window information plate text color
			fbg1 = self.color.main .. "40",   -- first background color for focused window placeholder
			fbg2 = self.color.main .. "20",   -- second background color for focused window placeholder
			hbg1 = self.color.urgent .. "40", -- first background color for highlighted window placeholder
			hbg2 = self.color.urgent .. "20", -- second background color for highlighted window placeholder
			bg1  = self.color.gray .. "40",   -- first background color for window placeholder
			bg2  = self.color.gray .. "20"    -- second background color for window placeholder
		}
	}

	-- layout hotkeys helper settings
	self.service.navigator.keytip = {}

	-- this one used as fallback when style for certain layout missed
	self.service.navigator.keytip["base"] = { geometry = { width = 600, height = 600 }, exit = true }

	-- styles for certain layouts
	self.service.navigator.keytip["fairv"] = { geometry = { width = 600, height = 360 }, exit = true }
	self.service.navigator.keytip["fairh"] = self.service.navigator.keytip["fairv"]
	self.service.navigator.keytip["spiral"] = self.service.navigator.keytip["fairv"]
	self.service.navigator.keytip["dwindle"] = self.service.navigator.keytip["fairv"]

	self.service.navigator.keytip["tile"] = { geometry = { width = 600, height = 480 }, exit = true }
	self.service.navigator.keytip["tileleft"]   = self.service.navigator.keytip["tile"]
	self.service.navigator.keytip["tiletop"]    = self.service.navigator.keytip["tile"]
	self.service.navigator.keytip["tilebottom"] = self.service.navigator.keytip["tile"]

	self.service.navigator.keytip["cornernw"] = { geometry = { width = 600, height = 440 }, exit = true }
	self.service.navigator.keytip["cornerne"] = self.service.navigator.keytip["cornernw"]
	self.service.navigator.keytip["cornerse"] = self.service.navigator.keytip["cornernw"]
	self.service.navigator.keytip["cornersw"] = self.service.navigator.keytip["cornernw"]

	self.service.navigator.keytip["magnifier"] = { geometry = { width = 600, height = 360 }, exit = true }

	self.service.navigator.keytip["grid"] = { geometry = { width = 1400, height = 440 }, column = 2, exit = true }
	self.service.navigator.keytip["usermap"] = { geometry = { width = 1400, height = 480 }, column = 2, exit = true }

	-- Desktop file parser
	--------------------------------------------------------------------------------
	self.service.dfparser = {
		-- list of path to check desktop files
		desktop_file_dirs = {
			'/usr/share/applications/',
			'/usr/local/share/applications/',
			'~/.local/share/applications',
		},
		-- icon theme settings
		icons = {
			theme         = nil, -- user icon theme path
			--theme         = "/usr/share/icons/ACYLS", -- for example
			df_icon       = self.icon.system, -- default (fallback) icon
			custom_only   = false, -- use icons from user theme (no system fallback like 'hicolor' allowed) only
			scalable_only = false  -- use vector(svg) icons (no raster icons allowed) only
		},
		wm_name = nil -- window manager name
	}


	-- Menu config
	--------------------------------------------------------------------------------
	self.menu = {
		border_width = 4, -- menu border width
		screen_gap   = self.useless_gap + self.border_width, -- minimal space from screen edge on placement
		height       = 32,  -- menu item height
		width        = 250, -- menu item width
		icon_margin  = { 8, 8, 8, 8 }, -- space around left icon in menu item
		ricon_margin = { 9, 9, 9, 9 }, -- space around right icon in menu item
		nohide       = false, -- do not hide menu after item activation
		auto_expand  = true,  -- show submenu on item selection (without item activation)
		auto_hotkey  = false, -- automatically set hotkeys for all menu items
		select_first = true,  -- auto select first item when menu shown
		hide_timeout = 1,     -- auto hide timeout (auto hide disables if this set to 0)
		font         = self.fonts.menu, -- menu font
		submenu_icon = self.path .. "/common/submenu.svg", -- icon for submenu items
		keytip       = { geometry = { width = 400, height = 460 } }, -- hotkeys helper settings
		svg_scale    = { false, false }, -- use vector scaling for left, right icons in menu item
	}

	self.menu.color = {
		border       = self.color.wibox,     -- menu border color
		text         = self.color.text,      -- menu text color
		highlight    = self.color.highlight, -- menu text and icons color for selected item
		main         = self.color.main,      -- menu selection color
		wibox        = self.color.wibox,     -- menu background color
		submenu_icon = self.color.icon,      -- submenu icon color
		right_icon   = nil,                  -- right icon color in menu item
		left_icon    = nil,                  -- left icon color in menu item
	}


	-- Gauge (various elements that used as component for other widgets) style
	------------------------------------------------------------
	self.gauge = { tag = {}, task = {}, graph = {}}

	-- Separator (decoration used on panel, menu and some other widgets)
	------------------------------------------------------------
	self.gauge.separator = {
		marginv = { 2, 2, 4, 4 }, -- margins for vertical separator
		marginh = { 6, 6, 3, 3 }, -- margins for horizontal separator
		color  = self.color -- colors (shadow used)
	}

	-- Tag (base element of taglist)
	------------------------------------------------------------
	self.gauge.tag.orange = {
		width        = 38,    -- widget width
		line_width   = 4,     -- width of arcs
		iradius      = 5,     -- radius for center point
		radius       = 11,    -- arcs radius
		cgap         = 0.314, -- gap between arcs in radians
		min_sections = 1,     -- minimal amount of arcs
		show_min     = false, -- indicate minimized apps by color
		color        = self.color -- colors (main used)
	}

	-- Task (base element of tasklist)
	------------------------------------------------------------
	self.gauge.task.blue = {
		width      = 70,   -- widget width
		show_min   = true, -- indicate minimized apps by color
		font       = self.cairo_fonts.tag, -- font
		text_shift = 20, -- shift from upper border of widget to lower border of text
		color      = self.color, -- colors (main used)

		-- apps indicator
		point = {
			width = 70, -- apps indicator total width
			height = 3, -- apps indicator total height
			gap = 27,   -- shift from upper border of widget to apps indicator
			dx = 5      -- gap between apps indicator parts
		},
	}

	-- Dotcount (used in minitray widget)
	------------------------------------------------------------
	self.gauge.graph.dots = {
		column_num   = { 3, 5 },  -- amount of dot columns (min/max)
		row_num      = 3,         -- amount of dot rows
		dot_size     = 5,         -- dots size
		dot_gap_h    = 4,         -- horizontal gap between dot (with columns number it'll define widget width)
		color        = self.color -- colors (main used)
	}
	
	-- Panel widgets
	------------------------------------------------------------
	self.widget = {}

	-- individual margins for panel widgets
	------------------------------------------------------------
	self.widget.wrapper = {
		mainmenu    = { 12, 10, 6, 6 },
		layoutbox   = { 10, 10, 6, 6 },
		textclock   = { 12, 12, 0, 0 },
		taglist     = { 4, 4, 0, 0 },
		tray        = { 10, 12, 7, 7 },
		-- tasklist    = { 0, 70, 0, 0 }, -- centering tasklist widget
	}

	-- Textclock
	------------------------------------------------------------
	self.widget.textclock = {
		font    = self.fonts.clock, -- font
		tooltip = {},               -- redflat tooltip style (see theme.float.tooltip)
		color   = { text = self.color.icon }
	}

	-- Minitray
	------------------------------------------------------------
	self.widget.minitray = {
		dotcount     = {}, -- redflat dotcount style (see theme.gauge.graph.dots)
		border_width = 0,  -- floating widget border width
		geometry     = { height = 40 }, -- floating widget size
		screen_gap   = 2 * self.useless_gap, -- minimal space from screen edge on floating widget placement
		color        = { wibox = self.color.wibox, border = self.color.wibox },

		-- function to define floating widget position when shown
		set_position = function()
			return { x = mouse.screen.workarea.x + mouse.screen.workarea.width,
			         y = mouse.screen.workarea.y + mouse.screen.workarea.height }
		end,
	}


	-- Layoutbox
	------------------------------------------------------------
	self.widget.layoutbox = {
		micon = self.icon,  -- some common menu icons (used: 'blank', 'check')
		color = self.color  -- colors (main used)
	}

	-- layout icons
	self.widget.layoutbox.icon = {
		floating          = self.path .. "/layouts/floating.svg",
		max               = self.path .. "/layouts/max.svg",
		fullscreen        = self.path .. "/layouts/fullscreen.svg",
		tilebottom        = self.path .. "/layouts/tilebottom.svg",
		tileleft          = self.path .. "/layouts/tileleft.svg",
		tile              = self.path .. "/layouts/tile.svg",
		tiletop           = self.path .. "/layouts/tiletop.svg",
		fairv             = self.path .. "/layouts/fair.svg",
		fairh             = self.path .. "/layouts/fair.svg",
		grid              = self.path .. "/layouts/grid.svg",
		usermap           = self.path .. "/layouts/map.svg",
		magnifier         = self.path .. "/layouts/magnifier.svg",
		spiral            = self.path .. "/layouts/spiral.svg",
		cornerne          = self.path .. "/layouts/cornerne.svg",
		cornernw          = self.path .. "/layouts/cornernw.svg",
		cornerse          = self.path .. "/layouts/cornerse.svg",
		cornersw          = self.path .. "/layouts/cornersw.svg",
		unknown           = self.path .. "/common/unknown.svg",  -- this one used as fallback
	}

	-- redflat menu style (see theme.menu)
	self.widget.layoutbox.menu = {
		icon_margin  = { 8, 12, 8, 8 },
		width        = 260,
		auto_hotkey  = true,
		nohide       = false,
		color        = { right_icon = self.color.icon, left_icon = self.color.icon }
	}

	-- human readable aliases for layout names (displayed in menu and tooltip)
	self.widget.layoutbox.name_alias = {
		floating          = "Floating",
		fullscreen        = "Fullscreen",
		max               = "Maximized",
		grid              = "Grid",
		usermap           = "User Map",
		tile              = "Right Tile",
		fairv             = "Fair Tile",
		tileleft          = "Left Tile",
		tiletop           = "Top Tile",
		tilebottom        = "Bottom Tile",
		magnifier         = "Magnifier",
		spiral            = "Spiral",
		cornerne          = "Corner NE",
		cornernw          = "Corner NW",
		cornerse          = "Corner SE",
		cornersw          = "Corner SW",
	}

	-- Tasklist
	--------------------------------------------------------------

	-- main settings
	self.widget.tasklist = {
		custom_icon = false, -- use custom applications icons (not every gauge task widget support icons)
		iconnames   = {},    -- icon name aliases for custom applications icons
		widget      = nil,   -- task gauge widget (usually setted by rc file)
		width       = 40,    -- width of task element in tasklist
		char_digit  = 3,     -- number of characters in task element text
 		need_group  = true,  -- group application instances into one task element
		parser      = {},    -- redlat desktop file parser settings (see theme.service.dfparser)
		task_margin = { 5, 5, 0, 0 },      -- margins around task element
		task        = self.gauge.task.blue -- style for task gauge widget
	}

	-- menu settings
	self.widget.tasklist.winmenu = {
		micon          = self.icon, -- some common menu icons
		titleline      = {
			font = self.fonts.title, -- menu title height
			height = 30              -- menu title font
		},
		stateline      = { height = 35 },             -- height of menu item with state icons
		state_iconsize = { width = 18, height = 18 }, -- size for state icons
		layout_icon    = self.widget.layoutbox.icon,  -- list of layout icons
		sep_margin     = { 3, 3, 5, 5 },              -- margins around menu separators
		color          = self.color,                  -- colors (main used)

		-- main menu style (see theme.menu)
		menu = { width = 220, color = { right_icon = self.color.icon }, ricon_margin = { 9, 9, 10, 10 } },

		-- tag action submenu style (see theme.menu)
		tagmenu = { width = 160, color = { right_icon = self.color.icon, left_icon = self.color.icon },
		            icon_margin = { 8, 10, 8, 8 } },

		-- set which action will hide menu after activate
		hide_action = { min = true, move = true, max = false, add = false, floating = false, sticky = false,
		                ontop = false, below = false, maximized = false },
	}

	-- menu icons
	self.widget.tasklist.winmenu.icon = {
		floating             = self.path .. "/common/window_control/floating.svg",
		sticky               = self.path .. "/common/window_control/pin.svg",
		ontop                = self.path .. "/common/window_control/ontop.svg",
		below                = self.path .. "/common/window_control/below.svg",
		close                = self.path .. "/common/window_control/close.svg",
		minimize             = self.path .. "/common/window_control/minimize.svg",
		maximized            = self.path .. "/common/window_control/maximized.svg",

		unknown              = self.path .. "/common/unknown.svg",  -- this one used as fallback
	}

	-- multiline task element tip
	self.widget.tasklist.tasktip = {
		border_width = 2,                -- tip border width
		margin       = { 10, 10, 5, 5 }, -- margins around text in tip lines
		timeout      = 0.5,              -- hide timeout
		sl_highlight = false,            -- highlight application state when it's single line tip
		color = self.color,              -- colors (main used)
	}

	-- task text aliases
	self.widget.tasklist.appnames = {}
	self.widget.tasklist.appnames["Firefox"             ] = "FIFOX"
	self.widget.tasklist.appnames["Gnome-terminal"      ] = "GTERM"


	-- Floating widgets
	--------------------------------------------------------------
	self.float = { decoration = {} }

	-- Client menu
	------------------------------------------------------------
	self.float.clientmenu = {
		actionline      = { height = 28 },             -- height of menu item with action icons
		action_iconsize = { width = 18, height = 18 }, -- size for action icons
		stateline       = { height = 35 },             -- height of menu item with state icons
		state_iconsize  = { width = 20, height = 20 }, -- size for state icons

		sep_margin      = { horizontal = { 3, 3, 5, 5 }, vertical = { 3, 3, 3, 3 } }, -- margins around menu separators

		-- same elements as for task list menu
		icon            = self.widget.tasklist.winmenu.icon,
		micon           = self.widget.tasklist.winmenu.micon,
		layout_icon     = self.widget.layoutbox.icon,
		menu            = self.widget.tasklist.winmenu.menu,
		state_iconsize  = self.widget.tasklist.winmenu.state_iconsize,
		tagmenu         = self.widget.tasklist.winmenu.tagmenu,
		hide_action     = self.widget.tasklist.winmenu.hide_action,
		color           = self.color,
	}

	-- Application runner
	------------------------------------------------------------
	self.float.apprunner = {
		itemnum       = 6,                                 -- number of visible items
		geometry      = { width = 620, height = 480 },     -- widget size
		border_margin = { 24, 24, 24, 24 },                -- margin around widget content
		icon_margin   = { 8, 16, 0, 0 },                   -- margins around widget icon
		title_height  = 48,                                -- height of title (promt and icon) area
		prompt_height = 35,                                -- prompt line height
		title_icon    = self.path .. "/widget/search.svg", -- widget icon
		border_width  = 0,                                 -- widget border width
		parser        = {},                                -- desktop file parser settings (see theme.service.dfparser)
		color         = self.color,                        -- colors (main used)

		name_font     = self.fonts.title,   -- application title font
		comment_font  = self.fonts.main,    -- application comment font
		list_text_vgap   = 4,               -- space between application title and comment
		list_icon_margin = { 6, 12, 6, 6 }, -- margins around applications icons
		dimage           = self.path .. "/common/unknown.svg", -- fallback icon for applications

		keytip        = { geometry = { width = 400, height = 260 } }, -- redflat key tip settings
	}
	
	-- Application switcher
	------------------------------------------------------------
	self.float.appswitcher = {
		wibox_height    = 240, -- widget height
		label_height    = 28,  -- height of the area with application mark(key)
		title_height    = 40,  -- height of widget title line (application name and tag name)
		icon_size       = 96,  -- size of the application icon in preview area
		preview_gap     = 20,  -- gap between preview areas
		parser          = {},  -- desktop file parser settings (see theme.service.dfparser)

		border_margin   = { 10, 10, 0, 10 },  -- margins around widget content
		preview_margin  = { 15, 15, 15, 15 }, -- margins around application preview
		preview_format  = 16 / 10,            -- preview acpect ratio
		title_font      = self.fonts.title,   -- font of widget title line
		border_width    = 0,                  -- widget border width
		update_timeout  = 1 / 12,             -- application preview update timeout
		min_icon_number = 4,                  -- this one will define the minimal widget width
		                                      -- (widget will not shrink if number of apps items less then this)
		color           = self.color,         -- colors (main used)
		font            = self.cairo_fonts.appswitcher, -- font of application mark(key)

		-- redflat key tip settings
		keytip         = { geometry = { width = 400, height = 320 }, exit = true },
	}
	
	-- additional color
	self.float.appswitcher.color.preview_bg = self.color.main .. "12"
	
	-- application marks(keys) list
	self.float.appswitcher.hotkeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
	                                   "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12" }


	-- Quick launcher
	------------------------------------------------------------
	self.float.qlaunch = {
		geometry      = { width = 1400, height = 170 }, -- widget size

		border_width  = 0,                   -- widget border width
		border_margin = { 5, 5, 12, 15 },    -- margins around widget content
		parser        = {},                  -- desktop file parser settings (see theme.service.dfparser)
		notify        = {},                  -- desktop file parser settings (see theme.float.notify)
		recoloring    = false,               -- apply redflat recoloring feature on application icons
		label_font    = self.fonts.qlaunch,  -- font of application mark(key)
		color         = self.color,          -- colors (main used)
		df_icon       = self.path .. "/common/system.svg",  -- fallback application icon
		no_icon       = self.path .. "/common/unknown.svg", -- icon for unused application slot

		appline       = {
			iwidth = 140,           -- application item width
			im = { 5, 5, 0, 0 },    -- margins around application item area
			igap = { 0, 0, 5, 15 }, -- margins around application icon itself (will affect icon size)
			lheight = 26            -- height of application mark(key) area
		},
		state         = {
			gap = 5,    -- space between application state marks
			radius = 5, -- application state mark radius
			size = 10,  -- application state mark size
			height = 14 -- height of application state marks area
		},

		-- redflat key tip settings
		keytip        = { geometry = { width = 600, height = 260 } },

		-- file to store widget data
		-- this widget is rare one which need to keep settings between sessions
		configfile      = os.getenv("HOME") .. "/.cache/awesome/applist",
	}

	-- Hotkeys helper
	------------------------------------------------------------
	self.float.hotkeys = {
		geometry      = { width = 1400, height = 600 }, -- widget size
		border_margin = { 20, 20, 10, 10 },             -- margins around widget content
		border_width  = 0,                              -- widget border width
		delim         = "   ",                          -- text separator between key and description
		tspace        = 5,                              -- space between lines in widget title
		is_align      = true,                           -- align keys description (monospace font required)
		separator     = { marginh = { 0, 0, 2, 6 } },   -- redflat separator style (see theme.gauge.separator)
		font          = self.fonts.hotkeys.main,        -- keys description font
		keyfont       = self.fonts.hotkeys.key,         -- keys font
		titlefont     = self.fonts.hotkeys.title,       -- widget title font
		color         = self.color                      -- colors (main used)
	}

---- Key sequence tip
--------------------------------------------------------------
--theme.float.keychain = {
--	geometry        = { width = 250, height = 54 },
--	font            = theme.fonts.keychain,
--	-- border_width    = 0,
--	keytip          = { geometry = { width = 600, height = 400 }, column = 1 },
--	color           = theme.color,
--}
--
---- Tooltip
--------------------------------------------------------------
--theme.float.tooltip = {
--	margin       = { 6, 6, 4, 4 },
--	timeout      = 0,
--	font         = theme.fonts.tooltip,
--	border_width = 2,
--	color        = theme.color
--}
--
---- Floating prompt
--------------------------------------------------------------
--theme.float.prompt = {
--	border_width = 0,
--	color        = theme.color
--}
--
---- Notify
--------------------------------------------------------------
--theme.float.notify = {
--	geometry     = { width = 484, height = 106 },
--	screen_gap   = 2 * theme.useless_gap,
--	font         = theme.fonts.notify,
--	icon         = theme.icon.warning,
--	border_width = 0,
--	color        = theme.color,
--	set_position = function()
--		return { x = mouse.screen.workarea.x + mouse.screen.workarea.width, y = mouse.screen.workarea.y }
--	end,
--}
--
---- Decoration elements
--------------------------------------------------------------
--theme.float.decoration.button = {
--	color = {
--		shadow3 = theme.color.shadow3,
--		shadow4 = theme.color.shadow4,
--		gray    = theme.color.gray,
--		text    = "#cccccc"
--	},
--}
--
--theme.float.decoration.field = {
--	color = theme.color
--}
--
--
---- Titlebar
-------------------------------------------------------------------------------------------------------------------------
--theme.titlebar = {
--	size          = 8,
--	position      = "top",
--	font          = theme.fonts.titlebar,
--	icon          = { size = 30, gap = 10 },
--	border_margin = { 0, 0, 0, 4 },
--	color         = theme.color,
--}
--
---- Naughty config
-------------------------------------------------------------------------------------------------------------------------
--theme.naughty = {}
--
--theme.naughty.base = {
--	timeout      = 10,
--	margin       = 12,
--	icon_size    = 80,
--	font         = theme.fonts.main,
--	bg           = theme.color.wibox,
--	fg           = theme.color.text,
--	height       = theme.float.notify.geometry.height,
--	width        = theme.float.notify.geometry.width,
--	border_width = 4,
--	border_color = theme.color.wibox
--}
--
--theme.naughty.normal = {}
--theme.naughty.critical = { timeout = 0, border_color = theme.color.main }
--theme.naughty.low = { timeout = 5 }
--
-- Default awesome theme vars
-----------------------------------------------------------------------------------------------------------------------

	-- colors
	self.bg_normal     = self.color.wibox
	self.bg_focus      = self.color.main
	self.bg_urgent     = self.color.urgent
	self.bg_minimize   = self.color.gray

	self.fg_normal     = self.color.text
	self.fg_focus      = self.color.highlight
	self.fg_urgent     = self.color.highlight
	self.fg_minimize   = self.color.highlight

	self.border_normal = self.color.wibox
	self.border_focus  = self.color.wibox
	self.border_marked = self.color.main

	-- font
	self.font = self.fonts.main
end

theme:update()


-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
