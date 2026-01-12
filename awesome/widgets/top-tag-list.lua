--      ████████╗ █████╗  ██████╗     ██╗     ██╗███████╗████████╗
--      ╚══██╔══╝██╔══██╗██╔════╝     ██║     ██║██╔════╝╚══██╔══╝
--         ██║   ███████║██║  ███╗    ██║     ██║███████╗   ██║
--         ██║   ██╔══██║██║   ██║    ██║     ██║╚════██║   ██║
--         ██║   ██║  ██║╚██████╔╝    ███████╗██║███████║   ██║
--         ╚═╝   ╚═╝  ╚═╝ ╚═════╝     ╚══════╝╚═╝╚══════╝   ╚═╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local modkey = require('keys').modkey

-- define module table
local tag_list = {}

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t)
								if client.focus then
									client.focus:move_to_tag(t)
								end
							end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
								if client.focus then
									client.focus:toggle_tag(t)
								end
							end),
	awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)


tag_list.create = function(s)
	return awful.widget.taglist(
		s, awful.widget.taglist.filter.all,
		taglist_buttons
	)
end


return tag_list
