-----------------------------------------------------------------------------------------------------------------------
--                                                   Base setup                                                      --
-----------------------------------------------------------------------------------------------------------------------

-- Fix unpack compatibility between lua versions
unpack = unpack or table.unpack

-- Set lock 'true' to disable autostart applications
local timestamp = require("redflat.timestamp")
timestamp.lock = true

-- DPI setup
local beautiful = require("beautiful")
beautiful.xresources.set_dpi(96)

-- Configuration file setup
-----------------------------------------------------------------------------------------------------------------------
-- local rc = "rc-red"
 local rc = "rc-blue"
-- local rc = "rc-orange"
-- local rc = "rc-green"
-- local rc = "rc-colorless"

require(rc)
