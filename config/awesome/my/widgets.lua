local awful   = require("awful")
local wibox   = require("wibox")
local gears   = require("gears")
local naughty = require("naughty")

local icons_path = gears.filesystem.get_configuration_dir() .. 'themes/icons'
local icons = {
	cpu       = icons_path .. '/cpu.png',
	mem       = icons_path .. '/mem.png',
	vol       = icons_path .. '/vol.png',
	temp      = icons_path .. '/temp.png',
	net       = icons_path .. '/net.png',
	bat       = icons_path .. '/battery.png',
	bat_empty = icons_path .. '/battery.png',
	bat_low   = icons_path .. '/battery.png',
	hdd       = icons_path .. '/hdd.png',
	any       = icons_path .. '/hdd.png',
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
		text:set_markup(msg)
	end
	function widget:refresh()
		if widget.updatefn then
			widget.updatefn()
		end
	end
	function widget:handler(signal, handlerfn)
	end
	function widget:init(initfn)
		initfn()
	end
	function widget:timer(updatefn, timeout)
		if (updatefn) then
			widget.updatefn = updatefn
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
					bat_stat:update(string.format('%s, %02i', string.sub(bs,1,2), bl))
				end)
		end)
	end, 5)

local vol_ctrl = compose_widget(icons.vol)
function notify_sndvol_event(msg)
	naughty.notify({
		replaces_id = 1,
		font        = 'DejaVu Sans 17',
		icon        = '/usr/share/icons/Adwaita/96x96/devices/audio-speakers-symbolic.symbolic.png',
		icon_size   = 40,
		text        = msg,
		timeout     = 2,
	})
end
vol_muted=false
function vol_update_realtime()
	awful.spawn.easy_async(
		{"sh", "-c", "~/scripts/xdg/sys.mond.lua fn vol_usage"},
		function(out)
			local val = tonumber(out)
			local msg = '00'
			if vol_muted then
				msg = 'MM'
			else
				msg = string.format("%02i", val)
			end
			vol_ctrl:update(msg)
			notify_sndvol_event(msg)
		end)
	end
vol_ctrl:init(vol_update_realtime)
vol_ctrl:buttons(awful.util.table.join(
		awful.button({}, 3, function() -- right click
			awful.spawn.easy_async("pactl set-sink-mute @DEFAULT_SINK@ toggle", function()
				if vol_muted then
					vol_muted = false
				else
					vol_muted = true
				end
				vol_update_realtime()
			end)
		end),
		awful.button({}, 4, function () -- up
			awful.spawn.easy_async("pactl set-sink-volume @DEFAULT_SINK@ +5%", function()
				vol_update_realtime()
			end)
		end),
		awful.button({}, 5, function () -- down
			awful.spawn.easy_async("pactl set-sink-volume @DEFAULT_SINK@ -5%", function()
				vol_update_realtime()
			end)
		end)
	))

-- TODO: mouse click opens calendar
local clock = compose_widget(icons.clock)
clock:timer(function()
	local date = os.date('%Y-%m-%dT%H:%M:%S')
	clock:update(date)
end, 1)

-- fs info
local fs_stat = compose_widget(icons.hdd)
fs_stat:timer(function()
	awful.spawn.easy_async(
		{"sh", "-c", "df -h --output='pcent' . | grep -v 'Use' | tr -d ' %'"},
		function(out)
			local val = tonumber(out)
			fs_stat:update(string.format("%02i", val))
		end)
end, 1)

-- kb info
local kb_info = awful.widget.keyboardlayout()

-- app launcher
local beautiful = _G.CTX.beautiful
local mainmenu = _G.CTX.mymainmenu
local applauncher = awful.widget.launcher({
		image = beautiful.awesome_icon,
		menu = mainmenu,
	})
local dpi = require("beautiful.xresources").apply_dpi
local boxed_applauncher = wibox.container.margin(applauncher, dpi(4), dpi(4), dpi(24), dpi(0))

return {
	cpu = cpu,
	mem = mem,
	cpu_temp = cpu_temp,
	gpu_tem = gpu_temp,
	net = net,
	vol_ctrl = vol_ctrl,
	clock = clock,
	fs_stat = fs_stat,
	bat_stat = bat_stat,
	kb_info = kb_info,
	app_launcher = boxed_applauncher
}
