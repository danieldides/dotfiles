-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Import theme
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

-- Import Keybinds
local keys = require("keys")
root.keys(keys.globalkeys)
root.buttons(keys.desktopbuttons)

-- Import rules
local create_rules = require("rules").create
awful.rules.rules = create_rules(keys.clientkeys, keys.clientbuttons)


-- Define tag layouts
awful.layout.layouts = {
    awful.layout.suit.tile, awful.layout.suit.floating, awful.layout.suit.max
}

-- Import tag settings
local tags = require("tags")

-- Import panels
local top_panel = require("components.top-panel")

-- Import notification appearance
require("components.notifications")

-- Import titlebar
require("components.titlebars")


-- Set up each screen (add tags & panels)
awful.screen.connect_for_each_screen(function(s)
    awful.tag({"1", "2", "3", "4", "5", "6", "7", "8", "9"}, s,
              awful.layout.layouts[1])

    -- Only add the left panel on the primary screen
    -- if s.index == 1 then
    --    left_panel.create(s)
    -- end

    -- Add the top panel to every screen
    top_panel.create(s)
end)

-- remove gaps if layout is set to max
tag.connect_signal('property::layout', function(t)
    local current_layout = awful.tag.getproperty(t, 'layout')
    if (current_layout == awful.layout.suit.max) then
        t.gap = 0
    else
        t.gap = beautiful.useless_gap
    end
end)

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the window as a slave (put it at the end of others instead of setting it as master)
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and
        not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("property::floating", function(c)
    if c.floating then
        awful.titlebar.show(c)
    else
        awful.titlebar.hide(c)
    end
end) -- END EDIT --

-- Autofocus a new client when previously focused one is closed
require("awful.autofocus")

collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
