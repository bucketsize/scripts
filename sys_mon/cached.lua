local socket = require("socket")
local server = assert(socket.bind("*", 51515))
local tcp = assert(socket.tcp())

tcp:listen(10)

print(socket._VERSION)
print(tcp)

local Cache = {}

local Handler = {
   put = function(client, so)
      local k, v = so:match("([%w_]+)|(.*)")
      print(">> put", k, v )
      Cache[k] = v
      print("<< ok")
      client:send("ok\n")
   end,
   get = function(client, so)
      local k, v = so:match("([%w_]+)")
      print(">> get", k, v )
      print("<< ", Cache[k])
      if Cache[k] == nil then
	 client:send("\n")
      else
	 client:send(Cache[k].."\n")
      end
   end,
   getAll = function(client, so)
      print(">> getAll *")
      print("<< all")
      for k,v in pairs(Cache) do
	 client:send(string.format("%s|%s\n", k, v))
      end
   end
}

while true do
   local client = server:accept()
   client:settimeout(10)
   local line, err = client:receive("*l")
   if not err then
      local op, oo = line:match("(%w+)|(.*)")
      if not (Handler[op] == nil) then
	 Handler[op](client, oo)
      else
	 print("!! nothing")
	 client:send("error\n")
      end
   end
   client:close()
end
