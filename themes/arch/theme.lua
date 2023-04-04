-----------------------------------------------------------------------------------------------------------------------
--                                                Arch theme                                                    --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- local theme = {}
local theme = require("themes/colored/theme")
-- local wa = mouse.screen.workarea

-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color = {
    -- main colors
    main = "#02606D",
    gray = "#575757",
    bg = "#161616",
    bg_second = "#181818",
    wibox = "#202020",
    icon = "#a0a0a0",
    text = "#aaaaaa",
    urgent = "#B25500",
    highlight = "#e0e0e0",
    border = "#404040",

    -- secondary colors
    shadow1 = "#141414",
    shadow2 = "#313131",
    shadow3 = "#1c1c1c",
    shadow4 = "#767676",

    button = "#575757",
    pressed = "#404040",

    desktop_gray = "#404040",
    desktop_icon = "#606060"
}

-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/arch"
theme.homedir = os.getenv("HOME")

-- Main config
------------------------------------------------------------

theme.panel_height = 16 -- panel height
theme.border_width = 1 -- window border width
theme.useless_gap = 2 -- useless gap

theme.cellnum = {
    x = 96,
    y = 58
} -- grid layout property

theme.wallpaper = theme.path .. "/wallpaper/primary.png" -- wallpaper file

-- Setup parent theme settings
--------------------------------------------------------------------------------
theme:update()

-- Fonts
------------------------------------------------------------
theme.fonts = {
    main = "sans 10", -- main font
    menu = "sans 10", -- main menu font
    tooltip = "sans 10", -- tooltip font
    notify = "sans bold 10", -- redflat notify popup font
    clock = "sans bold 10", -- textclock widget font
    qlaunch = "sans bold 10", -- quick launch key label font
    -- logout = "sans bold 10", -- logout screen labels
    title = "sans bold 10", -- widget titles font
    tiny = "sans bold 10", -- smallest font for widgets
    keychain = "sans bold 10", -- key sequence tip font
    titlebar = "sans bold 10", -- client titlebar font
    logout = {
        label = "sans bold 10", -- logout option labels
        counter = "sans bold 14" -- logout counter
    },
    hotkeys = {
        main = "sans 9", -- hotkeys helper main font
        key = "mono 9", -- hotkeys helper key font (use monospace for align)
        title = "sans bold 10" -- hotkeys helper group title font
    },
    player = {
        main = "sans bold 9", -- player widget main font
        time = "sans bold 10" -- player widget current time font
    },
    -- very custom calendar fonts
    calendar = {
        clock = "Sans 12",
        date = "Sans 11",
        week_numbers = "Sans 10",
        weekdays_header = "Sans 9",
        days = "Sans 9",
        default = "Sans 8",
        focus = "Sans 10 Bold",
        controls = "Sans 11"
    }
}

theme.cairo_fonts = {
    tag = {
        font = "Sans",
        size = 10,
        face = 1
    }, -- tag widget font
    appswitcher = {
        font = "Sans",
        size = 12,
        face = 1
    }, -- appswitcher widget font
    navigator = {
        title = {
            font = "Sans",
            size = 18,
            face = 1,
            slant = 0
        }, -- window navigation title font
        main = {
            font = "Sans",
            size = 12,
            face = 1,
            slant = 0
        } -- window navigation  main font
    },
    desktop = {
        textbox = {
            font = "prototype",
            size = 9,
            face = 0
        }
    }
}

-----------------------------------------------------------------------------------------------------------------------
theme.desktop.textset = {
    font = "Belligerent Madness 5",
    spacing = 10,
    color = theme.desktop.color
}

-- Shared icons
--------------------------------------------------------------------------------
theme.icon = {
    check = theme.path .. "/common/check.svg",
    blank = theme.path .. "/common/blank.svg",
    submenu = theme.path .. "/common/submenu.svg",
    warning = theme.path .. "/common/warning.svg",
    awesome = theme.path .. "/common/awesome.svg",
    system = theme.path .. "/common/system.svg",
    mark = theme.path .. "/common/mark.svg",
    left = theme.path .. "/common/arrow_left.svg",
    right = theme.path .. "/common/arrow_right.svg",
    unknown = theme.path .. "/common/unknown.svg",
    keyboard = theme.path .. "/widget/keyboard.svg"
}

-- Main theme settings
-- Make it updatabele since it may depends on common
-----------------------------------------------------------------------------------------------------------------------
function theme:init()

    -- Service utils config
    ----------------------------------------------------------------------------------
    self.service = {}

    -- Window control mode appearance
    --------------------------------------------------------------------------------
    self.service.navigator = {
        border_width = 0, -- window placeholder border width
        gradstep = 60, -- window placeholder background stripes width
        marksize = { -- window information plate size
            width = 160, -- width
            height = 80, -- height
            r = 20 -- corner roundness
        },
        linegap = 32, -- gap between two lines on window information plate
        timeout = 1, -- highlight duration
        notify = {}, -- redflat notify style (see theme.float.notify)
        titlefont = self.cairo_fonts.navigator.title, -- first line font on window information plate
        font = self.cairo_fonts.navigator.main, -- second line font on window information plate

        -- array of hot key marks for window placeholders
        num = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "F1", "F3", "F4", "F5"},

        -- colors
        color = {
            border = self.color.main, -- window placeholder border color
            mark = self.color.gray, -- window information plate background color
            text = self.color.wibox, -- window information plate text color
            fbg1 = self.color.main .. "40", -- first background color for focused window placeholder
            fbg2 = self.color.main .. "20", -- second background color for focused window placeholder
            hbg1 = self.color.urgent .. "40", -- first background color for highlighted window placeholder
            hbg2 = self.color.urgent .. "20", -- second background color for highlighted window placeholder
            bg1 = self.color.gray .. "40", -- first background color for window placeholder
            bg2 = self.color.gray .. "20" -- second background color for window placeholder
        }
    }

    -- layout hotkeys helper settings
    self.service.navigator.keytip = {}

    -- this one used as fallback when style for certain layout missed
    self.service.navigator.keytip["base"] = {
        geometry = {
            width = 600
        },
        exit = true
    }

    -- styles for certain layouts
    self.service.navigator.keytip["fairv"] = {
        geometry = {
            width = 600
        },
        exit = true
    }
    self.service.navigator.keytip["fairh"] = self.service.navigator.keytip["fairv"]
    self.service.navigator.keytip["spiral"] = self.service.navigator.keytip["fairv"]
    self.service.navigator.keytip["dwindle"] = self.service.navigator.keytip["fairv"]

    self.service.navigator.keytip["tile"] = {
        geometry = {
            width = 600
        },
        exit = true
    }
    self.service.navigator.keytip["tileleft"] = self.service.navigator.keytip["tile"]
    self.service.navigator.keytip["tiletop"] = self.service.navigator.keytip["tile"]
    self.service.navigator.keytip["tilebottom"] = self.service.navigator.keytip["tile"]

    self.service.navigator.keytip["cornernw"] = {
        geometry = {
            width = 600
        },
        exit = true
    }
    self.service.navigator.keytip["cornerne"] = self.service.navigator.keytip["cornernw"]
    self.service.navigator.keytip["cornerse"] = self.service.navigator.keytip["cornernw"]
    self.service.navigator.keytip["cornersw"] = self.service.navigator.keytip["cornernw"]

    self.service.navigator.keytip["magnifier"] = {
        geometry = {
            width = 600
        },
        exit = true
    }

    self.service.navigator.keytip["grid"] = {
        geometry = {
            width = 1400
        },
        column = 2,
        exit = true
    }
    self.service.navigator.keytip["usermap"] = {
        geometry = {
            width = 1400
        },
        column = 2,
        exit = true
    }

    -- Log out screen
    --------------------------------------------------------------------------------
    self.service.logout = {
        button_size = {
            width = 128,
            height = 128
        },
        icon_margin = 22,
        text_margin = 18,
        button_spacing = 64,
        counter_top_margin = 800,
        label_font = self.fonts.logout.label,
        counter_font = self.fonts.logout.counter,
        keytip = {
            geometry = {
                width = 400
            }
        },
        graceful_shutdown = true,
        double_key_activation = true,
        client_kill_timeout = 5,
        icons = {},
        color = self.color -- colors (main used)
    }

    -- Desktop file parser
    --------------------------------------------------------------------------------
    self.service.dfparser = {
        -- list of path to check desktop files
        desktop_file_dirs = {'/usr/share/applications/', '/usr/local/share/applications/', '~/.local/share/applications'},
        -- icon theme settings
        icons = {
            theme = nil, -- user icon theme path
            -- theme         = "/usr/share/icons/ACYLS", -- for example
            df_icon = self.icon.system, -- default (fallback) icon
            custom_only = false, -- use icons from user theme (no system fallback like 'hicolor' allowed) only
            scalable_only = false -- use vector(svg) icons (no raster icons allowed) only
        },
        wm_name = nil -- window manager name
    }

    -- Menu config
    --------------------------------------------------------------------------------
    self.menu = {
        border_width = 4, -- menu border width
        screen_gap = self.useless_gap + self.border_width, -- minimal space from screen edge on placement
        height = 24, -- menu item height
        width = 250, -- menu item width
        icon_margin = {8, 8, 8, 8}, -- space around left icon in menu item
        ricon_margin = {9, 9, 9, 9}, -- space around right icon in menu item
        nohide = false, -- do not hide menu after item activation
        auto_expand = true, -- show submenu on item selection (without item activation)
        auto_hotkey = false, -- automatically set hotkeys for all menu items
        select_first = true, -- auto select first item when menu shown
        hide_timeout = 1, -- auto hide timeout (auto hide disables if this set to 0)
        font = self.fonts.menu, -- menu font
        submenu_icon = self.icon.submenu, -- icon for submenu items
        keytip = {
            geometry = {
                width = 400
            }
        }, -- hotkeys helper settings
        shape = nil, -- wibox shape
        action_on_release = false, -- active menu item on mouse release instead of press
        svg_scale = {false, false} -- use vector scaling for left, right icons in menu item
    }

    self.menu.color = {
        border = self.color.wibox, -- menu border color
        text = self.color.text, -- menu text color
        highlight = self.color.highlight, -- menu text and icons color for selected item
        main = self.color.main, -- menu selection color
        wibox = self.color.wibox, -- menu background color
        submenu_icon = self.color.icon, -- submenu icon color
        right_icon = nil, -- right icon color in menu item
        left_icon = nil -- left icon color in menu item
    }

    -- Gauge (various elements that used as component for other widgets) style
    --------------------------------------------------------------------------------
    self.gauge = {
        tag = {},
        task = {},
        icon = {},
        audio = {},
        monitor = {},
        graph = {}
    }

    -- Plain progressbar element
    ------------------------------------------------------------
    self.gauge.graph.bar = {
        color = self.color -- colors (main used)
    }

    -- Plain monitor (label and progressbar below)
    --------------------------------------------------------------
    self.gauge.monitor.plain = {
        width = 50, -- widget width
        font = self.cairo_fonts.tag, -- widget font
        text_shift = 19, -- shift from upper border of widget to lower border of text
        label = "MON", -- widget text
        step = 0.05, -- progressbar painting step
        line = {
            height = 4,
            y = 27
        }, -- progressbar style
        color = self.color -- colors (main used)
    }

    -- Simple monitor with sigle vertical dashed progressbar
    ------------------------------------------------------------
    self.gauge.monitor.dash = {
        width = 10, -- widget width
        color = self.color, -- colors (main used)

        -- progressbar line style
        line = {
            num = 3, -- number of chunks in progressbar
            height = 3 -- height of progressbar chunk
        }
    }

    -- Icon indicator (decoration in some panel widgets)
    ------------------------------------------------------------
    self.gauge.icon.single = {
        icon = self.icon.system, -- default icon
        is_vertical = false, -- use vertical gradient (horizontal if false)
        step = 0.02, -- icon painting step
        color = self.color -- colors (main used)
    }

    -- Double icon indicator
    --------------------------------------------------------------
    self.gauge.icon.double = {
        icon1 = self.icon.system, -- first icon
        icon2 = self.icon.system, -- second icon
        is_vertical = true, -- use vertical gradient (horizontal if false)
        igap = 4, -- gap between icons
        step = 0.02, -- icon painting step
        color = self.color -- colors (main used)
    }

    -- Double value monitor (double progressbar with icon)
    --------------------------------------------------------------
    self.gauge.monitor.double = {
        icon = self.icon.system, -- default icon
        width = 50, -- widget width
        dmargin = {3, 0, 0, 0}, -- margins around progressbar area
        color = self.color, -- colors (main used)

        -- progressbar style
        line = {
            width = 3, -- progressbar height
            v_gap = 3, -- space between progressbar
            gap = 4, -- gap between progressbar dashes
            num = 5 -- number of progressbar dashes
        }
    }

    -- Separator (decoration used on panel, menu and some other widgets)
    ------------------------------------------------------------
    self.gauge.separator = {
        marginv = {2, 2, 4, 4}, -- margins for vertical separator
        marginh = {6, 6, 3, 3}, -- margins for horizontal separator
        color = self.color -- color (secondary used)
    }

    -- Step like dash bar (user for volume widgets)
    ------------------------------------------------------------
    self.gauge.graph.dash = {
        bar = {
            width = 4, -- dash element width
            num = 10 -- number of dash elements
        },
        color = self.color -- color (main used)
    }

    -- Volume indicator
    ------------------------------------------------------------
    self.gauge.audio.blue = {
        width = 75, -- widget width
        dmargin = {0, 0, 5, 5}, -- margins around dash area
        icon = theme.path .. "/widget/audio.svg", -- volume icon

        -- colors
        color = {
            icon = self.color.icon,
            mute = self.color.urgent
        },

        -- dash style
        dash = {
            plain = true,
            bar = {
                num = 10,
                width = 3
            }
        }
    }

    -- Dotcount (used in minitray widget)
    ------------------------------------------------------------
    self.gauge.graph.dots = {
        column_num = {3, 5}, -- amount of dot columns (min/max)
        row_num = 3, -- amount of dot rows
        dot_size = 3, -- dots size
        dot_gap_h = 2, -- horizontal gap between dot (with columns number it'll define widget width)
        color = self.color -- colors (main used)
    }

    -- Circle shaped monitor
    --------------------------------------------------------------
    self.gauge.monitor.circle = {
        width = 32, -- widget width
        line_width = 4, -- width of circle
        iradius = 5, -- radius for center point
        radius = 11, -- circle radius
        step = 0.05, -- circle painting step
        color = self.color -- colors (main used)
    }

    -- Tag (base element of taglist)
    ------------------------------------------------------------
    self.gauge.tag.orange = {
        width = 38, -- widget width
        line_width = self.gauge.monitor.circle.line_width, -- width of arcs
        iradius = self.gauge.monitor.circle.iradius, -- radius for center point
        radius = self.gauge.monitor.circle.radius, -- arcs radius
        cgap = 0.314, -- gap between arcs in radians
        min_sections = 1, -- minimal amount of arcs
        show_min = false, -- indicate minimized apps by color
        text = false, -- replace middle circle by text
        font = self.cairo_fonts.tag, -- font for text
        color = self.color -- colors (main used)
    }

    self.gauge.tag.ruby = {
        width = 30, -- widget width
        color = self.color, -- colors (main used)

        -- tag state mark
        base = {
            pad = 5, -- left/right padding
            height = 9, -- mark height
            thickness = 2 -- mark lines thickness
        },

        -- client focus mark
        mark = {
            pad = 10, -- left/right padding
            height = 3 -- mark height
        }
    }

    self.gauge.tag.blue = {
        width = 103, -- widget width
        show_min = false, -- indicate minimized apps by color
        text_shift = 20, -- shift from upper border of widget to lower border of text
        color = self.color, -- colors (main used)
        font = self.cairo_fonts.tag, -- font

        -- apps indicator
        point = {
            width = 50, -- apps indicator total width
            height = 3, -- apps indicator total height
            gap = 27, -- shift from upper border of widget to apps indicator
            dx = 5 -- gap between apps indicator parts
        }
    }

    self.gauge.tag.red = {
        width = 80, -- widget width
        text_shift = 19, -- shift from upper border of widget to lower border of text
        font = self.cairo_fonts.tag, -- font
        show_counter = true, -- visible/hidden apps counter
        color = self.color, -- colors (main used)

        -- apps counter
        counter = {
            size = 12, -- counter font size
            margin = 2, -- margin around counter
            coord = {40, 28} -- counter position
        },

        -- functions for state marks
        marks = nil,

        -- geometry for state marks
        geometry = {
            active = {
                height = 4,
                y = 27
            }, -- active tag mark
            focus = {
                x = 5,
                y = 7,
                width = 10,
                height = 12
            }, -- focused tag mark
            occupied = {
                x = 68,
                y = 7,
                width = 8,
                height = 12
            } -- occupied tag mark
        }
    }

    self.gauge.tag.green = {
        width = 44, -- widget width
        margin = {0, 0, 8, 8}, -- margin around tag icon
        icon = nil, -- layouts icon list (will be defined below)
        color = self.color -- colors (main used)
    }

    -- Task (base element of tasklist)
    ------------------------------------------------------------

    -- the same structure as blue tag
    self.gauge.task.blue = {
        width = 70,
        show_min = true,
        text_shift = 12,
        color = self.color,
        font = self.cairo_fonts.tag,
        point = {
            width = 70,
            height = 2,
            gap = 14,
            dx = 5
        }
    }

    self.gauge.task.ruby = {
        width = 76,
        text_shift = 26,
        color = self.color,
        font = self.cairo_fonts.tag,

        point = {
            size = 4,
            space = 4,
            gap = 2
        },
        underline = {
            height = 10,
            thickness = 3,
            gap = 34,
            dh = 0
        }
    }

    self.gauge.task.red = {
        width = 40, -- widget width
        text_shift = 19, -- shift from upper border of widget to lower border of text
        font = self.cairo_fonts.tag, -- font
        line = {
            height = 4,
            y = 27
        }, -- application state indicator
        color = self.color, -- colors (main used)

        -- applications counter
        counter = {
            size = 12, -- counter font size
            margin = 2 -- margin around counter
        }
    }

    self.gauge.task.green = {
        width = 40, -- widget width
        df_icon = self.icon.system, -- fallback icon
        margin = {0, 0, 2, 2}, -- margin around icon
        color = self.color -- colors (main used)
    }

    -- Panel widgets
    --------------------------------------------------------------------------------
    self.widget = {}

    -- individual margins for panel widgets
    ------------------------------------------------------------
    self.widget.wrapper = {
        cpu = {4, 0, 2, 2},
        ram = {0, 0, 2, 2},
        battery = {0, 4, 2, 2},
        keyboard = {4, 4, 2, 2},
        layoutbox = {4, 4, 2, 2},
        mainmenu = {4, 4, 2, 2},
        textclock = {4, 4, 2, 2},
        taglist = {0, 0, 2, 2},
        tray = {4, 4, 2, 2},
        tasklist = {4, 4, 0, 0} -- centering tasklist widget
    }

    -- Textclock
    ------------------------------------------------------------
    self.widget.textclock = {
        font = self.fonts.clock, -- font
        tooltip = {}, -- redflat tooltip style (see theme.float.tooltip)
        color = {
            text = self.color.icon
        } -- colors
    }

    -- Binary clock
    ------------------------------------------------------------
    self.widget.binclock = {
        width = 52, -- widget width
        tooltip = {}, -- redflat tooltip style (see theme.float.tooltip)
        dot = {
            size = 5
        }, -- mark size
        color = self.color -- colors (main used)
    }

    -- Battery indicator
    ------------------------------------------------------------
    self.widget.battery = {
        timeout = 30, -- update timeout
        notify = {}, -- redflat notify style (see theme.float.notify)

        -- notification levels
        levels = {0.05, 0.1, 0.15, 0.20, 0.25}
    }

    -- Minitray
    ------------------------------------------------------------
    self.widget.minitray = {
        dotcount = {}, -- redflat dotcount style (see theme.gauge.graph.dots)
        border_width = 0, -- floating widget border width
        geometry = {
            height = 24
        }, -- floating widget size
        screen_gap = 2 * self.useless_gap, -- minimal space from screen edge on floating widget placement
        shape = nil, -- wibox shape
        color = {
            wibox = self.color.wibox,
            border = self.color.wibox
        },

        -- function to define floating widget position when shown
        set_position = function(wibox)
            local geometry = {
                x = mouse.screen.workarea.x + mouse.screen.workarea.width,
                y = mouse.screen.workarea.y + mouse.screen.workarea.height
            }
            wibox:geometry(geometry)
        end
    }

    -- Pulseaudio volume control
    ------------------------------------------------------------
    self.widget.pulse = {
        notify = {}, -- redflat notify style (see theme.float.notify)
        widget = nil, -- audio gauge (usually setted by rc file)
        audio = {} -- style for gauge
    }

    -- Keyboard layout indicator
    ------------------------------------------------------------
    self.widget.keyboard = {
        icon = self.icon.keyboard, -- widget icon
        micon = self.icon, -- some common menu icons

        -- list of colors associated with keyboard layouts
        layout_color = {self.color.icon, self.color.main},

        -- redflat menu style (see theme.menu)
        menu = {
            width = 180,
            color = {
                right_icon = self.color.icon
            },
            nohide = true
        }
    }

    -- Mail indicator
    ------------------------------------------------------------
    self.widget.mail = {
        icon = self.icon.system, -- widget icon
        notify = {}, -- redflat notify style (see theme.float.notify)
        need_notify = true, -- show notification on new mail
        firstrun = true, -- check mail on wm start/restart
        color = self.color -- colors (main used)
    }

    -- System updates indicator
    ------------------------------------------------------------
    self.widget.updates = {
        icon = self.icon.system, -- widget icon
        notify = {}, -- redflat notify style (see theme.float.notify)
        need_notify = true, -- show notification on updates
        firstrun = true, -- check updates on wm start/restart
        color = self.color, -- colors (main used)

        -- redflat key tip settings
        keytip = {
            geometry = {
                width = 400
            }
        },

        -- tooltips style
        tooltip = {
            base = {},
            state = {
                timeout = 1
            }
        },

        -- wibox style settings
        wibox = {
            geometry = {
                width = 250,
                height = 160
            }, -- widget size
            border_width = 0, -- widget border width
            title_font = self.fonts.title, -- widget title font
            tip_font = self.fonts.tiny, -- widget state tip font
            separator = {}, -- redflat separator style (see theme.gauge.separator)
            shape = nil, -- wibox shape
            set_position = nil, -- set_position

            -- wibox icons
            icon = {
                package = self.icon.system, -- main wibox image
                close = self.base .. "/titlebar/close.svg", -- close button
                normal = self.icon.system, -- regular notification
                daily = self.icon.system, -- defer notification for day
                weekly = self.icon.system, -- defer notification for 7 day
                silent = self.icon.system -- disable notification
            },

            -- widget areas height
            height = {
                title = 28, -- titlebar
                state = 34 -- control icon area
            },

            -- widget element margins
            margin = {
                close = {0, 0, 6, 6}, -- close button
                title = {16 + 2 * 6, 16, 4, 0}, -- titlebar area
                state = {4, 4, 4, 12}, -- control icon area
                image = {0, 0, 2, 4} -- main wibox image area
            }
        }
    }

    -- Layoutbox
    ------------------------------------------------------------
    self.widget.layoutbox = {
        micon = self.icon, -- some common menu icons (used: 'blank', 'check')
        color = self.color -- colors (main used)
    }

    -- layout icons
    self.widget.layoutbox.icon = {
        floating = self.base .. "/layouts/floating.svg",
        max = self.base .. "/layouts/max.svg",
        fullscreen = self.base .. "/layouts/fullscreen.svg",
        tilebottom = self.base .. "/layouts/tilebottom.svg",
        tileleft = self.base .. "/layouts/tileleft.svg",
        tile = self.base .. "/layouts/tile.svg",
        tiletop = self.base .. "/layouts/tiletop.svg",
        fairv = self.base .. "/layouts/fair.svg",
        fairh = self.base .. "/layouts/fair.svg",
        grid = self.base .. "/layouts/grid.svg",
        usermap = self.base .. "/layouts/map.svg",
        magnifier = self.base .. "/layouts/magnifier.svg",
        spiral = self.base .. "/layouts/spiral.svg",
        cornerne = self.base .. "/layouts/cornerne.svg",
        cornernw = self.base .. "/layouts/cornernw.svg",
        cornerse = self.base .. "/layouts/cornerse.svg",
        cornersw = self.base .. "/layouts/cornersw.svg",
        unknown = self.icon.unknown -- this one used as fallback
    }

    -- redflat menu style (see theme.menu)
    self.widget.layoutbox.menu = {
        icon_margin = {8, 12, 8, 8},
        width = 260,
        auto_hotkey = true,
        nohide = false,
        color = {
            right_icon = self.color.icon,
            left_icon = self.color.icon
        }
    }

    -- human readable aliases for layout names (displayed in menu and tooltip)
    self.widget.layoutbox.name_alias = {
        floating = "Floating",
        fullscreen = "Fullscreen",
        max = "Maximized",
        grid = "Grid",
        usermap = "User Map",
        tile = "Right Tile",
        fairv = "Fair Tile",
        tileleft = "Left Tile",
        tiletop = "Top Tile",
        tilebottom = "Bottom Tile",
        magnifier = "Magnifier",
        spiral = "Spiral",
        cornerne = "Corner NE",
        cornernw = "Corner NW",
        cornerse = "Corner SE",
        cornersw = "Corner SW"
    }

    -- green tag icons
    self.gauge.tag.green.icon = self.widget.layoutbox.icon

    -- Tasklist
    --------------------------------------------------------------

    -- main settings
    self.widget.tasklist = {
        custom_icon = false, -- use custom applications icons (not every gauge task widget support icons)
        iconnames = {}, -- icon name aliases for custom applications icons
        widget = nil, -- task gauge widget (usually setted by rc file)
        width = 40, -- width of task element in tasklist
        char_digit = 4, -- number of characters in task element text
        need_group = true, -- group application instances into one task element
        parser = {}, -- redlat desktop file parser settings (see theme.service.dfparser)
        task_margin = {5, 5, 0, 0}, -- margins around task element
        task = self.gauge.task.blue -- style for task gauge widget
    }

    -- menu settings
    self.widget.tasklist.winmenu = {
        micon = self.icon, -- some common menu icons
        titleline = {
            font = self.fonts.title, -- menu title height
            height = 25 -- menu title font
        },
        tagline = {
            height = 30
        }, -- tag line height
        tag_iconsize = {
            width = 16,
            height = 16
        }, -- tag line marks size
        enable_screen_switch = false, -- screen option in menu
        enable_tagline = false, -- tag marks instead of menu options
        stateline = {
            height = 30
        }, -- height of menu item with state icons
        state_iconsize = {
            width = 18,
            height = 18
        }, -- size for state icons
        layout_icon = self.widget.layoutbox.icon, -- list of layout icons
        separator = {
            marginh = {3, 3, 5, 5}
        }, -- redflat separator style (see theme.gauge.separator)
        color = self.color, -- colors (main used)

        -- main menu style (see theme.menu)
        menu = {
            width = 200,
            color = {
                right_icon = self.color.icon
            },
            ricon_margin = {9, 9, 9, 9}
        },

        -- tag action submenu style (see theme.menu)
        tagmenu = {
            width = 160,
            color = {
                right_icon = self.color.icon,
                left_icon = self.color.icon
            },
            icon_margin = {9, 9, 9, 9}
        },

        -- set which action will hide menu after activate
        hide_action = {
            min = true,
            move = true,
            max = false,
            add = false,
            floating = false,
            sticky = false,
            ontop = false,
            below = false,
            maximized = false
        }
    }

    -- menu icons
    self.widget.tasklist.winmenu.icon = {
        floating = self.base .. "/titlebar/floating.svg",
        sticky = self.base .. "/titlebar/pin.svg",
        ontop = self.base .. "/titlebar/ontop.svg",
        below = self.base .. "/titlebar/below.svg",
        close = self.base .. "/titlebar/close.svg",
        minimize = self.base .. "/titlebar/minimize.svg",
        maximized = self.base .. "/titlebar/maximized.svg",

        tag = self.icon.mark, -- tag line mark
        unknown = self.icon.unknown -- this one used as fallback
    }

    -- multiline task element tip
    self.widget.tasklist.tasktip = {
        border_width = 2, -- tip border width
        margin = {10, 10, 5, 5}, -- margins around text in tip lines
        timeout = 0.5, -- hide timeout
        shape = nil, -- wibox shape
        sl_highlight = false, -- highlight application state when it's single line tip
        color = self.color -- colors (main used)
    }

    -- task text aliases
    self.widget.tasklist.appnames = {}
    self.widget.tasklist.appnames["Firefox"] = "FIFOX"
    self.widget.tasklist.appnames["Gnome-terminal"] = "GTERM"

    -- Floating widgets
    --------------------------------------------------------------------------------
    self.float = {
        decoration = {}
    }

    -- Brightness control
    ------------------------------------------------------------
    self.float.brightness = {
        notify = {} -- redflat notify style (see theme.float.notify)
    }

    -- Client menu
    ------------------------------------------------------------
    self.float.clientmenu = {
        actionline = {
            height = 28
        }, -- height of menu item with action icons
        action_iconsize = {
            width = 18,
            height = 18
        }, -- size for action icons
        stateline = {
            height = 30
        }, -- height of menu item with state icons

        tagline = {
            height = 30
        }, -- tag line height
        tag_iconsize = {
            width = 16,
            height = 16
        }, -- tag line marks size

        -- redflat separator style(see theme.gauge.separator)
        separator = {
            marginh = {3, 3, 5, 5},
            marginv = {3, 3, 3, 3}
        },

        -- same elements as for task list menu
        icon = self.widget.tasklist.winmenu.icon,
        micon = self.widget.tasklist.winmenu.micon,
        layout_icon = self.widget.layoutbox.icon,
        menu = self.widget.tasklist.winmenu.menu,
        state_iconsize = self.widget.tasklist.winmenu.state_iconsize,
        tagmenu = self.widget.tasklist.winmenu.tagmenu,
        hide_action = self.widget.tasklist.winmenu.hide_action,
        enable_screen_switch = false,
        enable_tagline = false,
        color = self.color
    }

    -- Audio player
    ------------------------------------------------------------
    self.float.player = {
        geometry = {
            width = 490,
            height = 130
        }, -- widget size
        screen_gap = 2 * self.useless_gap, -- minimal space from screen edge on floating widget placement
        border_margin = {15, 15, 15, 15}, -- margins around widget content
        elements_margin = {15, 0, 0, 0}, -- margins around main player elements (exclude cover art)
        controls_margin = {0, 0, 14, 6}, -- margins around control player elements
        volume_margin = {0, 0, 0, 3}, -- margins around volume element
        buttons_margin = {0, 0, 3, 3}, -- margins around buttons area
        pause_margin = {12, 12, 0, 0}, -- margins around pause button
        line_height = 26, -- text lines height
        bar_width = 6, -- progressbar width
        volume_width = 50, -- volume element width
        titlefont = self.fonts.player.main, -- track font
        artistfont = self.fonts.player.main, -- artist/album font
        timefont = self.fonts.player.time, -- track progress time font
        border_width = 0, -- widget border width
        timeout = 1, -- widget update timeout
        set_position = nil, -- set_position
        shape = nil, -- wibox shape
        color = self.color, -- color (main used)

        -- volume dash style (see theme.gauge.graph.dash)
        dashcontrol = {
            color = self.color,
            bar = {
                num = 7
            }
        },

        -- progressbar style (see theme.gauge.graph.bar)
        progressbar = {
            color = self.color
        }
    }

    -- widget icons
    self.float.player.icon = {
        cover = self.base .. "/player/cover.svg",
        next_tr = self.base .. "/player/next.svg",
        prev_tr = self.base .. "/player/previous.svg",
        play = self.base .. "/player/play.svg",
        pause = self.base .. "/player/pause.svg"
    }

    -- Top processes
    ------------------------------------------------------------
    self.float.top = {
        geometry = {
            width = 460,
            height = 400
        }, -- widget size
        screen_gap = 2 * self.useless_gap, -- minimal space from screen edge on floating widget placement
        border_margin = {20, 20, 10, 0}, -- margins around widget content
        button_margin = {140, 140, 18, 18}, -- margins around kill button
        title_height = 40, -- widget title height
        border_width = 0, -- widget border width
        bottom_height = 70, -- kill button area height
        list_side_gap = 8, -- left/rigth borger margin for processes list
        title_font = self.fonts.title, -- widget title font
        timeout = 2, -- widget update timeout
        shape = nil, -- wibox shape
        color = self.color, -- color (main used)

        -- list columns width
        labels_width = {
            num = 30,
            cpu = 70,
            mem = 120
        },

        -- redflat key tip settings
        keytip = {
            geometry = {
                width = 400
            }
        },

        -- placement function
        set_position = nil
    }

    -- Application runner
    ------------------------------------------------------------
    self.float.apprunner = {
        itemnum = 6, -- number of visible items
        geometry = {
            width = 620,
            height = 480
        }, -- widget size
        border_margin = {24, 24, 24, 24}, -- margin around widget content
        icon_margin = {8, 16, 0, 0}, -- margins around widget icon
        title_height = 48, -- height of title (promt and icon) area
        prompt_height = 35, -- prompt line height
        title_icon = self.icon.system, -- widget icon
        border_width = 0, -- widget border width
        parser = {}, -- desktop file parser settings (see theme.service.dfparser)
        field = nil, -- redflat text field style(see theme.float.decoration.field)
        shape = nil, -- wibox shape
        color = self.color, -- colors (main used)

        name_font = self.fonts.title, -- application title font
        comment_font = self.fonts.main, -- application comment font
        list_text_vgap = 4, -- space between application title and comment
        list_icon_margin = {6, 12, 6, 6}, -- margins around applications icons
        dimage = self.icon.unknown, -- fallback icon for applications

        keytip = {
            geometry = {
                width = 400
            }
        } -- redflat key tip settings
    }

    -- Application switcher
    ------------------------------------------------------------
    self.float.appswitcher = {
        wibox_height = 240, -- widget height
        label_height = 28, -- height of the area with application mark(key)
        title_height = 40, -- height of widget title line (application name and tag name)
        icon_size = 96, -- size of the application icon in preview area
        preview_gap = 20, -- gap between preview areas
        shape = nil, -- wibox shape

        -- desktop file parser settings (see theme.service.dfparser)
        parser = {
            desktop_file_dirs = awful.util.table.join(self.service.dfparser.desktop_file_dirs,
                {'~/.local/share/applications-fake'})
        },

        border_margin = {10, 10, 0, 10}, -- margins around widget content
        preview_margin = {15, 15, 15, 15}, -- margins around application preview
        preview_format = 16 / 10, -- preview acpect ratio
        title_font = self.fonts.title, -- font of widget title line
        border_width = 0, -- widget border width
        update_timeout = 1 / 12, -- application preview update timeout
        min_icon_number = 4, -- this one will define the minimal widget width
        -- (widget will not shrink if number of apps items less then this)
        color = self.color, -- colors (main used)
        font = self.cairo_fonts.appswitcher, -- font of application mark(key)

        -- redflat key tip settings
        keytip = {
            geometry = {
                width = 400
            },
            exit = true
        }
    }

    -- additional color
    self.float.appswitcher.color.preview_bg = self.color.main .. "12"

    -- application marks(keys) list
    self.float.appswitcher.hotkeys = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "F2", "F3", "F4", "F5", "F6",
                                      "F7", "F8", "F9", "F10", "F11", "F12"}

    -- Quick launcher
    ------------------------------------------------------------
    self.float.qlaunch = {
        geometry = {
            width = 1400,
            height = 170
        }, -- widget size

        border_width = 0, -- widget border width
        border_margin = {5, 5, 12, 15}, -- margins around widget content
        notify = {}, -- redflat notify style (see theme.float.notify)
        shape = nil, -- wibox shape
        recoloring = false, -- apply redflat recoloring feature on application icons
        label_font = self.fonts.qlaunch, -- font of application mark(key)
        color = self.color, -- colors (main used)
        df_icon = self.icon.system, -- fallback application icon
        no_icon = self.icon.unknown, -- icon for unused application slot

        -- desktop file parser settings (see theme.service.dfparser)
        parser = {
            desktop_file_dirs = awful.util.table.join(self.service.dfparser.desktop_file_dirs,
                {'~/.local/share/applications-fake'})
        },

        appline = {
            iwidth = 140, -- application item width
            im = {5, 5, 0, 0}, -- margins around application item area
            igap = {0, 0, 5, 15}, -- margins around application icon itself (will affect icon size)
            lheight = 26 -- height of application mark(key) area
        },
        state = {
            gap = 5, -- space between application state marks
            radius = 5, -- application state mark radius
            size = 10, -- application state mark size
            height = 14 -- height of application state marks area
        },

        -- redflat key tip settings
        keytip = {
            geometry = {
                width = 600
            }
        },

        -- file to store widget data
        -- this widget is rare one which need to keep settings between sessions
        configfile = os.getenv("HOME") .. "/.cache/awesome/applist"
    }

    -- Hotkeys helper
    ------------------------------------------------------------
    self.float.hotkeys = {
        geometry = {
            width = 1200
        }, -- widget size
        border_margin = {20, 20, 8, 10}, -- margins around widget content
        border_width = 0, -- widget border width
        delim = "   ", -- text separator between key and description
        tspace = 5, -- space between lines in widget title
        is_align = true, -- align keys description (monospace font required)
        separator = {
            marginh = {0, 0, 3, 6}
        }, -- redflat separator style (see theme.gauge.separator)
        font = self.fonts.hotkeys.main, -- keys description font
        keyfont = self.fonts.hotkeys.key, -- keys font
        titlefont = self.fonts.hotkeys.title, -- widget title font
        shape = nil, -- wibox shape
        color = self.color, -- colors (main used)

        -- manual setup for expected text line heights
        -- used for auto adjust widget height
        heights = {
            key = 20, -- hotkey tip line height
            title = 22 -- group title height
        }
    }

    -- Titlebar helper
    ------------------------------------------------------------
    self.float.bartip = {
        geometry = {
            width = 260,
            height = 40
        }, -- widget size
        border_margin = {10, 10, 10, 10}, -- margins around widget content
        border_width = 0, -- widget border widthj
        font = self.fonts.title, -- widget font
        set_position = nil, -- placement function
        shape = nil, -- wibox shape
        names = {"Mini", "Plain", "Full"}, -- titlebar layout names
        color = self.color, -- colors (main used)

        -- margin around widget elements
        margin = {
            icon = {
                title = {10, 10, 8, 8},
                state = {10, 10, 8, 8}
            }
        },

        -- widget icons
        icon = {
            title = self.base .. "/titlebar/title.svg",
            active = self.base .. "/titlebar/active.svg",
            hidden = self.base .. "/titlebar/hidden.svg",
            disabled = self.base .. "/titlebar/disabled.svg",
            absent = self.base .. "/titlebar/absent.svg",
            unknown = self.icon.unknown
        },

        -- redflat key tip settings
        keytip = {
            geometry = {
                width = 540
            }
        }
    }

    -- Floating window control helper
    ------------------------------------------------------------
    self.float.control = {
        geometry = {
            width = 260,
            height = 48
        }, -- widget size
        border_margin = {10, 10, 10, 10}, -- margins around widget content
        border_width = 0, -- widget border widthj
        font = self.fonts.title, -- widget font
        steps = {1, 10, 25, 50, 200}, -- move/resize step
        default_step = 3, -- select default step by index
        onscreen = true, -- no off screen for window placement
        set_position = nil, -- widget placement function
        shape = nil, -- wibox shape
        color = self.color, -- colors (main used)

        -- margin around widget elements
        margin = {
            icon = {
                onscreen = {10, 10, 8, 8},
                mode = {10, 10, 8, 8}
            }
        },

        -- widget icons
        icon = {
            onscreen = self.icon.system,
            resize = {}
        },

        -- redflat key tip settings
        keytip = {
            geometry = {
                width = 540
            }
        }
    }

    -- Key sequence tip
    ------------------------------------------------------------
    self.float.keychain = {
        geometry = {
            width = 250,
            height = 56
        }, -- default widget size
        font = self.fonts.keychain, -- widget font
        border_width = 2, -- widget border width
        shape = nil, -- wibox shape
        color = self.color, -- colors (main used)

        -- redflat key tip settings
        keytip = {
            geometry = {
                width = 600
            },
            column = 1
        }
    }

    -- Tooltip
    ------------------------------------------------------------
    self.float.tooltip = {
        timeout = 0, -- show delay
        shape = nil, -- wibox shapea
        font = self.fonts.tooltip, -- widget font
        border_width = 2, -- widget border width
        set_position = nil, -- function to setup tooltip position when shown
        color = self.color, -- colors (main used)

        -- padding around widget content
        padding = {
            vertical = 3,
            horizontal = 6
        }
    }

    -- Floating prompt
    ------------------------------------------------------------
    self.float.prompt = {
        geometry = {
            width = 620,
            height = 120
        }, -- widget size
        border_width = 0, -- widget border width
        margin = {20, 20, 40, 40}, -- margins around widget content
        field = nil, -- redflat text field style (see theme.float.decoration.field)
        shape = nil, -- wibox shape
        naughty = {}, -- awesome notification style
        color = self.color -- colors (main used)
    }

    -- Floating calendar
    ------------------------------------------------------------
    self.float.calendar = {
        geometry = {
            width = 340,
            height = 420
        },
        margin = {20, 20, 20, 15},
        controls_margin = {0, 0, 5, 0},
        calendar_item_margin = {2, 5, 2, 2},
        spacing = {
            separator = 28,
            datetime = 5,
            controls = 5,
            calendar = 8
        },
        controls_icon_size = {
            width = 18,
            height = 18
        },
        separator = {},
        border_width = 2,
        days = {
            weeknumber = {
                fg = self.color.gray,
                bg = "transparent"
            },
            weekday = {
                fg = self.color.gray,
                bg = "transparent"
            },
            weekend = {
                fg = self.color.highlight,
                bg = self.color.gray
            },
            today = {
                fg = self.color.highlight,
                bg = self.color.main
            },
            day = {
                fg = self.color.text,
                bg = "transparent"
            },
            default = {
                fg = "white",
                bg = "transparent"
            }
        },
        fonts = self.fonts.calendar,
        icon = {
            next = self.icon.right,
            prev = self.icon.left
        },
        clock_format = "%H:%M",
        date_format = "%A, %d. %B",
        clock_refresh_seconds = 60,
        weeks_start_sunday = false,
        show_week_numbers = true,
        show_weekday_header = true,
        long_weekdays = false,
        weekday_name_replacements = {},
        -- screen_gap                = 0,
        set_position = nil,
        shape = nil,
        screen_gap = 2 * self.useless_gap, -- screen edges gap on placement
        color = self.color -- colors (main used)
    }

    -- Notify (redflat notification widget)
    ------------------------------------------------------------
    self.float.notify = {
        geometry = {
            width = 484,
            height = 106
        }, -- widget size
        screen_gap = 2 * self.useless_gap, -- screen edges gap on placement
        border_margin = {20, 20, 20, 20}, -- margins around widget content
        elements_margin = {20, 0, 10, 10}, -- margins around main elements (text and bar)
        font = self.fonts.notify, -- widget font
        icon = self.icon.warning, -- default widget icon
        border_width = 0, -- widget border width
        timeout = 5, -- hide timeout
        shape = nil, -- wibox shape
        color = self.color, -- colors (main used)

        -- progressbar is optional element used for some notifications
        bar_width = 8, -- progressbar width
        progressbar = {}, -- redflat progressbar style (see theme.gauge.graph.bar)

        -- placement function
        set_position = function(wibox)
            wibox:geometry({
                x = mouse.screen.workarea.x + mouse.screen.workarea.width,
                y = mouse.screen.workarea.y
            })
        end
    }

    -- Decoration (various elements that used as component for other widgets) style
    --------------------------------------------------------------------------------
    self.float.decoration.button = {
        color = self.color -- colors (secondary used)
    }

    self.float.decoration.field = {
        color = self.color -- colors (secondary used)
    }

    -- Titlebar
    --------------------------------------------------------------------------------
    self.titlebar = {}

    self.titlebar.base = {
        position = "top", -- titlebar position
        font = self.fonts.titlebar, -- titlebar font
        border_margin = {0, 0, 0, 4}, -- margins around titlebar active area
        color = self.color -- colors (main used)
    }

    -- application state marks settings
    self.titlebar.mark = {
        color = self.color -- colors (main used)
    }

    -- application control icon settings
    self.titlebar.icon = {
        color = self.color, -- colors (main used)

        -- icons list
        list = {
            focus = self.base .. "/titlebar/focus.svg",
            floating = self.base .. "/titlebar/floating.svg",
            ontop = self.base .. "/titlebar/ontop.svg",
            below = self.base .. "/titlebar/below.svg",
            sticky = self.base .. "/titlebar/pin.svg",
            maximized = self.base .. "/titlebar/maximized.svg",
            minimized = self.base .. "/titlebar/minimize.svg",
            close = self.base .. "/titlebar/close.svg",
            menu = self.base .. "/titlebar/menu.svg",

            unknown = self.icon.unknown -- this one used as fallback
        }
    }

    -- Desktop config
    -----------------------------------------------------------------------------------------------------------------------

    -- Desktop widgets placement
    --------------------------------------------------------------------------------
    theme.desktop.grid = {
        width = {300, 300, 300},
        height = {75, 75, 75, 75, 75},
        edge = {
            width = {30, 30},
            height = {20, 20}
        }
    }

    theme.desktop.places = {
        netspeed = {1, 1},
        ssdspeed = {2, 1},
        hddspeed = {3, 1},
        cpumem = {1, 2},
        transm = {1, 3},
        disks = {1, 4},
        thermal = {1, 5}
    }

    -- Desktop widgets
    --------------------------------------------------------------------------------
    -- individual widget settings doesn't used by redflat module
    -- but grab directly from rc-files to rewrite base style
    theme.individual.desktop = {
        speedmeter = {},
        multimeter = {},
        multiline = {},
        singleline = {}
    }

    theme.desktop.line_height = 12

    -- Lines (common part)
    theme.desktop.common.pack.lines = {
        label = {
            font = {
                font = "Noto Sans Mono Regular",
                size = 10
                -- face = 1,
                -- slant = 0
            },
            width = 88,
            draw = "by_width"
        },
        text = {
            width = 88,
            draw = "by_edges"
        },
        gap = {
            text = 2,
            label = 2
        },
        line = {
            height = theme.desktop.line_height
        }
    }

    -- Speedmeter (base widget)
    theme.desktop.speedmeter.normal = {
        label = {
            font = {
                font = "Noto Sans Mono Regular",
                size = 10,
                face = 1,
                slant = 0
            },
            height = theme.desktop.line_height
        },
        progressbar = {
            chunk = {
                width = 3,
                gap = 3
            },
            height = 3
        },
        chart = {
            bar = {
                width = 3,
                gap = 3
            },
            height = 20,
            zero_height = 3
        },
        barvalue_height = 15,
        fullchart_height = 35,
        image_gap = 10,
        images = {theme.path .. "/desktop/up.svg", theme.path .. "/desktop/down.svg"}
    }

    -- Speedmeter drive (individual widget)
    theme.individual.desktop.speedmeter.drive = {
        unit = {{"B", -1}, {"KB", 2}, {"MB", 2048}}
    }

    -- Multimeter (base widget)
    theme.desktop.multimeter = {
        upbar = {
            width = 10,
            chunk = {
                height = 15,
                num = 12,
                line = 3
            },
            shape = "plain"
        },
        height = {
            lines = 30,
            upright = 50
        },
        icon = {
            margin = {0, 20, 0, 0}
        },
        lines = {
            show = {
                label = true,
                tooltip = true,
                text = true
            },
            text        = { font = { font = "Noto Sans Mono Regular", size = 9, face = 1, slant = 0 }, width = 44 },
		    label       = { font = { font = "Noto Sans Mono Regular", size = 9, face = 1, slant = 0 } },
        }
    }

    -- Multimeter cpu and ram (individual widget)
    theme.individual.desktop.multimeter.cpumem = {
        labels = {"RAM", "SWAP"},
        icon = {
            image = theme.path .. "/desktop/cpu.svg"
        },
        upbar = {
            width = 20
        },
    }

    -- Multimeter transmission info (individual widget)
    theme.individual.desktop.multimeter.transmission = {
        labels = {"SEED", "DNLD"},
        unit = {{"KB", -1}, {"MB", 1024 ^ 1}},
        icon = {
            image = theme.path .. "/desktop/skull.svg"
        }
    }

    -- Multilines disks (individual widget)
    theme.individual.desktop.multiline.disks = {
        lines = {

            line = {
                height = theme.desktop.line_height
            },
            text = {
                font = {
                    font = "Noto Sans Mono Regular",
                    size = 9,
                    face = 1,
                    slant = 0
                },
                width = 44
            },
            label = {
                font = {
                    font = "Noto Sans Mono Regular",
                    size = 9,
                    face = 1,
                    slant = 0
                }
            },
            gap = {
                text = 10
            },
            progressbar = {
                chunk = {
                    gap = 4,
                    width = 4
                }
            },
            show = {
                text = true,
                label = true,
                tooltip = true
            }
        },
        unit = {{"KB", 1}, {"MB", 1024 ^ 1}, {"GB", 1024 ^ 2}}
    }

    -- Singleline temperature (individual widget)
    theme.individual.desktop.singleline.thermal = {
        icon = theme.path .. "/desktop/star.svg",
        unit = {{"°C", -1}}
    }

    -- Default awesome theme vars
    --------------------------------------------------------------------------------

    -- colors
    self.bg_normal = self.color.wibox
    self.bg_focus = self.color.main
    self.bg_urgent = self.color.urgent
    self.bg_minimize = self.color.gray

    self.fg_normal = self.color.text
    self.fg_focus = self.color.highlight
    self.fg_urgent = self.color.highlight
    self.fg_minimize = self.color.highlight

    self.border_normal = self.color.wibox
    self.border_focus = self.color.wibox
    self.border_marked = self.color.main

    -- font
    self.font = self.fonts.main

    -- standart awesome notification widget
    self.naughty = {}

    self.naughty.base = {
        timeout = 10,
        margin = 12,
        icon_size = 80,
        font = self.fonts.main,
        bg = self.color.wibox,
        fg = self.color.text,

        border_width = 4,
        border_color = self.color.wibox
    }

    self.naughty.normal = {
        height = self.float.notify.geometry.height,
        width = self.float.notify.geometry.width
    }

    self.naughty.low = {
        timeout = 5,
        height = self.float.notify.geometry.height,
        width = self.float.notify.geometry.width
    }

    self.naughty.critical = {
        timeout = 0,
        border_color = self.color.main
    }
end

-- End
-----------------------------------------------------------------------------------------------------------------------
theme:init()

return theme
