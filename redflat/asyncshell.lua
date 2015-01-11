-----------------------------------------------------------------------------------------------------------------------
--                                                   RedFlat asyncshell                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Asynchronous read shell command output
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ asynchronous io.popen for Awesome WM
------ @copyright Alexander Yakushev
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local awful = require('awful')

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local asyncshell = { request_table = {}, id_counter = 0 }

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- request counter
local function next_id()
	asyncshell.id_counter = (asyncshell.id_counter + 1) % 10000
	return asyncshell.id_counter
end

-- remove given request
function asyncshell.clear(id)
	if asyncshell.request_table[id] then asyncshell.request_table[id] = nil end
end

-- Sends an asynchronous request for an output of the shell command
-- @param command Command to be executed and taken output from
-- @param callback Function to be called when the command finishes
-- @param timeout Maximum amount of time to wait for the result (optional)
-----------------------------------------------------------------------------------------------------------------------
function asyncshell.request(command, callback, timeout)
	local id = next_id()
	asyncshell.request_table[id] = { callback = callback }

	local formatted_command = string.gsub(command, '"','\"')
	                          .. " | sed -e 's/\"/\\\\\"/g' -e ':a;N;$!ba;s/\\n/\\\\n/g'"

	local req = string.format(
		"echo \"asyncshell.deliver(%s, \\\"$(%s)\\\")\" | awesome-client &",
		id, formatted_command
	)

	awful.util.spawn_with_shell(req)

	if timeout then
		awful.util.spawn_with_shell(string.format(
			"sleep %s && echo \"asyncshell.clear(%s)\" | awesome-client &",
			timeout, id
		))
	end
end

-- Calls the remembered callback function on the output of the shell command
-- @param id Request ID
-- @param output Shell command output to be delievered
-----------------------------------------------------------------------------------------------------------------------
function asyncshell.deliver(id, output)
	if asyncshell.request_table[id] then
		asyncshell.request_table[id].callback(output)
		asyncshell.request_table[id] = nil
	end
end

-----------------------------------------------------------------------------------------------------------------------
return asyncshell
