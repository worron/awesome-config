-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat map layout                                                 --
-----------------------------------------------------------------------------------------------------------------------
-- Tiling with user defined geometry
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local ipairs = ipairs
local pairs = pairs
local math = math

local beautiful = require("beautiful")
local awful = require("awful")
local navigator = require("redflat.service.navigator")
local redutil = require("redflat.util")

local hasitem = awful.util.table.hasitem

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local map = {}
map.name = "usermap"
map.fstep = 0.02
map.smartclose = false
map.autoaim = false

local data = setmetatable({}, { __mode = 'k' })
data.aim = 0

-- default keys
map.keys = {
	move_up    = { "Up" },
	move_down  = { "Down" },
	move_left  = { "Left" },
	move_right = { "Right" },
	resize_up    = { "k", "K" },
	resize_down  = { "j", "J" },
	resize_left  = { "h", "H" },
	resize_right = { "l", "L" },
	aim          = { "f", "F" },
	swap         = { "s", "S" },
	last         = { "i", "I" },
	fair         = { "e", "E" },
	exit = { "Escape", "Super_L" },
	mod  = { total = "Shift" }
}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Client geometry correction depending on useless gap and window border
--------------------------------------------------------------------------------
local function size_correction(c, geometry, useless_gap)
	geometry.width  = math.max(geometry.width  - 2 * c.border_width - useless_gap, 1)
	geometry.height = math.max(geometry.height - 2 * c.border_width - useless_gap, 1)
	geometry.x = geometry.x + useless_gap / 2
	geometry.y = geometry.y + useless_gap / 2
end

-- Construct object with full placement info
--------------------------------------------------------------------------------
local function construct_item()
	local item = { child = {}, factor = { x = 1, y = 1 } }

	-- Increase geometry factor
	------------------------------------------------------------
	function item:incf(value, is_vertical)
		local d = is_vertical and "y" or "x"
		self.factor[d] = self.factor[d] + value
		if self.factor[d] < 0.05 then self.factor[d] = 0.05 end
	end

	-- Calculate window geometry
	------------------------------------------------------------
	function item:get_geometry(except)
		local area

		-- get base geometry
		if self.geometry then
			area = awful.util.table.clone(self.geometry)
		else
			-- cut area from parent window
			local g = self.parent:get_geometry(self)

			if self.vertical then
				local h = g.height * self.factor.y / (self.parent.factor.y  + self.factor.y)
				area = { x = g.x, y = g.y + g.height - h, width = g.width, height = h }
			else
				local w = g.width * self.factor.x / (self.parent.factor.x  + self.factor.x)
				area = { x = g.x + g.width - w, y = g.y, width = w, height = g.height }
			end
		end

		-- correct area size depending on child windows
		-- !!! need optimization here !!!
		local ex_index = hasitem(self.child, except) or #self.child + 1
		for i, chd in ipairs(self.child) do
			if ex_index > i then
				if chd.vertical then
					area.height = area.height * self.factor.y / (chd.factor.y  + self.factor.y)
				else
					area.width = area.width * self.factor.x / (chd.factor.x  + self.factor.x)
				end
			end
		end

		return area
	end

	------------------------------------------------------------
	return item
end

-- Find the biggest window index
--------------------------------------------------------------------------------
local function get_max_object(tagmap, current_id)
	local s = 0
	local max_id

	for i = 1, current_id do
		local g = tagmap[i]:get_geometry()
		local cs = g.width * g.height

		if cs > s then max_id = i; s = cs end
	end

	return max_id
end

-- Select object (index) which will be used as sourse for new windows geometry
--------------------------------------------------------------------------------
function data:set_aim()
	for i, o in ipairs(self[self.ctag]) do
		if o.client == client.focus then self.aim = i end
	end
end

-- Get index of focused window
--------------------------------------------------------------------------------
function data:update_focus()
	self.fid = nil

	for i, o in ipairs(self[self.ctag]) do
		if o.client == client.focus then
			self.fid = i
			break
		end
	end
end

-- Set fair gemetry for focused window
--------------------------------------------------------------------------------

-- Form all parent objects with given direction
------------------------------------------------------------
local function get_branch(object, is_vertical, storage)
	local storage = storage or {}
	table.insert(storage, object)

	if object.parent then
		if object.parent.vertical == is_vertical then
			get_branch(object.parent, is_vertical, storage)
		else
			table.insert(storage, object.parent)
		end
	end

	return storage
end

-- Set fair factor
------------------------------------------------------------
function data:set_fair()
	self:update_focus()

	local vertical = self[self.ctag][self.fid].vertical
	local d = vertical and "y" or "x"
	local branch = get_branch(self[self.ctag][self.fid], vertical)

	local k = branch[#branch].factor[d]
	for i = #branch - 1, 1, -1 do
		k = k * i
		branch[i].factor[d] = k
	end

	self.ctag:emit_signal("property::layout")
end

-- Change focused window geometry factor
--------------------------------------------------------------------------------
function data:incfactor(value, is_vertical)
	self:update_focus()
	self[self.ctag][self.fid]:incf(value, is_vertical)
	self.ctag:emit_signal("property::layout")
end

-- Save current client list
--------------------------------------------------------------------------------
function data:make_snapshot()
	snapshot = {}
	for i, o in ipairs(self[self.ctag]) do
		snapshot[i] = o.client
	end

	return snapshot
end

-- Move last opened client to focused client as child
--------------------------------------------------------------------------------
function data:movelast(is_infront)
	self:update_focus()
	local moved = self[self.ctag][#self[self.ctag]]

	-- remove last object from list
	if moved.parent then
		table.remove(moved.parent.child, hasitem(moved.parent.child, moved))
	end
	self[self.ctag][#self[self.ctag]] = nil

	if is_infront then
		-- Create new object in front of focused
		local newitem = construct_item()
		local snapshot = self:make_snapshot()
		local focused = self[self.ctag][data.fid]

		if focused.parent then
			local cindex = hasitem(focused.parent.child, focused)
			focused.parent.child[cindex] = newitem
			newitem.parent = focused.parent
		else
			newitem.geometry = focused.geometry
			focused.geometry = nil
		end

		newitem.child[1] = focused
		newitem.factor = { x = focused.factor.x, y = focused.factor.y }
		focused.parent = newitem
		table.insert(self[self.ctag], data.fid, newitem)

		-- move last client into focused position
		self.lock = true
		for i = #snapshot, data.fid, -1 do moved.client:swap(snapshot[i]) end
		self.lock = false
	else
		-- create new object behind focused
		data:split(data.fid)
	end

	self.ctag:emit_signal("property::layout")
end

-- Swap split direction
--------------------------------------------------------------------------------
local function sw(object, is_total)
	object.vertical = not object.vertical
	if is_total then
		for _, chd in ipairs(object.child) do sw(chd, is_total) end
	end
end

function data:swap(is_total)
	self:update_focus()

	if self.fid then sw(self[self.ctag][self.fid], is_total) end
	self.ctag:emit_signal("property::layout")
end

-- Create new window object by cutting area from parent object
-- @index Index of parent object
--------------------------------------------------------------------------------
function data:split(index)
	local tagmap = self[self.ctag]
	local g = tagmap[index]:get_geometry()
	local is_vertical = g.width <= g.height
	local new = construct_item()

	new.vertical = is_vertical
	new.factor = { x = tagmap[index].factor.x, y = tagmap[index].factor.y }
	new.parent = tagmap[index]
	table.insert(tagmap[index].child, new)
	table.insert(tagmap, new)

	-- reset aim
	self.aim = 0
end

-- Make placement shifting after one of the client was closed
--------------------------------------------------------------------------------

-- Find difference in two client list
------------------------------------------------------------
local function first_diff(list1, list2)
	for i, c in ipairs(list1) do
		if list2[i] ~= c then return i end
	end
end

-- Check if one of clients was closed
------------------------------------------------------------
function data:is_single_closed(cls)
	if data[data.ctag].lastcls and #data[data.ctag].lastcls == #cls + 1 then
		local diff_id = first_diff(cls, data[data.ctag].lastcls)
		if not diff_id then return end

		for i = diff_id, #cls do
			if cls[i] ~= data[data.ctag].lastcls[i + 1] then return end
		end

		return diff_id
	end
end

-- Factor correction after object replacement
------------------------------------------------------------
local function correct_factor(object, k)
	local ck = { x = k.x, y = k.y }

	ck[object.vertical and "x" or "y"] = 1
	object.factor = { x = object.factor.x * ck.x, y = object.factor.y * ck.y }

	for _, chd in ipairs(object.child) do
		correct_factor(chd, ck)
	end
end

local function factor_transfer(object, factor, real_child_num)
	local k = { x = factor.x / object.factor.x, y = factor.y / object.factor.y  }
	object.factor = factor

	for i = real_child_num, #object.child do
		correct_factor(object.child[i], k)
	end
end


-- Remove placement object with client shifting
------------------------------------------------------------
function data:delete_item(cls, id)
	local removed = self[self.ctag][id]

	if #removed.child > 0 then
		for i, chd in ipairs(removed.child) do
			if i == #removed.child then
				-- replace removing object with its last child
				local cindex = hasitem(self[self.ctag], chd)
				table.remove(self[self.ctag], cindex)
				chd.vertical = removed.vertical
				chd.parent = removed.parent
				factor_transfer(chd, removed.factor, #removed.child)
				self[self.ctag][id] = chd

				if removed.parent then
					local rindex = hasitem(removed.parent.child, removed)
					removed.parent.child[rindex] = chd
				else
					chd.geometry = removed.geometry
				end

				-- restore client placement order
				self.lock = true
				local c = cls[cindex - 1]
				for i = cindex - 2, id, -1 do c:swap(cls[i]) end
				client.focus = cls[id]
				self.lock = false
			else
				-- all children except last have new parent
				chd.parent = removed.child[#removed.child]
				table.insert(removed.child[#removed.child].child, i, chd)
			end
		end
	else
		-- just remove object if it has no child
		if removed.parent then
			table.remove(removed.parent.child, hasitem(removed.parent.child, removed))
		end
		table.remove(self[self.ctag], id)
	end

end

-- Keygrabber
-----------------------------------------------------------------------------------------------------------------------
data.keygrabber = function(mod, key, event)
	local total = hasitem(mod, map.keys.mod.total)
	local step = total and 5 * map.fstep or map.fstep
	if event == "press" then return false
	elseif hasitem(map.keys.exit, key) then
		if data.on_close then data.on_close() end
		awful.keygrabber.stop(data.keygrabber)
		data.smartclose = false
	elseif navigator.raw_keygrabber(mod, key, event) then
	elseif hasitem(map.keys.move_up, key)    then awful.client.swap.bydirection("up")
	elseif hasitem(map.keys.move_down, key)  then awful.client.swap.bydirection("down")
	elseif hasitem(map.keys.move_left, key)  then awful.client.swap.bydirection("left")
	elseif hasitem(map.keys.move_right, key) then awful.client.swap.bydirection("right")
	elseif hasitem(map.keys.aim, key)   then data:set_aim()
	elseif hasitem(map.keys.swap, key)  then data:swap(total)
	elseif hasitem(map.keys.last, key)  then data:movelast(total)
	elseif hasitem(map.keys.fair, key)  then data:set_fair()
	elseif hasitem(map.keys.resize_up, key)    then data:incfactor(step, true)
	elseif hasitem(map.keys.resize_down, key)  then data:incfactor(-step, true)
	elseif hasitem(map.keys.resize_left, key)  then data:incfactor(-step)
	elseif hasitem(map.keys.resize_right, key) then data:incfactor(step)
	else return false
	end
end

-- Tile function
-----------------------------------------------------------------------------------------------------------------------
function map.arrange(p)

	-- theme vars
	local useless_gap = beautiful.useless_gap_width or 0
	local global_border = beautiful.global_border_width or 0

	-- aliases
	local wa = p.workarea
	local cls = p.clients
    data.ctag = awful.tag.selected(p.screen)

    if not data[data.ctag] then data[data.ctag] = {} end
    local tagmap = data[data.ctag]

	-- nothing to tile here
	if #cls == 0 or data.lock then return end

	-- make shift palcement if need
	if  map.smartclose or data.smartclose then
		local closed_id = data:is_single_closed(cls)
		if closed_id then data:delete_item(cls, closed_id) end
	end

    tagmap.lastcls = cls

	-- workarea size correction depending on useless gap and global border
	wa.height = wa.height - 2 * global_border - useless_gap
	wa.width  = wa.width -  2 * global_border - useless_gap
	wa.x = wa.x + useless_gap / 2 + global_border
	wa.y = wa.y + useless_gap / 2 + global_border

	-- Construct object tree for client list
	------------------------------------------------------------
	for i, c in ipairs(cls) do
		if not tagmap[i] then
			if i > 1 then
				local aim = tagmap[data.aim] and data.aim or map.autoaim and get_max_object(tagmap, i - 1) or #tagmap
				data:split(aim)
			else
				tagmap[i] = construct_item()
				tagmap[i].geometry = awful.util.table.clone(wa)
			end
		end

		tagmap[i].client = c
	end

	-- Clear empty items
	------------------------------------------------------------
	if #tagmap > #cls then
		for i = #cls + 1, #tagmap do
			if tagmap[i].parent then
				-- !!! need some optimization here !!!
				table.remove(tagmap[i].parent.child, hasitem(tagmap[i].parent.child, tagmap[i]))
			end
			tagmap[i] = nil
		end
		tagmap[#tagmap].child = {}
	end

	-- Tile
	------------------------------------------------------------
	for i, c in ipairs(cls) do
		local g = tagmap[i]:get_geometry()
		size_correction(c, g, useless_gap)
		c:geometry(g)
	end
end

-- Mouse moving function
-----------------------------------------------------------------------------------------------------------------------
function map.mouse_move_handler(c)
	mousegrabber.run(
		function (_mouse)
			for k, v in ipairs(_mouse.buttons) do
				if v then
					local c_u_m = awful.mouse.client_under_pointer()
					if c_u_m and not awful.client.floating.get(c_u_m) then
						if c_u_m ~= c then c:swap(c_u_m) end
					end
					return true
				end
			end
			return false
		end,
		"fleur"
	)
end

-- Keyboard handler function
-----------------------------------------------------------------------------------------------------------------------
function map.key_handler(c, on_close)
	data.on_close = on_close
	data.smartclose = true
	awful.keygrabber.run(data.keygrabber)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return map
