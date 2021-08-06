local Fmt = require('config.formats')

-- Log to '/var/tmp/sys_mon.out' --
function logger()
	while true do
		local ll = ""
		for i,k in Fmt:ipairs() do
			local fmt = Fmt[k]
			local v = MTAB[k]
			ll = ll .. string.format(fmt, v) ..  ","
		end
		print(ll)
		coroutine.yield()
	end
end
return {co=logger, ri=2}
