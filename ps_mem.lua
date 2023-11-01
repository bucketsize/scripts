#!/usr/bin/env lua 

local h = assert(io.popen("ps -e -o rss -o args k rss | sed 's/^s*//'"))
local total = 0
for l in h:lines() do
	local mem, cmd = l:match("(%d+)%s+(.*)")
	if mem == nil then
		mem = 0
	end
	print(string.format("%1.2f M - %s", (mem / 1024), cmd))
	total = total + mem
end
print(string.format("total: %1.2f M", total / 1024))
