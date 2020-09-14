#!/usr/bin/env lua

package.path = package.path .. '?.lua;../?.lua;lib/?.lua;../lib/?.lua;../../lib/?.lua'

local Util = require('util')
local Shell = require('shell')
local Proc = require('process')

local Fn = {}

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
		.add(Shell.echo())
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
	local r = Proc.pipe()
		.add(Shell.exec('ip route'))
		.add(Shell.grep('default via (%d+.%d+.%d+.%d+) dev (%w+) proto (%w+)'))
		.run()

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

if arg[1] == nil then
	for k,fn in pairs(Fn) do
		print('0> ' .. k, fn())
	end
else
	print(arg[1]..'> ', Fn[arg[1]]())
end

return Fn
