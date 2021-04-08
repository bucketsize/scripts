--
--------------------------------------------------------------------------------
--         File:  pkgq_size.lua
--
--        Usage:  ./pkgq_size.lua
--
--  Description:  
--
--      Options:  ---
-- Requirements:  ---
--         Bugs:  ---
--        Notes:  ---
--       Author:  YOUR NAME (), <>
-- Organization:  
--      Version:  1.0
--      Created:  02/21/21
--     Revision:  ---
--------------------------------------------------------------------------------
--
--

function calcOld()
	h = io.open('/var/tmp/pkgq.log', 'r')
	sz=0
	while true do
		l = h:read("*l")
		if l==nil then break end
		s,t,n = string.match(l, "(%d+.%d+)%s(%w+)")
		v=s
		if t=="MiB" then v=s*1024 end
		sz = sz + v
		print(s,t,n,v)
	end
	print(sz, sz/1024)
end

function calc()
	h = io.popen("pacman -Ss | grep \"\\[installed\"")
	sz=0
	i=0
	while true do
		l = h:read("*l")
		if l==nil then break end
		p = string.match(l, "%w+/([%w%p]+)%s")
		h2 = io.popen(string.format("pacman -Si %s | grep \"Installed\"", p))
		l2 = h2:read("*l")
		z,t = string.match(l2, "Installed Size%s+:%s(%d+.%d+)%s(%a+)")
		v=z
		if t=="MiB" then v=v*1024 end
		print(v, p)
		sz = sz + v
		i = i + 1
	end
	print(i, sz, sz/1024)
end


calc()
