#!/usr/bin/env lua

package.path = package.path
	.. '?.lua;'
	.. 'scripts/lib/?.lua;'
	.. 'scripts/sys_mon/?.lua;'

local Util = require("util")

local Al = {
	cpu = {
		trigger = 59,		count = 0,		highmark = 10
	},
	mem = {
		trigger = 79,		count = 0,		highmark = 10
	},
	cpu_temp = {
		trigger = 79,		count = 0,		highmark = 5
	}
}

function Al:alert(p)
	Util:exec(string.format('notify-send -u critical -c system "%s is overboard"', p))
	print(string.format('a: %s, c: %d, t: %s , h: %d', p, Al[p].count, Al[p].trigger, Al[p].highmark))
end

function Al:check(p, pc)
	local b = Al[p].trigger
	local a = Al[p].count
	local h = Al[p].highmark
	--print('1->',p, pc,":",type(pc), b,a,h)
	if pc > b then
		if a > h then
				Al:alert(p)
				h = h * 2 -- exponential backoff
		end
		a = a + 1
	else
		a = 0
	end
	Al[p].count = a
	Al[p].highmark = h
end

function test()
	for i=1,45 do
		Al:check('cpu', 80)
		Al:check('cpu_temp', 80)
	end
	print('done')
end

-- test()

return Al
