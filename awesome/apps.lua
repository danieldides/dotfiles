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

return apps
