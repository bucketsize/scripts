local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

local Wiman = {}
function Wiman:setup(ctx)
	self.ctx = ctx
	return self
end
function Wiman:apply_wallpaper_in_screen(s)
	local beautiful = self.ctx.beautiful
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end
function Wiman:apply()
	-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
	screen.connect_signal("property::geometry", function(s)
		self:apply_wallpaper_in_screen(s)
	end)

	-- Setup screen and stuff
	awful.screen.connect_for_each_screen(function(s)
		self:apply_wallpaper_in_screen(s)
	end)
end
return Wiman
