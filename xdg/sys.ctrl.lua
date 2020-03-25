#!/bin/lua
-- $(luarocks path) && sys.ctrl.lua start

local sleep = require('socket').sleep

-- pre: arch linux
-- luarocks install --server=https://luarocks.org/dev lua-dbus --local DBUS_INCDIR=/usr/include/dbus-1.0 DBUS_ARCH_INCDIR=/usr/lib/dbus-1.0/include DBUS_LIBDIR=/usr/lib
local dbus = require 'lua-dbus'

Fn={}
Mtab={
	bri_def = 0.9,
	gam_def = '0.7:0.7:0.7',
	gam_nmo = '0.5:0.4:0.3',
	bri = 0.9,
	gam = '0.7:0.7:0.7'
}
function Mtab:save()
	local h=io.open('/var/tmp/sys.ctrl.cfg', "w")
	for k, v in pairs(Mtab) do
		if type(v) == 'function' or k == nil then
			print('skip', k, v)
		else
			print(k, v)
			h:write(k,"=",v,"::",type(v),"\n")
		end
	end
	h:close()
end
function Mtab:fetch()
	local h=io.open('/var/tmp/sys.ctrl.cfg', "r")
	if h == nil then
		return
	end
	local r=h:lines()
	for l in r do
		local k,v,t = string.match(l, "(.+)=(.+)::(%w+)")
		if t == 'number' then
			v=tonumber(v)
		end
		print(k,v)
		Mtab[k]=v
	end
	h:close()
end

function Fn:vol_stat()
	local h=io.popen('pactl info')
	local r=h:read("*a")
	if r == nil then
		return false
	end
	h:close()
	return true
end
function Fn:vol_init()
	if not Fn:vol_stat() then
	local h=io.popen('pulseaudio --kill && pulseaudio --start')
	h:close()
	end
end
function Fn:vol_up()
	local h=io.popen('pactl set-sink-volume 0 +10%')
	h:close()
end
function Fn:vol_down()
	local h=io.popen('pactl set-sink-volume 0 -10%')
	h:close()
end
function Fn:vol_mute()
	local h=io.popen('pactl set-sink-mute 0 true')
	h:close()
end
function Fn:vol_unmute()
	local h=io.popen('pactl set-sink-mute 0 false')
	h:close()
end
function Fn:vol_switch_sink()
	local h=io.popen()
	h:close()
end
function Fn:vid_info()
	local handle = io.popen("xrandr -q")
	local result = handle:read("*a")
	handle:close()

	local dev = result:match('.*%s(.*)%sconnected')
	local xf, yf = 800, 600
	for x, y in result:gmatch('%s+(%d+)x(%d+)%s+') do
		xf, yf = x, y
		break
	end

	Mtab['vid_dev']=dev
	Mtab['vid_x']=xf
	Mtab['vid_y']=yf

	print('vid:',dev,xf,yf)
end
function Fn:vid_nightmode()
	Fn:vid_info()
	local cmd=string.format('xrandr --output %s --gamma %s --brightness %s'
		, Mtab['vid_dev']
		, Mtab['gam_nightmode']
		, Mtab['bri'])
	local handle = io.popen(cmd)
	handle:close()

	Mtab['gam'] = Mtab['gam_nightmode']
end
function Fn:vid_daymode()
	Fn:vid_info()
	local cmd=string.format('xrandr --output %s --gamma %s --brightness %s'
		, Mtab['vid_dev']
		, Mtab['gam_def']
		, Mtab['bri'])
	local handle = io.popen(cmd)
	handle:close()

	Mtab['gam'] = Mtab['gam_def']
end
function Fn:vid_darken()
	Mtab:fetch()
	Fn:vid_info()
	if Mtab['bri'] < 0.2 then
	else
		Mtab['bri'] = Mtab['bri'] - 0.1
		local cmd=string.format('xrandr --output %s --gamma %s --brightness %s'
			, Mtab['vid_dev']
			, Mtab['gam']
			, Mtab['bri'])
		print(cmd)
		local handle = io.popen(cmd)
		handle:close()
	end

	Mtab:save()
end
function Fn:vid_lighten()
	Mtab:fetch()
	Fn:vid_info()
	if Mtab['bri'] > 0.9 then
	else
		Mtab['bri'] = Mtab['bri'] + 0.1
		local cmd=string.format('xrandr --output %s --gamma %s --brightness %s'
			, Mtab['vid_dev']
			, Mtab['gam']
			, Mtab['bri'])
		print(cmd)
		local handle = io.popen(cmd)
		handle:close()
	end

	Mtab:save()
end

function Fn:shutdown()
end

function Fn:reboot()
end

function Fn:sleep()
end

function Fn:hibernate()
end

function Fn:wallpaper()
end

function on_signal()

end

Cmd={}
function Cmd:start()
	if not awesome then
		dbus.init()

		-- system messages
		dbus.on('NameOwnerChanged',
			function (...)
				print("NameOwnerChanged", ...)
			end,
			{ bus = 'session', interface = 'org.freedesktop.DBus' })

		-- custom messages
		dbus.on('CtrlDo',
			function (...)
				print('CtrlDo', ...)
			end,
			{ bus = 'session', interface = 'org.freedesktop.Ctrl' })

		print('Dbus listen ...')
		while true do
			dbus.poll()
			sleep(0.3)
		end
	end
end


local fn = Cmd[arg[1]]
if fn == nil then
	print('huh!')
else
	fn()
end
