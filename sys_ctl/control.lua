#!/usr/bin/env lua

----------------------------
package.path = package.path
   .. '?.lua;'
   .. 'scripts/lib/?.lua;'
   .. 'scripts/sys_ctl/?.lua;'
----------------------------

local Sh = require('shell')
local Pr = require('process')
local Util = require('util')

function mergeWith(f, t)
   for k, v in pairs(t) do
	  f[k] = v
   end
   return f
end

local Cmds = require('control_cmds')

local Funs = {}
mergeWith(Funs, require('control_x11'))
mergeWith(Funs, require('control_process'))
mergeWith(Funs, require('control_pulseaudio'))

------------------------------------------------------
local Fn = {}
function Fn:cmd(key)
   local cmd = Cmds[key]
   if cmd then
      print('cmd>', cmd)
      Util:exec(cmd)
   else
      print('cmd: ', key, 'not mapped')
   end
end
function Fn:fun(key)
   local cmd = Funs[key]
   if cmd then
      cmd = Funs[key]()
      if cmd then
	 if type(cmd) == 'table' then
	    for i,icmd in ipairs(cmd) do
	       Util:exec(icmd)
	    end
	 else
	    Util:exec(cmd)
	 end
      end
   else
      print('cmd: ', key, 'not mapped')
   end
end
function Fn:help()
   print("cmd")
   for k,v in pairs(Cmds) do
      print('\t',k)
   end
   print("fun")
   for k,v in pairs(Funs) do
      print('\t',k)
   end
end

local fn = Fn[arg[1]]
if fn == nil then
   print('huh!')
else
   fn(fn, arg[2])
end

return {Cmds = Cmds, Funs = Funs }
