#!/usr/bin/env lua

local Cmds = {
	vol_up      = 'pactl set-sink-volume @DEFAULT_SINK@ +10%',
	vol_down    = 'pactl set-sink-volume @DEFAULT_SINK@ -10%',
	mute        = 'pactl set-sink-mute   @DEFAULT_SINK@ toggle',
	unmute      = 'pactl set-sink-mute   @DEFAULT_SINK@ toggle',
	scr_lock    = 'light-locker-command --lock',
	scr_lock_on = 'light-locker --lock-on-suspend --lock-on-lid',
	scr_cap     = 'import -window root ~/Pictures/$(date +%Y%m%dT%H%M%S).png',
	scr_cap_sel = 'import ~/Pictures/$(date +%Y%m%dT%H%M%S).png',
	win_left    = 'xdotool getactivewindow windowmove 03% 02% windowsize 48% 92%',
	win_right   = 'xdotool getactivewindow windowmove 52% 02% windowsize 48% 92%',
	win_max     = 'wmctrl -r :ACTIVE: -b    add,maximized_vert,maximized_horz',
	win_unmax   = 'wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz',
	win_big     = 'xdotool getactivewindow windowmove 04% 04% windowsize 92% 92%',
	win_small   = 'xdotool getactivewindow windowmove 20% 20% windowsize 70% 50%'
}

local Fn = {}
function Fn:cmd(key)
	local h = io.popen(Cmds[key])
	h:close()
end

local fn = Fn[arg[1]]
if fn == nil then
	print('huh!')
else
	fn(fn, arg[2])
end
