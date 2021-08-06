local Util = require('util')

local cpufreq_files={}
Util:stream_exec("ls /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq", function(f)
		    table.insert(cpufreq_files,f)
end)
function cpu_freq()
   local freq={}
   for i,v in ipairs(cpufreq_files) do
      local handle = io.open(v, "r")
      if not handle == nil then
	 local result = handle:read("*l")
	 handle:close()
	 freq[i]=tonumber(result)
      end
   end
   return freq
end
function co_cpu_freq()
   while true do
      local freq=cpu_freq()
      for i,v in ipairs(freq) do
	 MTAB['cpu'..tostring(i-1)] = v/1000
      end
      coroutine.yield()
   end
end
return {co=co_cpu_freq, ri=2}


