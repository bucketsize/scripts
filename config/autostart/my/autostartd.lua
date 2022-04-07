#!/usr/bin/env lua

require "luarocks.loader"

local Lr = require("minilib.process_listener")
local Sh = require("minilib.shell")
local Ut = require("minilib.util")

local USER = os.getenv("USER")
Lr.new_listener()
	.listen(USER, "weston",  "start", function()
		print("handle multi vt startup")
	end)
	.listen(USER, "openbox", "start", function()
		print("handle multi vt startup")
	end)
	.start()

