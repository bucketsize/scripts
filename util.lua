#!/usr/bin/env lua

_HOME = os.getenv("HOME")
_PATH = {
    "/bin/",
    "/sbin/",
    "/usr/bin/",
    "/usr/sbin/",
    "/usr/local/bin/",
    "/usr/local/sbin/",
    _HOME .. "/.local/bin/",
}
_MLOG = "/tmp/exec.1.out"
local Util = {}
function Util:log(level, file, msg)
   local h = assert(io.open(file, "a"))
   h:write(string.format("%s - %s - %s\n", os.date("%Y-%m-%dT%H:%M:%S+05:30"), level, msg))
   h:close()
end
function Util:path_exists(file)
	local h = io.open(file, "r")
	if h == nil then
		return false
	end
	h:close()
	return true
end
function Util:file_exists(file)
    for i,v in ipairs(_PATH) do
        local p = v..file
        if Util:path_exists(p) then
            return p
        end
    end
    return nil
end
function Util:assert_file_exists(file)
    if not Util:file_exists(file) then
        print(file .. " -> required") 
        os.exit(1)
    end
end
function Util:tofile(file, ot)
   local h = assert(io.open(file, 'w'))
   for k, v in ot:opairs() do
	  h:write(string.format('%s => %s\n', k, v))
   end
   h:close()
end
function Util:fromfile(file)
   local h = assert(io.open(file, 'r'))
   local r = Ot.newT()
   for l in h:lines() do
	  local k, v = string.match(l, "(.+) => (.+)")
	  r[k] = v
   end
   h:close()
   return r
end
function Util:segpath(path)
   function __segpath(a, path)
	  local l = string.len(path)
	  local s,f = string.find(path, "/")
	  if not f then
		 table.insert(a, path)
	  else
		 if f > 1 then
			local p = string.sub(path, 0, s-1)
			table.insert(a, p)
		 end
		 __segpath(a, string.sub(path, f+1))
	  end
   end
   local a = {}
   __segpath(a, path)
   return a
end
function Util:reverse(itable)
   local r = {}
   for i = #itable,1,-1 do
	  table.insert(r, itable[i])
   end
   return r
end
function Util:map(f, t)
	local r = {}
	for k, v in pairs(t) do
		r[k] = f(k, v)
	end
	return r
end
function Util:map2(fk, fv, t)
	local r = {}
	for k, v in pairs(t) do
	   r[fk(k)] = fv(v)
	end
	return r
end
function Util:filter(f, t)
	local r = {}
	for k, v in pairs(t) do
		if f(v) then
			r[k] = v
		end
	end
	return r
end
function Util:fold(f, t, i)
	local r = i
	for k, v in pairs(t) do
		r = f(v, r)
	end
	return r
end
function Util:f_else(p, fn1, fn2)
   if p then
 fn1()
   else
      return fn2()
   end
end
function Util:if_else(p, o1, o2)
   if p then
      return o1
   else
      return o2
   end
end
function Util:read(filename)
   local h = io.open(filename, "r")
   local r
   if h then
	  r = h:read("*a")
	  h:close()
   else
	  r = nil
   end
   return r
end
function Util:grep(file, pattern)
   local r = Util:stream_file(file,
							  function(line)
								 local m = string.match(line, pattern)
								 if m then
									return m
								 end
   end)
   for i,v in ipairs(r) do
	  if not (v == nil) then
		 return v
	  end
   end
end
function Util:launch(app)
   local cmd = string.format("nohup setsid %s > /dev/null &"
    , app:gsub("%%U", "/var/tmp")
    , _MLOG)
   Util:log("INFO", _MLOG, "exec> "..cmd)
   local h = assert(io.popen(cmd, "r"))
   local r = h:read("*a")
   socket.sleep(1) -- for some reason needed so exit can nohup process to 1
   h:close()
   Util:log("INFO", _MLOG, "out> "..r)
end
function Util:stream_file(cmd, fn)
   local h = assert(io.open(cmd, 'r'))
   local r = {}
   while true do
	  local l = h:read("*line")
	  if l == nil then break end
	  local s = fn(l)
	  if s then
		 table.insert(r,s)
	  end
   end
   h:close()
   return r
end
function Util:split(str, pat)
	local arr = {}
	for i in string.gmatch(str, pat) do
		table.insert(arr, i)
	end
	return arr
end
function Util:join(tag, list)
	local s=""
	for i,v in ipairs(list) do
		if i == #list then
			s = string.format("%s%s",s,v)
		else
			s = string.format("%s%s%s",s,v,tag)
		end
	end
	return s
end
function Util:iswhitespace(c)
	return (c == "" or c == " " or c == "\t")
end
function Util:strip(str)
	for i = 1, #str do
		local c = str:sub(i, i)
		--print(i,c)
		if not Util:iswhitespace(c) then
			for j = #str, 1, -1 do
				local r = str:sub(j, j)
				--print(j,r)
				if not Util:iswhitespace(r) then
					return str:sub(i, j)
				end
			end
		end
	end
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
math.randomseed(os.time())
function Util:rndstr()
    return string.format("%s-%s",os.time(),string.char(
        math.random(65, 90),
        math.random(65, 90),
        math.random(65, 90),
        math.random(65, 90)
        ))
end

Util.PSV_PAT='([%a%s%d-+_{}./]+)|'
Util.FILENAME_PAT='/([%a%d%s+=-_\\.\\]*)$'
-- CHILLCODE™


--
-- TESTS
--

function test()
    print("find", Util:file_exists("find"))
    print("fseer", Util:file_exists("fseer"))
    print("fseer.x86_64", Util:file_exists("fseer.x86_64"))
    print(Util:read("/proc/cpuinfo", "r"))
    print(Util:exec("ls -l", "r"))

    local cmd = string.format("~/scripts/detect.sh")
    local r = Util:exec(cmd)
    print(r)
end
function test_rndstr()
    print(Util:rndstr())
end
return Util
