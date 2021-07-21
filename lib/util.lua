local socket = require("socket")

local Util={}
function Util:if_else(p, o1, o2)
   if p then
      return o1
   else
      return o2
   end
end
function Util:file_exists(file)
	local h = io.open(file, "r")
	if h == nil then
		return false
	end
	h:close()
	return true
end
function Util:read(filename)
	local h = io.open(filename, "r")
	local r
	if h == nil then
		r = nil
	else
		r = h:read("*a")
		h:close()
	end
	return r
end
function Util:exec(cmd)
	local h = io.popen(cmd)
	local r
	if h == nil then
		r = ""
	else
		r = h:read("*a")
		h:close()
	end
	return r
end
function Util:exec_stream(cmd, fn)
	local h = io.popen(cmd)
	while true do
		local l = h:read("*line")
		if l == nil then break end
		fn(l)
	end
end
function Util:stream_file(cmd, fn)
	local h = io.open(cmd, 'r')
	while true do
		local l = h:read("*line")
		if l == nil then break end
		fn(l)
	end
end
function Util:split(str, pat)
	local arr = {}
	for i in string.gmatch(str, pat) do
		table.insert(arr, i)
	end
	return arr
end
function Util:printITable(t)
	for i,v in ipairs(t) do
		print(i .. ': ', v)
	end
end
function Util:printOTable(t)
	for i,v in pairs(t) do
		if type(v) == 'table' then
			print(i ..':')
			Util:printOTable(v)
		else
			print(i .. ': ', v)
		end
	end
end

--[[
   LUA 5.1 compatible

   Ordered Table
   keys added will be also be stored in a metatable to recall the insertion oder
   metakeys can be seen with for i,k in ( <this>:ipairs()  or ipairs( <this>._korder ) ) do ipairs( ) is a bit faster

   variable names inside __index shouldn't be added, if so you must delete these again to access the metavariable
   or change the metavariable names, except for the 'del' command. thats the reason why one cannot change its value
]]--
function Util:newT( t )
   local mt = {}
   -- set methods
   mt.__index = {
      -- set key order table inside __index for faster lookup
      _korder = {},
      -- traversal of hidden values
      hidden = function() return pairs( mt.__index ) end,
      -- traversal of table ordered: returning index, key
      ipairs = function( self ) return ipairs( self._korder ) end,
      -- traversal of table
      pairs = function( self ) return pairs( self ) end,
      -- traversal of table ordered: returning key,value
      opairs = function( self )
         local i = 0
         local function iter( self )
            i = i + 1
            local k = self._korder[i]
            if k then
               return k,self[k]
            end
         end
         return iter,self
      end,
      -- to be able to delete entries we must write a delete function
      del = function( self,key )
         if self[key] then self[key] = nil
            for i,k in ipairs( self._korder ) do
               if k == key then
                  table.remove( self._korder, i )
                  return
               end
            end
         end
      end,
   }
   -- set new index handling
   mt.__newindex = function( self,k,v )
      if k ~= "del" and v then
         rawset( self,k,v )
         table.insert( self._korder, k )
      end
   end
   return setmetatable( t or {},mt )
end
Util.PSV_PAT='([%a%s%d-+_{}./]+)|'
Util.FILENAME_PAT='/([%a%d%s+=-_\\.\\]*)$'
-- CHILLCODE™


-- print(Util:read("/proc/cpuinfo", "r"))
-- print(Util:exec("ls -l", "r"))

-- local cmd = string.format("~/scripts/pam_auth %s %s", "jb", "1234")
-- local r = Util:exec(cmd)
-- print(r)
-- local s = string.match(r, "status:%s(%w+)%c")
-- print('|' .. s ..'|')

function Util:run_co(k, co)
   local status = coroutine.status(co)
   if status == 'dead' then
      return print('co/ ' .. k, status)
   end
   local ok,res = coroutine.resume(co)
   if not ok then
      print('co/ ' .. k, res)
   end
end

Util.Timer = {
   epoc = 1,
   t = 0,
   fns = {},
   tick = function(self, interval, fn)
      table.insert(self.fns, {fn = fn, i = interval})
   end,
   start = function(self)
      print("run forever ...")
      while true do
	 for i, fd in ipairs(self.fns) do
	    if (self.t % fd.i) == 0 then
	       fd.fn()
	    end
	 end
	 socket.sleep(self.epoc)
	 self.t = self.t + 1
      end
   end
}

-----------
-- TESTS --
-----------
function test_split()
	local ss = Util:split("|jah { 11 | 97 | k5jk|-|+| 1 | |sk-dj|/mnt/foo bar - 1.mp4|", Util.PSV_PAT)
	Util:printTable(ss)
end

function test_timer()
   Util.Timer:tick(2, function() print(2) end)
   Util.Timer:tick(5, function() print(5) end)
   Util.Timer:tick(8, function() print(8) end)
   Util.Timer:start()
end

--test_timer()

return Util
