#!/usr/bin/env lua

package.path = package.path
	.. '?.lua;'
	.. 'scripts/lib/?.lua;'
	.. 'scripts/sys_mon/?.lua;'

local socket = require("socket")
local cachec = require("cachec")
local util = require("util")

local Sym ={
	cpu = "",
	gpu = "",
	mem = "",
	eth = "",
	wifi = "",
	disc = "",
	clock = "",
	battery = "",
	snd = "",
	snd_mute = "",
	disabled = ""
}

function co_i3bar_out()
	print('{"version":1}')
	print('[')
	print('[],')
	while true do
		local mtab = cachec:getAll()
		print('[')
		-- print(string.format([[{"full_text": "[net %d %d]"},]], mtab['net_ts'], mtab['net_rs']))
		print(string.format([[{"full_text": "| %s %d"},]], Sym['cpu'], mtab['cpu']))
		-- print(string.format([[{"full_text": "%d MHz"},]], mtab['cpu1_freq']))
		-- print(string.format([[{"full_text": "%d V"},]], mtab['cpu1_volt']))
		-- print(string.format([[{"full_text": "%d rpm]"},]], mtab['cpu_fan']))
		print(string.format([[{"full_text": "%d C"},]], mtab['cpu_temp']))
		print(string.format([[{"full_text": "| %s %d"},]], Sym['mem'], mtab['mem']))
		print(string.format([[{"full_text": "vram %d"},]], mtab['gpu_mem_used_pc']))
		print(string.format([[{"full_text": "| %s %d"},]], Sym['disc'], mtab['discio']))
		print(string.format([[{"full_text": "/ %d]"},]], mtab['fs_free']))
		print(string.format([[{"full_text": "| %s %s %d"},]], Sym['battery'], mtab['battery_status'], mtab['battery']))
		print(string.format([[{"full_text": "| %s %d"},]], Sym['snd'], mtab['vol']))
		print(string.format([[{"full_text": "| %s %s"}]], Sym['clock'], os.date("%a %b %d, %Y | %H:%M")))
		print('],')
		coroutine.yield()
	end
end

local i3co1 = coroutine.create(co_i3bar_out)
while true do
	util:run_co('i3bar_out', i3co1)
	socket.sleep(2)
end
