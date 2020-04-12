local wibox           = require('wibox')
local gears           = require('gears')
local awful           = require('awful')
local naughty         = require('naughty')
local beautiful       = require('beautiful')
local dpi             = beautiful.xresources.apply_dpi

local filesystem      = require('gears.filesystem')
local config_dir      = filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'widgets/icons/'
print(">>> widget_icon_dir:", widget_icon_dir)

local Config          = require('config')

-- FIXME: backspace restarts x
-- FIXME: modal window / popup before lock looses keygrabber focus
--
local Lockscreen      = {}
function Lockscreen:shouldlock()
	local cs = client.get()
	for i, j in pairs(cs) do
		-- firefox
		if not string.find(j.name, 'YouTube') == nil then
		end
		-- firefox
		if not string.find(j.name, 'Picture-in-Picture') == nil then
		end
		-- videoplayer
		if not string.find(j.class, 'mpv') == nil then
		end

		-- TODO: check if reapply playing, hint: pulse audio / cpu/gpu activity
		return true
	end
end
function Lockscreen:setup(ctx)
	self.ctx = ctx
	self.ctx.lockscreen = Lockscreen
	return self
end
function Lockscreen:apply()
	awful.screen.connect_for_each_screen(function(s)
		self.I = Lockscreen:build(s)
	end)
end
function Lockscreen:auto_on()
	if Lockscreen:shouldlock() then
		Lockscreen:on()
	else
		print('>>> skip lock on criteria')
	end
end
function Lockscreen:on()
	self.I.visible = true
	local pin = Lockscreen:input()
	pin:start()
end
function Lockscreen:off()
	Lockscreen:release()
end
function Lockscreen:pass(username, password)
	-- print('>>> pass:', username, password)
	local h = io.popen(string.format("~/scripts/pam_auth %s %s %s", Config.pam_domain, username, password))
	local r
	if h == nil then
		r = ""
	else
		r = h:read("*a")
		h:close()
	end
	local s = string.match(r, "status:%s(%w+)%c")
	print('>>> auth: ', Config.pam_domain, username, s)

	return (s == "success")
end
function Lockscreen:check_caps()
	awful.spawn.easy_async("xset q", function(stdout)
		local caps_lock = string.match(stdout, "Caps Lock:%s+(%w+)%s")
		if string.match(caps_lock, 'on') then
			Lockscreen.caps_text.opacity = 1.0
			Lockscreen.caps_text:set_markup('Caps Lock is on')
		else
			Lockscreen.caps_text.opacity = 0.0
		end
		Lockscreen.caps_text:emit_signal('widget::redraw_needed')
	end)
end
function Lockscreen:set_msg(msg)
	Lockscreen.msg_text.opacity = 1.0
	print('>>> set_msg:', msg)
	Lockscreen.msg_text:set_markup(msg)
	Lockscreen.msg_text:emit_signal('widget::redraw_needed')
end
function Lockscreen:release()
	gears.timer.start_new(1, function()
		for s in screen do
			if s.index == 1 then
				Lockscreen.I.visible = false
			else
				-- Lockscreen_extended.visible = false -- TODO
			end
		end
		Lockscreen.lock_again = true
		Lockscreen.type_again = true
	end)

end
function Lockscreen:throw()
	Lockscreen:set_msg("Invalid credentials, please try again")
	gears.timer.start_new(1, function()
		Lockscreen.type_again = true
		Lockscreen:set_msg("Start typing the password and `Return` when ready!")
	end)
end
function Lockscreen:input()
	Lockscreen.type_again = true
	Lockscreen.input_password = nil
	Lockscreen:set_msg("Start typing the password and `Return` when ready!")
	local password_grabber = awful.keygrabber {
		autostart            = true,
		stop_event           = 'release',
		mask_event_callback  = true,
		keybindings          = {
			{{'Mod1', 'Control'}, 'r', function(self)
				print('>>> secret pass')
				self:stop()
				Lockscreen:release()
			end},
		},
		keypressed_callback = function(self, mod, key, command)
			if not Lockscreen.type_again then
				return
			end

			if key == 'Escape' then
				Lockscreen.input_password = nil
			end

			-- Accept only the single charactered key
			-- Ignore 'Shift', 'Control', 'Return', 'F1', 'F2', etc., etc
			if #key == 1 then
				if Lockscreen.input_password == nil then
					Lockscreen.input_password = key
					return
				end
				Lockscreen.input_password = Lockscreen.input_password .. key
				Lockscreen:set_msg(".." .. string.len(Lockscreen.input_password))
			end
		end,
		keyreleased_callback = function(self, mod, key, command)
			-- print(">>> input", mod, key, command)
			if key == 'Caps_Lock' then
				Lockscreen:check_caps()
			end

			if not Lockscreen.type_again then
				return
			end

			if key == 'Return' then
				Lockscreen.type_again = false
				if Lockscreen:pass(Lockscreen.username, Lockscreen.input_password) then
					self:stop()
					Lockscreen:release()
				else
					Lockscreen:throw()
				end
				Lockscreen.input_password = nil
			end
		end

	}
	return password_grabber
end
function Lockscreen:build(s)
	local lockscreen = wibox {
		visible = false,
		ontop   = true,
		type    = "splash",
		width   = s.geometry.width,
		height  = s.geometry.height,
		fg      = beautiful.fg_normal,
		bg      = beautiful.background,
	}

	local uname_text = wibox.widget {
		id     = 'uname_text',
		markup = '$USER',
		font   = 'DejaVu Sans 17',
		align  = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

	local caps_text = wibox.widget {
		id      = 'uname_text',
		markup  = 'Caps Lock is off',
		font    = 'DejaVu Sans Italic 10',
		align   = 'center',
		valign  = 'center',
		opacity = 0.0,
		widget  = wibox.widget.textbox
	}
	Lockscreen.caps_text = caps_text

	local msg_text = wibox.widget {
		id      = 'msg_text',
		markup  = '',
		font    = 'DejaVu Sans Italic 12',
		align   = 'center',
		valign  = 'center',
		opacity = 0.8,
		widget  = wibox.widget.textbox
	}
	Lockscreen.msg_text = msg_text

	-- Update username textbox
	awful.spawn.easy_async_with_shell('whoami | tr -d "\\n"', function(stdout)
		uname_text.markup = stdout
		Lockscreen.username = string.match(stdout, "%w+")
	end)

	local profile_imagebox = wibox.widget {
		id            = 'user_icon',
		image         = widget_icon_dir .. 'user.svg',
		forced_height = dpi(128),
		forced_width  = dpi(128),
		resize        = true,
		align         = 'center',
		widget        = wibox.widget.imagebox
	}

	local update_profile_pic = function()
		profile_imagebox:set_image(widget_icon_dir .. 'user' .. '.svg')
		profile_imagebox:emit_signal('widget::redraw_needed')
	end

	-- Update image
	gears.timer.start_new(5, function()
		update_profile_pic()
	end)

	local date = wibox.widget.textclock(
		'<span font="DejaVu Sans Bold 12">%a %d %b, %Y</span>'
		,	1)

	local time = wibox.widget.textclock(
		'<span font="DejaVu Sans Bold 32">%H:%M:%S</span>'
		,	1)

	-- build layout
	lockscreen : setup {
		layout = wibox.layout.align.vertical,
		expand = 'none',
		nil,
		{ --1
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			nil,
			{ --2
				layout = wibox.layout.fixed.vertical,
				expand = 'none',
				spacing = dpi(20),
				{ --3
					{
						layout = wibox.layout.align.horizontal,
						expand = 'none',
						nil,
						{
							date,
							vertical_offset = dpi(-1),
							widget = wibox.layout.stack
						},
						nil
					},
					{
						layout = wibox.layout.align.horizontal,
						expand = 'none',
						nil,
						{
							time,
							vertical_offset = dpi(-1),
							widget = wibox.layout.stack
						},
						nil
					},
					expand = 'none',
					layout = wibox.layout.fixed.vertical
				},
				{ --4
					layout = wibox.layout.fixed.vertical,
					{
						{
							layout = wibox.layout.align.vertical,
							expand = 'none',
							nil,
							{
								layout = wibox.layout.align.horizontal,
								expand = 'none',
								nil,
								profile_imagebox,
								nil
							},
							nil,
						},
						layout = wibox.layout.stack
					},
					{
						uname_text,
						vertical_offset = dpi(-1),
						widget = wibox.layout.stack
					},
					{
						caps_text,
						vertical_offset = dpi(-1),
						widget = wibox.layout.stack
					},
					{
						msg_text,
						vertical_offset = dpi(-1),
						widget = wibox.layout.stack
					}
				},
			},
			nil
		},
		nil
	}
	return lockscreen
end

LOCKSCREEN = Lockscreen
return Lockscreen
