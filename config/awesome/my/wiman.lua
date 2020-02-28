local awful = require("awful")
local wibox = require("wibox")
local lain  = require("lain")
local markup = lain.util.markup
local gears = require("gears")
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

local icons_path = gears.filesystem.get_configuration_dir() .. 'themes/icons'
local icons = {
		cpu=icons_path .. '/cpu.png',
		mem=icons_path .. '/mem.png',
		vol=icons_path .. '/vol.png',
		temp=icons_path .. '/temp.png',
		net=icons_path .. '/net.png',
		bat=icons_path .. '/battery.png',
		bat_empty=icons_path .. '/battery.png',
		bat_low=icons_path .. '/battery.png',
		hdd=icons_path .. '/hdd.png',
		any=icons_path .. '/hdd.png',

	}

function create_icon(icon_path)
	if not icon_path then
		icon_path = icons.any
	end
	local image =  wibox.widget {
			image = icon_path,
			resize = false,
			widget = wibox.widget.imagebox,

	}
	local icon = wibox.widget {
		image,
		top = 3,
		widget = wibox.container.margin
	}
	icon.image = image
	return icon
end
function create_wgt(icon, actual)
	local wgt = wibox.widget {
		icon,
		actual,
		layout = wibox.layout.fixed.horizontal
	}
	wgt.actual = actual
	return wgt
end


Wiman = {}
function Wiman:setup(ctx)
	self.ctx = ctx
	self:build()
	return self
end

function Wiman:build()
	local theme = self.ctx.beautiful.get()

	local	sprtr = wibox.widget.textbox()
	sprtr:set_text(" | ")

	local wgts = {}
	wgts.kb = awful.widget.keyboardlayout()


	---- Clock / Calendar
	wgts.clock_icon = create_icon(icons.clock)
	wgts.clock = wibox.widget.textclock()
	-- wgts.cal = create_wgt(
	-- 	'/usr/share/icons/Arc/devices/symbolic/media-flash-symbolic.svg',
	-- 	lain.widget.cal({
	-- 			attach_to = { wgts.clock },
	-- 			notification_preset = {
	-- 				font = theme.font_mono,
	-- 				fg   = theme.fg_normal,
	-- 				bg   = theme.bg_normal
	-- 			}
	-- 		})
	-- 	)
	local cal = require("awesome-wm-widgets/calendar-widget/calendar")
	wgts.cal = cal({
			theme = 'dark',
			placement = 'top_right'
		})
	wgts.clock:connect_signal("button::press",
		function(_, _, _, button)
			if button == 1 then wgts.cal.toggle() end
		end)

		---- MEM
		wgts.mem_icon = create_icon(icons.mem)
		wgts.mem = create_wgt(
			wgts.mem_icon,
			lain.widget.mem({
					settings = function()
						widget:set_markup(markup.font(theme.font, string.format("%04i%s", mem_now.used, "M")))
					end
				})
			)
		-- local mem = require("widgets/memarc-widget/memarc")
		-- wgts.mem = mem()

		---- CPU
		wgts.cpu_icon = create_icon(icons.cpu)
		wgts.cpu = create_wgt(
			wgts.cpu_icon,
			lain.widget.cpu({
					settings = function()
						widget:set_markup(markup.font(theme.font, string.format("%02i%s", cpu_now.usage, "")))
					end
				})
			)
		-- local cpu = require("widgets/cpuarc-widget/cpuarc")
		-- wgts.cpu = cpu()

		---- Coretemp
		wgts.temp_icon = create_icon(icons.temp)
		wgts.temp = create_wgt(
			wgts.temp_icon,
			lain.widget.temp({
					settings = function()
						widget:set_markup(markup.font(theme.font, string.format("%s°C", coretemp_now )))
					end
				})
			)

		---- / fs
		wgts.fs_icon = create_icon(icons.hdd)
		wgts.fs = create_wgt(
			wgts.fs_icon,
			lain.widget.fs({
					notification_preset = { fg = theme.fg_normal, bg = theme.bg_normal, font = theme.font_mono },
					settings = function()
						widget:set_markup(markup.font(theme.font_mono, string.format("%02i%s",fs_now["/"].percentage, "")))
					end
				})
			)
		-- local fs = require("widgets/fsarc-widget/fsarc")
		-- wgts.fs = fs()

		---- Battery
		wgts.bat_icon = create_icon(icons.bat)
		wgts.bat = create_wgt(
			wgts.bat_icon,
			lain.widget.bat({
					settings = function()
						if bat_now.status and bat_now.status ~= "N/A" then
							if bat_now.ac_status == 1 then
							elseif not bat_now.perc and tonumber(bat_now.perc) <= 5 then
							elseif not bat_now.perc and tonumber(bat_now.perc) <= 15 then
							else
							end
							widget:set_markup(markup.font(theme.font, string.format("%02i%s", bat_now.perc, "")))
						else
							widget:set_markup(markup.font(theme.font, "AC"))
						end
					end
				})
			)
		-- local bat = require("awesome-wm-widgets/batteryarc-widget/batteryarc")
		-- wgts.bat = bat()

		---- ALSA/pulse volume
		wgts.vol_icon = create_icon(icons.vol)
		wgts.vol = create_wgt(
			wgts.vol_icon,
			lain.widget.pulse({
					timeout = 5,
					settings = function()
						--objdump('pulse', volume_now)
						if (volume_now.index == 'N/A') then
							-- Annoying
							-- naughty.notify({
							-- 		preset = naughty.config.presets.critical,
							-- 		title = "pulseaudio may not be running, start it!",
							-- 	})
							print("Pulseaudio daemon not running, start it.")
							return
						end
						local vl, vr = tonumber(volume_now.left), tonumber(volume_now.right)
						local v = vl
						if (v < vr) then
							v = vr
						end
						local d = volume_now.device
						if volume_now.status == "off" then
						elseif tonumber(v) == 0 then
						elseif tonumber(v) <= 50 then
						else
						end
						widget:set_markup(markup.font(theme.font, string.format("%02i%s", v, "")))
					end
				})
			)
		wgts.vol:buttons(awful.util.table.join(
				awful.button({}, 3, function() -- right click
					awful.util.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
					wgts.vol.actual:update()
				end),
				awful.button({}, 4, function () -- up
					awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
					wgts.vol.actual:update()
				end),
				awful.button({}, 5, function () -- down
					awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
					wgts.vol.actual:update()
				end)
			))
		-- local vol = require("awesome-wm-widgets/volumearc-widget/volumearc")
		-- wgts.vol = vol()

		local bri = require("awesome-wm-widgets/brightnessarc-widget/brightnessarc")
		wgts.bri = bri()

		---- Net
		wgts.net_icon = create_icon(icons.net)
		wgts.net = create_wgt(
			wgts.net_icon,
			lain.widget.net({
					settings = function()
						widget:set_markup(markup.font(theme.font,
								string.format("%s %s",
									markup("#7AC82E",  string.format("%06.1f", net_now.received)),
									markup("#46A8C3", string.format("%06.1f", net_now.sent))
							)))
					end
				})
			)

		---- Weather
		wgts.weather_icon = create_icon(icons.weather)
		wgts.weather = create_wgt(
			wgts.weather_icon,
			lain.widget.weather({
					city_id = 1277333,
					notification_preset = { font = theme.font_mono, fg = theme.fg_normal },
					weather_na_markup = markup.fontfg(theme.font, theme.fg_normal, "N/A "),
					settings = function()
						descr = weather_now["weather"][1]["description"]:lower()
						units = math.floor(weather_now["main"]["temp"])
						widget:set_markup(markup.fontfg(theme.font, theme.fg_normal, descr .. " @ " .. units .. "°C "))
					end
				})
			)

		self.widgets = wgts
		objdump('self', self)
	end

	function Wiman:boxes_right()
		return
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			wibox.widget.systray(),
			self.widgets.bri,
			self.widgets.vol,
			self.widgets.mem,
			self.widgets.cpu,
			self.widgets.temp,
			self.widgets.bat,
			self.widgets.net,
			self.widgets.fs,
			self.widgets.weather,
			self.widgets.clock,
			self.widgets.kb,
			self.mylayoutbox,
		}
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
			self:apply_in_screen(s)
		end)
	end
	function Wiman:apply_in_screen(s)
		self:apply_wallpaper_in_screen(s)

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
			awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
			)
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
			end))
			-- Each screen has its own tag table.
			awful.tag({ "1", "2", "3", "4" }, s, awful.layout.layouts[1])

			-- Create a promptbox for each screen
			self.mypromptbox = awful.widget.prompt()
			self.ctx.mypromptbox = self.mypromptbox

			-- Create an imagebox widget which will contain an icon indicating which layout we're using.
			-- We need one layoutbox per screen.
			self.mylayoutbox = awful.widget.layoutbox(s)
			self.mylayoutbox:buttons(gears.table.join(
					awful.button({ }, 1, function () awful.layout.inc( 1) end),
					awful.button({ }, 3, function () awful.layout.inc(-1) end),
					awful.button({ }, 4, function () awful.layout.inc( 1) end),
				awful.button({ }, 5, function () awful.layout.inc(-1) end)))

				-- Create a taglist widget
				self.mytaglist = awful.widget.taglist {
					screen  = s,
					filter  = awful.widget.taglist.filter.all,
					buttons = taglist_buttons
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
				}
				-- Create the wibox
				self.mywibox = awful.wibar({ position = "top", screen = s, width = "50%" })

				-- Add widgets to the wibox
				self.mywibox:setup {
					layout = wibox.layout.align.horizontal,
					self:boxes_right()
				}

				-- Create the wibox
				self.mywibox2 = awful.wibar({ position = "bottom", screen = s })

				-- Add widgets to the wibox
				self.mywibox2:setup {
					layout = wibox.layout.align.horizontal,
					{ -- Left widgets
						layout = wibox.layout.fixed.horizontal,
						self.mytaglist,
						self.mypromptbox,
					},
					self.mytasklist, -- Middle widget
				}
			end
	return Wiman
