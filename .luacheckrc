-- Only allow symbols available in all Lua versions
std = "min"

-- Get rid of "unused argument self" - warnings
self = false

-- Do not check files outside of config
exclude_files = {
    ".luacheckrc", -- this file itself
    "rc-back.lua", -- orinal config
    "redflat",     -- submodule
}

-- Global objects defined by the C code
read_globals = {
    -- awesome API
    "awesome",
    "button",
    "dbus",
    "drawable",
    "drawin",
    "key",
    "keygrabber",
    "mousegrabber",
    "root",
    "selection",
    "tag",
    "window",

    -- lua unpack
    "table.unpack",
    "unpack"
}

-- Not read-only globals.
globals = {
    -- awesome API
    "screen",
    "mouse",
    "client",

    -- global used in configs
    "lock"
}