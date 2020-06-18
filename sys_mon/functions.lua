#!/usr/bin/env lua
-- sys.mond.lua test
-- sys.mond.lua

package.path = package.path .. ';/home/jb/scripts/?.lua'
local Util = require("util")

local Fn={}

-- CPU --
function Fn:cpu_usage()
	local handle = io.open("/proc/stat", "r")
	local result = handle:read("*l")
	handle:close()
	local t,s1,z1,i={},0,0,0
	for d in string.gmatch(result, "%d+") do
		s1=s1+d
		t[i]=d
		i=i+1
	end
	z1=t[3]
	return s1,z1
end

-- MEM --
function Fn:mem_usage()
	local result = Util:read("/proc/meminfo")
	local mtotl = string.match(result, "MemTotal:%s+(%d+) kB")
	local mfree = string.match(result, "MemFree:%s+(%d+) kB")
	return 1-mfree/mtotl
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
	local result = Util:exec("pactl list sinks 2>&1")
	local vol = string.match(result, "Volume:(.*)balance")
	if vol == nil then
		return 0
	end
	volt=0
	for v in string.gmatch(vol, "/%s+(%d+)") do
		volt=volt+v
	end
	volt=volt/2
	return volt
end

-- TEMP --
local coretemp_files = {
    '/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp1_input',
    '/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp2_input',
    '/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp3_input',
}
function Fn:coretemp_usage()
    local ts = {}
    for i,v in ipairs(coretemp_files) do
        local handle = io.open(v, "r")
	    local result = handle:read("*l")
	    handle:close()
        ts[i] = tonumber(result)
    end
    return ts
end

function Fn:senors_usage_ryzen3_2200g()
	local result = Util:exec("sensors")
	local tcpu = string.match(result, "Tdie:%s++(%d+.%d+)°C")
	local tgpu = string.match(result, "edge:%s++(%d+.%d+)°C")
	return tonumber(tcpu),tonumber(tgpu)
end

function Fn:senors_usage_i3()
	local result = Util:exec("sensors")
	local tcpu = string.match(result, "CPU:%s++(%d+.%d+)°C")
	local tgpu = string.match(result, "GPU:%s++(%d+.%d+)°C")
	return tonumber(tcpu),tonumber(tgpu)
end


function Fn:gpu_usage_amdgpu()
	local result = Util:read("/sys/kernel/debug/dri/0/amdgpu_pm_info")
	local tgpu = string.match(result, "GPU Temperature: (%d+) C")
	local mclk = string.match(result, "%s+(%d+) MHz%s+%ZMCLK")
	local sclk = string.match(result, "%s+(%d+) MHz%s+%ZSCLK")
	return tonumber(tgpu),tonumber(mclk),tonumber(sclk)
end

-- NET --
function Fn:net_usage()
	local net_if_pat = "default via (%d+.%d+.%d+.%d+) dev (%w+) proto (%w+)"
	local result = Util:exec("ip route")
	local gw,dev,proto = string.match(result, net_if_pat)

	local net_stat_pat = dev .. ": (.+)%c"
	local r2 = Util:read("/proc/net/dev", "r")
	local r3 = string.match(r2, net_stat_pat)

	local t={}
	for i in string.gmatch(r3, "(%d+)") do
		table.insert(t, i)
	end

	return gw,dev,proto,t[1],t[9]
end

-- BAT --
function Fn:bat_usage()
	local r1 = Util:read("/sys/class/power_supply/BAT0/capacity")
	if r1 == "" then
		r1 = -1
	else
		r1 = tonumber(r1)
	end

	local r2 = Util:read("/sys/class/power_supply/BAT0/status")
	if r2 == "" then
		r2 = "AC"
	end

	return r1, r2
end

for k,fn in pairs(Fn) do
	print(k, fn())
end

return Fn
