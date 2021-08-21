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

local Util = require("util")

function test_segpath()
   local ts = {"/var/tmp/foo/bar.egg", "fry.egg", "./goto.egg", "//more.egg", "fifa/la/kase.egg"}
   for i, v in ipairs(ts) do
	  print("test_segpath", i, v)
	  local ps = Util:segpath(v)
	  Util:printITable(Util:reverse(ps))
	  print(ps[#ps])
   end
end

test_segpath()
