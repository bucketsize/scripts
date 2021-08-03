local version = _VERSION:match("%d+%.%d+")
package.path  = '.luarocks/share/lua/' .. version .. '/?.lua;lua_modules/share/lua/' .. version .. '/?/init.lua;' .. package.path
package.cpath = '.luarocks/lib/lua/' .. version .. '/?.so;' .. package.cpath

package.path = package.path
	.. '?.lua;'
	.. 'scripts/lib/?.lua;'
	.. 'scripts/sys_mon/?.lua;'

local Sh = require('shell')
local Pr = require('process')
local Util = require('util')

function pa_sinks()
	local iv = Pr.pipe()
	.add(Sh.exec('pacmd list-sinks'))
	.add(Sh.grep('name: <(.+)>'))
	.run()
	return iv
end

local Funs = {}
function Funs:tmenu_select_pa_sinks()
	local opts = ""
	for i, v in ipairs(pa_sinks()) do
		opts = opts .. v .. "\n"
	end

	Pr.pipe()
	.add(Sh.exec(string.format('echo "%s" | fzy', opts)))
	.add(function(id)
		Util:exec('pacmd set-default-sink '..id)
	end)
	.run()
end
function Funs:dmenu_select_pa_sinks()
	Util:exec("urxvt -title popeye -e ~/scripts/sys_mon/control.lua fun tmenu_select_pa_sinks")
end

return Funs
