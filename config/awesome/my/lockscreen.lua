local wibox = require('wibox')
local gears = require('gears')
local awful = require('awful')
local naughty = require('naughty')
local beautiful = require('beautiful')

local dpi = beautiful.xresources.apply_dpi

local filesystem = require('gears.filesystem')
local config_dir = filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'widgets/icons/'
print(">>> widget_icon_dir:", widget_icon_dir)

local Lockscreen = {}
function Lockscreen:setup(ctx)
	self.ctx = ctx
	self.ctx.lockscreen = Lockscreen
	return self
end
function Lockscreen:apply()
	-- Create a lockscreen for each screen
	-- screen.connect_signal("request::desktop_decoration", function(s)
	awful.screen.connect_for_each_screen(function(s)
		self.I = Lockscreen:build(s)
	end)
	-- screen.emit_signal("request::desktop_decoration")
end
function Lockscreen:on()
	self.I.visible = true
	local pin = Lockscreen:input()
	pin:start()
end
function Lockscreen:off()
	self.I.visible = false
end
function Lockscreen:pass(username, password)
	-- print('pass:', username, password)
	local h = io.popen(string.format("~/scripts/pam_auth %s %s", username, password))
	local r
	if h == nil then
		r = ""
	else
		r = h:read("*a")
		h:close()
	end
	local s = string.match(r, "status:%s(%w+)%c")
	print('pass:', s)

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

		-- Add a little delay before unlocking completely
		gears.timer.start_new(1, function()

			-- Hide all the lockscreen on all screen
			for s in screen do
				if s.index == 1 then
					Lockscreen.I.visible = false
				else
					-- Lockscreen_extended.visible = false -- TODO
				end
			end


			-- Enable locking again
			Lockscreen.lock_again = true

			-- Enable validation again
			Lockscreen.type_again = true

			-- if capture_now then
			-- 	-- Hide wanted poster
			-- 	wanted_poster.visible = false
			-- end
		end)

	end
	function Lockscreen:throw()
		gears.timer.start_new(1, function()
			Lockscreen.type_again = true
		end)
		gears.timer.start_new(5, function()
			Lockscreen:set_msg("Start typing the password and `Return` when ready!")
		end)
		Lockscreen:set_msg("Invalid credentials, please try again")
	end
function Lockscreen:input()
	Lockscreen.type_again = true
	Lockscreen.input_password = nil
	Lockscreen:set_msg("Start typing the password and `Return` when ready!")
	local password_grabber = awful.keygrabber {
		autostart          = true,
		stop_event          = 'release',
		mask_event_callback = true,
		keybindings = {
			{{'Control'         }, 'u', function()
				input_password = nil
			end},
      {{'Control'         }, 'Return', function(self)
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
		ontop = true,
		type = "splash",
		width = s.geometry.width,
		height = s.geometry.height,
		bg = beautiful.background,
		fg = beautiful.fg_normal
	}

	local uname_text = wibox.widget {
		id = 'uname_text',
		markup = '$USER',
		font = 'SF Pro Display Bold 17',
		align = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

	local caps_text = wibox.widget {
		id = 'uname_text',
		markup = 'Caps Lock is off',
		font = 'SF Pro Display Italic 10',
		align = 'center',
		valign = 'center',
		opacity = 0.0,
		widget = wibox.widget.textbox
	}
  Lockscreen.caps_text = caps_text

	local msg_text = wibox.widget {
		id = 'msg_text',
		markup = '',
		font = 'SF Pro Display Italic 12',
		align = 'center',
		valign = 'center',
		opacity = 0.8,
		widget = wibox.widget.textbox
	}
  Lockscreen.msg_text = msg_text

	-- Update username textbox
	awful.spawn.easy_async_with_shell('whoami | tr -d "\\n"', function(stdout)
		uname_text.markup = stdout
		Lockscreen.username = string.match(stdout, "%w+")
	end)

	local profile_imagebox = wibox.widget {
		id = 'user_icon',
		image = widget_icon_dir .. 'user.svg',
		forced_height = dpi(128),
		forced_width = dpi(128),
		resize = true,
		align = 'center',
		widget = wibox.widget.imagebox
	}

	local update_profile_pic = function()
		profile_imagebox:set_image(widget_icon_dir .. 'user' .. '.svg')
		profile_imagebox:emit_signal('widget::redraw_needed')
	end

	-- Update image
	gears.timer.start_new(5, function()
		update_profile_pic()
	end)

	local time = wibox.widget.textclock(
		'<span font="SF Pro Display Bold 56">%H:%M</span>',
		1
	)

	local date_value = function()
		local date_val = {}
		local ordinal = nil

		local day = os.date('%d')
		local month = os.date('%B')

		local first_digit = string.sub(day, 0, 1)
		local last_digit = string.sub(day, -1)

		if first_digit == '0' then
		  day = last_digit
		end

		if last_digit == '1' and day ~= '11' then
		  ordinal = 'st'
		elseif last_digit == '2' and day ~= '12' then
		  ordinal = 'nd'
		elseif last_digit == '3' and day ~= '13' then
		  ordinal = 'rd'
		else
		  ordinal = 'th'
		end

		date_val.day = day
		date_val.month = month
		date_val.ordinal= ordinal

		return date_val
	end
	local date = wibox.widget {
		markup = date_value().day .. date_value().ordinal .. ' of ' .. date_value().month,
		font = 'SF Pro Display Bold 20',
		align = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

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
							time,
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
							date,
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

return Lockscreen
