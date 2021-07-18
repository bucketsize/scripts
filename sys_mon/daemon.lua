#!/usr/bin/env lua

package.path = package.path
	.. '?.lua;'
	.. 'scripts/lib/?.lua;'
	.. 'scripts/sys_mon/?.lua;'

local socket = require("socket")

local Util = require('util')
local Sh = require('shell')
local Pr = require('process')
local Fn = require('functions')
local Al = require('alerts')

local Fmt = Util:newT()
Fmt['time']="%s"
Fmt['cpu']="%3.0f"
Fmt['cpu_level']="%.0f"
Fmt['cpu_temp']="%.0f"
Fmt['cpu0']="%.0f"
Fmt['cpu1']="%.0f"
Fmt['cpu2']="%.0f"
Fmt['cpu3']="%.0f"
Fmt['mem']="%3.0f"
Fmt['mem_level']="%.0f"
Fmt['snd_live']="%s"
Fmt['vol']="%3.0f"
Fmt['vol_level']="%.0f"
Fmt['gpu_mem']="%4f"
Fmt['gpu_mem_used']="%4f"
Fmt['gpu_mem_used_pc']="%3.0f"
Fmt['gpu_temp']="%d"
Fmt['gpu_sclk']="%4d"
Fmt['gpu_mclk']="%4d"
Fmt['Tdie']="%.0f"
Fmt['net_gateway']="%s"
Fmt['net_device']="%s"
Fmt['net_proto']="%s"
Fmt['net_tx']="%f"
Fmt['net_rx']="%f"
Fmt['net_ts']="%4.0f"
Fmt['net_rs']="%4.0f"
Fmt['p2_pid']="%s"
Fmt['p2_pcpu']="%s"
Fmt['p2_pmem']="%s"
Fmt['p2_name']="%s"
Fmt['cpu1_volt']="%s"
Fmt['cpu1_freq']="%s"
Fmt['cpu_fan']="%s"
Fmt['discio']="%d"
Fmt['discio_r']="%d"
Fmt['discio_w']="%d"
Fmt['fs_free']="%s"
Fmt['battery_status']="%s"
Fmt['battery']="%d"

local EPOC=2
local MTAB={}
for i,k in Fmt:ipairs() do
	MTAB[k] = 0
end

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
function Co:disc_usage()
	while true do
		local r,w=Fn:disc_usage()
		MTAB['discio_r'] = math.floor(r / 1000)
		MTAB['discio_w'] = math.floor(w / 1000)
		MTAB['discio'] = math.floor((r+w) / 1000)
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

-- PS --
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
		local v, s = Fn:vol_usage()
		MTAB['vol'] = v
		MTAB['vol_level'] = v*0.05
		MTAB['snd_live'] = s
		coroutine.yield()
	end
end

-- TEMP --
function Co:cputemp_usage()
	while true do
		local cputs = Fn:cputemp_usage()
		for i,v in pairs(cputs) do
			MTAB[i] = v / 1000
			Al:check('cpu_temp', MTAB[i])
		end
		MTAB['cpu_temp'] = cputs['Tdie'] / 1000
		coroutine.yield()
	end
end
function Co:gpu_usage_amdgpu()
	while true do
		local vram,vram_used,tgpu,gmf,gsf=Fn:gpu_usage_amdgpu()
		-- print('->', vram,vram_used,tgpu,gmf,gsf)
		MTAB['gpu_mem'] = vram / 1000000
		MTAB['gpu_mem_used'] = vram_used / 1000000
		MTAB['gpu_mem_used_pc'] = vram_used * 100 / vram
		MTAB['gpu_temp'] = tgpu
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
		MTAB['net_tx']=tx/100
		MTAB['net_rx']=rx/100
		MTAB['net_ts']=ts/100
		MTAB['net_rs']=rs/100

		coroutine.yield()
	end
end

-- BAT --
function Co:bat_usage()
	while true do
		local level,status=Fn:bat_usage()
		MTAB['battery_status']=status
		MTAB['battery']=level
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
	while true do
		local hout = io.open("/tmp/sys_mon.out", "w")
		local hlog = io.open("/var/tmp/sys_mon.log", "a")
		hout:write('\ntime: ', os.date("%Y-%m-%dT%H:%M:%S+05:30"), '\n')
		hlog:write(os.date("%Y-%m-%dT%H:%M:%S+05:30"), ',')
		for i,k in Fmt:ipairs() do
			local fmt = Fmt[k]
			local v = MTAB[k]
			print("-> ", k, v, type(v))
			hout:write(k,': ',string.format(fmt, v), "\n")
			hlog:write(string.format(fmt, v), ",")
		end
		hout:close()
		hlog:write('\n')
		hlog:close()
		coroutine.yield()
	end
end

function Co:cachemtab()
	while true do
		local cachec = require("cachec")
		for i,k in Fmt:ipairs() do
			local fmt = Fmt[k]
			local v = MTAB[k]
			cachec:put(k, string.format(fmt, v), "string")
		end
		coroutine.yield()
	end
end

-- START --
local CoInst={}
local Cmd={}
function Cmd:start()
	for k,co in pairs(Co) do
		Util:start_co(CoInst, k, co)
	end
	while true do
		MTAB['time'] = os.date("%Y-%m-%dT%H:%M:%S+05:30")
		for k,coInst in pairs(CoInst) do
			Util:run_co(k, coInst)
		end
		socket.sleep(EPOC)
	end
end


if arg[1] == nil then
	Cmd['start']()
else
	Cmd[arg[1]]()
end
