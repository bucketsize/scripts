local Util = require('util')

function ps_top()
	local t={}
	local result = Util:exec_stream(
		"ps -Ao user,pid,pcpu,pmem,comm --sort=-pcpu | head -n 6"
		, function(line)
			local user,pid,pcpu,pmem,comm=string.match(line, "(%w+)%s+(%w+)%s+(%d+.%d+)%s+(%d+.%d+)%s+(%a+)")
			local r={}
			r['user']=user
			r['comm']=comm
			r['pid'] =pid
			r['pcpu']=pcpu
			r['pmem']=pmem
			--print('->', user, comm, pcpu, pmem)
			table.insert(t, r)
		end)
	return t
end
function co_ps_top()
	while true do
		local m=ps_top()
		for i,p in ipairs(m) do
			MTAB[string.format('p%s_pid',i)] = p['pid']
			MTAB[string.format('p%s_pcpu',i)] = p['pcpu']
			MTAB[string.format('p%s_pmem',i)] = p['pmem']
			MTAB[string.format('p%s_name',i)] = p['comm']
			--print(MTAB['p2'])
		end
		coroutine.yield()
	end
end
return {co=co_ps_top, ri=2}
