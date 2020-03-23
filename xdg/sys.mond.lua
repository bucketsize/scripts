#!/bin/lua

socket = require("socket")

EPOC=2
MTAB={}

Fn={}
Co={}

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

function Co:cpu_usage()
	local s0,z0,c=0,0,0
	while true do
		local s,z=Fn:cpu_usage()
		local c=1-(z-z0)/(s-s0)
		s0,z0=s,z
		MTAB['cpu'] = c*100
		MTAB['cpu_level'] = c*5 
		coroutine.yield()
	end
end

-- MEM --
function Fn:mem_usage()
	local handle = io.open("/proc/meminfo", "r")
	local result = handle:read("*a")
	handle:close()
	local mtotl = string.match(result, "MemTotal:%s+(%d+) kB")
	local mfree = string.match(result, "MemFree:%s+(%d+) kB")
	return 1-mfree/mtotl
end

function Co:mem_usage()
	while true do
		local m=Fn:mem_usage()
		MTAB['mem'] = m*100
		MTAB['mem_level'] = m*5
		coroutine.yield()
	end
end

-- VOL --
function Fn:vol_usage()
	local handle = io.popen("pactl list sinks")
	local result = handle:read("*a")
	handle:close()
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

function Co:vol_usage()
	while true do
		local v=Fn:vol_usage()
		MTAB['vol'] = v
		MTAB['vol_level'] = v*0.05
		coroutine.yield()
	end
end

-- TEMP --
function Fn:tem_usage()
	local tcpu_pat = "Tdie:%s++(%d+.%d+)°C"
	local tgpu_pat = "edge:%s++(%d+.%d+)°C"
	local handle = io.popen("sensors")
	local result = handle:read("*a")
	handle:close()
	local tcpu = string.match(result, tcpu_pat)
	local tgpu = string.match(result, tgpu_pat)
	return tcpu,tgpu
end

function Co:tem_usage()
	while true do
		local tcpu,tgpu=Fn:tem_usage()
		MTAB['cpu_temp'] = tcpu
		MTAB['gpu_temp'] = tgpu
		coroutine.yield()
	end
end

-- TEMP --
function Fn:net_usage()
	local net_if_pat = "default via (%d+.%d+.%d+.%d+) dev (%w+) proto (%w+)"
	local handle = io.popen("ip route")
	local result = handle:read("*a")
	handle:close()
	local gw,dev,proto = string.match(result, net_if_pat)

	local net_stat_pat = dev .. ": (.+)%c"
	local h2 = io.open("/proc/net/dev", "r")
	local r2 = h2:read("*a")
	h2:close()
	local r3 = string.match(r2, net_stat_pat)

	t={}
	for i in string.gmatch(r3, "(%d+)") do
		table.insert(t, i)
	end

	return gw,dev,proto,t[1],t[9]
end


function Co:net_usage()
	local tx0,rx0=0,0
	while true do
		local gw,dev,proto,tx,rx=Fn:net_usage()
		local ts,rs = (tx-tx0)/EPOC, (rx-rx0)/EPOC
		tx0,rx0=tx,rx

		MTAB['net_gateway']=gw
		MTAB['net_device']=dev
		MTAB['net_proto']=proto
		MTAB['net_tx']=tx
		MTAB['net_rx']=rx
		MTAB['net_ts']=ts
		MTAB['net_rs']=rs

		coroutine.yield()
	end
end

Fmt={
	cpu="%s: %3.0f",
	cpu_level="%s: %.0f",
	mem="%s: %3.0f",
	mem_level="%s: %.0f",
	vol="%s: %3.0f",
	vol_level="%s: %.0f",
	cpu_temp="%s: %.0f",
	gpu_temp="%s: %.0f",
	net_gateway="%s: %s",
	net_device="%s: %s",
	net_proto="%s: %s",
	net_tx="%s: %d",
	net_rx="%s: %d",
	net_ts="%s: %.0f",
	net_rs="%s: %.0f"
}

function Co:logger()
	print("logging metrics to '/tmp/sys.montor.out' ...")
	while true do
		local hout = io.open("/tmp/sys.monitor.out", "w")
		hout:write("<param>: <value>\n")
		for k,v in pairs(MTAB) do
			hout:write(string.format(Fmt[k], k, v), "\n")
		end
		hout:close()
		print('--> logged')
		coroutine.yield()
	end
end

-- START --
Cmd={}
CoInst={}
function Cmd:start()
	for k,co in pairs(Co) do
		CoInst[k] = coroutine.create(co)
		print('created co:', k)
	end
	while true do
		for k,coInst in pairs(CoInst) do
			print('resuming co:', k, coroutine.status(coInst))
			coroutine.resume(coInst)
		end
		socket.sleep(EPOC)
	end
end

function Cmd:test()
	for k,fn in pairs(Fn) do
		print(k, fn())
	end
end

Cmd[arg[1]]()
