-------------------------------------------------
-- Volume Arc Widget for Awesome Window Manager
-- Shows the current volume level
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/volumearc-widget

-- @author Pavel Makhov
-- @copyright 2018 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local beautiful = require("beautiful")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")

local PATH_TO_ICON = "/usr/share/icons/Arc/devices/16/harddrive.png"

local widget = {}

local function worker(args)

    local args = args or {}

    local main_color = args.main_color or beautiful.fg_color
    local mute_color = args.mute_color or beautiful.fg_urgent
    local path_to_icon = args.path_to_icon or PATH_TO_ICON
    local thickness = args.thickness or 2
    local height = args.height or 18

    local icon = {
        id = "icon",
        image = path_to_icon,
        resize = true,
        widget = wibox.widget.imagebox,
    }

    local fsarc = wibox.widget {
        icon,
        max_value = 1,
        thickness = thickness,
        start_angle = 4.71238898, -- 2pi*3/4
        forced_height = height,
        forced_width = height,
        bg = "#ffffff11",
        paddings = 2,
        widget = wibox.container.arcchart
    }

    local update_graphic = function(widget, stdout, _, _, _)
			local _,_,_,_,pfull  = string.match(stdout, "(/dev/%w+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
			pfull = tonumber(string.format("% 3d", pfull))
			widget.value = pfull / 100;
    end

    fsarc:connect_signal("button::press", function(_, _, _, button)
        spawn.easy_async('df', function(stdout, stderr, exitreason, exitcode)
            update_graphic(fsarc, stdout, stderr, exitreason, exitcode)
        end)
    end)

    watch('df /', 1, update_graphic, fsarc)

    return fsarc
end

return setmetatable(widget, { __call = function(_, ...) return worker(...) end })
