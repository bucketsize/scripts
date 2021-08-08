#!/usr/bin/env lua

package.path = package.path
.. '?.lua;'
.. 'scripts/lib/?.lua;'
.. 'scripts/sys_mon/?.lua;'

local util = require("util")

local Client = {}
function Client.configure(self, client)
   self.client = client
end
function Client.put(self, k, v, type)
	local s, status, partial = self.client:send("put", string.format("%s|%s::%s\n", k, tostring(v), type))
end
function Client.get(self, k)
	local s, status, partial = self.client:send("get", string.format("%s\n", k))
	local v,t = s:match("([%w%p%s]+)::(%w+)")
	return v
end
function Client.getAll(self)
	local rx = self.client:sendxr("getAll", "BLAH\n")
	local mtab = util:fold(
	   function(s, a)
		  local k, v, ty = s:match("([%w_]+)|([%w%p%s]+)::(.*)")
		  local r
		  if k == nil then
			 k = 'nothing'
		  end
		  if ty == "number" then
			 r=tonumber(v)
		  else
			 if ty == "integer" then
				r=math.floor(tonumber(v))
			 else
				r=v
			 end
		  end
		  a[k]=r
		  return a
	   end, rx, {})
	return mtab
end

------------------------------
function test_perf(client)
	----------------------------
	for i=1,50000,1 do
		client:put('keyNN'..tostring(i), "hello !wow." .. tostring(i), "string")
		print(client:get('keyNN'..tostring(i)))
	end
end
function test(client)
   for i=1,5,1 do
	  local k = 'key1'..tostring(i)
	  client:put(k, i, "integer")
	  print(k, client:get(k))
   end
	for i=1,5,1 do
	  local k = 'key2'..tostring(i)
	  client:put(k, 'wow! ..' .. i, "string")
	  print(k, client:get(k))
	end
	print("getting all ...")
	util:printOTable(client:getAll())
end

-----------------------------
local host, port = "localhost", 51515
if arg[1] and not (arg[1] == "-") then
   host = arg[1]
end
if arg[1] and not (arg[2] == "-") then
   port = tonumber(arg[2])
end
-----------------------------

local CmdClient = require('cmd_client')
CmdClient:configure(host, port)
Client:configure(CmdClient)

if arg[3] == 'test' then
   test(Client)
end

return Client
