#!/usr/bin/env lua

----------------------------------------------------------
local version = _VERSION:match("%d+%.%d+")
package.path  = package.path
   .. '.luarocks/share/lua/' .. version .. '/?.lua;'
package.cpath = package.cpath
   .. '.luarocks/lib/lua/' .. version .. '/?.so;'

package.path = package.path
   .. '?.lua;'
   .. 'scripts/lib/?.lua;'
----------------------------------------------------------

local Cache = {}

local Handler = {
   put = function(client, so)
	  local k, v = so:match("([%w_]+)|(.*)")
	  print(">> put", k, v )
	  Cache[k] = v
	  print("<< ok")
	  client:send("ok\n")
   end,
   get = function(client, so)
	  local k, v = so:match("([%w_]+)")
	  print(">> get", k, v )
	  print("<< ", Cache[k])
	  if Cache[k] == nil then
		 client:send("\n")
	  else
		 client:send(Cache[k].."\n")
	  end
   end,
   getAll = function(client, so)
	  print(">> getAll *")
	  print("<< all")
	  for k,v in pairs(Cache) do
		 client:send(string.format("%s|%s\n", k, v))
	  end
   end,
}

-----------------------------
local host, port = "*", 51515
if not (arg[1] == "-") then
   host = arg[1]
end
if not (arg[2] == "-") then
   port = tonumber(arg[2])
end
-----------------------------

local CmdServer =  require('cmd_server')
CmdServer:start(host, port, Handler)
