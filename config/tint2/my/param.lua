#!/bin/lua

BASEDIR=arg[0]:match(".*/")
ICON_PATH=BASEDIR .. 'icons/'
ICON_MAP = {
	cpu = 'cpu.svg',
	mem = 'mem.svg',
	vol = 'vol%s.svg',
	net_device = 'net.svg',
	tem = 'tem.svg',
	bri = 'bri%s.svg',
	bat = 'bat%s.svg'
}

function resolve_indicator(sym)
	local handle = io.open("/tmp/sys.monitor.out", "r")
	local result = handle:read("*a")
	handle:close()
	local l = string.match(result, sym .. "_level:%s+(%w+)%c")
	local v = string.match(result, sym .. ":%s+(%w+)%c")
	local fmt = ICON_MAP[sym]
	if fmt == nil then
		fmt = "question.svg"
	end
	print(ICON_PATH .. string.format(fmt, l))
	print(v)
end

resolve_indicator(arg[1])
