local awful = require("awful")
local filesystem = require("gears.filesystem")

-- define module table
local apps = {}

-- define default apps
apps.default = {
   terminal = "alacritty",
   launcher = "rofi -normal-window -modi drun -show drun",
   lock = "dm-tool lock",
   screenshot = "scrot -e 'mv $f ~/Pictures/screenshots/ 2>/dev/null'",
   screenshot_box = "scrot -es 'mv $f ~/Pictures/screenshots/ 2>/dev/null'",
   filebrowser = "thunar"
}

-- List of apps to start once on start-up
local run_on_start_up = {
   "picom --config /home/daniel.config/picom.conf",
   "unclutter",
   "nm-applet",
   "blueman-applet",
   "xfce4-power-manager",
   "redshift-gtk",
   "udiskie",
   "thunar --daemon"
}

-- Run all the apps listed in run_on_start_up
function apps.autostart()
   for _, app in ipairs(run_on_start_up) do
      local findme = app
      local firstspace = app:find(" ")
      if firstspace then
         findme = app:sub(0, firstspace - 1)
      end
         awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, app), false)
   end
end

return apps
