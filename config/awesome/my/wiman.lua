local awful = require("awful")
local wibox = require("wibox")
local lain  = require("lain")
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

	local wgts = {}
	wgts.kb = awful.widget.keyboardlayout()
	wgts.clock = wibox.widget.textclock()

	local theme = self.theme

	---- Calendar
	wgts.cal = lain.widget.cal({
			attach_to = { wgts.clock },
			notification_preset = {
				font = theme.font_mono,
				fg   = theme.fg_normal,
				bg   = theme.bg_normal
			}
		})

	---- Mail IMAP check
	--wgts.mailicon = wibox.widget.imagebox(theme.widget_mail)
	----[[ commented because it needs to be set before use
	--wgts.mailicon:buttons(my_table.join(awful.button({ }, 1, function () awful.spawn(mail) end)))
	--theme.mail = lain.widget.imap({
	--timeout  = 180,
	--server   = "server",
	--mail     = "mail",
	--password = "keyring get mail",
	--settings = function()
	--if mailcount > 0 then
	--widget:set_markup(markup.font(theme.font, " " .. mailcount .. " "))
	--mailicon:set_image(theme.widget_mail_on)
	--else
	--widget:set_text("")
	--mailicon:set_image(theme.widget_mail)
	--end
	--end
	--})
	----]]

	---- MPD
	--wgts.musicplr = awful.util.terminal .. " -title Music -g 130x34-320+16 -e ncmpcpp"
	--wgts.mpdicon = wibox.widget.imagebox(theme.widget_music)
	--wgts.mpdicon:buttons(my_table.join(
	--awful.button({ modkey }, 1, function () awful.spawn.with_shell(musicplr) end),
	--awful.button({ }, 1, function ()
	--os.execute("mpc prev")
	--theme.mpd.update()
	--end),
	--awful.button({ }, 2, function ()
	--os.execute("mpc toggle")
	--theme.mpd.update()
	--end),
	--awful.button({ }, 3, function ()
	--os.execute("mpc next")
	--theme.mpd.update()
	--end)))
	--theme.mpd = lain.widget.mpd({
	--settings = function()
	--if mpd_now.state == "play" then
	--artist = " " .. mpd_now.artist .. " "
	--title  = mpd_now.title  .. " "
	--mpdicon:set_image(theme.widget_music_on)
	--elseif mpd_now.state == "pause" then
	--artist = " mpd "
	--title  = "paused "
	--else
	--artist = ""
	--title  = ""
	--mpdicon:set_image(theme.widget_music)
	--end

	--widget:set_markup(markup.font(theme.font, markup("#EA6F81", artist) .. title))
	--end
	--})

	---- MEM
	wgts.mem = lain.widget.mem({
			settings = function()
				widget:set_markup(markup.font(theme.font, string.format("mem: %04i%s", mem_now.used, "M")))
			end
		})

	---- CPU
	wgts.cpu = lain.widget.cpu({
			settings = function()
				widget:set_markup(markup.font(theme.font, string.format("cpu: %02i%s", cpu_now.usage, "%")))
			end
		})

	---- Coretemp
	wgts.temp = lain.widget.temp({
			settings = function()
				widget:set_markup(markup.font(theme.font, string.format("T: %s°C", coretemp_now )))
			end
		})

	---- / fs
	wgts.fs = lain.widget.fs({
			notification_preset = { fg = theme.fg_normal, bg = theme.bg_normal, font = theme.font_mono },
			settings = function()
				widget:set_markup(markup.font(theme.font_mono, string.format("/: %02i%s",fs_now["/"].percentage, "%")))
			end
		})

	---- Battery
	wgts.bat = lain.widget.bat({
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
		})

	---- ALSA volume
	wgts.vol = lain.widget.alsa({
			settings = function()
				if volume_now.status == "off" then
				elseif tonumber(volume_now.level) == 0 then
				elseif tonumber(volume_now.level) <= 50 then
				else
				end
				widget:set_markup(markup.font(theme.font, string.format("vol: %02i%s", volume_now.level, "%")))
			end
		})
	wgts.vol.widget:buttons(awful.util.table.join(
			awful.button({}, 4, function ()
				awful.util.spawn("amixer set Master 5%+")
				wgts.vol.update()
			end),
			awful.button({}, 5, function ()
				awful.util.spawn("amixer set Master 5%-")
				wgts.vol.update()
			end)
		))

	---- Net
	wgts.net = lain.widget.net({
			settings = function()
				widget:set_markup(markup.font(theme.font,
						markup("#7AC82E", " " .. string.format("%06.1f", net_now.received))
						.. " " ..
					markup("#46A8C3", " " .. string.format("%06.1f", net_now.sent) .. " ")))
			end
		})

	---- Weather
	wgts.weather = lain.widget.weather({
			city_id = 1277333, -- placeholder (London)
			notification_preset = { font = theme.font_mono, fg = theme.fg_normal },
			weather_na_markup = markup.fontfg(theme.font, theme.fg_normal, "N/A "),
			settings = function()
				descr = weather_now["weather"][1]["description"]:lower()
				units = math.floor(weather_now["main"]["temp"])
				widget:set_markup(markup.fontfg(theme.font, theme.fg_normal, descr .. " @ " .. units .. "°C "))
			end
		})

	wgts.clock:connect_signal("button::press",
		function(_, _, _, button)
			if button == 1 then wgts.cal.toggle() end
		end)

		self.widgets = wgts
		objdump('self', self)
	end

function Wiman:boxes_right()
	local s	= self.screen
	return
        { -- Right widgets
					layout = wibox.layout.fixed.horizontal,
					self.widgets.kb,
										self.widgets.weather,
										wibox.widget.systray(),
										self.widgets.vol, sprtr,
										self.widgets.mem,
										self.widgets.cpu,
										self.widgets.temp,
										self.widgets.bat,
										self.widgets.net,
										self.widgets.fs,
										self.widgets.clock,
										s.mylayoutbox,
        }
	end

return Wiman
