#!/usr/bin/env lua

-- BP --
package.path = os.getenv("HOME")..'/scripts/?.lua;' .. package.path
local Util = require("util")
local Proc = require('process')
--

local F = {}

function F.cat(path)
   local h = assert(io.open(path, 'r'))
   return function()
	  local l = h:read("*line")
	  if l == nil then
		 h:close()
	  end
	  return l
   end
end

function F.exec(path)
   local h = assert(io.popen(path))
   return function()
	  local l = h:read("*line")
	  if l == nil then
		 h:close()
	  end
	  return l
   end
end
function F.exec(cmd)
    Util:log("INFO", _MLOG, "exec> "..cmd)
    local s,err,sig = os.execute(cmd)
    return err
end
function F.assert_exec(cmd, m)
    Util:log("INFO", _MLOG, "exec> "..cmd)
    local s,err,sig = os.execute(cmd)
    if err=="exit" then
        if sig==0 then
            -- nothing to do
        else
            print(err,sig,m)
            os.exit(sig)
        end
    else
        if err=="signal" then
            print(err,sig,m)
            os.exit(sig)
        else
            print(err,sig,m)
            os.exit(sig)
        end
    end
end
function F.exec_stream(cmd, fn)
	local h = assert(io.popen(cmd))
	while true do
		local l = h:read("*line")
		if l == nil then break end
		fn(l)
	end
	h:close()
end
function F.grep(patt)
	return function(s)
		local r = {}
		r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8],r[9],r[10] = string.match(s, patt)
		if r[1] == nil then return nil end
		return r
	end
end
function listToString(list, level)
	if level == nil then level = 1 end
	local b = ''
	local i = 1
	for k, v in pairs(list) do
		if type(v) == 'function' then
			v = 'function'
		end
		if type(v) == 'table' then
			if level < 3 then
				v = listToString(v, level+1)
			end
		end
		if i==1 then
			b = string.format('%s', v)
		else
			b = string.format('%s, %s', b, v)
		end
		i = i + 1
	end
	return b
end
function F.echo()
	return function(s)
		if type(s) == 'function' then
			print('function')
		else
			if type(s) == 'table' then
				print(listToString(s))
			else
				print(s)
			end
		end
		return s
	end
end
function F.format(patt)
	return function(s)
		return string.format(patt, s)
	end
end

function F.flat(delim)
	return function(list)
		local s = ''
		for i,v in pairs(list) do
				if i == 1 then
					s = s .. v
				else
					s = s .. delim .. v
				end
		end
		return s
	end
end
function F.ln(s, t)
    F.exec(string.format("ln -svf %s %s", s, t))
end
function F.cp(s, t)
    F.exec(string.format("cp -vb %s %s", s, t))
end
function F.md(p)
    F.exec(string.format("mkdir -pv %s", p))
end
function F.wget(url)
    F.exec(string.format("wget %s", url))
end

-- mutually exclusive CPU arch flags
_ARCH_FLAG = {
    lm = "x86_64",
    BCM2835 = "aarch64" 
}
function F.arch()
    local flags = Proc.pipe()
	.add(F.cat("/proc/cpuinfo"))
    .add(Proc.branch()
        .add(F.grep("BCM2835"))
        .add(F.grep("lm"))
        .build()
    )
    .add(Proc.cull())
    .run()
    for _,i in ipairs(flags) do
        for _,j in ipairs(i) do
            print("arch flag: ", j)
            if _ARCH_FLAG[j] then
                return _ARCH_FLAG[j]
            end
        end
    end
    return "UnknownISA"
end

--
-- TESTS
-- 

function test()
    F.arch()
end

test()

return F
