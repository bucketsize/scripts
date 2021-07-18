#!/usr/bin/env lua

package.path = package.path
	.. '?.lua;'
	.. 'scripts/lib/?.lua;'
	.. 'scripts/sys_mon/?.lua;'

local util = require("util")
local socket = require("socket")
local host, port = "127.0.0.1", 51515
local tcp = assert(socket.tcp())

local Client = {}
function Client:put(k, v, type)
	tcp:connect(host, port)
	tcp:send(string.format("put %s %s::%s\n", k, tostring(v), type))
	local s, status, partial = tcp:receive('*l')
	tcp:close()
end
function Client:get(k)
	tcp:connect(host, port)
	tcp:send(string.format("get %s\n", k))
	local s, status, partial = tcp:receive('*l')
	--print(">> ", s, status, partial)
	tcp:close()
	local v,t = s:match("(%w+)::(%w+)")
	return v
end
function Client:getAll()
	tcp:connect(host, port)
	tcp:send("getAll BLAH\n")
	local s, status, partial
	local mtab={}
	while true do
		s, status, partial = tcp:receive('*l')
		if status == "closed"
			then break
		end
		--print(">> ", s, status, partial)
		local k, v, ty = s:match("([%w%p]+)%s+([%w%p]+)::(.*)")
		mtab[k]=v
	end
	tcp:close()
	return mtab
end
function test()
	for i=1,10,1 do
		Client:put('key'..tostring(i), i, "integer")
		print(Client:get('key'..tostring(i)))
	end
	util:printOTable(Client:getAll())
end

--test()

return Client

