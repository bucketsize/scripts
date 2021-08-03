local Sh = require('shell')
local Pr = require('process')
local Util = require('util')
local Cmds = require('control_cmds')

local Funs = {}
function Funs:tmenu_select_window()
	local ws = {}
	local wl = ''
	Pr.pipe()
	.add(Sh.exec('wmctrl -l'))
	.add(Sh.grep('(%w+)%s+(%d+)%s+([%w%p]+)%s+(.*)'))
	.add(function(arr)
		ws[arr[4]]= {id = arr[1], ws = arr[2], name = arr[4]}
		return arr[4]
	end)
	.add(function(name)
		wl = wl .. name .. '\n'
	end)
	.run()

	Pr.pipe()
	.add(Sh.exec(string.format('echo "%s" | fzy', wl)))
	.add(function(name)
		Util:exec('wmctrl -ia ' .. ws[name].id)
	end)
	.run()
end
function Funs:dmenu_select_window()
	Util:exec(Cmds['popeye'] .. " tmenu_select_window")
end
function Funs:tmenu_run()
	Pr.pipe()
	.add(Sh.exec('ls ~/.local/bin ~/.local/share/flatpak/exports/share/applications /usr/share/applications  | fzy'))
	.add(function(app)
		local bin = string.match(app, "(.+).desktop")
		if not (bin == nil) then
			Util:execl("gtk-launch "..bin)
		else
			Util:execl(app)
		end
	end)
	.run()
end
function Funs:dmenu_run()
	Util:exec(Cmds['popeye'] .. " tmenu_run")
end
function Funs:scr_lock_if()
	local iv = Pr.pipe()
		.add(Sh.exec('pacmd list-sink-inputs'))
		.add(Sh.grep('state: RUNNING.*'))
		.add(Sh.echo())
		.run()
	print("audio live:", iv)
  if iv == nil then
		return Cmds['scr_lock']
	end
end
function Funs:tmenu_exit()
	local exit_with = {
		lock = Cmds["scr_lock"],
		logout = "i3-msg exit",
		suspend = "systemctl suspend",
		hibernate = "systemctl hibernate",
		reboot = "systemctl reboot",
		shutdown = "systemctl poweroff -i"
	}

	local opts = ""
	for k,v in pairs(exit_with) do
		opts = opts .. k .. "\n"
	end

	Pr.pipe()
	.add(Sh.exec(string.format('echo "%s" | fzy', opts)))
	.add(function(name)
		Util:exec(exit_with[name])
	end)
	.run()
end
function Funs:dmenu_exit()
	Util:exec(Cmds['popeye'] .. " tmenu_exit")

end

return Funs
