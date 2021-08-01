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
local Util = require('util')

DISPLAYS = {
	{
		name = 'DisplayPort-0',
		mode = 720,
		pos = {0,0},
		extra_opts = '--primary'
	},
	{
		name = 'HDMI-A-0',
		mode = 720,
		pos = {1,0},
		extra_opts = '--set underscan on --set "underscan hborder" 48 --set "underscan vborder" 24'
	}
}
DISPLAY_ON = [[
		xrandr \
			--output %s \
			--mode %dx%d \
			--rotate normal \
			--pos %dx%d %s]]
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
function pa_sinks()
	local iv = Pr.pipe()
	.add(Sh.exec('pacmd list-sinks'))
	.add(Sh.grep('name: <(.+)>'))
	.add(Sh.echo())
	.run()
	return iv
end
function Funs:tmenu_select_pa_sinks()
	local opts = ""
	for i, v in ipairs(pa_sinks()) do
		opts = opts .. v .. "\n"
	end

	Pr.pipe()
	.add(Sh.exec(string.format('echo "%s" | fzy', opts)))
	.add(function(id)
		Util:exec('pacmd set-default-sink '..id)
	end)
	.run()
end
function Funs:dmenu_select_pa_sinks()
	Util:exec("urxvt -title popeye -e ~/scripts/sys_mon/control.lua fun tmenu_select_pa_sinks")
end

function Funs:tmenu_select_window()
	local ws = {}
	local wl = ''
	Pr.pipe()
	.add(Sh.exec('wmctrl -l'))
	.add(Sh.grep('(%w+)%s+(%d+)%s+([%w%p]+)%s+(.*)'))
	.add(function(arr)
		ws[arr[4]]= {id = arr[1], ws = arr[2], name = arr[4]}
		return arr[4]
	end)
	.add(function(name)
		wl = wl .. name .. '\n'
	end)
	.run()

	Pr.pipe()
	.add(Sh.exec(string.format('echo "%s" | fzy', wl)))
	.add(function(name)
		Util:exec('wmctrl -ia ' .. ws[name].id)
	end)
	.run()
end
function Funs:dmenu_select_window()
	Util:exec("urxvt -title popeye -e ~/scripts/sys_mon/control.lua fun tmenu_select_window")
end
function Funs:tmenu_launch()
	Pr.pipe()
	.add(Sh.exec('ls ~/.local/bin ~/.local/share/flatpak/exports/share/applications /usr/share/applications  | fzy'))
	.add(function(app)
		local bin = string.match(app, "(.+).desktop")
		if not (bin == nil) then
			Util:exec("gtk-launch "..bin)
		else
			Util:exec(app .. " &")
		end
	end)
	.run()
end
function Funs:dmenu_run()
	Util:exec("urxvt -title popeye -e ~/scripts/sys_mon/control.lua fun tmenu_launch")
end
function xrandr_info()
	local h = io.popen("xrandr -q")
	local ots = {}

	if h then
		local ot
		for line in h:lines() do
			local otc = line:match("^([%w-]+) connected ")
			if otc then
				ot = otc
				if ots[ot] == nil then
					ots[ot] = {modes={}}
				end
			else
				if not (ot == nil) then
					local mx, my = string.match(line, "%s+(%d+)x(%d+)")
					if not (my == nil) then
						table.insert(ots[ot].modes, {x=mx, y=my})
						--print(ot, mx, my)
					end
				end
			end
		end
		h:close()
	end
	return ots
end

function get2dElem(t, i, j)
	if t[i] == nil then
		return nil
	else
		return t[i][j]
	end
end

function xrandr_configs()
	local outputs = xrandr_info()
	local outgrid = {}
	for i,d in ipairs(DISPLAYS) do
		--print("configure", i, d.name)
		local o = outputs[d.name]
		local mode = o.modes[1]
		for i,m in ipairs(o.modes) do
			--print("?y", m.x, m.y, d.mode, type(m.y), type(d.mode))
			if tonumber(m.y) == d.mode then
				o.name = d.name
				o.mode = m
				o.pos = d.pos
				o.extra_opts = d.extra_opts
				outgrid[d.pos[1]] = {}
				outgrid[d.pos[1]][d.pos[2]] = o
				--print("configure", d.name, d.pos[1], d.pos[2])
				break
			end
		end
	end

	local outsetup, outgrid_ctl = {}, {}
	for i,d in ipairs(DISPLAYS) do
		local x, y = d.pos[1], d.pos[2]
		local o = get2dElem(outgrid, x, y)
		local off_xo, off_yo = get2dElem(outgrid, x-1, y), get2dElem(outgrid, x, y-1)
		local off_x, off_y
		if off_xo == nil then
			off_x = 0
		else
			off_x = off_xo.mode.x * d.pos[1]
		end
		if off_yo == nil then
			off_y = 0
		else
			off_y = off_xo.mode.y * d.pos[2]
		end

		local dOn = string.format(DISPLAY_ON
				, o.name
				, o.mode.x, o.mode.y
				, off_x, off_y
			  , o.extra_opts)
		local dOff = string.format(DISPLAY_OFF, o.name)
		outgrid_ctl[d.name .. " on"]  = dOn
		outgrid_ctl[d.name .. " off"] = dOff
		table.insert(outsetup, dOn)
	end
	return outsetup, outgrid_ctl
end

function Funs:setup_video()
	local setup, _ = xrandr_configs()
	return setup
end

function Funs:tmenu_setup_video()
	local _, vgridctl = xrandr_configs()
	local opts = ""
	for k, cmd in pairs(vgridctl) do
		opts = opts .. string.format("%s", k) .. "\n"
	end

	Pr.pipe()
	.add(Sh.exec(string.format('echo "%s" | fzy', opts)))
	.add(function(id)
		Util:exec(vgridctl[id])
	end)
	.run()
end

function Funs:dmenu_setup_video()
	Util:exec("urxvt -title popeye -e ~/scripts/sys_mon/control.lua fun tmenu_setup_video")
end

function Funs:tmenu_exit()
	local exit_with = {
		lock = Cmds["scr_lock"],
		logout = "i3-msg exit",
		suspend = "systemctl suspend",
		hibernate = "systemctl hibernate",
		reboot = "systemctl reboot",
		shutdown = "systemctl poweroff -i"
	}

	local opts = ""
	for k,v in pairs(exit_with) do
		opts = opts .. k .. "\n"
	end

	Pr.pipe()
	.add(Sh.exec(string.format('echo "%s" | fzy', opts)))
	.add(function(name)
		Util:exec(exit_with[name].." &")
	end)
	.run()
end
function Funs:dmenu_exit()
	Util:exec("urxvt -title popeye -e ~/scripts/sys_mon/control.lua fun tmenu_exit")
end

function Funs:get_wallpaper()
end

------------------------------------------------------
local Fn = {}
function Fn:cmd(key)
	local cmd = Cmds[key]
	if cmd then
		print('cmd>', cmd)
		Util:exec(cmd)
	else
		print('cmd: ', key, 'not mapped')
	end
end
function Fn:fun(key)
	local cmd = Funs[key]
	if cmd then
		cmd = Funs[key]()
		if cmd then
			if type(cmd) == 'table' then
				for i,icmd in ipairs(cmd) do
					Util:exec(icmd)
				end
			else
				Util:exec(cmd)
			end
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
