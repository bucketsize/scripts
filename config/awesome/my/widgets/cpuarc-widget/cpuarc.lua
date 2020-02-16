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
local CMD = [[bash -c "cat /proc/stat | grep cpu | head -1"]]

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

    local wiarc = wibox.widget {
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

    local update_graphic = function(widget, stdout, stderr, _, _)

			print('->>' .. stdout)
			print('->>' .. stderr)

			local name, user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice =
				string.match(stdout, '(%w+)%s+(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)')
			local total = user + nice + system + idle + iowait + irq + softirq + steal
			local cpu = (total - idle) / total
			widget.value = cpu;
    end

    wiarc:connect_signal("button::press", function(_, _, _, button)
        spawn.easy_async(CMD, function(stdout, stderr, exitreason, exitcode)
            update_graphic(wiarc, stdout, stderr, exitreason, exitcode)
        end)
    end)

    watch(CMD, 1, update_graphic, wiarc)

    return wiarc
end

return setmetatable(widget, { __call = function(_, ...) return worker(...) end })
