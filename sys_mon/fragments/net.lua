local Proc = require('process')
local Shell = require('shell')
local Util = require('util')

function net_usage()
	local r = Proc.pipe()
	.add(Shell.exec('ip route'))
	.add(Shell.grep('default via (%d+.%d+.%d+.%d+) dev (%w+) proto (%w+)'))
	.run()

	if r == nil then
		return "?", "?", "?",0,0
	end

	local net_stat_pat = r[2] .. ": (.+)%c"
	local r2 = Util:read("/proc/net/dev", "r")
	local r3 = string.match(r2, net_stat_pat)

	local t={}
	for i in string.gmatch(r3, "(%d+)") do
		table.insert(t, i)
	end

	return r[1],r[2],r[3],tonumber(t[1]),tonumber(t[9])
end
function co_net_usage()
	local tx0,rx0=0,0
	while true do
		local gw,dev,proto,tx,rx=net_usage()
		local ts,rs = (tx-tx0)/EPOC, (rx-rx0)/EPOC
		tx0,rx0=tx,rx

		MTAB['net_gateway']=gw
		MTAB['net_device']=dev
		MTAB['net_proto']=proto
		MTAB['net_tx']=tx/100
		MTAB['net_rx']=rx/100
		MTAB['net_ts']=ts/100
		MTAB['net_rs']=rs/100

		coroutine.yield()
	end
end
return {co=co_net_usage, ri=2}

