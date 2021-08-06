local alert = require('config.alerts')
local Proc = require('process')
local Shell = require('shell')

function mem_usage()
	local rf,rt,sf,st
	Proc.pipe()
	.add(Shell.cat("/proc/meminfo"))
	.add(Proc.branch()
		.add(Shell.grep("MemTotal:%s+(%d+) kB"))
		.add(Shell.grep("MemFree:%s+(%d+) kB"))
		.add(Shell.grep("SwapTotal:%s+(%d+) kB"))
		.add(Shell.grep("SwapFree:%s+(%d+) kB"))
		.build())
	.add(Proc.cull())
	.add(Proc.map(function(x)
		if not (x[1]==nil) then rt=x[1][1]
		elseif not (x[2]==nil) then rf=x[2][1]
		elseif not (x[3]==nil) then st=x[3][1]
		elseif not (x[4]==nil) then sf=x[4][1]
		end
		return x
	end))
	-- .add(Shell.echo())
	.run()

	return 1-rf/rt, 1-sf/st
end
function co_mem_usage()
	while true do
		local m=mem_usage()
		MTAB['mem'] = m*100
		MTAB['mem_level'] = m*5
		coroutine.yield()
	end
end
return {co=co_mem_usage, ri=2}
