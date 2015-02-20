-----------------------------------------------------------------------------------------------------------------------
--                                           RedFlat desctop file parser                                             --
-----------------------------------------------------------------------------------------------------------------------
-- Create application menu analyzing .desktop files in given directories
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.menubar v3.5.2
------ (c) 2009, 2011-2012 Antonio Terceiro, Alexander Yakushev
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local io = io
local table = table
local ipairs = ipairs
local string = string
local awful = require("awful")
local beautiful = require("beautiful")

local redutil = require("redflat.util")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local dfparser = {}

dfparser.terminal = 'uxterm'

local all_icon_folders = { "apps", "actions", "devices", "places", "categories", "status" }
local all_icon_sizes   = { '128x128' , '96x96', '72x72', '64x64', '48x48',
                           '36x36',    '32x32', '24x24', '22x22', '16x16', 'scalable' }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icons             = { custom_only = false, scalable_only = false },
		desktop_file_dirs = { "/usr/share/applications/" },
		wm_name           = nil,
	}

	return redutil.table.merge(style, redutil.check(beautiful, "float.dfparser") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Check whether the icon format is supported
--------------------------------------------------------------------------------
local function is_format(icon_file, icon_formats)
	for _, f in ipairs(icon_formats) do
		if icon_file:match('%.' .. f) then return true end
	end
	return false
end

-- Find all possible locations of the icon
--------------------------------------------------------------------------------
local function all_icon_path(style)

	local icon_path = {}
	local icon_theme_paths = {}

	-- add user icon theme
	if style.theme then
		table.insert(icon_theme_paths, style.theme .. '/')
		-- TODO also look in parent icon themes, as in freedesktop.org specification
	end

	-- add fallback theme
	if not style.custom_only then table.insert(icon_theme_paths, '/usr/share/icons/hicolor/') end

	-- seach only svg icons if need
	local all_icon_sizes = style.scalable_only and { 'scalable' } or all_icon_sizes

	-- form all avalible icon dirs
	for _, icon_theme_directory in ipairs(icon_theme_paths) do
		for _, size in ipairs(all_icon_sizes) do
			for _, folder in ipairs(all_icon_folders) do
				table.insert(icon_path, icon_theme_directory .. size .. "/" .. folder .. '/')
			end
		end
	end

	-- lowest priority fallbacks
	if not style.custom_only then
		table.insert(icon_path, '/usr/share/pixmaps/')
		table.insert(icon_path, '/usr/share/icons/')
	end

	return icon_path
end

-- Lookup an icon in different folders of the filesystem
-- @param icon_file Short or full name of the icon
-- @param style.default_icon Return if no icon was found
-- @param style.icon_theme Full path to custom icon theme
-- @param style.custom_only Seach only custom theme icons, ignore system
-- @param style.scalable_only Seach only svg type icons
-- @return full name of the icon
-----------------------------------------------------------------------------------------------------------------------
function dfparser.lookup_icon(icon_file, style)

	local style = redutil.table.merge(default_style().icons, style or {})
	local icon_formats = style.scalable_only and { "svg" } or { "svg", "png", "gif" }

	local df_icon
	if style.df_icon and awful.util.file_readable(style.df_icon) then
		df_icon = style.df_icon
	end

	-- No icon name
	if not icon_file or icon_file == "" then return style.default_icon end


	-- Handle full path icons
	if icon_file:sub(1, 1) == '/' then
		if is_format(icon_file, icon_formats) then
			return icon_file
		else
			icon_file = string.match(icon_file, "([%a%d%-]+)%.")
		end
	end

	-- Find all possible locations to search
 	local icon_path = all_icon_path(style)

	-- Icon searching
	for i, directory in ipairs(icon_path) do

		-- check if icon format specified and supported
		if is_format(icon_file, icon_formats) and awful.util.file_readable(directory .. icon_file) then
			return directory .. icon_file
		else

			-- check if icon format specified but not supported
			if string.match(icon_file, "%.") and not is_format(icon_file, icon_formats) then
				icon_file = string.match(icon_file, "[%a%d%-]+")
			end

			-- icon is probably specified without path and format,
			-- like 'firefox'. Try to add supported extensions to
			-- it and see if such file exists.
			for _, format in ipairs(icon_formats) do
				local possible_file = directory .. icon_file .. "." .. format
				if awful.util.file_readable(possible_file) then
					return possible_file
				end
			end
		end
	end

	return df_icon
end

-- Main parsing functions
-----------------------------------------------------------------------------------------------------------------------

-- Parse a .desktop file
-- @param file The .desktop file
-- @param style Arguments for dfparser.lookup_icon
-- @return A table with file entries
--------------------------------------------------------------------------------
local function parse(file, style)

	local program = { show = true, file = file }
	local desktop_entry = false

	-- Parse the .desktop file.
	-- We are interested in [Desktop Entry] group only.
	for line in io.lines(file) do
		if not desktop_entry and line == "[Desktop Entry]" then
			desktop_entry = true
		else
			if line:sub(1, 1) == "[" and line:sub(-1) == "]" then
				-- A declaration of new group - stop parsing
				break
			end

			-- Grab the values
			for key, value in line:gmatch("(%w+)%s*=%s*(.+)") do
				program[key] = value
			end
		end
	end

	-- In case [Desktop Entry] was not found
	if not desktop_entry then return nil end

	-- Don't show program if NoDisplay attribute is false
	if program.NoDisplay and string.lower(program.NoDisplay) == "true" then
		program.show = false
	end

	-- Only show the program if there is no OnlyShowIn attribute
	-- or if it's equal to given wm name
	if program.OnlyShowIn ~= nil and style.wm_name and not program.OnlyShowIn:match(style.wm_name) then
		program.show = false
	end

	-- Look up for a icon.
	if program.Icon then
		program.icon_path = dfparser.lookup_icon(program.Icon, style.icons)
	end

	-- Split categories into a table. Categories are written in one
	-- line separated by semicolon.
	if program.Categories then
		program.categories = {}

		for category in program.Categories:gmatch('[^;]+') do
			table.insert(program.categories, category)
		end
	end

	if program.Exec then
		-- Substitute Exec special codes as specified in
		-- http://standards.freedesktop.org/desktop-entry-spec/1.1/ar01s06.html
		local cmdline = program.Exec:gsub('%%c', program.Name)
		cmdline = cmdline:gsub('%%[fuFU]', '')
		cmdline = cmdline:gsub('%%k', program.file)

		if program.icon_path then
			cmdline = cmdline:gsub('%%i', '--icon ' .. program.icon_path)
		else
			cmdline = cmdline:gsub('%%i', '')
		end

		if program.Terminal == "true" then
			cmdline = dfparser.terminal .. ' -e ' .. cmdline
		end

		program.cmdline = cmdline
	end

	return program
end

-- Parse a directory with .desktop files
-- @param dir The directory
-- @param style Arguments for dfparser.lookup_icon
-- @return A table with all .desktop entries
--------------------------------------------------------------------------------
local function parse_dir(dir, style)
	local programs = {}
	local files = awful.util.pread('find '.. dir ..' -maxdepth 1 -name "*.desktop" 2>/dev/null')

	for file in string.gmatch(files, "[^\n]+") do
		local program = parse(file, style)
		if program then table.insert(programs, program) end
	end

	return programs
end

-- Create a new application menu
-- @param style.icons Arguments for dfparser.lookup_icon
-- @param style.desktop_file_dirs Table containing all .desktop file directories
-- @return Applications menu table
-----------------------------------------------------------------------------------------------------------------------
function dfparser.menu(style)

	local style = redutil.table.merge(default_style(), style or {})

	-- Categories list
	--------------------------------------------------------------------------------
	local categories = {
		{ app_type = "AudioVideo",  name = "Multimedia",   icon_name = "applications-multimedia" },
		{ app_type = "Development", name = "Development",  icon_name = "applications-development" },
		{ app_type = "Education",   name = "Education",    icon_name = "applications-science" },
		{ app_type = "Game",        name = "Games",        icon_name = "applications-games" },
		{ app_type = "Graphics",    name = "Graphics",     icon_name = "applications-graphics" },
		{ app_type = "Office",      name = "Office",       icon_name = "applications-office" },
		{ app_type = "Network",     name = "Internet",     icon_name = "applications-internet" },
		{ app_type = "Settings",    name = "Settings",     icon_name = "applications-utilities" },
		{ app_type = "System",      name = "System Tools", icon_name = "applications-system" },
		{ app_type = "Utility",     name = "Accessories",  icon_name = "applications-accessories" }
	}

	-- Find icons for categories
	--------------------------------------------------------------------------------
	for _, v in ipairs(categories) do
		v.icon = dfparser.lookup_icon(v.icon_name, style)
	end

	-- Find all visible menu items
	--------------------------------------------------------------------------------
	local prog_list = {}
	for _, path in ipairs(style.desktop_file_dirs) do
		local programs = parse_dir(path, style)

		for _, prog in ipairs(programs) do
			if prog.show and prog.Name and prog.cmdline then
				table.insert(prog_list, prog)
			end
		end
	end

	-- Sort menu items by category and create submenu
	--------------------------------------------------------------------------------
	local appmenu = {}
	local catmenu = {}
	for _, menu_category in ipairs(categories) do
		catmenu = {}

		for i = #prog_list, 1, -1 do
			if prog_list[i].categories then
				for _, item_category in ipairs(prog_list[i].categories) do
					if item_category == menu_category.app_type then
						table.insert(catmenu, { prog_list[i].Name, prog_list[i].cmdline, prog_list[i].icon_path })
						table.remove(prog_list, i)
					end
				end
			end
		end
		if #catmenu > 0 then table.insert(appmenu, { menu_category.name, catmenu, menu_category.icon }) end
	end

	-- Collect all items without category to "Other" submenu
	--------------------------------------------------------------------------------
	if #prog_list > 0 then
		catmenu = {}

		for _, prog in ipairs(prog_list) do
			table.insert(catmenu, { prog.Name, prog.cmdline, prog.icon_path })
		end

		table.insert(appmenu, { "Other", catmenu, dfparser.lookup_icon("applications-other", icon_args) })
	end

	return appmenu
end

-- Get list of icons linked with process name
-- @param style.icons Arguments for dfparser.lookup_icon
-- @param style.desktop_file_dirs Table containing all .desktop file directories
-- @return Icon list
-----------------------------------------------------------------------------------------------------------------------
function dfparser.icon_list(style)

	local style = redutil.table.merge(default_style(), style or {})
	local list = {}

	for _, path in ipairs(style.desktop_file_dirs) do
		local programs = parse_dir(path, style)

		for _, prog in ipairs(programs) do
			if prog.Icon and prog.Exec then
				local key = string.match(prog.Exec, "[%a%d%.%-/]+")
				if string.find(key, "/") then key = string.match(key, "[%a%d%.%-]+$") end
				list[key] = prog.icon_path
			end
		end
	end

	return list
end

-- Generate table with avaliable programs
-- without sorting by categories
-- @param style.icons Arguments for dfparser.lookup_icon
-- @param style.desktop_file_dirs Table containing all .desktop file directories
-----------------------------------------------------------------------------------------------------------------------
function dfparser.program_list(style)

	local style = redutil.table.merge(default_style(), style or {})
	local prog_list = {}

	for _, path in ipairs(style.desktop_file_dirs) do
		local programs = parse_dir(path, style)

		for _, prog in ipairs(programs) do
			if prog.show and prog.Name and prog.cmdline then
				table.insert(prog_list, prog)
			end
		end
	end

	return prog_list
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return dfparser
