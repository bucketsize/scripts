local awful = require('awful')
local items = {
	'picom &',

	'xautolock'
		.. ' -time 1 -locker "awesome-client \'_G.LOCKSCREEN:on()\'"'
		.. ' -killtime 10 -killer "xterm"'
		.. ' -notify 30 -notifier "notify-send -u critical -t 10000 -- \'Lock activated ETA 30s\'" &'
}

local Autostart = {}
function Autostart:setup(ctx)
end
function Autostart:apply()
	for i,cmd in pairs(items) do
		local spt = "pkill -f %s; sleep 1; %s"
		local exe = string.match(cmd, '(%w+)%s+')
		local spx = string.format(spt, exe, cmd)
		print('cmd>: ' .. spx)
		awful.spawn.with_shell(spx, false)
	end
end
return Autostart
