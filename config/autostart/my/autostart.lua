#!/usr/bin/env lua

local _HOME = os.getenv("HOME")
local fn = loadfile(_HOME.."/.local/bin/autostart_qtile")
fn()
autostart()



