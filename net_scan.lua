#!/usr/bin/env lua

local fn = {
	disc = function(ip)
		print("#discover network of", ip)
		local neti, rptip, ipup = {}, nil, false
		local f = assert(io.popen("sudo nmap -v -O --osscan-guess --osscan-limit --host-timeout 8 " .. ip, "r"))
		for x in f:lines("*l") do
			print(">", x)
			local port, host = x:match("Discovered open port ([%w%p]+) on (.*)")
			if host ~= nil and port ~= nil then
				if neti[host] == nil then
					neti[host] = { ports = {}, info = {} }
				else
					table.insert(neti[host].ports, port)
				end
			end

			local rpts, s = x:match("Nmap scan report for (%d+.%d+.%d+.%d+) (.*)")
			if rpts ~= nil and s:find("host down") == nil then
				rptip, ipup = rpts, true
				if neti[rptip] == nil then
					neti[rptip] = { ports = {}, info = {} }
				end
			end

			if rptip and ipup then
				-- MAC Address: AE:72:4B:8B:DE:1C (Unknown)
				-- Device type: general purpose
				-- Running: Microsoft Windows 10
				-- OS CPE: cpe:/o:microsoft:windows_10
				-- OS details: Microsoft Windows 10 1709 - 1909
				-- Network Distance: 1 hop
				-- TCP Sequence Prediction: Difficulty=263 (Good luck!)
				local mac = x:match("MAC Address: (.*)")
				if mac then
					table.insert(neti[rptip].info, mac)
				end
				local dev = x:match("Device type: (.*)")
				if dev then
					table.insert(neti[rptip].info, dev)
				end
				local os_run = x:match("Running: (.*)")
				if os_run then
					table.insert(neti[rptip].info, os_run)
				end
				local os_cpe = x:match("OS CPE: (.*)")
				if os_cpe then
					table.insert(neti[rptip].info, os_cpe)
				end
			end
		end
		for i, j in pairs(neti) do
			print(i)
			print("ports: ")
			for _, k in ipairs(j.ports) do
				print("- ", k)
			end
			print("info: ")
			for _, k in ipairs(j.info) do
				print("- ", k)
			end
		end
		return neti
	end,
	scan = function(ip)
		print("#scanning")
		local f = assert(io.popen("nmap -T5 -A " .. ip, "r"))
		for x in f:lines("*l") do
			print(x)
		end
	end,
	fastscan = function(ip)
		print("#fast scanning")
		local f = assert(io.popen("nmap -sV --allports -T4 " .. ip, "r"))
		for x in f:lines("*l") do
			print(x)
		end
	end,
	help = function()
		print([[
    net_scan help       - displayes this help
    net_scan disc <ip>  - discovers network
    net_scan scan <ip>  - deepscan the <ip>
    ]])
	end,
}

if arg[1] == nil or arg[2] == nil then
	fn["help"]()
else
	fn[arg[1]](arg[2])
end
