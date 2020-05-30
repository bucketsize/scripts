local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

local Wiman = {}
function Wiman:setup(ctx)
	self.ctx = ctx
	return self
end
function Wiman:apply()
	awful.screen.connect_for_each_screen(function(s)
		self:apply_in_screen(s)
	end)
end
function Wiman:apply_in_screen(s)
	-- Create a wibox for each screen and add it
	local taglist_buttons = gears.table.join(
		awful.button({ }, 1, function(t) t:view_only() end),
		awful.button({ modkey }, 1, function(t)
			if client.focus then
				client.focus:move_to_tag(t)
			end
		end),
		awful.button({ }, 3, awful.tag.viewtoggle),
		awful.button({ modkey }, 3, function(t)
			if client.focus then
				client.focus:toggle_tag(t)
			end
		end),
		awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end))

	local tasklist_buttons = gears.table.join(
		awful.button({ }, 1, function (c)
			if c == client.focus then
				c.minimized = true
			else
				c:emit_signal(
					"request::activate",
					"tasklist",
					{raise = true}
					)
			end
		end),
		awful.button({ }, 3, function()
			awful.menu.client_list({ theme = { width = 250 } })
		end),
		awful.button({ }, 4, function ()
			awful.client.focus.byidx(1)
		end),
		awful.button({ }, 5, function ()
			awful.client.focus.byidx(-1)
		end)
		)
	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4" }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	self.mypromptbox = awful.widget.prompt()
	self.ctx.mypromptbox = self.mypromptbox

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	local layoutbox0 = awful.widget.layoutbox(s)
	layoutbox0:buttons(
		gears.table.join(
			awful.button({}, 1, function () awful.layout.inc( 1) end),
			awful.button({}, 3, function () awful.layout.inc(-1) end),
			awful.button({}, 4, function () awful.layout.inc( 1) end),
		  awful.button({}, 5, function () awful.layout.inc(-1) end))
		)

	local dpi = require("beautiful.xresources").apply_dpi
	self.layoutbox = wibox.container.margin(layoutbox0, dpi(4), dpi(4), dpi(4), dpi(0))

	-- Create a taglist widget
	self.taglist = awful.widget.taglist {
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		layout   = {
			layout  = wibox.layout.fixed.vertical
		},
	}

	-- Create a systray
	-- FIXME: not displaying when placed on wibar
	self.systray = wibox.widget.systray {
		forced_width    = 32,
		forced_height   = 32,
		layout  = wibox.layout.fixed.vertical
	}

	-- Create a tasklist widget
	self.tasklist = awful.widget.tasklist {
		screen  = s,
		filter  = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		style    = {
			shape_border_width = 0,
		},
		layout   = {
			spacing = 2,
			layout  = wibox.layout.fixed.vertical
		},
		widget_template = {
			{
				{
					id     = 'clienticon',
					widget = awful.widget.clienticon,
				},
				margins = 4,
				widget  = wibox.container.margin,
			},
			id              = 'background_role',
			forced_width    = 40,
			forced_height   = 40,
			widget          = wibox.container.background,
			create_callback = function(self, c, index, objects) --luacheck: no unused
				self:get_children_by_id('clienticon')[1].client = c
			end,
		},
	}

	local Widgets = require('widgets')

	-- Create the wibox
	self.wibox = awful.wibar({ position = "left", screen = s, -- ontop = true,
		width = 42, opacity = 0.7 })

	-- Add widgets to the wibox
	self.wibox:setup {
		layout = wibox.layout.align.vertical,
		{ -- Left widgets
			layout = wibox.layout.fixed.vertical,
			Widgets.app_launcher,
			-- self.taglist,
			-- self.promptbox,
		},
		self.tasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.vertical,
			Widgets.cpu,
			Widgets.cpu_temp,
			Widgets.vol_ctrl,
			self.systray,
			self.layoutbox,
		}
	}
end
return Wiman
