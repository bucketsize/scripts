local Fmt = require('config.formats')
local cachec = require("lib.cachec")

function mcache()
	while true do
		for i,k in Fmt:ipairs() do
			local fmt = Fmt[k]
			local v = MTAB[k]
			cachec:put(k, v, type(v))
		end
		coroutine.yield()
	end
end
return {co=mcache, ri=2}
