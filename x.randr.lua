#!/bin/lua

local rcfg = {}
function rcfg:connect()
	local socket = require("socket")
	host = "localhost"
	port = 8080

	print('connecting ...')
	self.c = assert(socket.connect(host, port))
	return self
end
function rcfg:put(k, v)
	local c = self.c
	assert(c:send('put:' .. k .."=" .. tostring(v) .. "\n"))
	print('>> ')
	v, e = c:receive()
	if e then
		print('error: ' .. e)
	end
	print('<< ' .. v)
end
function rcfg:get(k, d)
	local c = self.c
	assert(c:send('get:' .. k .. "\n"))
	print('>> ')
	v, e = c:receive()
	if e then
		print('error: ' .. e)
	end
	print('<< ' .. v)
	if d and not v or v == nil then
		return d
	end
	return v
end

function init()
	local handle = io.popen("xrandr -q")
	local result = handle:read("*a")
	local dev = result:match('.*%s(.*)%sconnected')
	local xf, yf=800, 600
	for x, y in result:gmatch('%s+(%d+)x(%d+)%s+') do
		xf, yf = x, y
		break
	end
	handle:close()

	return {dev=dev, res=res, x=xf, y=yf}
end

local config = init()

local bri_default = 0.9
local cbase1=rcfg:connect()
local cmd=nil

if arg[1] == 'nightmode' then
	gam = '0.5:0.4:0.3'
	bri = tonumber(cbase1:get('bri', bri_default))
	cmd=string.format('xrandr --output %s --gamma %s --brightness %s', config.dev, gam, bri)
	cbase1:put('gam', gam)
elseif arg[1] == "lighten" then
	gam = cbase1:get('gam')
	bri = tonumber(cbase1:get('bri', bri_default)) + 0.1
	cmd=string.format('xrandr --output %s --gamma %s --brightness %s', config.dev, gam, bri)
	cbase1:put('bri', bri)
elseif arg[1] == 'darken' then
	gam = cbase1:get('gam')
	bri = tonumber(cbase1:get('bri', bri_default)) - 0.1
	cmd=string.format('xrandr --output %s --gamma %s --brightness %s', config.dev, gam, bri)
	cbase1:put('bri', bri)
end

if not (cmd == nil) then
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	print(result)
	handle:close()
end
