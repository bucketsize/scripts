local awful = require("awful")
local wibox = require("wibox")
local lain  = require("lain")
local gears = require("gears")
local markup = lain.util.markup

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

Wiman = {}
function Wiman:new(theme, screen)
	self.theme = theme
	self.screen = screen
	return self
end

function Wiman:build()
	local	sprtr = wibox.widget.textbox()
	sprtr:set_text(" | ")

	icons_path = gears.filesystem.get_configuration_dir() .. 'themes/icons'
	local icons = {
		cpu=icons_path .. '/cpu.png',
		mem=icons_path .. '/mem.png',
		vol=icons_path .. '/vol.png',
		temp=icons_path .. '/temp.png',
		net=icons_path .. '/net.png',
		bat=icons_path .. '/battery.png',
		hdd=icons_path .. '/hdd.png',
	}

	local wgts = {}
	wgts.kb = awful.widget.keyboardlayout()

	local theme = self.theme

	---- Clock / Calendar
	wgts.clock = wibox.widget.textclock()
	-- wgts.cal = wibox.widget {
	-- 	wibox.widget {
	-- 		{
	-- 			image = '/usr/share/icons/Arc/devices/symbolic/media-flash-symbolic.svg',
	-- 			resize = false,
	-- 			widget = wibox.widget.imagebox,
	-- 		},
	-- 		top = 3,
	-- 		widget = wibox.container.margin
	-- 	},
	-- 	lain.widget.cal({
	-- 		attach_to = { wgts.clock },
	-- 		notification_preset = {
	-- 			font = theme.font_mono,
	-- 			fg   = theme.fg_normal,
	-- 			bg   = theme.bg_normal
	-- 		}
	-- 	}),
	-- 	layout = wibox.layout.fixed.horizontal,
	-- }
	-- local cal = require("awesome-wm-widgets/calendar-widget/calendar")
	-- wgts.cal = cal({
	-- 		theme = 'dark',
	-- 		placement = 'top_right'
	-- 	})
	-- wgts.clock:connect_signal("button::press",
	-- 	function(_, _, _, button)
	-- 		if button == 1 then wgts.cal.toggle() end
	-- 	end)

	---- MEM
	wgts.mem = wibox.widget {
		wibox.widget {
			{
				image = icons.mem,
				resize = false,
				widget = wibox.widget.imagebox,
			},
			top = 3,
			widget = wibox.container.margin
		},
		lain.widget.mem({
			settings = function()
				widget:set_markup(markup.font(theme.font, string.format("%04i%s", mem_now.used, "M")))
			end
		}),
		layout = wibox.layout.fixed.horizontal,
	}
	-- local mem = require("widgets/memarc-widget/memarc")
	-- wgts.mem = mem()

	---- CPU
	wgts.cpu = wibox.widget {
		wibox.widget {
			{
				image = icons.cpu,
				resize = false,
				widget = wibox.widget.imagebox,
			},
			top = 3,
			widget = wibox.container.margin
		},
		lain.widget.cpu({
				settings = function()
					widget:set_markup(markup.font(theme.font, string.format("%02i%s", cpu_now.usage, "")))
				end
			}),
		layout = wibox.layout.fixed.horizontal,
	}

	-- local cpu = require("widgets/cpuarc-widget/cpuarc")
	-- wgts.cpu = cpu()

	---- Coretemp
	wgts.temp = wibox.widget {
		wibox.widget {
			{
				image = icons.temp,
				resize = false,
				widget = wibox.widget.imagebox,
			},
			top = 3,
			widget = wibox.container.margin
		},
		lain.widget.temp({
			settings = function()
				widget:set_markup(markup.font(theme.font, string.format("%s°C", coretemp_now )))
			end
		}),
		layout = wibox.layout.fixed.horizontal,
	}

	---- / fs
	wgts.fs = wibox.widget {
		wibox.widget {
			{
				image = icons.hdd,
				resize = false,
				widget = wibox.widget.imagebox,
			},
			top = 3,
			widget = wibox.container.margin
		},
		lain.widget.fs({
				notification_preset = { fg = theme.fg_normal, bg = theme.bg_normal, font = theme.font_mono },
				settings = function()
					widget:set_markup(markup.font(theme.font_mono, string.format("%02i%s",fs_now["/"].percentage, "")))
				end
			}),
		layout = wibox.layout.fixed.horizontal,
	}
	-- local fs = require("widgets/fsarc-widget/fsarc")
	-- wgts.fs = fs()

	---- Battery
	wgts.bat = wibox.widget {
		wibox.widget {
			{
				image = icons.bat,
				resize = false,
				widget = wibox.widget.imagebox,
			},
			top = 3,
			widget = wibox.container.margin
		},
		lain.widget.bat({
			settings = function()
				if bat_now.status and bat_now.status ~= "N/A" then
					if bat_now.ac_status == 1 then
						baticon:set_image(theme.widget_ac)
					elseif not bat_now.perc and tonumber(bat_now.perc) <= 5 then
						baticon:set_image(theme.widget_battery_empty)
					elseif not bat_now.perc and tonumber(bat_now.perc) <= 15 then
						baticon:set_image(theme.widget_battery_low)
					else
						baticon:set_image(theme.widget_battery)
					end
					widget:set_markup(markup.font(theme.font, string.format("bat: %02i%s", bat_now.perc, "% ")))
				else
					widget:set_markup(markup.font(theme.font, " AC "))
				end
			end
		}),
		layout = wibox.layout.fixed.horizontal,
	}
	-- local bat = require("awesome-wm-widgets/batteryarc-widget/batteryarc")
	-- wgts.bat = bat()

	---- ALSA/pulse volume
	wgts.vol = wibox.widget {
		wibox.widget {
			{
				image = icons.vol,
				resize = false,
				widget = wibox.widget.imagebox,
			},
			top = 3,
			widget = wibox.container.margin
		},
		lain.widget.pulse({
				timeout = 1,
				settings = function()
					if (volume_now.index == 'N/A') then
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
					widget:buttons(awful.util.table.join(
							awful.button({}, 3, function() -- right click
								os.execute(string.format("pactl set-sink-mute %s toggle", d))
								widget.update()
							end),
							awful.button({}, 4, function ()
								awful.util.spawn("amixer set Master 5%+")
								widget.update()
							end),
							awful.button({}, 5, function ()
								awful.util.spawn("amixer set Master 5%-")
								widget.update()
							end)
						))
				end
			}),
		layout = wibox.layout.fixed.horizontal,
	}
	-- local vol = require("awesome-wm-widgets/volumearc-widget/volumearc")
	-- wgts.vol = vol()

	local bri = require("awesome-wm-widgets/brightnessarc-widget/brightnessarc")
	wgts.bri = bri()

	---- Net
	wgts.net = wibox.widget {
		wibox.widget {
			{
				image = '/usr/share/icons/Arc/devices/symbolic/media-flash-symbolic.svg',
				resize = false,
				widget = wibox.widget.imagebox,
			},
			top = 3,
			widget = wibox.container.margin
		},
		lain.widget.net({
			settings = function()
				widget:set_markup(markup.font(theme.font,
						markup("#7AC82E", " " .. string.format("%06.1f", net_now.received))
						.. " " ..
					markup("#46A8C3", " " .. string.format("%06.1f", net_now.sent) .. " ")))
			end
		}),
		layout = wibox.layout.fixed.horizontal,
	}

	---- Weather
	wgts.weather = wibox.widget {
		wibox.widget {
			{
				image = '/usr/share/icons/Arc/devices/symbolic/media-flash-symbolic.svg',
				resize = false,
				widget = wibox.widget.imagebox,
			},
			top = 3,
			widget = wibox.container.margin
		},
		lain.widget.weather({
			city_id = 1277333,
			notification_preset = { font = theme.font_mono, fg = theme.fg_normal },
			weather_na_markup = markup.fontfg(theme.font, theme.fg_normal, "N/A "),
			settings = function()
				descr = weather_now["weather"][1]["description"]:lower()
				units = math.floor(weather_now["main"]["temp"])
				widget:set_markup(markup.fontfg(theme.font, theme.fg_normal, descr .. " @ " .. units .. "°C "))
			end
		}),
		layout = wibox.layout.fixed.horizontal,
	}

	self.widgets = wgts
	objdump('self', self)
end

function Wiman:boxes_right()
	local s	= self.screen
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
			s.mylayoutbox,
		}
	end

return Wiman
