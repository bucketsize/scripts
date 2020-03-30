local awful = require('awful')
local items = {
	'picom',
	'~/scripts/xdg/x.wallpaper.sh',
  '~/scripts/xdg/sys.mond.lua',
	'xautolock'
		.. ' -time 5 -locker "awesome-client \'_G.LOCKSCREEN:on()\'"'
		.. ' -killtime 10 -killer "feh"'
		.. ' -notify 30 -notifier "notify-send -u critical -t 10000 -- \'Lock activated ETA 30s\'"',
	'lxsession',
}

local Autostart = {}
function Autostart:setup(ctx)
end
function Autostart:apply()
	for i,cmd in pairs(items) do
		local exe = string.match(cmd, '(%w+)%s+')
		local spx = string.format("killall %s; %s &", exe, cmd)
		print('cmd> ' .. spx)
		awful.spawn.with_shell(spx)
	end
end
return Autostart
