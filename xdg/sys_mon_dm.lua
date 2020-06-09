#!/usr/bin/env lua
-- sys.mond.lua test
-- sys.mond.lua

package.path = package.path .. ';/home/jb/scripts/?.lua;/home/jb/scripts/xdg/?.lua'
local socket = require("socket")
local Util = require("util")
local Fn = require("sys_mon_fn")

local EPOC=2
local MTAB={}
local Fmt={
	cpu="%s: %3.0f",
	cpu_level="%s: %.0f",
	cpu_temp="%s: %.0f",
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
	p1="%s: %s",
	p2="%s: %s",
	p3="%s: %s",
	p4="%s: %s",
	p5="%s: %s",
}
local ORen = {'cpu','cpu_temp','gpu_mclk','gpu_temp','mem','vol','net_tx','net_rx','p2','p3','p4'}

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
			MTAB['p' .. tostring(i)] = string.format('%s, pid=%s, cpu=%s, mem=%s'
				, p['comm'], p['pid'], p['pcpu'], p['pmem'])
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

-- Log to '/tmp/sys.montor.out' --
function Co:logger()
	print("logging metrics to '/tmp/sys.montor.out' ...")
	while true do
		local hout = io.open("/tmp/sys.monitor.out", "w")
		for i,k in ipairs(ORen) do
			local fmt = Fmt[k]
			local v = MTAB[k]
			if v == nil then
				v = ''
				fmt = "%s: %s"
			end
			hout:write(string.format(fmt, k, v), "\n")
		end
		hout:close()
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
