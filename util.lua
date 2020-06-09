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
function Util:exec_stream(cmd, fn)
	local h = io.popen(cmd)
	while true do
		local l = h:read("*line")
		if l == nil then break end
		fn(l)
	end
end

-- print(Util:read("/proc/cpuinfo", "r"))
-- print(Util:exec("ls -l", "r"))

-- local cmd = string.format("~/scripts/pam_auth %s %s", "jb", "1234")
-- local r = Util:exec(cmd)
-- print(r)
-- local s = string.match(r, "status:%s(%w+)%c")
-- print('|' .. s ..'|')

return Util
