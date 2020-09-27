package.path = package.path
	.. '?.lua;'
	.. 'scripts/lib/?.lua;'
	.. 'scripts/sys_mon/?.lua;'

local Util = require('util')
local Process = require('process')

local F = {}

function F.cat(path)
	local h = io.open(path, 'r')
	return function()
		if not (h == nil) then
			local l = h:read("*line")
			if l == nil then
				h:close()
				h = nil
			end
			return l
		else
			return nil
		end
	end
end

function F.exec(path)
	local h = io.popen(path)
	return function()
		if not (h == nil) then
			local l = h:read("*line")
			if l == nil then
				h:close()
				h = nil
			end
			return l
		else
			return nil
		end
	end
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

function test_pipe()
	local m1,m2
	local r = Process.pipe()
		.add(F.cat('/proc/meminfo'))
		.add(Process.branch()
			.add(F.grep('MemFree'))
			.add(F.grep('SwapFree'))
			.build())
		.add(Process.cull())
		.add(function(list)
			for i,v in pairs(list) do
				if (i == 1) then m1=v end
				if (i == 2) then m2=v end
			end
			return list
		end)
		.add(F.tee())
		.run()
end

function test_pipe2()
	local m1,m2
	local r = Process.pipe()
		.add(F.exec('lspci'))
		.add(Process.branch()
			.add(F.grep('VGA.*'))
			.add(F.grep('Audio.*'))
			.build())
		.add(Process.cull())
		.add(function(list)
			for i,v in pairs(list) do
				if (i == 1) then m1=v end
				if (i == 2) then m2=v end
			end
			return list
		end)
		.add(F.echo())
		.run()
end

function test_cat()
	local cat = F.cat('/proc/meminfo')
	print(type(cat))

	p = cat()
	print(p)

	p = cat()
	print(p)
end

function test_listToString()
	local a = {A=123, b=45}
	print(listToString(a))
end

-- test_listToString()
-- test_pipe2()

return F
