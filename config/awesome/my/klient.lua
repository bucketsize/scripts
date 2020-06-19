local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local Klient = {}
function Klient:setup(ctx)
	self.ctx = ctx
	return self
end
function Klient:apply()
	local beautiful = self.ctx.beautiful
	-- {{{ Signals
	-- Signal function to execute when a new client appears.
	client.connect_signal("manage", function (c)
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- if not awesome.startup then awful.client.setslave(c) end

		local icon_image = {
			URxvt   = '/usr/share/icons/hicolor/128x128/apps/lxterminal.png',
			unknown = '/usr/share/icons/hicolor/128x128/apps/fcitx.png',
		}

		if c.icon == nil then
			print(">> c :: ",  c, c.icon, c.class)
			local image = icon_image[c.class]
			if image == nil then
				image = icon_image['unknown']
			end
			local icon = gears.surface(image)
			c.icon = icon and icon._native or nil
		end

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
					align  = "left",
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
		-- focus follow mouse
		-- c:emit_signal("request::activate", "mouse_enter", {raise = false})
	end)

	client.connect_signal("focus", function(c)
		c.border_color = beautiful.border_focus
	end)
	client.connect_signal("unfocus", function(c)
		c.border_color = beautiful.border_normal
	end)
	-- }}}
end


return Klient
