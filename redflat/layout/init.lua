-----------------------------------------------------------------------------------------------------------------------
--                                                  RedFlat library                                                  --
-----------------------------------------------------------------------------------------------------------------------

local wrequire = require("redflat.util").wrequire
local setmetatable = setmetatable

local lib = { _NAME = "redflat.layout" }

return setmetatable(lib, { __index = wrequire })
