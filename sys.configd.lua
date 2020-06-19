local socket = require("socket")
host = host or "*"
port = port or 8080

print("listening on: " ..host.. ":" ..port.. "...")
s = assert(socket.bind(host, port))
i, p = s:getsockname()
assert(i, p)

count = 0
map = {}
while 1 do
	c = assert(s:accept())
	ci, cp = c:getsockname()
	assert(ci, cp)
	print("client connected")

	while not e do
		count = count + 1
		l, e = c:receive()
		if not e then
			print('<< ' .. l)
			local m, a = l:match('(%a+):(.*)')
			print('got:' .. m .. ', ' .. a)
			if m == 'put' then
				local k, v = a:match('(%a+)=(.*)')
					print('storing: ' .. k .. ', ' .. v)
				if k then
					map[k] = v
				end
				c:send("ok\n")
			end
			if m == 'get' then
				local k, v = a, nil
				if k then
					v = map[k]
				end
				c:send(tostring(v) .. "\n")
			end
			print('>> ')
		end
	end
	print('error: ' .. e)
	e=nil
end
