local Fmt = require('config.formats')

-- Log to '/var/tmp/sys_mon.out' --
function logger()
	while true do
		local hout = io.open("/tmp/sys_mon.out", "w")
		local hlog = io.open("/var/tmp/sys_mon.log", "a")
		for i,k in Fmt:ipairs() do
			local fmt = Fmt[k]
			local v = MTAB[k]
			--print("-> ", k, v, type(v))
			hout:write(k,': ',string.format(fmt, v), "\n")
			hlog:write(string.format(fmt, v), ",")
		end
		hout:close()
		hlog:write('\n')
		hlog:close()
		coroutine.yield()
	end
end
return {co=logger, ri=2}
