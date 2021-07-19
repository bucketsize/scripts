#!/usr/bin/env lua

package.path = package.path
	.. '?.lua;'
	.. 'scripts/lib/?.lua;'
	.. 'scripts/sys_mon/?.lua;'

local socket = require("socket")
local cachec = require("cachec")
local util = require("util")
local formats = require("formats")

local Sym ={
	cpu = "",
	gpu = "",
	mem = "",
	eth = "",
	wifi = "",
	disc = "",
	clock = "",
	battery = "",
	snd = "",
	snd_mute = "",
	disabled = "",
	temperature = "",
}

function if_else(p, o1, o2)
   if p then
      return o1
   else
      return o2
   end
end

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
	   print(string.format([[[
    {"full_text": "%s C %s"},
    {"full_text": "| %s%s"},
    {"full_text": "| %s %s C"},
    {"full_text": "| %s %s"},
    {"full_text": "| %s %s"},
    {"full_text": "| %s %s %s free"},
    {"full_text": "| %s %s"},
    {"full_text": "| %s %s %s"},
    {"full_text": "| %s %s"},
    {"full_text": "| %s %s"}
],]]
		, mtab['weather_temperature'], mtab['weather_summary']
		, Sym['eth'], if_else(mtab['net_gateway']=="?", Sym['disabled'], "")
		, Sym['cpu'], mtab['cpu']
		, Sym['temperature'], mtab['cpu_temp']
		, Sym['mem'], mtab['mem']
		, Sym['gpu'], mtab['gpu_mem_used_pc']
		, Sym['disc'], mtab['discio'], mtab['fs_free']
		, Sym['battery'], mtab['battery_status'], mtab['battery']
		, Sym['snd'], mtab['vol']
		, Sym['clock'], os.date("%a %b %d, %Y | %H:%M")))
	   coroutine.yield()
	end
end

local i3co1 = coroutine.create(co_i3bar_out)
while true do
	util:run_co('i3bar_out', i3co1)
	socket.sleep(2)
end
