local awful = require("awful")
local freedesktop   = require("freedesktop")
local Config = require('config')

local Menu = {}
function Menu:setup(ctx)
	self.ctx = ctx
	return self
end
function Menu:apply()
	local beautiful = self.ctx.beautiful
	local terminal  = Config.terminal
	local editor    = Config.editor

	-- {{{ Menu
	local hotkeys_popup  = require("awful.hotkeys_popup")
	-- Enable hotkeys help widget for VIM and other apps
	-- when client with a matching name is opened:
	require("awful.hotkeys_popup.keys")

	-- Create a launcher widget and a main menu
	-- local menubar = require("menubar")
	local myawesomemenu = {
		{ "hotkeys",     function() return false, hotkeys_popup.show_help end },
		{ "manual",      terminal .. " -e man awesome" },
		{ "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
		{ "restart",     awesome.restart },
		{ "shutdown",    terminal .. " -e shutdown -h now" },
		{ "quit",        function() awesome.quit() end }
	}
	local mymainmenu = freedesktop.menu.build({
			icon_size = beautiful.menu_height or dpi(24),
			before = {
				{ "Awesome", myawesomemenu, beautiful.awesome_icon },
				-- other triads can be put here
			},
			after = {
				{ "terminal", terminal },
				-- other triads can be put here
			}
		})
	local mylauncher = awful.widget.launcher({
			image = beautiful.awesome_icon,
			menu = mymainmenu,
		})

	self.ctx.hotkeys_popup = hotkeys_popup
	self.ctx.myawesomemenu = myawesomemenu
	self.ctx.mymainmenu    = mymainmenu
	self.ctx.mylauncher    = mylauncher

	-- }}}
end




return Menu
