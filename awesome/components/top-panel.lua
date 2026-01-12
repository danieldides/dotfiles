local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

-- import widgets
local task_list = require("widgets.task-list")
local tag_list = require("widgets.top-tag-list")

-- define module table
local top_panel = {}

top_panel.create = function(s)
    local panel = awful.wibar({
        screen = s,
        position = "top",
        ontop = true,
        height = beautiful.top_panel_height,
        width = s.geometry.width
    })

    panel:setup{
        expand = "none",
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            tag_list.create(s),
            task_list.create(s)
        },
        {
            require("widgets.calendar"),
            layout = wibox.layout.fixed.horizontal
        },
        {
            layout = wibox.layout.fixed.horizontal,
            wibox.layout.margin(wibox.widget.systray(), 0, 0, 3, 3),
            apw,
            require("widgets.layout-box")
        }
    }

    -- hide panel when client is fullscreen
    client.connect_signal('property::fullscreen',
                          function(c) panel.visible = not c.fullscreen end)
end

return top_panel
