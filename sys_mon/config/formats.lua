#!/usr/bin/env lua

package.path = package.path
	.. '?.lua;'
	.. 'scripts/lib/?.lua;'
	.. 'scripts/sys_mon/?.lua;'

local Util =  require("util")

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
Fmt['weather_temperature']="%.1f"
Fmt['weather_humidity']="%.1f"
Fmt['weather_summary']="%s"

return Fmt
