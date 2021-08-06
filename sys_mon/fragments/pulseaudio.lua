local Proc = require('process')
local Shell = require('shell')

function vol_usage()
	local v = Proc.pipe()
	.add(Shell.exec('pactl list sinks 2>&1'))
	.add(Shell.grep('Volume: f.*'))
	.add(Proc.map(function(s)
		vol=0
		for v in string.gmatch(s[1], "/%s+(%d+)") do
			vol=vol+v
		end
		vol=vol/2
		return vol
	end))
	.run()
	local iv = Proc.pipe()
	.add(Shell.exec('pacmd list-sink-inputs'))
	.add(Shell.grep('state: RUNNING.*'))
	--.add(Shell.echo())
	.run()
	return v, not (iv == nil)
end
function co_vol_usage()
	while true do
		local v, s = vol_usage()
		MTAB['vol'] = v
		MTAB['vol_level'] = v*0.05
		MTAB['snd_live'] = s
		coroutine.yield()
	end
end
return {co=co_vol_usage, ri=2}
