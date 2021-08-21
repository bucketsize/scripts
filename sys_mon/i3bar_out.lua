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

local socket = require("socket")
local util = require("util")
local formats = require("config.formats")
local cachec = require("lib.cachec")

local Sym ={
	cpu = "",
	gpu = "gpu",
	mem = "",
	eth = "",
	wifi = "",
	disc = "",
	clock = "",
	battery = "",
	AC = "",
	snd = "",
	snd_mute = "",
	disabled = "",
	temperature = "",
}


function co_i3bar_out()
	print('{"version":1}')
	print('[')
	print('[],')
	while true do
		local otab = cachec:getAll()
		local mtab = {}
		for k,v in pairs(otab) do
			if not (formats[k] == nil) then
				mtab[k]=string.format(formats[k], v)
			end
		end

		local power = util:if_else(mtab['battery_status'] == "AC"
			, {icon = Sym["AC"], val = "AC"}
			, {icon = Sym["battery"], val = mtab["battery"]})
		local audio = util:if_else(otab['vol'] == nil or otab['vol'] < 1
			, {icon = Sym["snd_mute"], val = ""}
			, {icon = Sym["snd"], val = mtab["vol"]})

		print(string.format([[[
				{"full_text": "%sC %sH %s"},
				{"full_text": "| %s%s"},
				{"full_text": "| %s %s"},
				{"full_text": "%s %s"},
				{"full_text": "%s %s | %s %s"},
				{"full_text": "| %s %s %s"},
				{"full_text": "| %s %s"},
				{"full_text": "| %s %s"},
				{"full_text": "| %s %s"}
],]]
				, mtab['weather_temperature'], mtab['weather_humidity'], mtab['weather_summary']
				, Sym['eth'], util:if_else(mtab['net_gateway']=="?", Sym['disabled'], "")
				, Sym['cpu'], mtab['cpu']
				, Sym['temperature'], mtab['cpu_temp']
				, Sym['mem'], mtab['mem'], Sym['gpu'], mtab['gpu_mem_used_pc']
				, Sym['disc'], mtab['discio'], mtab['fs_free']
				, audio.icon, audio.val
				, power.icon, power.val
			, Sym['clock'], os.date("%a %b %d, %Y | %H:%M")))
		coroutine.yield()
	end
end

local i3co1 = coroutine.create(co_i3bar_out)
while true do
	util:run_co('i3bar_out', i3co1)
	socket.sleep(2)
end
