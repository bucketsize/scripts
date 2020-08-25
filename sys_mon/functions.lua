#!/usr/bin/env lua

package.path = package.path .. '?.lua;../?.lua'
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
	local vol = string.match(result, "Volume:(.*)balance") -- TODO: optimize
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
	local result = Util:read("/sys/kernel/debug/dri/0/amdgpu_pm_info")
	if not result == nil then
		local tgpu = string.match(result, "GPU Temperature: (%d+) C")
		local mclk = string.match(result, "%s+(%d+) MHz%s+%ZMCLK")
		local sclk = string.match(result, "%s+(%d+) MHz%s+%ZSCLK")
		return tonumber(tgpu),tonumber(mclk),tonumber(sclk)
	end
	return 0,0,0
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

	return gw,dev,proto,tonumber(t[1]),tonumber(t[9])
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
