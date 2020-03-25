local Util={}
function Util:read(filename)
	local h = io.open(filename, "r")
	local r
	if h == nil then
		r = ""
	else
		r = h:read("*a")
		h:close()
	end
	return r
end
function Util:exec(cmd)
	local h = io.popen(cmd)
	local r
	if h == nil then
		r = ""
	else
		r = h:read("*a")
		h:close()
	end
	return r
end

-- print(Util:read("/proc/cpuinfo", "r"))
-- print(Util:exec("ls -l", "r"))

return Util
