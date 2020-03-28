-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi

-- Notification library
local naughty = require("naughty")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
			title = "Oops, there were errors during startup!",
		text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
				title = "Oops, an error happened!",
			text = tostring(err) })
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "zenburn/theme.lua")
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/zenburn.theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "sakura"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

CTX = {}
CTX.beautiful = beautiful
CTX.terminal = terminal
CTX.editor = editor
CTX.root = root


local menu = require("menu")
menu:setup(CTX)
menu:apply()

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.fair,
}
-- }}}
--





	-- local function set_wallpaper(s)
	-- 	-- Wallpaper
	-- 	if beautiful.wallpaper then
	-- 		local wallpaper = beautiful.wallpaper
	-- 		-- If wallpaper is a function, call it with the screen
	-- 		if type(wallpaper) == "function" then
	-- 			wallpaper = wallpaper(s)
	-- 		end
	-- 		gears.wallpaper.maximized(wallpaper, s, true)
	-- 	end
	-- end

	-- -- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
	-- screen.connect_signal("property::geometry", set_wallpaper)

	-- awful.screen.connect_for_each_screen(function(s)
	-- 	-- Wallpaper
	-- 	set_wallpaper(s)


	-- 	local wiman = require('wiman')
	-- 	CTX.screen = s
	-- 	wiman:setup(CTX)
	-- 	wiman:apply()

	-- end)
		local panel_top = require('panel_top')
		panel_top:setup(CTX)
		panel_top:apply()
		
		local panel_left = require('panel_left')
		panel_left:setup(CTX)
		panel_left:apply()
		
		local wallpaper = require('wallpaper')
		wallpaper:setup(CTX)
		wallpaper:apply()
		-- }}}

	-- Set keys
		local keyman = require('keyman')
		keyman:setup(CTX)
		keyman:apply()


		local rules = require("rules")
		rules:setup(CTX)
		rules:apply()

	-- {{{ Signals
	-- Signal function to execute when a new client appears.
	client.connect_signal("manage", function (c)
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- if not awesome.startup then awful.client.setslave(c) end

		if awesome.startup
			and not c.size_hints.user_position
			and not c.size_hints.program_position then
			-- Prevent clients from being unreachable after screen count changes.
			awful.placement.no_offscreen(c)
		end
	end)

	-- Add a titlebar if titlebars_enabled is set to true in the rules.
	client.connect_signal("request::titlebars", function(c)
		-- buttons for the titlebar
		local buttons = gears.table.join(
			awful.button({ }, 1, function()
				c:emit_signal("request::activate", "titlebar", {raise = true})
				awful.mouse.client.move(c)
			end),
			awful.button({ }, 3, function()
				c:emit_signal("request::activate", "titlebar", {raise = true})
				awful.mouse.client.resize(c)
			end)
			)

		awful.titlebar(c) : setup {
			{ -- Left
				awful.titlebar.widget.iconwidget(c),
				buttons = buttons,
				layout  = wibox.layout.fixed.horizontal
			},
			{ -- Middle
				{ -- Title
					align  = "center",
					widget = awful.titlebar.widget.titlewidget(c)
				},
				buttons = buttons,
				layout  = wibox.layout.flex.horizontal
			},
			{ -- Right
				--awful.titlebar.widget.floatingbutton (c),
				awful.titlebar.widget.maximizedbutton(c),
				--awful.titlebar.widget.stickybutton   (c),
				awful.titlebar.widget.ontopbutton    (c),
				awful.titlebar.widget.closebutton    (c),
				layout = wibox.layout.fixed.horizontal()
			},
			layout = wibox.layout.align.horizontal
		}
	end)

	-- Enable sloppy focus, so that focus follows mouse.
	client.connect_signal("mouse::enter", function(c)
		c:emit_signal("request::activate", "mouse_enter", {raise = false})
	end)

	client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
	client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
	-- }}}
