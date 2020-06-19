local awful   = require("awful")
local wibox   = require("wibox")
local gears   = require("gears")
local naughty = require("naughty")

function objdump(tag, o)
	print(tag .. ':')
	if type(o) == 'table' then
		for k,v in pairs(o) do
			print('\t' .. k .. ' = ' .. tostring(v))
		end
	else
		print('\t' .. tostring(o))
	end
end

local Widgets = require('widgets')

local Wiman = {}
function Wiman:setup(ctx)
	self.ctx = ctx
	self:build()
	return self
end

function Wiman:build()
	local theme = self.ctx.beautiful.get()
end

function Wiman:apply()
	-- Setup screen and stuff
	awful.screen.connect_for_each_screen(function(s)
		self:apply_in_screen(s)
	end)
end
function Wiman:apply_in_screen(s)
	-- Create the wibox
	self.mywibox = awful.wibar({ position = "top", screen = s, -- ontop = true
			opacity = 0.8
		})

	-- Add widgets to the wibox
	self.mywibox:setup {
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.flex.horizontal,
			bat_stat,
		},
		kb,
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			Widgets.cpu,
			Widgets.mem,
			Widgets.cpu_temp,
			Widgets.gpu_temp,
			Widgets.net,
			Widgets.vol_ctrl,
			Widgets.fs_stat,
			Widgets.clock,
		},
	}
end
return Wiman
