-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
-- Widget and layout library
local wibox = require("wibox")
-- DPI handling
local dpi = require("beautiful").xresources.apply_dpi

local bg_default = "#e8e8e7"
local bg_color = "#880000"
local fg_focus_color = "#00FFFF"
local fg_normal_color = "#0000FF"

local buttons = gears.table.join(awful.button({}, 1, function()
    client.focus = e
    c:raise()
    awful.mouse.client.move(c)
end), awful.button({}, 3, function()
    client.focus = c
    c:raise()
    awful.mouse.client.resize(c)
end))

-- Add a titlebar
client.connect_signal("request::titlebars", function(c)
    local base_color = bg_default

    -- Set titlebar colors
    local titlebar = awful.titlebar(c, {
        -- size = dpi(32),
        size = 24
    })

    titlebar:setup{
        { -- Left
            layout = wibox.layout.fixed.horizontal(),
            awful.titlebar.widget.closebutton(c),
            awful.titlebar.widget.minimizebutton(c),
            awful.titlebar.widget.maximizedbutton(c)
        },
        { -- Middle
            { -- Title
                align = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            layout = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)
