-----------------------------------------------------------------------------------------------------------------------
--                                                  Menu config                                                      --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local beautiful = require("beautiful")
local redflat = require("redflat")
local awful = require("awful")


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local menu = {}


-- Build function
-----------------------------------------------------------------------------------------------------------------------
function menu:init(args)

	-- vars
	args = args or {}
	local env = args.env or {} -- fix this?
	local separator = args.separator or { widget = redflat.gauge.separator.horizontal() }
	local theme = args.theme or { auto_hotkey = true }
	local icon_style = args.icon_style or { custom_only = true, scalable_only = true }

	-- theme vars
	local default_icon = redflat.util.base.placeholder()
	local icon = redflat.util.table.check(beautiful, "icon.awesome") and beautiful.icon.awesome or default_icon
	local color = redflat.util.table.check(beautiful, "color.icon") and beautiful.color.icon or nil

	-- icon finder
	local function micon(name)
		return redflat.service.dfparser.lookup_icon(name, icon_style)
	end

	-- extra commands
	local ranger_comm = env.terminal .. " -e ranger"

	-- Application submenu
	------------------------------------------------------------
	local appmenu = redflat.service.dfparser.menu({ icons = icon_style, wm_name = "awesome" })

	-- Awesome submenu
	------------------------------------------------------------
	local awesomemenu = {
		{ "Перезапуск",         awesome.restart,                  micon("gnome-session-reboot") },
		separator,
		{ "Awesome config",  env.fm .. " .config/awesome",        micon("folder-bookmarks") },
		{ "Awesome lib",     env.fm .. " /usr/share/awesome/lib", micon("folder-bookmarks") }
	}

	-- Places submenu
	------------------------------------------------------------
	local placesmenu = {
		{ "Документы",   	env.fm .. " Documents", micon("folder-documents") },
		{ "Загрузки",   	env.fm .. " Downloads", micon("folder-download")  },
		{ "Музыка",       	env.fm .. " Music",     micon("folder-music")     },
		{ "Изображения",    env.fm .. " Pictures",  micon("folder-pictures")  },
		{ "Видео",      	env.fm .. " Videos",    micon("folder-videos")    },
		separator,
		{ "Медиа",       	env.fm .. " /mnt/media",   micon("folder-bookmarks") },
		{ "Хранилище",     	env.fm .. " /mnt/storage", micon("folder-bookmarks") },
	}

	-- Exit submenu
	------------------------------------------------------------
	local exitmenu = {
		{ "Перезагрузка",          	"reboot",                    micon("gnome-session-reboot")  },
		{ "Выключить",        		"shutdown now",              micon("system-shutdown")       },
		separator,
		{ "Сменить пользователя",	"dm-tool switch-to-greeter", micon("gnome-session-switch")  },
		{ "Режим ожидания",         "systemctl suspend" ,        micon("gnome-session-suspend") },
		{ "Выход",         			awesome.quit,                micon("exit")                  },
	}

	-- Main menu
	------------------------------------------------------------
	self.mainmenu = redflat.menu({ theme = theme,
		items = {
			{ "Awesome",   	awesomemenu,  micon("awesome") },
			{ "Приложения",	appmenu,      micon("distributor-logo") },
			{ "Места",      placesmenu,   micon("folder_home"), key = "c" },
			separator,
			{ "Терминал",	env.terminal, micon("terminal") },
			{ "Nemo",       env.fm,       micon("folder"), key = "n" },
			{ "Ranger",     ranger_comm,  micon("folder"), key = "r" },
			{ "Редактор",   "code",       micon("code") },
			separator,
			{ "Выход",      exitmenu,     micon("exit") },
		}
	})

	-- Menu panel widget
	------------------------------------------------------------

	self.widget = redflat.gauge.svgbox(icon, nil, color)
	self.buttons = awful.util.table.join(
		awful.button({ }, 1, function () self.mainmenu:toggle() end)
	)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return menu