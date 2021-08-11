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
.. 'scripts/sys_mon/?.lua;'
----------------------------------------------------------

local Util = require('util')
local Fmt = require('config.formats')

EPOC=1
MTAB={}
for i,k in Fmt:ipairs() do
   MTAB[k] = 0
end

local Co = Util:map(function(s)
	local codef = require('fragments.' .. s)
	codef.name = s
	return codef
end, {"cpu", "mem", "cpu_temp", "net", "pulseaudio", "weather"})

Util:map(function(s)
	local codef = require('writers.' .. s)
	codef.name = s
	table.insert(Co, codef)
end, {"mcache",	"mlogger"})

-----------------------------------------------------------------
function start()
   for i, co in pairs(Co) do
      local inst = coroutine.create(co.co)
      print('co/', co.name, co.ri)
      Util.Timer:tick(co.ri, function()
						 Util:run_co(co.name, inst)
	  end)
   end
   Util.Timer:start()
end
start()
