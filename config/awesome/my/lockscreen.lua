local wibox = require('wibox')
local gears = require('gears')
local awful = require('awful')
local naughty = require('naughty')
local beautiful = require('beautiful')

local dpi = beautiful.xresources.apply_dpi

local filesystem = require('gears.filesystem')
local config_dir = filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. '/widgets/icons/'

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
function Lockscreen:pass(password)
	return true
end
function Lockscreen:input()
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
				-- back_door()
			end},
		},
		keypressed_callback = function(self, mod, key, command)

			if not type_again then
				return
			end

			-- Clear input string
			if key == 'Escape' then
				-- Clear input threshold
				input_password = nil
			end

			-- Accept only the single charactered key
			-- Ignore 'Shift', 'Control', 'Return', 'F1', 'F2', etc., etc
			if #key == 1 then

				-- locker_widget_rotate()

				if input_password == nil then
					input_password = key
					return
				end

				input_password = input_password .. key
			end

		end,
		keyreleased_callback = function(self, mod, key, command)
			Lockscreen.locker_arc.bg = beautiful.transparent
			Lockscreen.locker_arc:emit_signal('widget::redraw_needed')

			if key == 'Caps_Lock' then
				-- check_caps()
			end

			if not type_again then
				return
			end

			-- Validation
			if key == 'Return' then

				type_again = false

				-- Validate password
				if Lockscreen:pass(input_password) then
					-- Come in!
					self:stop()
					-- generalkenobi_ohhellothere()
				else
					-- F*ck off, you [REDACTED]!
					-- stoprightthereyoucriminalscum()
				end

				input_password = nil
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

	local uname_text_shadow = wibox.widget {
		id = 'uname_text_shadow',
		markup = '<span foreground="#00000066">' .. '$USER' .. "</span>",
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
	local caps_text_shadow = wibox.widget {
		id = 'uname_text',
		markup = '<span foreground="#00000066">' .. 'Caps Lock is off' .. "</span>",
		font = 'SF Pro Display Italic 10',
		align = 'center',
		valign = 'center',
		opacity = 0.0,
		widget = wibox.widget.textbox
	}

	-- Update username textbox
	awful.spawn.easy_async_with_shell('whoami | tr -d "\\n"', function(stdout) 
		uname_text.markup = stdout
		uname_text_shadow.markup = '<span foreground="#00000066">' .. stdout .. "</span>"
	end)


	local profile_imagebox = wibox.widget {
		id = 'user_icon',
		image = widget_icon_dir .. 'user.svg',
		forced_height = dpi(100),
		forced_width = dpi(100),
		clip_shape = gears.shape.circle,
		widget = wibox.widget.imagebox,
		resize = true
	}

	local update_profile_pic = function()

		local user_jpg_checker = [[
		if test -f ]] .. widget_icon_dir .. 'user.jpg' .. [[; then print 'yes'; fi
		]]

		awful.spawn.easy_async_with_shell(user_jpg_checker, function(stdout)

			if stdout:match('yes') then
				profile_imagebox:set_image(widget_icon_dir .. 'user' .. '.jpg')
			else
				profile_imagebox:set_image(widget_icon_dir .. 'user' .. '.svg')
			end
			
			profile_imagebox:emit_signal('widget::redraw_needed')
		end)
	end

	-- Update image
	gears.timer.start_new(5, function() 
		update_profile_pic()
	end)

	local time = wibox.widget.textclock(
		'<span font="SF Pro Display Bold 56">%H:%M</span>',
		1
	)

	local time_shadow = wibox.widget.textclock(
		'<span foreground="#00000066" font="SF Pro Display Bold 56">%H:%M</span>',
		1
	)

	local wanted_text = wibox.widget {
		markup = 'INTRUDER ALERT',
		font   = 'SFNS Pro Text Bold 12',
		align  = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

	local msg_table = {
		'We are watching you.',
		'We know where you live.',
		'This incident will be reported.',
		'RUN!',
		'Yamete, Oniichan~ uwu',
		'This will self-destruct in 5 seconds!',
		'Image successfully sent!',
		'You\'re doomed!'
	}

	local wanted_msg = wibox.widget {
		markup = 'This incident will be reported!',
		font   = 'SFNS Pro Text Regular 10',
		align  = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}

	local wanted_image = wibox.widget {
		image  = widget_icon_dir .. 'user.svg',
		resize = true,
		forced_height = dpi(100),
		clip_shape = gears.shape.rounded_rect,
	    widget = wibox.widget.imagebox
	}
	
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
	local date_shadow = wibox.widget {
		markup = "<span foreground='#00000066'>" .. date_value().day .. date_value().ordinal .. " of " .. 
			date_value().month .. "</span>",
		font = 'SF Pro Display Bold 20',
		align = 'center',
		valign = 'center',
		widget = wibox.widget.textbox
	}
	local circle_container = wibox.widget {
		bg = '#f2f2f233',
	    forced_width = dpi(110),
	    forced_height = dpi(110),
	    shape = gears.shape.circle,
	    widget = wibox.container.background
	}

	local locker_arc = wibox.widget {
	    bg = beautiful.transparent,
	    forced_width = dpi(110),
	    forced_height = dpi(110),
	    shape = function(cr, width, height)
	        gears.shape.arc(cr, width, height, dpi(5), 0, math.pi/2, true, true)
	    end,
	    widget = wibox.container.background
	}
	Lockscreen.locker_arc = locker_arc
	local rotate_container = wibox.container.rotate()

	local locker_widget = wibox.widget {
		{
		    locker_arc,
		    widget = rotate_container
		},
		layout = wibox.layout.fixed.vertical
	}

	-- build layout
	lockscreen : setup {
		layout = wibox.layout.align.vertical,
		expand = 'none',
		nil,
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			nil,
			{
				layout = wibox.layout.fixed.vertical,
				expand = 'none',
				spacing = dpi(20),
				{
					{
						layout = wibox.layout.align.horizontal,
						expand = 'none',
						nil,
						{
							time_shadow,
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
							date_shadow,
							date,
							vertical_offset = dpi(-1),
							widget = wibox.layout.stack
						},
						nil

					},
					expand = 'none',
					layout = wibox.layout.fixed.vertical
				},
				{
					layout = wibox.layout.fixed.vertical,
					{
						circle_container,
						locker_widget,
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
						uname_text_shadow,
						uname_text,
						vertical_offset = dpi(-1),
						widget = wibox.layout.stack
					},
					{
						caps_text_shadow,
						caps_text,
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
