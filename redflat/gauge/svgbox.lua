-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat svg icon widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Imagebox widget modification
-- Use rsvg-convert to resize svg image
-- Color setup added
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ wibox.widget.imagebox v3.5.2
------ (c) 2010 Uli Schlachter
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local string = string
local type = type
local pcall = pcall
local print = print
local math = math
local os = os

local cairo = require("lgi").cairo
local base = require("wibox.widget.base")
local surface = require("gears.surface")
local awful = require("awful")
local color = require("gears.color")
local beautiful = require("beautiful")

local asyncshell = require("redflat.asyncshell")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local svgbox = { mt = {} }

svgbox.tempdir = "/tmp/awesome/"
os.execute("mkdir -p " .. svgbox.tempdir)

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Check if given argument is svg file
local function is_svg(args)
	return type(args) == "string" and string.match(args, "\.svg")
end

-- Check if need scale svg image
local function need_scale(width, height, image, data)
	return data.scale
	       and ((image.width ~= width or image.height ~= height)
	       and (data.last.width ~= width or data.last.height ~= height or data.last.image ~= data.iname))
end

-- Function to resize svg image and set new image to the widget
local function resize_and_set_svg(widg, width, height, data)

	-- generate name for temporary file
	-- I'm too lazy to make proper names and hope there will be no collisions
	local tempfile = svgbox.tempdir .. tostring(math.random(1000000)) .. ".png"

	-- convert command
	local command = string.format("rsvg-convert %s -w %s -h %s -o %s", data.iname, width, height, tempfile)

	-- set new image as soon as conversion finished
	asyncshell.request(command,
		function(o)
			widg:set_image(tempfile, true)  -- set image
			os.execute("rm " .. tempfile)   -- remove temporary file
		end)
end

-- Check if cached surface available
local function is_cached(cache, iname, width, height)
	return cache[iname] and cache[iname].width == width and cache[iname].height == height
end

-- Returns a new svgbox
-- @param image The image to display
-----------------------------------------------------------------------------------------------------------------------
function svgbox.new(image, svg_scale)

	-- Initialize vars
	--------------------------------------------------------------------------------

	local cache = setmetatable({}, { __mode = 'k' })

	-- updating values
	local data = {
		last  = {},
		scale = true,
	}
	if svg_scale ~= nil then data.scale = svg_scale end

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = base.make_widget()

	-- User functions
	------------------------------------------------------------
	function widg:set_image(newimage, service_call)

		local image
		--if not newimage or newimage == data.iname then return false end

		if type(newimage) == "string" then
			local success, result = pcall(surface.load, newimage)
			if not success then
				print("Error while reading '" .. newimage .. "': " .. result)
				return false
			end
			image = result
		else
			image = surface.load(newimage)
		end

		if image and (image.height <= 0 or image.width <= 0) then return false end

		self._image = image

		if service_call then
			cache[data.iname] = image
		else
			data.iname = newimage
		end

		self:emit_signal("widget::updated")
		return true
	end

	function widg:set_size(args)
		local args = args or {}
		data.width = args.width or data.width
		data.height = args.height or data.height
		self:emit_signal("widget::updated")
	end

	function widg:set_color(newcolor)
		data.color = newcolor
		self:emit_signal("widget::updated")
	end

	function widg:set_svg_scale(scale)
		data.scale = scale
		self:emit_signal("widget::updated")
	end

	-- Fit
	------------------------------------------------------------
	function widg:fit(width, height)
		if data.width or data.height then
			return data.width or width, data.height or height
		else
			if not self._image then return 0, 0 end

			local w, h = self._image.width, self._image.height
			local aspect = math.min(width / w, height / h)
			return w * aspect, h * aspect
		end
	end

	-- Draw
	------------------------------------------------------------
	function widg:draw(wibox, cr, width, height)
		if not self._image then return end
		if width == 0 or height == 0 then return end

		-- convert svg to png with wanted size if need
		if is_svg(data.iname) then
			if is_cached(cache, data.iname, width, height) then self._image = cache[data.iname] end
			if need_scale(width, height, self._image, data) then
				--naughty.notify({ text = "converted " .. width .. " x " .. height })
				-- save last parametres
				-- this need to prevent looping rsvg-convert requests
				data.last = { width = width, height = height, image = data.iname }

				-- convert and set new image
				resize_and_set_svg(self, width, height, data)
				return
			end
		end

		cr:save()
		-- let's scale the image so that it fits into (width, height)
		-- this part wiil be useful when rsvg-convert resizing disabled
		if (self._image:get_width() ~= width or self._image:get_height() ~= height) then
			local w = self._image:get_width()
			local h = self._image:get_height()
			local aspect = width / w
			local aspect_h = height / h
			if aspect > aspect_h then aspect = aspect_h end
			cr:scale(aspect, aspect)
		end

		-- set icon color if need
		if data.color then
			cr:set_source(color(data.color))
			cr:mask(cairo.Pattern.create_for_surface(self._image), 0, 0)
		else
			cr:set_source_surface(self._image, 0, 0)
			cr:paint()
		end

		cr:restore()
	end

	--------------------------------------------------------------------------------
	if image then widg:set_image(image) end

	return widg
end

-- Config metatable to call svgbox module as function
-----------------------------------------------------------------------------------------------------------------------
function svgbox.mt:__call(...)
	return svgbox.new(...)
end

return setmetatable(svgbox, svgbox.mt)
