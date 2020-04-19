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
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/gtk/theme.lua")
beautiful.notification_opacity  = 70
beautiful.notification_width  = 200
beautiful.notification_height = 50
beautiful.notification_max_width  = 500
beautiful.notification_max_height = 50
beautiful.notification_icon_size  = 40


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

CTX              = {}
CTX.beautiful    = beautiful
CTX.root         = root

local menu       = require("menu")
menu:setup(CTX)
menu:apply()

local autostart  = require('autostart')
autostart:setup(CTX)
autostart:apply()

local klient  = require('klient')
klient:setup(CTX)
klient:apply()

local panel_top  = require('panel_top')
panel_top:setup(CTX)
panel_top:apply()

local panel_left  = require('panel_left')
panel_left:setup(CTX)
panel_left:apply()

-- local tasklist_popup = require('tasklist_popup')
-- tasklist_popup:setup(CTX)
-- tasklist_popup:apply()
-- tasklist_popup:toggle()

local wallpaper  = require('wallpaper')
wallpaper:setup(CTX)
wallpaper:apply()

local keyman     = require('keyman')
keyman:setup(CTX)
keyman:apply()

local rules      = require("rules")
rules:setup(CTX)
rules:apply()

local lockscreen = require('lockscreen')
lockscreen:setup(CTX)
lockscreen:apply()

