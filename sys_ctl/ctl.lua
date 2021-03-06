#!/usr/bin/env lua

package.path = package.path
	.. '?.lua;'
	.. 'scripts/lib/?.lua;'
	.. 'scripts/sys_mon/?.lua;'

local Sh = require('shell')
local Pr = require('process')

function exec(cmd)
	local h = io.popen(cmd)
	h:close()
end

local Cmds = {
	vol_up      = 'pactl set-sink-volume @DEFAULT_SINK@ +10%',
	vol_down    = 'pactl set-sink-volume @DEFAULT_SINK@ -10%',
	vol_mute    = 'pactl set-sink-mute   @DEFAULT_SINK@ toggle',
	vol_unmute  = 'pactl set-sink-mute   @DEFAULT_SINK@ toggle',
	
	scr_lock    = 'light-locker-command --lock',
	scr_lock_on = 'light-locker --lock-on-suspend --lock-on-lid',
	
	scr_cap     = 'import -window root ~/Pictures/$(date +%Y%m%dT%H%M%S).png',
	scr_cap_sel = 'import ~/Pictures/$(date +%Y%m%dT%H%M%S).png',
	
	win_left    = 'xdotool getactivewindow windowmove 03% 02% windowsize 48% 92%',
	win_right   = 'xdotool getactivewindow windowmove 52% 02% windowsize 48% 92%',
	win_max     = 'wmctrl -r :ACTIVE: -b    add,maximized_vert,maximized_horz',
	win_unmax   = 'wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz',
	win_big     = 'xdotool getactivewindow windowmove 04% 04% windowsize 92% 92%',
	win_small   = 'xdotool getactivewindow windowmove 20% 20% windowsize 70% 50%',
	
	dtop_viga   = [[
		xrandr \
			--output DisplayPort-0 --mode 1280x720 --pos 0x0 --rotate normal \
			--output HDMI-A-0 --off \
			--output DVI-D-0 --off
	]],
	dtop_hdmi   = [[
		xrandr \
			--output DisplayPort-0 --off \
			--output HDMI-A-0 --mode 1280x720 --pos 1280x0 --rotate normal \
			--output DVI-D-0 --off
	]],
	dtop_extn   = [[
		xrandr \
			--output DisplayPort-0 --mode 1280x720 --pos 0x0 --rotate normal --primary \
			--output HDMI-A-0 --mode 1280x720 --pos 1280x0 --rotate normal \
			--output DVI-D-0 --off
	]],

	kb_led_on   = 'xset led on',
	kb_led_off  = 'xset led off',
	autolockd_xautolock   = [[
		xautolock
			-time 3 -locker "~/scripts/sys_ctl/ctl.lua fun scr_lock_if"
			-killtime 10 -killer "notify-send -u critical -t 10000 -- 'Killing system ...'"
			-notify 30 -notifier "notify-send -u critical -t 10000 -- 'Locking system ETA 30s ...'";
	]]
}

local Funs = {}
function Funs:scr_lock_if()
	local iv = Pr.pipe()
		.add(Sh.exec('pacmd list-sink-inputs'))
		.add(Sh.grep('state: RUNNING.*'))
		.add(Sh.echo())
		.run()
	print("audio live:", iv)
  if iv == nil then
		return Cmds['scr_lock']
	end
end
function Funs:pa_sinks_name()
	local iv = Pr.pipe()
		.add(Sh.exec('pacmd list-sinks'))
		.add(Sh.grep('name: <(.+)>'))
		.add(Sh.echo())
		.run()
end
function Funs:pa_set_default()
	local iv = Pr.pipe()
		.add(Sh.exec('pacmd list-sinks'))
		.add(Sh.grep('name: <(.+analog.stereo)>'))
		.add(Sh.echo())
		.run()
	return 'pacmd set-default-sink '..iv[1]
end

local Fn = {}
function Fn:cmd(key)
	local cmd = Cmds[key]
	if cmd then
		print('cmd>', cmd)
		exec(cmd)
	else
		print('cmd: ', key, 'not mapped')
	end
end
function Fn:fun(key)
	local cmd = Funs[key]
	if cmd then
		cmd = Funs[key]()
		print('cmd>', cmd)
		if cmd then
			exec(cmd)
		end
	else
		print('cmd: ', key, 'not mapped')
	end
end

local fn = Fn[arg[1]]
if fn == nil then
	print('huh!')
else
	fn(fn, arg[2])
end
