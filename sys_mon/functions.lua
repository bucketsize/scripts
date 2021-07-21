#!/usr/bin/env lua

local version = _VERSION:match("%d+%.%d+")
package.path  = '.luarocks/share/lua/' .. version .. '/?.lua;lua_modules/share/lua/' .. version .. '/?/init.lua;' .. package.path
package.cpath = '.luarocks/lib/lua/' .. version .. '/?.so;' .. package.cpath

package.path = package.path
   .. '?.lua;'
   .. 'scripts/lib/?.lua;'
   .. 'scripts/sys_mon/?.lua;'

local Util = require('util')
local Shell = require('shell')
local Proc = require('process')
local json = require("json")
local http_request = require("http.request")

local OpenWeatherApi="http://api.openweathermap.org/data/2.5/weather?q=bengaluru&appid=%s"
local OpenWeatherApiKey="16704e3405a0cb1a1ae1b7917e4ff2fd"
local Fn = {}

-- CPU --
function Fn:cpu_usage()
   local handle = io.open("/proc/stat", "r")
   local result = handle:read("*l")
   handle:close()
   -- print('-> result: ', result)
   local t,s1,z1,i={},0,0,0
   for d in string.gmatch(result, "%d+") do
      s1=s1+d
      t[i]=d
      i=i+1
   end
   z1=t[3]
   return s1,z1
end

function Fn:disc_usage()
   local handle = io.open("/sys/block/sda/stat", "r")
   local result = handle:read("*l")
   handle:close()
   local v={}
   local i=1
   for d in string.gmatch(result, "%d+") do
      v[tostring(i)] = d
      i=i+1
   end
   return v['1'], v['5']
end

local cpufreq_files={}
Util:exec_stream("ls /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq", function(f)
		    table.insert(cpufreq_files,f)
end)
function Fn:cpu_freq()
   local freq={}
   for i,v in ipairs(cpufreq_files) do
      local handle = io.open(v, "r")
      if not handle == nil then
	 local result = handle:read("*l")
	 handle:close()
	 freq[i]=tonumber(result)
      end
   end
   return freq
end

-- MEM --
function Fn:mem_usage()
   local rf,rt,sf,st
   Proc.pipe()
      .add(Shell.cat("/proc/meminfo"))
      .add(Proc.branch()
	   .add(Shell.grep("MemTotal:%s+(%d+) kB"))
	   .add(Shell.grep("MemFree:%s+(%d+) kB"))
	   .add(Shell.grep("SwapTotal:%s+(%d+) kB"))
	   .add(Shell.grep("SwapFree:%s+(%d+) kB"))
	   .build())
      .add(Proc.cull())
      .add(Proc.map(function(x)
		 if not (x[1]==nil) then rt=x[1][1]
		 elseif not (x[2]==nil) then rf=x[2][1]
		 elseif not (x[3]==nil) then st=x[3][1]
		 elseif not (x[4]==nil) then sf=x[4][1]
		 end
		 return x
	  end))
   -- .add(Shell.echo())
      .run()

   return 1-rf/rt, 1-sf/st
end

function Fn:ps_top()
   local t={}
   local result = Util:exec_stream(
      "ps -Ao user,pid,pcpu,pmem,comm --sort=-pcpu | head -n 6"
      , function(line)
	 local user,pid,pcpu,pmem,comm=string.match(line, "(%w+)%s+(%w+)%s+(%d+.%d+)%s+(%d+.%d+)%s+(%a+)")
	 local r={}
	 r['user']=user
	 r['comm']=comm
	 r['pid'] =pid
	 r['pcpu']=pcpu
	 r['pmem']=pmem
	 --print('->', user, comm, pcpu, pmem)
	 table.insert(t, r)
   end)
   return t
end
-- VOL --
function Fn:vol_usage()
   local v = Proc.pipe()
      .add(Shell.exec('pactl list sinks 2>&1'))
      .add(Shell.grep('Volume: f.*'))
      .add(Proc.map(function(s)
		 vol=0
		 for v in string.gmatch(s[1], "/%s+(%d+)") do
		    vol=vol+v
		 end
		 vol=vol/2
		 return vol
	  end))
      .run()
   local iv = Proc.pipe()
      .add(Shell.exec('pacmd list-sink-inputs'))
      .add(Shell.grep('state: RUNNING.*'))
   --.add(Shell.echo())
      .run()
   return v, not (iv == nil)
end

-- TEMP --
local hwmons={}
Util:exec_stream("ls /sys/class/hwmon/hwmon*/temp*_label", function(f)
		    local d = string.gsub(Util:read(f, 'r'), '%c', '', 1)
		    local h = string.gsub(f, 'label', 'input', 1)
		    --print('--> cpuT',h)
		    hwmons[d] = h
end)
function Fn:cputemp_usage()
   local ts = {}
   for i,v in pairs(hwmons) do
      local handle = io.open(v, "r")
      local result = handle:read("*l")
      handle:close()
      ts[i] = tonumber(result)
      --print('--> cpuT',i,result)
   end
   return ts
end

function Fn:gpu_usage_amdgpu()
   local vram_used = tonumber(Util:read("/sys/class/drm/card0/device/mem_info_vram_used"))
   local vram = tonumber(Util:read("/sys/class/drm/card0/device/mem_info_vram_total"))
   local tgpu=0
   local clkm=0
   local	clks=0
   local result = Util:read("/sys/kernel/debug/dri/0/amdgpu_pm_info")
   if not (result == nil) then
      local tgpu = string.match(result, "GPU Temperature: (%d+) C")
      local clkm = string.match(result, "%s+(%d+) MHz%s+%ZMCLK")
      local clks = string.match(result, "%s+(%d+) MHz%s+%ZSCLK")
   end
   return vram, vram_used, tonumber(tgpu),tonumber(clkm),tonumber(clks)
end

-- NET --
function Fn:net_usage()
   local r = Proc.pipe()
      .add(Shell.exec('ip route'))
      .add(Shell.grep('default via (%d+.%d+.%d+.%d+) dev (%w+) proto (%w+)'))
      .run()

   if r == nil then
      return "?", "?", "?",0,0
   end

   local net_stat_pat = r[2] .. ": (.+)%c"
   local r2 = Util:read("/proc/net/dev", "r")
   local r3 = string.match(r2, net_stat_pat)

   local t={}
   for i in string.gmatch(r3, "(%d+)") do
      table.insert(t, i)
   end

   return r[1],r[2],r[3],tonumber(t[1]),tonumber(t[9])
end

-- BAT --
function Fn:bat_usage()
   local cap = Util:read("/sys/class/power_supply/BAT0/capacity")
   if cap == nil or cap == "" then
      cap = "0"
   end

   local status = Util:read("/sys/class/power_supply/BAT0/status")
   if status == nil or status == "" then
      status = "AC"
   end

   return tonumber(cap), status
end

-- WEATHER --
function Fn:weather()
   local headers, stream = assert(http_request
				  .new_from_uri(string.format(OpenWeatherApi, OpenWeatherApiKey))
				  :go())
   local body = assert(stream:get_body_as_string())
   if headers:get ":status" ~= "200" then
      print("OpenWeatherApi Error:", body)
      return 0,0,"?"
   end
   print("-> weather: \n", body)
   local res = json.decode(body)
   local temperature = tonumber(res["main"]["temp"]) - 273.15
   local summary = res["weather"][1]["description"]
   local humidity = tonumber(res["main"]["humidity"])
   return temperature, humidity, summary
end


--------------------------------------------------------
if arg[1] == nil then
   for k,fn in pairs(Fn) do
      print('0> ' .. k, fn())
   end
else
   print(arg[1]..'> ', Fn[arg[1]]())
end

return Fn
