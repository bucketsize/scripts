#!/usr/bin/env lua
-- sys.mond.lua test
-- sys.mond.lua

package.path = package.path .. ';/home/jb/scripts/?.lua;/home/jb/scripts/sys_mon/?.lua'
local socket = require("socket")
local Util = require("util")
local Fn = require("functions")
local Al = require("alerts")

local EPOC=2
local MTAB={}
local Fmt={
	cpu="%s: %3.0f",
	cpu_level="%s: %.0f",
	cpu_temp="%s: %.0f",
	cpu0="%s: %.0f",
	cpu1="%s: %.0f",
	cpu2="%s: %.0f",
	cpu3="%s: %.0f",
	mem="%s: %3.0f",
	mem_level="%s: %.0f",
	vol="%s: %3.0f",
	vol_level="%s: %.0f",
	gpu_temp="%s: %d",
	gpu_sclk="%s: %d",
	gpu_mclk="%s: %d",
	sensors="%s: %.0f",
	net_gateway="%s: %s",
	net_device="%s: %s",
	net_proto="%s: %s",
	net_tx="%s: %d",
	net_rx="%s: %d",
	net_ts="%s: %.0f",
	net_rs="%s: %.0f",
	p2_pid="%s: %s",
	p2_pcpu="%s: %s",
	p2_pmem="%s: %s",
	p2_name="%s: %s",
}
local ORen = {
	'cpu',
	'cpu_temp',
	'cpu0',
	'cpu1',
	'cpu2',
	'cpu3',
	'gpu_mclk',
	'gpu_temp',
	'mem',
	'vol',
	'net_tx',
	'net_rx',
	'p2_pid',
	'p2_pcpu',
	'p2_pmem',
	'p2_name'
}

local Co={}

-- CPU --
function Co:cpu_usage()
	local s0,z0,c=0,0,0
	while true do
		local s,z=Fn:cpu_usage()
		local c=1-(z-z0)/(s-s0)
		s0,z0=s,z
		MTAB['cpu'] = c*100
		MTAB['cpu_level'] = c*5
		Al:check('cpu', c*100)
		coroutine.yield()
	end
end
function Co:cpu_freq()
	while true do
		local freq=Fn:cpu_freq()
		for i,v in ipairs(freq) do
			MTAB['cpu'..tostring(i-1)] = v/1000
		end
		coroutine.yield()
	end
end

-- MEM --
function Co:mem_usage()
	while true do
		local m=Fn:mem_usage()
		MTAB['mem'] = m*100
		MTAB['mem_level'] = m*5
		coroutine.yield()
	end
end

-- MEM --
function Co:ps_top()
	while true do
		local m=Fn:ps_top()
		for i,p in ipairs(m) do
			MTAB[string.format('p%s_pid',i)] = p['pid']
			MTAB[string.format('p%s_pcpu',i)] = p['pcpu']
			MTAB[string.format('p%s_pmem',i)] = p['pmem']
			MTAB[string.format('p%s_name',i)] = p['comm']
			--print(MTAB['p2'])
		end
		coroutine.yield()
	end
end

-- VOL --
function Co:vol_usage()
	while true do
		local v=Fn:vol_usage()
		MTAB['vol'] = v
		MTAB['vol_level'] = v*0.05
		coroutine.yield()
	end
end

-- TEMP --
function Co:tem_usage()
	while true do
		local tcpu,_=Fn:senors_usage_ryzen3_2200g()
		MTAB['cpu_temp'] = tcpu
		Al:check('cpu_temp', tcpu)
		local tgpu,gmf,gsf=Fn:gpu_usage_amdgpu()
		--print('->', tgpu,gmf,gsf)
		MTAB['gpu_temp'] = tgpu
		MTAB['gpu_mclk'] = gmf
		MTAB['gpu_sclk'] = gsf
		coroutine.yield()
	end
end

-- NET --
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

-- BAT --
function Co:bat_usage()
	while true do
		local level,status=Fn:bat_usage()
		MTAB['bat_status']=status
		MTAB['bat_level']=level
		coroutine.yield()
	end
end

function num(x, d)
	if x == nil then
		return d
	else
		return x
	end
end

-- Log to '/tmp/sys.montor.out' --
function Co:logger()
	print("logging to ...\n\t/tmp/sys.montor.out\n\t/var/tmp/sys.monitor.log")
	while true do
		local hout = io.open("/tmp/sys.monitor.out", "w")
		local hlog = io.open("/var/tmp/sys.monitor.log", "a")
		for i,k in ipairs(ORen) do
			local fmt = Fmt[k]
			local v = MTAB[k]
			if v == nil then
				v = 0
				fmt = "%s: %d"
			end
			hout:write(string.format(fmt, k, v), "\n")
		end
		hout:close()
		hlog:write(string.format("%d,%.0f,%.0f,%d,%d,%.0f,%s,%s,%s,%s\n"
				, os.time()
				, num(MTAB['cpu'], 0)
				, num(MTAB['cpu_temp'], 0)
				, num(MTAB['gpu_mclk'], 0)
				, num(MTAB['gpu_temp'], 0)
				, num(MTAB['mem'], 0)
				, MTAB['p2_pid'], MTAB['p2_pcpu'], MTAB['p2_pmem'], MTAB['p2_name']
			))
		hlog:close()
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
			local status = coroutine.status(coInst)
			if status == 'dead' then
				print(k, status)
			end
			local ok,res = coroutine.resume(coInst)
			if not ok then
				print(k, ret, res)
			end
		end
		socket.sleep(EPOC)
	end
end

if arg[1] == nil then
	Cmd['start']()
else
	Cmd[arg[1]]()
end
