local alert = require('config.alerts')

function cpu_usage()
	local handle = io.open("/proc/stat", "r")
	local result = handle:read("*l")
	handle:close()
	-- print('-> result: ', result)
	local t,s1,z1,i={},0,0,0
	for d in string.gmatch(result, "%d+") do
		s1=s1+d
		t[i]=d
		i=i+1
	end
	z1=t[3]
	return s1,z1
end
function co_cpu_usage()
	local s0,z0,c = 0,0,0
	while true do
		local s,z = cpu_usage()
		local c = 1-(z-z0)/(s-s0)
		s0,z0 = s,z
		MTAB['cpu'] = c*100
		MTAB['cpu_level'] = c*5
		MTAB['time'] = os.date("%Y-%m-%dT%H:%M:%S+05:30")
		alert:check('cpu', c*100)
		coroutine.yield()
	end
end
return {co=co_cpu_usage, ri=2}
