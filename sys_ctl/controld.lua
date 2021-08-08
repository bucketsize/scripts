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
   .. 'scripts/sys_ctl/?.lua;'
----------------------------------------------------------

local Ctrl = require("control")
local Util = require("util")

local Handler = {
   cmd = function(client, p)
	  local cmd = Ctrl.Cmds[p]
	  print("cmd>", p, cmd)
	  if cmd then
		 Util:exec(cmd)
	  else
		 client:send("bad\n")
	  end
	  client:send("ok\n")
   end,
   fun = function(client, p)
	  local cmd = Ctrl.Funs[p]
	  print("fun>", p)
	  if cmd then
		 local rcmd = cmd()
		 if rcmd then
			if type(rcmd) == 'table' then
			   for i,icmd in ipairs(rcmd) do
				  Util:exec(icmd)
			   end
			else
			   Util:exec(rcmd)
			end
		 end
	  else
		 client:send("bad\n")
	  end
	  client:send("ok\n")
   end
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

local CmdServer = require('cmd_server')
CmdServer:start(host, port, Handler)
