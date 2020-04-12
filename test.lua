function listToString(ds)
	local ss = ''
	for i, j in pairs(ds) do
		ss = ss .. ", " .. tostring(j)
	end
	return ss
end

local cs = client.get()
local ds = {}
local rs = ''
for i, j in pairs(cs) do
	ds = {i, j.name, j.type, j.class, j.instance
		, j.ontop, j.fullscreen, j.role, j.minimized, j.hidden
		, j.above, j.below, j.focussable}
	rs = rs .. '\n' .. listToString(ds)
end
return rs


