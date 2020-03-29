local awful = require("awful")
local wibox = require("wibox")
local lain  = require("lain")
local markup = lain.util.markup
local gears = require("gears")
local naughty = require("naughty")

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
	self.mylayoutbox = awful.widget.layoutbox(s)
	self.mylayoutbox:buttons(
		gears.table.join(
			awful.button({}, 1, function () awful.layout.inc( 1) end),
			awful.button({}, 3, function () awful.layout.inc(-1) end),
			awful.button({}, 4, function () awful.layout.inc( 1) end),
		  awful.button({}, 5, function () awful.layout.inc(-1) end))
		)

	-- Create a taglist widget
	self.mytaglist = awful.widget.taglist {
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		layout   = {
			layout  = wibox.layout.fixed.vertical
		},
	}

	-- Create a systray
	-- FIXME: not displaying when placed on wibar
	self.mysystray = wibox.widget.systray {
		opacity = 0.8,
		visibility = true,
		forced_width    = 40,
		forced_height   = 40,
	}

	-- Create a tasklist widget
	self.mytasklist = awful.widget.tasklist {
		screen  = s,
		filter  = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		style    = {
			shape_border_width = 1,
			shape_border_color = '#777777',
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

	-- Create the wibox
	self.mywibox2 = awful.wibar({ position = "left", screen = s, ontop = true,
		width = 42, opacity = 0.7 })

	-- Add widgets to the wibox
	self.mywibox2:setup {
		layout = wibox.layout.align.vertical,
		{ -- Left widgets
			layout = wibox.layout.fixed.vertical,
			-- self.mytaglist,
			self.mypromptbox,
		},
		self.mytasklist, -- Middle widget
		--self.mysystray,
		self.mylayoutbox
	}
end
return Wiman
