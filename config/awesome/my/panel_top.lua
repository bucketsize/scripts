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
function create_text()
	return wibox.widget.textbox()
end
function compose_widget(icon_path)
	local icon = create_icon(icon_path)
	local text = create_text()
	local widget = wibox.widget {
		icon,
		text,
		layout = wibox.layout.fixed.horizontal
	}
	function widget:update(msg)
		print('>>> cpu2', msg)
		text:set_markup(msg)
	end
	function widget:handler(signal, handlerfn)
	end
	function widget:timer(updatefn, timeout)
		if (updatefn) then
			gears.timer {
				timeout   = 1,
				call_now  = true,
				autostart = true,
				callback  = updatefn
			}
		end
	end
	return widget
end

local cpu = compose_widget(icons.cpu)
cpu:timer(function()
	awful.spawn.easy_async(
		{"sh", "-c", "~/scripts/xdg/sys.param.lua cpu"},
		function(out)
			local val = tonumber(out)
			cpu:update(string.format("%02i", val))
		end)
	end, 1)

local mem = compose_widget(icons.mem)
mem:timer(function()
	awful.spawn.easy_async(
		{"sh", "-c", "~/scripts/xdg/sys.param.lua mem"},
		function(out)
			local val = tonumber(out)
			mem:update(string.format("%02i", val))
		end)
	end, 1)


local cpu_temp = compose_widget(icons.temp)
cpu_temp:timer(function()
	awful.spawn.easy_async(
		{"sh", "-c", "~/scripts/xdg/sys.param.lua cpu_temp"},
		function(out)
			local val = tonumber(out)
			cpu_temp:update(string.format("%02i", val))
		end)
	end, 1)

local gpu_temp = compose_widget(icons.temp)
gpu_temp:timer(function()
	awful.spawn.easy_async(
		{"sh", "-c", "~/scripts/xdg/sys.param.lua gpu_temp"},
		function(out)
			local val = tonumber(out)
			gpu_temp:update(string.format("%02i", out))
		end)
	end, 1)

local net = compose_widget(icons.net)
net:timer(function()
	awful.spawn.easy_async(
		{"sh", "-c", "~/scripts/xdg/sys.param.lua net_ts"},
		function(out)
			local ts = tonumber(out) / 1000
			awful.spawn.easy_async(
				{"sh", "-c", "~/scripts/xdg/sys.param.lua net_rs"},
				function(out)
					local rs = tonumber(out) / 1000
					net:update(string.format('%4.2f, %4.2f', ts, rs))
				end)
		end)
	end, 1)

local bat_stat = compose_widget(icons.bat)
bat_stat:timer(function()
	awful.spawn.easy_async(
		{"sh", "-c", "~/scripts/xdg/sys.param.lua bat_status"},
		function(out)
			local bs = out:match("^%s*(.-)%s*$")
			awful.spawn.easy_async(
				{"sh", "-c", "~/scripts/xdg/sys.param.lua bat_level"},
				function(out)
					local bl = tonumber(out)
					if bl == nil then bl = 0 end
					bat_stat:update(string.format('%s, %03i', bs, bl))
				end)
		end)
	end, 5)

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
	wgts.clock = create_wgt(
		wgts.clock_icon,
		wibox.widget.textclock()
		)
	wgts.cal = lain.widget.cal({
			attach_to = { wgts.clock },
			notification_preset = {
				font = theme.font_mono,
				fg   = theme.fg_normal,
				bg   = theme.bg_normal
			}
		})

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

function Wiman:apply()
	-- Setup screen and stuff
	awful.screen.connect_for_each_screen(function(s)
		self:apply_in_screen(s)
	end)
end
function Wiman:apply_in_screen(s)
	-- Create the wibox
	self.mywibox = awful.wibar({ position = "top", screen = s, ontop = true })

	-- Add widgets to the wibox
	self.mywibox:setup {
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.flex.horizontal,
			self.widgets.kb,
		},
		{
			layout = wibox.layout.flex.horizontal,
			self.widgets.weather
		},
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			wibox.widget.systray(),
			cpu,
			mem,
			cpu_temp,
			gpu_temp,
			bat_stat,
			net,
			self.widgets.fs,
			self.widgets.vol,
			self.widgets.clock,
		},
	}
end
return Wiman
