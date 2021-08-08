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

local CmdClient = {
   configure = function(self, host, port)
	  local socket = require("socket")
	  local tcp = assert(socket.tcp())
	  self.socket = socket
	  self.tcp = tcp
	  self.host = host
	  self.port = port
   end,
   send = function(self, cmd, p)
	  self.tcp:connect(self.host, self.port)
	  self.tcp:send(string.format("%s|%s\n", cmd, p))
	  local s, status, partial = self.tcp:receive('*l')
	  self.tcp:close()
	  return s, status
   end,
   sendxr = function(self, cmd, p)
	  self.tcp:connect(self.host, self.port)
	  self.tcp:send(string.format("%s|%s\n", cmd, p))
	  local s, status, partial
	  local mtab={}
	  while true do
		 s, status, partial = self.tcp:receive('*l')
		 if status == "closed"
		 then break
		 end
		 table.insert(mtab, s)
	  end
	  self.tcp:close()
	  return mtab
   end
}

return CmdClient
