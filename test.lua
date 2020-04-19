function listToString(ds)
	local ss = ''
	for i, j in pairs(ds) do
		ss = ss .. ", " .. tostring(j)
	end
	return ss
end

function listClients()
local cs = client.get()
local ds = {}
local rs = ''
for i, j in pairs(cs) do
	ds = {i, j.name, j.type, j.class, j.instance
		, j.ontop, j.fullscreen, j.role, j.minimized, j.hidden
		, j.above, j.below, j.focussable}
	rs = rs .. '\n' .. listToString(ds)
end
return rs
end

function notify_sndvol_event()
	local naughty = require('naughty')
	naughty.notify({
		replaces_id=1248,
		font='DejaVu Sans 18',
		icon='/usr/share/icons/Adwaita/96x96/devices/audio-speakers-symbolic.symbolic.png',
		icon_size=48,
		text='+5%',
	})
end

return notifyVol()


