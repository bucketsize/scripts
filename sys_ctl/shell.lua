local F = {}

function F:cat(path)
	local h = io.open(path, 'r')
	return function()
		while true do
			local l = h:read("*line")
			if l == nil then break end
			return l
		end
		h:close()
	end
end

function F:grep(patt)
	return function(s)
		local r = string.match(s, patt)
		if r == nil then
			return ''
		else
			return r
		end
	end
end

function F:tee(path)
	return function(s)
		print(s)
	end
end

function F:format(patt)
	return function(s)
		return string.format(patt, s)
	end
end

function F:flat(delim)
	return function(list)
		local s = ''
		for i,v in pairs(list) do
			if not v == '' then
				if i == 1 then
					s = s .. v
				else
					s = s .. delim .. v
				end
			end
		end
		return s
	end
end

function F:pipe()
	local s = {}
	local t = 1
	local p = {}
	function p:add(f)
		s[t] = f
		t = t + 1
		return p
	end
	function p:run()
		for r in s[1] do
			local a = r
			for i = 2, t-1 do
				a = s[i](a)
			end
		end
	end
	return p
end

function F:branch()
	local s = {}
	local t = 1
	local p = {}
	function p:add(f)
		s[t] = f
		t = t + 1
		return p
	end
	function p:run()
		return function(r)
			local out = {}
			for i = 1, t-1 do
				out[i] = s[i](r)
			end
			return out
		end
	end
	return p
end

F:pipe()
	:add(F:cat('/proc/meminfo'))
	:add(F:branch()
		:add(F:grep('MemTotal'))
		:add(F:grep('MemFree'))
		:run())
	:add(F:flat('\n'))
	:add(F:tee('/var/tmp/1.tmp'))
	:run()


-- for s in Iter:cat('/proc/meminfo') do
-- 	print(s)
-- end

--So:cat('/proc/cpuinfo').pipe(So:echo())


