#!/usr/bin/env lua

local version = _VERSION:match("%d+%.%d+")
package.path  = '.luarocks/share/lua/' .. version .. '/?.lua;lua_modules/share/lua/' .. version .. '/?/init.lua;' .. package.path
package.cpath = '.luarocks/lib/lua/' .. version .. '/?.so;' .. package.cpath

package.path = package.path
	.. '?.lua;'
	.. 'scripts/lib/?.lua;'
	.. 'scripts/sys_mon/?.lua;'

local Sh = require('shell')
local Pr = require('process')

DISPLAY1 = {
	name = 'DisplayPort-0',
	mode = '1280x720',
	pos = '0x0',
	extra_opts = '--primary'
}
DISPLAY2 = {
	name = 'HDMI-A-0',
	mode = '1280x720',
	pos = '1280x0',
	extra_opts = '--set underscan on --set "underscan hborder" 48 --set "underscan vborder" 24'
}
DISPLAY_ON = [[
		xrandr \
			--output %s \
			--mode %s \
			--rotate normal \
			--pos %s %s]]
DISPLAY_OFF = [[
		xrandr \
			--output %s \
			--off ]]

local Cmds = {
	vol_up      = 'pactl set-sink-volume @DEFAULT_SINK@ +10%',
	vol_down    = 'pactl set-sink-volume @DEFAULT_SINK@ -10%',
	vol_mute    = 'pactl set-sink-mute   @DEFAULT_SINK@ toggle',
	vol_unmute  = 'pactl set-sink-mute   @DEFAULT_SINK@ toggle',

	scr_lock    = '~/scripts/xdg/x.lock-i3.sh',

	scr_cap     = 'import -window root ~/Pictures/$(date +%Y%m%dT%H%M%S).png',
	scr_cap_sel = 'import ~/Pictures/$(date +%Y%m%dT%H%M%S).png',

	-- this stuff for openbox / floating win managers
	win_left    = 'xdotool getactivewindow windowmove 03% 02% windowsize 48% 92%',
	win_right   = 'xdotool getactivewindow windowmove 52% 02% windowsize 48% 92%',
	win_max     = 'wmctrl -r :ACTIVE: -b    add,maximized_vert,maximized_horz',
	win_unmax   = 'wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz',
	win_big     = 'xdotool getactivewindow windowmove 04% 04% windowsize 92% 92%',
	win_small   = 'xdotool getactivewindow windowmove 20% 20% windowsize 70% 50%',

	display1_on = string.format(DISPLAY_ON, DISPLAY1.name, DISPLAY1.mode, DISPLAY1.pos, DISPLAY1.extra_opts),
	display2_on = string.format(DISPLAY_ON, DISPLAY2.name, DISPLAY2.mode, DISPLAY2.pos, DISPLAY2.extra_opts),
	display2_off = string.format(DISPLAY_OFF, DISPLAY2.name),

	kb_led_on   = 'xset led on',
	kb_led_off  = 'xset led off',

	autolockd_xautolock   = [[
		xautolock
			-time 3 -locker "~/scripts/sys_mon/control.lua fun scr_lock_if"
			-killtime 10 -killer "notify-send -u critical -t 10000 -- 'Killing system ...'"
			-notify 30 -notifier "notify-send -u critical -t 10000 -- 'Locking system ETA 30s ...'";
	]]
}

function exec(cmd)
	local h = io.popen(cmd)
	h:close()
end

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
function Funs:dmenu_select_window()
    local ws = {}
    local wl = ''
    Pr.pipe()
    .add(Sh.exec('wmctrl -l'))
    .add(Sh.grep('(%w+)%s+(%d+)%s+([%w%p]+)%s+(.*)'))
    .add(Sh.echo())
    .add(function(arr)
        ws[arr[4]]=arr[1]
        return arr
    end)
    .add(function(arr)
        wl = wl .. arr[4] .. '\n'
    end)
    .run()

    Pr.pipe()
    .add(Sh.exec(string.format('echo "%s" | dmenu -l 10', wl)))
    .add(Sh.echo())
    .add(function(arr)
        print(ws[arr])
        exec('xdotool windowfocus ' .. ws[arr])
    end)
    .run()
end

function Funs:get_wallpaper()
end

------------------------------------------------------
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
		if cmd then
			exec(cmd)
		end
	else
		print('cmd: ', key, 'not mapped')
	end
end
function Fn:help()
	print("cmd")
	for k,v in pairs(Cmds) do
		print('\t',k)
	end
	print("fun")
	for k,v in pairs(Funs) do
		print('\t',k)
	end
end

local fn = Fn[arg[1]]
if fn == nil then
	print('huh!')
else
	fn(fn, arg[2])
end
