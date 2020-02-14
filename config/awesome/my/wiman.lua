local awful = require("awful")
local wibox = require("wibox")
local lain  = require("lain")
local markup = lain.util.markup

local theme                                     = {}
theme.font                                      = "DejaVu Sans 10"
theme.font_mono                                 = "DejaVu Sans Mono 10"
theme.fg_normal                                 = "#FEFEFE"
theme.fg_focus                                  = "#32D6FF"
theme.fg_urgent                                 = "#C83F11"
theme.bg_normal                                 = "#222222"

local	sprtr = wibox.widget.textbox()
sprtr:set_text(" ")

local co_widgets = {}
co_widgets.kb = awful.widget.keyboardlayout()
co_widgets.clock = wibox.widget.textclock()

local lain_widgets = {}

---- Calendar
lain_widgets.cal = lain.widget.cal({
    attach_to = { co_widgets.clock },
    notification_preset = {
        font = theme.font_mono,
        fg   = theme.fg_normal,
        bg   = theme.bg_normal
    }
})

---- Mail IMAP check
--lain_widgets.mailicon = wibox.widget.imagebox(theme.widget_mail)
----[[ commented because it needs to be set before use
--lain_widgets.mailicon:buttons(my_table.join(awful.button({ }, 1, function () awful.spawn(mail) end)))
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
--lain_widgets.musicplr = awful.util.terminal .. " -title Music -g 130x34-320+16 -e ncmpcpp"
--lain_widgets.mpdicon = wibox.widget.imagebox(theme.widget_music)
--lain_widgets.mpdicon:buttons(my_table.join(
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
lain_widgets.mem = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.font(theme.font, "mem: " .. mem_now.used .. "MB "))
    end
})

---- CPU
lain_widgets.cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.font(theme.font, "cpu: " .. cpu_now.usage .. "% "))
    end
})

---- Coretemp
lain_widgets.temp = lain.widget.temp({
    settings = function()
        widget:set_markup(markup.font(theme.font, "T: " .. coretemp_now .. "°C "))
    end
})

---- / fs
lain_widgets.fs = lain.widget.fs({
    notification_preset = { fg = theme.fg_normal, bg = theme.bg_normal, font = theme.font_mono_10 },
    settings = function()
        widget:set_markup(markup.font(theme.font_mono, " " .. fs_now["/"].percentage .. "% "))
    end
})

---- Battery
lain_widgets.bat = lain.widget.bat({
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
            widget:set_markup(markup.font(theme.font, " " .. bat_now.perc .. "% "))
        else
            widget:set_markup(markup.font(theme.font, " AC "))
        end
    end
})

---- ALSA volume
lain_widgets.vol = lain.widget.alsa({
		settings = function()
			if volume_now.status == "off" then
			elseif tonumber(volume_now.level) == 0 then
			elseif tonumber(volume_now.level) <= 50 then
			else
			end
			widget:set_markup(markup.font(theme.font, " " .. volume_now.level .. "% "))
		end
	})
lain_widgets.vol.widget:buttons(awful.util.table.join(
		awful.button({}, 4, function ()
			awful.util.spawn("amixer set Master 5%+")
			theme.volume.update()
		end),
		awful.button({}, 5, function ()
			awful.util.spawn("amixer set Master 5%-")
			theme.volume.update()
		end)
	))

---- Net
lain_widgets.net = lain.widget.net({
		settings = function()
			widget:set_markup(markup.font(theme.font,
					markup("#7AC82E", " " .. string.format("%06.1f", net_now.received))
					.. " " ..
				markup("#46A8C3", " " .. string.format("%06.1f", net_now.sent) .. " ")))
		end
	})

---- Weather
-- theme.lain_widgets.weather = lain.widget.weather({
-- 		city_id = 1277333, -- placeholder (London)
-- 		notification_preset = { font = theme.font_mono_10, fg = theme.fg_normal },
-- 		weather_na_markup = markup.fontfg(theme.font, theme.fg_normal, "N/A "),
-- 		settings = function()
-- 			descr = weather_now["weather"][1]["description"]:lower()
-- 			units = math.floor(weather_now["main"]["temp"])
-- 			widget:set_markup(markup.fontfg(theme.font, theme.fg_normal, descr .. " @ " .. units .. "°C "))
-- 		end
-- 	})

		local my_widgets = {}
		my_widgets.vol = lain_widgets.vol
		my_widgets.cpu = lain_widgets.cpu
		my_widgets.mem = lain_widgets.mem
		my_widgets.temp = lain_widgets.temp
		my_widgets.bat= lain_widgets.bat
		my_widgets.net= lain_widgets.net
		my_widgets.fs= lain_widgets.fs
		my_widgets.cal= lain_widgets.cal

		co_widgets.clock:connect_signal("button::press",
			function(_, _, _, button)
				if button == 1 then my_widgets.cal.toggle() end
			end)

local wiman = {
	boxes_right = function(ctx)
		local s = ctx.screen
		return
        { -- Right widgets
					layout = wibox.layout.fixed.horizontal,
					co_widgets.kb,
					sprtr,
					wibox.widget.systray(),
					sprtr,
					my_widgets.vol,
					sprtr,
					my_widgets.mem,
					sprtr,
					my_widgets.cpu,
					sprtr,
					my_widgets.bat,
					sprtr,
					my_widgets.net,
					sprtr,
					my_widgets.fs,
					sprtr,
					--my_widgets.weather,
					co_widgets.clock,
					sprtr,
					s.mylayoutbox,
        }
	end
}

return wiman
