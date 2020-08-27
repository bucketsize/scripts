local So={}

function createPipe(coi)
	print('|')
	return function(o)
		local coo = o.co
		while true do
			-- source
			local status = coroutine.status(coi)
			if status == 'dead' then
				return print('source', status)
			end
			local ok,res = coroutine.resume(coi)
			if not ok then
				return print('source', ret, res)
			end
			coi.next.val = res

			-- sink
			status = coroutine.status(coo)
			if status == 'dead' then
				return print('sink', status)
			end
			ok, res = coroutine.resume(coo, coi.next)
			if not ok then
				return print('sink', ret, res)
			end
		end
	end
end

function So:cat(path)
	local co = coroutine.create(function()
		local h = io.open(path, 'r')
		while true do
			local l = h:read("*line")
			if l == nil then break end
			coroutine.yield(l)
		end
	end)
	print('cat ' .. path)
	return {co=co, next={}, pipe=createPipe(co)}
end

function So:echo()
	local co = coroutine.create(function(next)
		while true do
			print(next.val)
			coroutine.yield(s)
		end
	end)
	print('echo ')
	return {co=co, next={}, pipe=createPipe(co)}
end


