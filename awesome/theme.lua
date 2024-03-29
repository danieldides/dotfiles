local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
require("gears")

-- define module table
local theme = {}

-- Font
theme.font = "SF Pro Text 9"
theme.title_font = "SF Pro Display Medium 10"

-- Background
theme.bg_normal = "#1f2430"
theme.bg_dark = "#000000"
theme.bg_focus = "#151821"
theme.bg_urgent = "#ed8274"
theme.bg_minimize = "#444444"
theme.bg_systray = theme.bg_normal

-- Foreground
theme.fg_normal = "#ffffff"
theme.fg_focus = "#e4e4e4"
theme.fg_urgent = "#ffffff"
theme.fg_minimize = "#ffffff"

-- Window Gap Distance
theme.useless_gap = dpi(2)

-- Show Gaps if Only One Client is Visible
theme.gap_single_client = true

-- Window Borders
theme.border_width = dpi(0)
theme.border_normal = theme.bg_normal
theme.border_focus = "#ff8a65"
theme.border_marked = theme.fg_urgent

-- Taglist
theme.taglist_bg_empty = theme.bg_normal
theme.taglist_bg_occupied = "#ffffff1a"
theme.taglist_bg_urgent = "#e91e6399"
theme.taglist_bg_focus = theme.bg_focus

-- Tasklist
theme.tasklist_font = theme.font

theme.tasklist_bg_normal = theme.bg_normal
theme.tasklist_bg_focus = theme.bg_focus
theme.tasklist_bg_urgent = theme.bg_urgent

theme.tasklist_fg_focus = theme.fg_focus
theme.tasklist_fg_urgent = theme.fg_urgent
theme.tasklist_fg_normal = theme.fg_normal

-- Panel Sizing
theme.left_panel_width = dpi(55)
theme.top_panel_height = dpi(26)

-- Notification Sizing
theme.notification_max_width = dpi(350)

-- Titlebars
theme.titlebar_bg_focus = "#1f252a"
theme.titlebar_bg_normal = "#1f252a"


theme.titlebar_close_button_normal = "~/.config/awesome/icons/titlebar/inactive.png"

theme.titlebar_close_button_normal = "~/.config/awesome/icons/titlebar/inactive.png"
theme.titlebar_close_button_focus  = "~/.config/awesome/icons/titlebar/close.png"

theme.titlebar_minimize_button_normal = "~/.config/awesome/icons/titlebar/inactive.png"
theme.titlebar_minimize_button_focus  = "~/.config/awesome/icons/titlebar/minimize.png"

theme.titlebar_ontop_button_normal_inactive = "~/.config/awesome/icons/titlebar/inactive.png"
theme.titlebar_ontop_button_focus_inactive  = "~/.config/awesome/icons/titlebar/ontop.png"
theme.titlebar_ontop_button_normal_active = "~/.config/awesome/icons/titlebar/inactive.png"
theme.titlebar_ontop_button_focus_active  = "~/.config/awesome/icons/titlebar/ontop.png"

theme.titlebar_sticky_button_normal_inactive = "~/.config/awesome/icons/titlebar/inactive.png"
theme.titlebar_sticky_button_focus_inactive  = "~/.config/awesome/icons/titlebar/sticky.png"
theme.titlebar_sticky_button_normal_active = "~/.config/awesome/icons/titlebar/inactive.png"
theme.titlebar_sticky_button_focus_active  = "~/.config/awesome/icons/titlebar/sticky.png"

theme.titlebar_floating_button_normal_inactive = "~/.config/awesome/icons/titlebar/inactive.png"
theme.titlebar_floating_button_focus_inactive  = "~/.config/awesome/icons/titlebar/floating.png"
theme.titlebar_floating_button_normal_active = "~/.config/awesome/icons/titlebar/inactive.png"
theme.titlebar_floating_button_focus_active  = "~/.config/awesome/icons/titlebar/floating.png"

theme.titlebar_maximized_button_normal_inactive = "~/.config/awesome/icons/titlebar/inactive.png"
theme.titlebar_maximized_button_focus_inactive  = "~/.config/awesome/icons/titlebar/maximize.png"
theme.titlebar_maximized_button_normal_active = "~/.config/awesome/icons/titlebar/inactive.png"
theme.titlebar_maximized_button_focus_active  = "~/.config/awesome/icons/titlebar/maximize.png"

-- You can use your own layout icons like this:
theme.layout_tile = "~/.config/awesome/icons/layouts/view-quilt.png"
theme.layout_floating = "~/.config/awesome/icons/layouts/view-float.png"
theme.layout_max = "~/.config/awesome/icons/layouts/arrow-expand-all.png"

theme.icon_theme = "Materia-light"

-- return theme
return theme
