-----------------------------------------------------------------------------------------------------------------------
--                                                   Base setup                                                      --
-----------------------------------------------------------------------------------------------------------------------

-- Disable autostart applications
local timestamp = require("redflat.timestamp")
timestamp.lock = true

-- DPI setup
local beautiful = require("beautiful")
beautiful.xresources.set_dpi(96)

-- Configuration file setup
-----------------------------------------------------------------------------------------------------------------------
--local rc = "color.red.rc-red"
local rc = "color.blue.rc-blue"
--local rc = "color.orange.rc-orange"
--local rc = "color.green.rc-green"
--local rc = "colorless.rc-colorless"

require(rc)
