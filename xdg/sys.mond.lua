#!/bin/lua

socket = require("socket")

EPOC=2
MTAB={}

-- CPU --
function cpu_usage()
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

function cpu_usage_co()
	local s0,z0,c=0,0,0
	while true do
		local s,z=cpu_usage()
		local c=1-(z-z0)/(s-s0)
		s0,z0=s,z
		MTAB['cpu'] = c
		coroutine.yield()
	end
end

-- MEM --
function mem_usage()
	local handle = io.open("/proc/meminfo", "r")
	local result = handle:read("*a")
	handle:close()
	local mtotl = string.match(result, "MemTotal:%s+(%d+) kB")
	local mfree = string.match(result, "MemFree:%s+(%d+) kB")
	return 1-mfree/mtotl
end

function mem_usage_co()
	while true do
		local m=mem_usage()
		MTAB['mem'] = m
		coroutine.yield()
	end
end

-- VOL --
function vol_usage()
	local handle = io.popen("pactl list sinks")
	local result = handle:read("*a")
	handle:close()
	vol = string.match(result, "Volume:(.*)balance")
	volt=0
	for v in string.gmatch(vol, "/%s+(%d+)") do
		volt=volt+v
	end
	volt=volt/2
	return volt
end

function vol_usage_co()
	while true do
		local v=vol_usage()
		MTAB['vol'] = v
		coroutine.yield()
	end
end

-- TEMP --
function tem_usage()
	local tcpu_pat = "Tdie:%s++(%d+.%d+)°C"
	local tgpu_pat = "edge:%s++(%d+.%d+)°C"
	local handle = io.popen("sensors")
	local result = handle:read("*a")
	handle:close()
	local tcpu = string.match(result, tcpu_pat)
	local tgpu = string.match(result, tgpu_pat)
	return tcpu,tgpu
end

function tem_usage_co()
	while true do
		local tcpu,tgpu=tem_usage()
		MTAB['cpu_temp'] = tcpu
		MTAB['gpu_temp'] = tgpu
		coroutine.yield()
	end
end

-- TEMP --
function net_usage()
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


function net_usage_co()
	local tx0,rx0=0,0
	while true do
		local gw,dev,proto,tx,rx=net_usage()
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

function logger_co()
	print("logging metrics to '/tmp/sys.montor.out' ...")
	while true do
		local hout = io.open("/tmp/sys.monitor.out", "w")
		hout:write("<param>:", "<value>")
		hout:write('\ncpu:', string.format("%.0f", MTAB['cpu']*100))
		hout:write('\nmem:', string.format("%.0f", MTAB['mem']*100))
		hout:write('\nvol:', string.format("%.0f", MTAB['vol']))
		hout:write('\ncpu_temp:', string.format("%.0f", MTAB['cpu_temp']))
		hout:write('\ngpu_temp:', string.format("%.0f", MTAB['gpu_temp']))
		hout:write('\nnet_gateway:', MTAB['net_gateway'])
		hout:write('\nnet_device:', MTAB['net_device'])
		hout:write('\nnet_proto:', MTAB['net_proto'])
		hout:write('\nnet_tx:', MTAB['net_tx'])
		hout:write('\nnet_rx:', MTAB['net_rx'])
		hout:write('\nnet_ts:', string.format("%.0f", MTAB['net_ts']))
		hout:write('\nnet_rs:', string.format("%.0f", MTAB['net_rs']))
		hout:close()
		coroutine.yield()
	end
end

-- START --
function monitor()
	local co_mem=coroutine.create(mem_usage_co)
	local co_cpu=coroutine.create(cpu_usage_co)
	local co_vol=coroutine.create(vol_usage_co)
	local co_tem=coroutine.create(tem_usage_co)
	local co_net=coroutine.create(net_usage_co)
	local co_logger=coroutine.create(logger_co)
	while true do
		coroutine.resume(co_mem)
		coroutine.resume(co_cpu)
		coroutine.resume(co_vol)
		coroutine.resume(co_tem)
		coroutine.resume(co_net)
		coroutine.resume(co_logger)
		socket.sleep(EPOC)
	end
end

monitor()
