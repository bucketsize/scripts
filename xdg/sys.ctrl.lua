Fns={}
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
function Fns:vol_start()
	local h=io.popen('pulseaudio --start')
	h:close()
end
function Fns:vol_up()
	local h=io.popen('pactl set-sink-volume 0 +10%')
	h:close()
end
function Fns:vol_down()
	local h=io.popen('pactl set-sink-volume 0 -10%')
	h:close()
end
function Fns:vol_mute()
	local h=io.popen('pactl set-sink-mute 0 true')
	h:close()
end
function Fns:vol_unmute()
	local h=io.popen('pactl set-sink-mute 0 false')
	h:close()
end
function Fns:vol_switch_sink()
	local h=io.popen()
	h:close()
end
function Fns:vid_info()
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
function Fns:vid_nightmode()
	Fns:vid_info()
	local cmd=string.format('xrandr --output %s --gamma %s --brightness %s'
		, Mtab['vid_dev']
		, Mtab['gam_nightmode']
		, Mtab['bri'])
	local handle = io.popen(cmd)
	handle:close()

	Mtab['gam'] = Mtab['gam_nightmode']
end
function Fns:vid_daymode()
	Fns:vid_info()
	local cmd=string.format('xrandr --output %s --gamma %s --brightness %s'
		, Mtab['vid_dev']
		, Mtab['gam_def']
		, Mtab['bri'])
	local handle = io.popen(cmd)
	handle:close()

	Mtab['gam'] = Mtab['gam_def']
end
function Fns:vid_darken()
	Mtab:fetch()
	Fns:vid_info()
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
function Fns:vid_lighten()
	Mtab:fetch()
	Fns:vid_info()
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

local fn = Fns[arg[1]]
if fn == nil then
	print('huh!')
else
	fn()
end
