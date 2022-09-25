#!/usr/bin/env lua

require "luarocks.loader"
package.path = '/?.lua;' .. package.path

local Ut = require('minilib.util')
local Sh = require('minilib.shell')
local Pr = require('minilib.process')

local fn = {
  disc = function (ip)
	local neti = {}
	Pr.pipe()
      .add(Sh.exec(string.format("nmap -v -n  %s", ip)))
      .add(Sh.grep("Discovered open port ([%w%p]+) on (.*)"))
      .add(Sh.echo())
	  .add(function(m)
		  if m == nil then return m end
		  if neti[m[2]] == nil then
			  neti[m[2]] = {m[1]}
		  else
			  table.insert(neti[m[2]], m[1])
		  end
		  return m
	  end)
      .run()
  	Ut:printOTable(neti)
  end,

  scan = function (ip)
    Pr.pipe()
      .add(Sh.exec(string.format("nmap -T5 -A  %s", ip)))
      .add(Sh.echo())
      .run()
  end,

  help = function ()
    print ([[
    net_scan help       -  displayes this help
    net_scan disc <ip>  - discovers network
    net_scan scan <ip>  - deepscan the <ip>
    ]])
  end
}

if arg[1] == nil or arg[2] == nil
then 
	fn["help"]()
else
	fn[arg[1]](arg[2])
end
